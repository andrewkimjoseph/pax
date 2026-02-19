#!/usr/bin/env bash
# Build Flutter web for production with PWA support (service worker for offline/install).
# Used by firebase deploy --only hosting predeploy.
set -e
cd "$(dirname "$0")/.."
flutter build web --release --pwa-strategy offline-first
