#!/bin/sh

set -e

codesign \
    --deep \
    --force \
    --verify \
    --options runtime \
    --timestamp \
    --sign "Developer ID Application: Kyung Jun Lee (5NJ6RQ9QCA)" \
    "${BUILD_DIR}/Release/ScreenPen.app"
