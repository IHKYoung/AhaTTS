#!/usr/bin/env bash
# =============================================================================
# AhaTalk - Linting & Formatting Script
# =============================================================================
# Usage:
#   ./scripts/lint.sh                 # Check backend (no changes)
#   ./scripts/lint.sh fix             # Auto-fix backend issues
#   ./scripts/lint.sh backend fix     # Same as above
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

# =============================================================================
# Configuration
# =============================================================================
ACTION="check"

# =============================================================================
# Usage
# =============================================================================
usage() {
    cat <<EOF
Usage: ./scripts/lint.sh [TARGET] [ACTION]

Targets:
  backend   Lint backend only (default)

Actions:
  check     Check for issues without modifying files (default)
  fix       Auto-fix issues and format code

Options:
  -h, --help   Show this help message

Examples:
  ./scripts/lint.sh                  # Check backend
  ./scripts/lint.sh fix              # Fix backend
  ./scripts/lint.sh backend fix      # Fix backend
EOF
}

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        backend)
            shift
            ;;
        check|fix)
            ACTION="$1"
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
# Lint Functions
# =============================================================================
lint_backend() {
    local action="$1"

    print_step "Linting backend (Python)..."

    check_uv

    # Use uvx to run ruff as standalone tool
    local ruff="uvx ruff"
    print_info "Ruff version: $($ruff --version)"
    echo ""

    if [[ "$action" == "fix" ]]; then
        print_step "Running ruff check with auto-fix..."
        $ruff check --fix "$PROJECT_ROOT"

        echo ""
        print_step "Running ruff format..."
        $ruff format "$PROJECT_ROOT"

        print_success "Backend linting complete (fixed)"
    else
        local has_errors=false

        print_step "Running ruff check..."
        if ! $ruff check "$PROJECT_ROOT"; then
            has_errors=true
        fi

        echo ""
        print_step "Checking format..."
        if ! $ruff format --check "$PROJECT_ROOT"; then
            has_errors=true
        fi

        if [[ "$has_errors" == true ]]; then
            echo ""
            print_warning "Issues found. Run './scripts/lint.sh backend fix' to auto-fix."
        else
            print_success "Backend linting passed"
        fi
    fi
}

# =============================================================================
# Main
# =============================================================================
print_header "AhaTalk Linter"

lint_backend "$ACTION"

echo ""
