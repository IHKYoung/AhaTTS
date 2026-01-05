#!/usr/bin/env bash
# =============================================================================
# AhaTalk - Shared Functions
# =============================================================================
# This file contains common functions used by all scripts.
# Source this file at the beginning of other scripts:
#   source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
# =============================================================================

# Strict mode
set -euo pipefail

# =============================================================================
# Colors
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# =============================================================================
# Paths
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
API_DIR="$PROJECT_ROOT/api"
VENV_PATH="$PROJECT_ROOT/.venv"

# =============================================================================
# Printing Functions
# =============================================================================
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# =============================================================================
# Device Selection (for PyTorch)
# =============================================================================
DEVICE=""

normalize_device() {
    case "$1" in
        [Cc][Pp][Uu])
            echo "cpu"
            ;;
        [Gg][Pp][Uu]|[Cc][Uu][Dd][Aa])
            echo "gpu"
            ;;
        [Mm][Aa][Cc]|[Mm][Pp][Ss])
            echo "mps"
            ;;
        *)
            echo ""
            ;;
    esac
}

prompt_device() {
    if [[ ! -t 0 ]]; then
        print_error "No --device provided and stdin is not a TTY."
        echo "Please pass --device cpu|gpu|mac" >&2
        exit 1
    fi

    echo "Select device for PyTorch:"
    echo "  1) cpu  - CPU only"
    echo "  2) gpu  - NVIDIA CUDA"
    echo "  3) mac  - Apple Silicon (MPS)"
    while true; do
        read -r -p "Enter choice [1-3]: " choice
        case "$choice" in
            1|cpu|CPU)
                DEVICE="cpu"
                break
                ;;
            2|gpu|GPU)
                DEVICE="gpu"
                break
                ;;
            3|mac|MAC|Mac|mps|MPS)
                DEVICE="mps"
                break
                ;;
            *)
                echo "Invalid selection. Please choose 1, 2, or 3."
                ;;
        esac
    done
}

parse_device_arg() {
    local raw_device="$1"
    DEVICE="$(normalize_device "$raw_device")"
    if [[ -z "$DEVICE" ]]; then
        print_error "Unsupported device: $raw_device"
        echo "Supported devices: cpu, gpu, mac (mps)" >&2
        exit 1
    fi
}

# =============================================================================
# Environment Setup
# =============================================================================
ensure_venv() {
    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        return
    fi

    if [[ ! -d "$VENV_PATH" ]]; then
        print_step "Creating Python virtual environment..."
        (cd "$PROJECT_ROOT" && uv venv)
    fi

    if [[ ! -d "$VENV_PATH" ]]; then
        print_error "Failed to create virtual environment at $VENV_PATH"
        exit 1
    fi

    export VIRTUAL_ENV="$VENV_PATH"
    export PATH="$VENV_PATH/bin:$PATH"
}

activate_venv() {
    if [[ ! -d "$VENV_PATH" ]]; then
        print_error ".venv not found. Run './scripts/install.sh' first."
        exit 1
    fi
    source "$VENV_PATH/bin/activate"
}

setup_pythonpath() {
    export PYTHONPATH="$PROJECT_ROOT:$PROJECT_ROOT/api"
}

setup_backend_env() {
    local device="${1:-cpu}"

    case "$device" in
        cpu)
            export USE_GPU=false
            ;;
        gpu)
            export USE_GPU=true
            ;;
        mps)
            export USE_GPU=true
            export DEVICE_TYPE=mps
            export PYTORCH_ENABLE_MPS_FALLBACK=1
            ;;
    esac

    export USE_ONNX=false
    export MODEL_DIR="$PROJECT_ROOT/api/src/models"
    export VOICES_DIR="$PROJECT_ROOT/api/src/voices/v1_0"
    export WEB_PLAYER_PATH="$PROJECT_ROOT/api/web"

    # Linux espeak path
    if [[ -z "${ESPEAK_DATA_PATH:-}" && -d "/usr/lib/x86_64-linux-gnu/espeak-ng-data" ]]; then
        export ESPEAK_DATA_PATH="/usr/lib/x86_64-linux-gnu/espeak-ng-data"
    fi

    setup_pythonpath
}

# =============================================================================
# Dependency Checks
# =============================================================================
check_uv() {
    if ! command -v uv &> /dev/null; then
        print_error "uv is not installed"
        echo -e "Install it with: ${YELLOW}curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
        exit 1
    fi
}

check_backend_deps() {
    if [[ ! -d "$VENV_PATH" ]]; then
        print_error "Backend dependencies not installed"
        echo "Run './scripts/install.sh' first (see scripts/README.md)"
        exit 1
    fi
}
