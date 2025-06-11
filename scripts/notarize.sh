#!/bin/sh

set -e

xcrun notarytool submit ScreenPen.pkg --apple-id "" --password "" --team-id "" --wait
