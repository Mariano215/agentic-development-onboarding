#!/usr/bin/env bash
# ===========================================
# Package presentation files for HostPapa upload
# Creates a zip file ready to upload via cPanel File Manager
# ===========================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/vibeops-deploy.zip"

# Clean previous build
rm -f "$OUTPUT"

# Create zip with the right structure for /vibeops/ directory
cd "$SCRIPT_DIR"
zip -r "$OUTPUT" \
    index.html \
    og-image.png \
    audio/*.mp3

echo ""
echo "Deploy package created: $OUTPUT"
echo "Size: $(du -h "$OUTPUT" | cut -f1)"
echo ""
echo "Upload instructions:"
echo "  1. Log in to HostPapa cPanel"
echo "  2. Open File Manager"
echo "  3. Navigate to public_html/"
echo "  4. Create a folder called 'vibeops'"
echo "  5. Open the 'vibeops' folder"
echo "  6. Click 'Upload' and upload vibeops-deploy.zip"
echo "  7. Select the zip file and click 'Extract'"
echo "  8. Delete the zip file after extraction"
echo ""
echo "Your presentation will be live at:"
echo "  https://matteisystems.com/vibeops/"
