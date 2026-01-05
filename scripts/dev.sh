#!/usr/bin/env bash
# =============================================================================
# AhaTTS - Backend API Startup Script
# =============================================================================
# Usage:
#   ./scripts/dev.sh                  # Start backend API
#   ./scripts/dev.sh --device gpu     # Start with GPU
#   ./scripts/dev.sh --host 0.0.0.0   # Bind host
#   ./scripts/dev.sh --port 25288     # Bind port
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

# =============================================================================
# Configuration
# =============================================================================
HOST="0.0.0.0"
PORT="25288"

case "$(uname -s)" in
    Darwin)
        DEVICE="mps"
        ;;
    *)
        DEVICE="cpu"
        ;;
esac

# =============================================================================
# Usage
# =============================================================================
usage() {
    cat <<EOF
Usage: ./scripts/dev.sh [OPTIONS]

Options:
  --device cpu|gpu|mac   Device for backend (default: auto-detect)
  --host HOST            Backend host (default: 0.0.0.0)
  --port PORT            Backend port (default: 25288)
  -h, --help             Show this help message

Examples:
  ./scripts/dev.sh                     # Start backend with auto-detect device
  ./scripts/dev.sh --device gpu        # Start backend with GPU
  ./scripts/dev.sh --host 127.0.0.1    # Bind to localhost only
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
        --host)
            HOST="${2:-}"
            shift 2
            ;;
        --port)
            PORT="${2:-}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

# =============================================================================
# Main
# =============================================================================
print_header "AhaTTS Backend API"

check_uv
check_backend_deps
setup_backend_env "$DEVICE"

print_info "Device: $DEVICE"
print_info "API: http://localhost:$PORT"
print_info "Docs: http://localhost:$PORT/docs"
print_info "Web: http://localhost:$PORT/web/"
echo ""

uv run --no-sync uvicorn api.src.main:app --host "$HOST" --port "$PORT" --reload
