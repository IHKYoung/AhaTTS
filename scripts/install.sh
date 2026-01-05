#!/usr/bin/env bash
# =============================================================================
# AhaTTS - Backend Installation Script
# =============================================================================
# Usage:
#   ./scripts/install.sh                    # Install backend (interactive device)
#   ./scripts/install.sh --device mac       # Install for Mac (MPS)
#   ./scripts/install.sh --skip-model       # Skip model download
#   ./scripts/install.sh --force-model      # Force re-download model
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

# =============================================================================
# Configuration
# =============================================================================
SKIP_MODEL=false
FORCE_MODEL=false
MODEL_DIR="$PROJECT_ROOT/api/src/models/v1_0"
MODEL_FILE="kokoro-v1_0.pth"
CONFIG_FILE="config.json"

# =============================================================================
# Usage
# =============================================================================
usage() {
    cat <<EOF
Usage: ./scripts/install.sh [OPTIONS]

Options:
  --device cpu|gpu|mac   Device for PyTorch (cpu, gpu, mac/mps)
  --skip-model           Skip downloading the TTS model
  --force-model          Re-download model even if exists
  -h, --help             Show this help message

Examples:
  ./scripts/install.sh                      # Interactive device selection
  ./scripts/install.sh --device mac         # Install for Mac (MPS)
  ./scripts/install.sh --skip-model         # Skip model download
  ./scripts/install.sh --force-model        # Force re-download model
EOF
}

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --device)
            parse_device_arg "${2:-}"
            shift 2
            ;;
        --skip-model)
            SKIP_MODEL=true
            shift
            ;;
        --force-model)
            FORCE_MODEL=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        backend)
            shift
            ;;
        *)
            print_error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

# =============================================================================
# Installation
# =============================================================================
install_backend() {
    print_step "Installing backend dependencies..."

    if [[ -z "$DEVICE" ]]; then
        prompt_device
    fi

    check_uv
    ensure_venv

    local install_target
    case "$DEVICE" in
        cpu)
            install_target=".[cpu,test]"
            ;;
        gpu)
            install_target=".[gpu,test]"
            ;;
        mps)
            install_target=".[test]"
            ;;
    esac

    print_info "Installing for device: $DEVICE"
    (cd "$PROJECT_ROOT" && uv pip install -e "$install_target")
    print_success "Backend dependencies installed"

    print_step "Checking UniDic dictionary..."
    if (cd "$PROJECT_ROOT" && uv run --no-sync python - <<'PY'
import os
import sys

try:
    import unidic
except Exception:
    sys.exit(1)

dicdir = getattr(unidic, "DICDIR", None)
# UniDic 3.1 ships these core files; model.def is model.bin in this version
required = ["dicrc", "matrix.bin", "sys.dic", "version"]
if dicdir and os.path.isdir(dicdir) and all(
    os.path.isfile(os.path.join(dicdir, name)) for name in required
):
    sys.exit(0)
sys.exit(1)
PY
    ); then
        print_success "UniDic dictionary already present; skipping download"
    else
        print_step "Downloading UniDic dictionary..."
        if (cd "$PROJECT_ROOT" && uv run --no-sync python -m unidic download); then
            print_success "UniDic dictionary downloaded"
        else
            print_warning "Failed to download UniDic dictionary. You may need to run: python -m unidic download"
        fi
    fi

    if [[ "$SKIP_MODEL" != true ]]; then
        print_step "Downloading TTS model..."
        local download_args=(--output "$MODEL_DIR")
        if [[ "$FORCE_MODEL" == true ]]; then
            download_args+=(--force)
        fi
        (cd "$PROJECT_ROOT" && uv run --no-sync python scripts/download_model.py "${download_args[@]}")
        print_success "Model downloaded"
    else
        print_info "Skipping model download"
        check_model_files
    fi
}

check_model_files() {
    local model_path="$MODEL_DIR/$MODEL_FILE"
    local config_path="$MODEL_DIR/$CONFIG_FILE"

    if [[ -f "$model_path" && -f "$config_path" ]]; then
        print_success "Model files found in $MODEL_DIR"
        return
    fi

    print_warning "Model files not found in $MODEL_DIR"
    echo -e "Download the model with:"
    echo -e "  uv run --no-sync python scripts/download_model.py --output $MODEL_DIR"
    echo -e "Or fetch it directly from:"
    echo -e "  https://huggingface.co/hexgrad/Kokoro-82M/resolve/main/kokoro-v1_0.pth"
    echo -e "Place the files at:"
    echo -e "  $model_path"
    echo -e "  $config_path (same directory)"
}

# =============================================================================
# Main
# =============================================================================
print_header "AhaTTS Backend Install"

install_backend

echo ""
print_header "Installation Complete"
echo -e "Next steps:"
echo -e "  ${CYAN}./scripts/dev.sh${NC}         Start backend API"
echo ""
