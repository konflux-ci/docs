#!/bin/bash

# hack/vale-check.sh - A wrapper script for running Vale with proper initialization

set -euo pipefail

# Ensure we're running from the repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()

    # Check for Vale
    if ! command_exists vale; then
        missing_deps+=("vale")
        echo "Error: Vale is not installed"
        echo "Please install Vale:"
        echo "  macOS: brew install vale"
        echo "  Linux: See https://vale.sh/docs/vale-cli/installation/"
    fi

    # Check for asciidoctor
    if ! command_exists asciidoctor; then
        missing_deps+=("asciidoctor")
        echo "Error: asciidoctor is not installed"
        echo "Please install asciidoctor:"
        echo "  macOS: brew install asciidoctor"
        echo "  Linux: sudo dnf install -y asciidoctor (Fedora/RHEL)"
    fi

    # If any dependencies are missing, exit
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "\nMissing required dependencies: ${missing_deps[*]}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Function to run vale sync
sync_vale() {
    echo "Syncing Vale styles..."
    vale sync
}

# Function to run vale with arguments
run_vale() {
    local vale_args=(--no-exit --output=line)
    local patterns=()
    local files=()

    # Process all arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --*=*|-*) # Handle options like --minAlertLevel=error
                vale_args+=("$1")
                ;;
            *) # Check if argument is a file that exists
                if [ -f "$1" ]; then
                    files+=("$1")
                else
                    # Treat as glob pattern if not an existing file
                    patterns+=("--glob=$1")
                fi
                ;;
        esac
        shift
    done

    # If no patterns or files specified, use default
    if [ ${#patterns[@]} -eq 0 ] && [ ${#files[@]} -eq 0 ]; then
        patterns=(--glob="modules/**/*.adoc")
    fi

    # Build the final command
    local cmd=(vale "${vale_args[@]}")
    
    # Add patterns if any exist
    if [ ${#patterns[@]} -gt 0 ]; then
        cmd+=("${patterns[@]}")
    fi

    # Add files if any exist
    if [ ${#files[@]} -gt 0 ]; then
        cmd+=("${files[@]}")
    fi

    # Run vale with all arguments
    echo "Running Vale with options: ${cmd[*]}"
    # shellcheck disable=SC2068
    "${cmd[@]}"
}

# Main function
main() {
    # Check for required dependencies
    check_dependencies

    # Run vale sync first
    sync_vale

    # Run vale with all arguments passed to the script
    run_vale "$@"
}

# Pass all arguments to main
main "$@"