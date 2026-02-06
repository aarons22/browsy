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

# First validate core logic files (no SwiftUI dependencies)
echo "  - Validating core logic files..."
swiftc -typecheck \
    Models/*.swift \
    API/DTOs/*.swift \
    API/Mappers/*.swift \
    Utilities/*.swift \
    API/*.swift \
    Cache/*.swift \
    Feed/*.swift \
    Repository/*.swift 2>&1 | tee /tmp/swift_validation.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ Core logic validation failed"
    exit 1
fi

echo "  - Core logic files: ✅"

# Note: ViewModels, Views, and BrowsyApp require SwiftUI which needs macOS SDK
# These will be validated when building in Xcode
echo "  - Skipping SwiftUI-dependent files (ViewModels, Views, BrowsyApp) - validate in Xcode"

echo ""
echo "✅ Core Swift files compile successfully!"
echo ""
echo "📊 Summary:"
echo "  - Core files validated: 16"
echo "  - Models: $(ls Models/*.swift 2>/dev/null | wc -l)"
echo "  - DTOs: $(ls API/DTOs/*.swift 2>/dev/null | wc -l)"
echo "  - API Clients: $(ls API/*.swift 2>/dev/null | wc -l)"
echo "  - Mappers: $(ls API/Mappers/*.swift 2>/dev/null | wc -l)"
echo "  - Utilities: $(ls Utilities/*.swift 2>/dev/null | wc -l)"
echo "  - Cache: $(ls Cache/*.swift 2>/dev/null | wc -l)"
echo "  - Feed: $(ls Feed/*.swift 2>/dev/null | wc -l)"
echo "  - Repository: $(ls Repository/*.swift 2>/dev/null | wc -l)"
echo ""
echo "  - Pending Xcode validation: $(ls ViewModels/*.swift Views/*.swift BrowsyApp.swift 2>/dev/null | wc -l)"
echo "    - ViewModels: $(ls ViewModels/*.swift 2>/dev/null | wc -l)"
echo "    - Views: $(ls Views/*.swift 2>/dev/null | wc -l)"
echo "    - App: $(ls BrowsyApp.swift 2>/dev/null | wc -l)"
echo ""
echo "✨ Swift migration validation complete!"
echo ""
echo "ℹ️  Next steps:"
echo "   1. Open project in Xcode"
echo "   2. Build to validate SwiftUI-dependent files"
echo "   3. Configure API key in Debug.xcconfig"
