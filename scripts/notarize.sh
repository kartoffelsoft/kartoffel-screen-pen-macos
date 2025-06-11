#!/bin/sh

set -e

xcrun notarytool submit "${BUILD_DIR}/ScreenPen.pkg" --apple-id "" --password "" --team-id "" --wait
