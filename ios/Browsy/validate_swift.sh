#!/bin/bash
set -e

# Swift Compilation Validation Script
# Validates that all migrated Swift files compile successfully

echo "🔍 Validating Swift code compilation..."

cd "$(dirname "$0")/Browsy"

# Check if swiftc is available
if ! command -v swiftc &> /dev/null; then
    echo "❌ Error: swiftc not found. Please install Swift."
    exit 1
fi

echo "✅ Swift compiler found: $(swift --version | head -n 1)"

# Type-check all Swift files in dependency order
echo "🔨 Type-checking Swift files..."
swiftc -typecheck \
    Models/*.swift \
    API/DTOs/*.swift \
    API/Mappers/*.swift \
    Utilities/*.swift \
    API/*.swift \
    Cache/*.swift \
    Feed/*.swift \
    Repository/*.swift

echo "✅ All Swift files compile successfully!"
echo ""
echo "📊 Summary:"
echo "  - $(find . -name "*.swift" | wc -l) Swift files validated"
echo "  - Models: $(ls Models/*.swift 2>/dev/null | wc -l)"
echo "  - DTOs: $(ls API/DTOs/*.swift 2>/dev/null | wc -l)"
echo "  - API Clients: $(ls API/*.swift 2>/dev/null | wc -l)"
echo "  - Mappers: $(ls API/Mappers/*.swift 2>/dev/null | wc -l)"
echo "  - Utilities: $(ls Utilities/*.swift 2>/dev/null | wc -l)"
echo "  - Cache: $(ls Cache/*.swift 2>/dev/null | wc -l)"
echo "  - Feed: $(ls Feed/*.swift 2>/dev/null | wc -l)"
echo "  - Repository: $(ls Repository/*.swift 2>/dev/null | wc -l)"
echo ""
echo "✨ Swift migration validation complete!"
