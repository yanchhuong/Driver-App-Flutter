#!/bin/bash

# DriveApp Flutter - Setup Script
# This script helps you quickly set up the Flutter project

echo "🚗 DriveApp Flutter Setup"
echo "=========================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed"
flutter --version
echo ""

# Ask for project name
read -p "Enter project name (default: driveapp): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-driveapp}

echo ""
echo "Creating Flutter project: $PROJECT_NAME"
echo ""

# Create Flutter project
flutter create $PROJECT_NAME

# Copy files
echo ""
echo "📁 Copying Flutter files..."

# Copy pubspec.yaml
cp pubspec.yaml $PROJECT_NAME/

# Copy main.dart
cp main.dart $PROJECT_NAME/lib/

# Copy directories
cp -r screens $PROJECT_NAME/lib/
cp -r models $PROJECT_NAME/lib/

echo "✅ Files copied successfully"
echo ""

# Navigate to project
cd $PROJECT_NAME

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 To run the app:"
echo "   cd $PROJECT_NAME"
echo "   flutter run"
echo ""
echo "📱 Make sure you have:"
echo "   - An iOS simulator running, OR"
echo "   - An Android emulator running, OR"
echo "   - A physical device connected"
echo ""
echo "📚 Documentation:"
echo "   - README.md"
echo "   - FLUTTER_CONVERSION_GUIDE.md"
echo "   - COMPLETE_SOURCE_CODE_SUMMARY.md"
echo ""
echo "Happy coding! 🎉"
