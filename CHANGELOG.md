# Changelog

## 1.3.0

### Added

- The open remote's ring now shows the connection status, in the same color as the menu bar icon.
- The app icon has a new color gradient.
- **Forget speaker** in the settings. The app now binds to the first speaker it connects to.
- A heart button in the settings opens the Ko-fi page in your browser.

### Changed

- The app runs with the macOS App Sandbox and Hardened Runtime.
- The log file moved to `~/Library/Containers/local.puckless.app/Data/Library/Logs/Puckless.log`. Only your user account can read it, and it's limited to about 1 MB.
- The app answers the speaker's connection step only during the handshake.

### Fixed

- Several presses of Play/Pause while connecting no longer make playback stutter.
- On demand's idle timer no longer keeps running after switching to Always on or disconnecting.

## 1.2

First version shared on GitHub.
