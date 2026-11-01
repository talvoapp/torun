#!/usr/bin/env bash
set -euo pipefail

FLUTTER_INSTALL_DIR="/usr/local/flutter"

echo "=== Installing dependencies ==="
sudo apt-get update -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

echo "=== Cloning Flutter SDK (stable) ==="
if [ ! -d "$FLUTTER_INSTALL_DIR" ]; then
  sudo git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_INSTALL_DIR
fi

echo "=== Adding Flutter to PATH ==="
export PATH="$PATH:$FLUTTER_INSTALL_DIR/bin"

echo "=== Checking Flutter ==="
flutter --version
