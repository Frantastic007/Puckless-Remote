# Puckless-Remote: Disclaimer

As of: November 5, 2026 · Version 1.3.0

## Security review

**Puckless-Remote has only had an internal, AI-assisted review, not an independent one, and none is planned.** It covered the code, app bundle, Git history and Apple's security notes, and it produced open findings, see the [review report](Security-Review.md). There was no penetration test, no attack testing of the Bluetooth connection and no third-party review. The result therefore does not confirm that the app is secure.

The app and the review were produced with the same AI tool (Claude, Anthropic). The assessment below is non-binding and has not been independently verified.

**Properties by design:**

- The app uses no third-party libraries, only Apple frameworks.
- It contains no networking code. The heart button in the settings opens the Ko-fi page in your browser, but only when you click it.
- It runs with the macOS App Sandbox and Hardened Runtime, and the only special permission it requests is Bluetooth.
- It stores no passwords or personal data. The log contains only commands and connection events.

**Known weaknesses:**

- The app binds to the first device that completes the connection steps, without checking that it really is a compatible speaker. A nearby device could pose as one at that moment. Protection against other devices after that has not been tested with a real foreign device.
- The speaker's control protocol appears to require neither sign-in nor pairing. People within radio range could probably control the speaker while the connection is free.
- The app is only signed locally and not notarized by Apple. A modified copy would go unnoticed when passed on.

This list is not exhaustive. Other, unknown weaknesses may exist. Keep macOS up to date, as newer versions fix Bluetooth flaws in the system.

## Functionality

The basic functions were tested with a single speaker and one Mac. Several functions are untested and may behave differently from what is described: longer Mac sleep in **Always on** mode, audio over the USB input, installation on a second Mac, the bass, track and play keyboard shortcuts, and start at login in version 1.3.0.

## No warranty

The app is provided "as is", without warranty of any kind. You use it at your own risk. No assurance is given as to its functionality, security or fitness for a particular purpose, including for damage to devices or data, to the extent permitted by law.

## Not a Logitech product

Puckless-Remote is compatible with the Logitech Z407, but is not a Logitech product and is not affiliated with Logitech. Logitech has neither reviewed nor approved the app. It relies on an unofficial protocol reverse-engineered by the community. A Z407 firmware update may affect it. Logitech and Z407 are trademarks of their respective owners.
