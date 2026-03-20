@echo off
REM DriveApp Flutter - Setup Script for Windows
REM This script helps you quickly set up the Flutter project

echo.
echo ================================
echo  DriveApp Flutter Setup
echo ================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed!
    echo Please install Flutter from: https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

echo [OK] Flutter is installed
flutter --version
echo.

REM Ask for project name
set /p PROJECT_NAME="Enter project name (default: driveapp): "
if "%PROJECT_NAME%"=="" set PROJECT_NAME=driveapp

echo.
echo Creating Flutter project: %PROJECT_NAME%
echo.

REM Create Flutter project
call flutter create %PROJECT_NAME%

REM Copy files
echo.
echo [INFO] Copying Flutter files...

REM Copy pubspec.yaml
copy pubspec.yaml %PROJECT_NAME%\ /Y

REM Copy main.dart
copy main.dart %PROJECT_NAME%\lib\ /Y

REM Copy directories
xcopy /E /I /Y screens %PROJECT_NAME%\lib\screens
xcopy /E /I /Y models %PROJECT_NAME%\lib\models

echo [OK] Files copied successfully
echo.

REM Navigate to project
cd %PROJECT_NAME%

REM Get dependencies
echo [INFO] Installing dependencies...
call flutter pub get

echo.
echo ================================
echo  Setup Complete!
echo ================================
echo.
echo To run the app:
echo    cd %PROJECT_NAME%
echo    flutter run
echo.
echo Make sure you have:
echo    - An iOS simulator running, OR
echo    - An Android emulator running, OR
echo    - A physical device connected
echo.
echo Documentation:
echo    - README.md
echo    - FLUTTER_CONVERSION_GUIDE.md
echo    - COMPLETE_SOURCE_CODE_SUMMARY.md
echo.
echo Happy coding!
echo.
pause
