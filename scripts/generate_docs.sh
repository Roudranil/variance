#!/bin/bash

# Exit on error
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Assume the script is in scripts/, so root is one level up
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "Checking dependencies..."
if ! command -v dart &> /dev/null; then
    echo "Dart SDK not found. Please install Dart."
    exit 1
fi

# Ensure dart_doc_markdown_generator is activated
if ! dart pub global list | grep -q "dart_doc_markdown_generator"; then
    echo "Installing dart_doc_markdown_generator..."
    dart pub global activate dart_doc_markdown_generator
else
    echo "dart_doc_markdown_generator is already installed."
fi

# Handle existing api_reference folder
if [ -d "doc/api_reference" ]; then
    echo "Backing up existing api_reference..."
    if [ -d "doc/api_reference.bak" ]; then
        rm -rf "doc/api_reference.bak"
    fi
    mv "doc/api_reference" "doc/api_reference.bak"
    echo "Existing api_reference moved to doc/api_reference.bak"
fi

# Clean temp directory
if [ -d "doc/temp" ]; then
    rm -rf doc/temp
fi
mkdir -p doc/temp

echo "Generating raw markdown..."
# Run the generator
dart pub global run dart_doc_markdown_generator . doc/temp

echo "Running merger..."
dart run tool/doc_merger.dart

echo "Cleaning up..."
rm -rf doc/temp

echo "Documentation generation complete! Output in doc/api_reference"
