#!/bin/bash

# Install Flutter (faster clone)
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Enable web
flutter config --enable-web

# Install dependencies
flutter pub get

# Build web (FIXED)
flutter build web --release