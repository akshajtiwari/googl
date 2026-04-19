#!/bin/bash

# Faster clone
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter pub get

# 🔥 reduce bundle size
flutter build web --release --web-renderer canvaskit