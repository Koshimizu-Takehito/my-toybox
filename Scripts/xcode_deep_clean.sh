#!/bin/zsh
set -eux

echo "Closing Xcode / Simulator related processes..."
killall Xcode 2>/dev/null || true
killall Simulator 2>/dev/null || true
killall XCPreviewAgent 2>/dev/null || true
killall com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true

echo "Shutting down simulators..."
xcrun simctl shutdown all || true

echo "Deleting Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "Deleting SwiftUI Preview data..."
rm -rf ~/Library/Developer/Xcode/UserData/Previews

echo "Resetting Preview simulator set..."
xcrun simctl --set previews delete all || true

echo "Deleting Xcode cache..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode

echo "Deleting SwiftPM cache..."
rm -rf ~/Library/Caches/org.swift.swiftpm

echo "Deleting CoreSimulator caches..."
rm -rf ~/Library/Developer/CoreSimulator/Caches

echo "Done."
echo "Recommended next steps:"
echo "1. Reboot macOS"
echo "2. Open Xcode"
echo "3. File > Packages > Reset Package Caches"
echo "4. Rebuild previews"
