#!/bin/sh

set -e

pkgbuild \
    --install-location "/Applications" \
    --component "${BUILD_DIR}/Release/ScreenPen.app" \
    --sign "Developer ID Installer: Kyung Jun Lee (5NJ6RQ9QCA)" \
    "${BUILD_DIR}/ScreenPen.pkg"
