#!/usr/bin/env bash
set -euo pipefail

FLUTTER_SDK_DIR="_flutter_sdk"
FLUTTER_VERSION="3.44.0"

if [ ! -d "$FLUTTER_SDK_DIR/.git" ]; then
  rm -rf "$FLUTTER_SDK_DIR"
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 "$FLUTTER_SDK_DIR"
fi

export PATH="$PATH:$(pwd)/$FLUTTER_SDK_DIR/bin"

flutter config --no-analytics
flutter pub get

build_args=(web --release)
if [ -n "${MULGIL_GOOGLE_WEB_CLIENT_ID:-}" ]; then
  build_args+=(--dart-define="MULGIL_GOOGLE_WEB_CLIENT_ID=$MULGIL_GOOGLE_WEB_CLIENT_ID")
fi

flutter build "${build_args[@]}"
