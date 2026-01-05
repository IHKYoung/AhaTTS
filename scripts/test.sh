#!/usr/bin/env bash
# =============================================================================
# AhaTalk - Test Runner Script
# =============================================================================
# Usage:
#   ./scripts/test.sh                 # Run backend tests
#   ./scripts/test.sh backend         # Same as above
#   ./scripts/test.sh -v              # Verbose output
#   ./scripts/test.sh --cov           # With coverage report
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

# =============================================================================
# Configuration
# =============================================================================
VERBOSE=false
COVERAGE=false
SPECIFIC_TEST=""

# =============================================================================
# Usage
# =============================================================================
usage() {
    cat <<EOF
Usage: ./scripts/test.sh [OPTIONS] [test_file]

Options:
  -v, --verbose   Verbose output
  --cov           Show coverage report
  -h, --help      Show this help message

Examples:
  ./scripts/test.sh                      # Run backend tests
  ./scripts/test.sh backend              # Backend tests
  ./scripts/test.sh -v --cov             # Verbose with coverage
  ./scripts/test.sh test_normalizer.py   # Run specific test file
EOF
}

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --cov)
            COVERAGE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        backend)
            shift
            ;;
        *.py)
            SPECIFIC_TEST="$1"
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
# Test Functions
# =============================================================================
test_backend() {
    print_step "Running backend tests..."

    check_backend_deps
    activate_venv
    setup_pythonpath

    # Check pytest
    if ! python -c "import pytest" 2>/dev/null; then
        print_warning "pytest not found, installing test dependencies..."
        uv pip install pytest pytest-asyncio pytest-cov httpx
    fi

    # Check torch
    if ! python -c "import torch" 2>/dev/null; then
        print_error "torch is not installed"
        echo "Run './scripts/install.sh' first (see scripts/README.md)"
        exit 1
    fi

    print_info "Python: $(python --version)"
    print_info "Pytest: $(python -m pytest --version 2>/dev/null | head -1)"
    echo ""

    # Build pytest arguments
    local pytest_args=()

    if [[ "$VERBOSE" == true ]]; then
        pytest_args+=("-v")
    fi

    if [[ "$COVERAGE" == true ]]; then
        pytest_args+=("--cov=api" "--cov-report=term-missing")
    fi

    # Test directory
    local test_dir="$PROJECT_ROOT/api/tests"

    if [[ -n "$SPECIFIC_TEST" ]]; then
        print_info "Running test: $SPECIFIC_TEST"
        python -m pytest "$test_dir/$SPECIFIC_TEST" "${pytest_args[@]}"
    else
        # Run all available test files
        local test_files=(
            "test_text_processor.py"
            "test_normalizer.py"
            "test_audio_service.py"
            "test_openai_endpoints.py"
        )

        local test_paths=()
        for test_file in "${test_files[@]}"; do
            if [[ -f "$test_dir/$test_file" ]]; then
                test_paths+=("$test_dir/$test_file")
            fi
        done

        if [[ ${#test_paths[@]} -eq 0 ]]; then
            print_warning "No test files found"
            return
        fi

        python -m pytest "${test_paths[@]}" "${pytest_args[@]}"
    fi

    print_success "Backend tests completed"
}

# =============================================================================
# Main
# =============================================================================
print_header "AhaTalk Test Runner"

test_backend

echo ""
print_success "All tests completed!"
