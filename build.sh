#!/bin/bash
# Reconstruct api_key.dart from Vercel secrets before building
echo "const String openWeatherApiKey = '${OPENWEATHER_API_KEY}';" > lib/api_key.dart

# Install Flutter SDK on Vercel since it's not pre-installed
echo "Cloning stable Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Web and Build
flutter config --enable-web
flutter pub get
echo "Building Flutter Web release..."
flutter build web --release
