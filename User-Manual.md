# Puckless: User Manual

Puckless is a remote control for your Mac, compatible with the Logitech Z407. It is not a Logitech product, see the [disclaimer](Disclaimer.md). The app runs in your Mac's menu bar and controls volume, bass, playback and input.

**Requirements:** Mac with Apple silicon (M1 or later), macOS 13 or later, Bluetooth turned on.

The app is available in English and German. This manual uses the English labels. If the app appears in German, switch the language in the settings (gear icon, then **English**).

## Getting started

1. Start **Puckless** from the `~/Applications` folder.
2. Allow Bluetooth access when asked on first launch.
3. A round dial appears in the menu bar. When its ring is green, the app is connected.
4. Click the icon to open the remote.

The app needs no Bluetooth pairing of its own. It finds the speaker by itself, as long as the speaker is on and its control connection is free.

## Menu bar icon

| Ring color | Meaning |
|---|---|
| Green | Connected |
| Orange | Searching or connecting |
| Red | Disconnected, Bluetooth off or no permission |

## The remote

### Volume and bass

At the top, select **Volume** or **Bass**. You then have three options:

- **Turn the ring:** Drag the colored ring in a circle with the mouse. Every 15° is one step. Clockwise raises the value.
- **Scroll:** Scroll with the pointer over the remote. Scrolling up raises the value.
- **+ and − buttons:** One click is one step. Hold a button to repeat.

Bass mode returns to volume after 15 seconds without input.

The speaker does not report its current volume or bass level. The app therefore shows no values, and the position of the ring says nothing about the level.

### Playback

| Button | Function |
|---|---|
| Play/Pause (center) | Start or pause playback |
| Double arrow left | Previous track |
| Double arrow right | Next track |

These buttons act on the device currently sending audio to the speaker over Bluetooth.

### Input

Select **BT** (Bluetooth), **AUX** or **USB**. The active input is highlighted.

The app only knows the active input after the first switch since connecting. Until then, no button is highlighted.

If you switch away from Bluetooth, you won't hear the Mac until you select **BT** again.

### Bottom row of buttons

| Icon | Function |
|---|---|
| Gear | Open settings |
| Radio waves | Disconnect or connect |
| Power | Quit the app |

### Closing the remote

Click outside it, press **Esc**, or click the menu bar icon again. The app keeps running.

## Keyboard shortcuts

The shortcuts work everywhere, even with the remote closed. Each press is one step.

| Shortcut | Function |
|---|---|
| ⌃⌥↑ / ⌃⌥↓ | Volume up / down |
| ⌃⌥⇧↑ / ⌃⌥⇧↓ | Bass up / down |
| ⌃⌥Space | Play or pause |
| ⌃⌥← / ⌃⌥→ | Previous / next track |

⌃ is Control, ⌥ is Option, ⇧ is Shift.

## Settings

- **Deutsch / English:** switches the app's language. The change applies immediately. On first launch, the language follows your system: German on German systems, otherwise English.
- **Always on / On demand:** sets how the app holds the connection, see below.
- **Keyboard shortcuts:** turns the shortcuts on or off.
- **Start at login:** starts the app automatically when you log in to your Mac.
- **Pairing mode:** puts the speaker into Bluetooth pairing mode so you can connect a new audio device. The app asks for confirmation first.

The app deliberately cannot trigger a factory reset.

The macOS Bluetooth prompt always follows the system language, not this setting.

### Always on or on demand?

The speaker accepts only **one control connection at a time**. This covers the app, other Macs and the supplied dial.

| Mode | Advantage | Disadvantage |
|---|---|---|
| **Always on** (default) | Responds immediately | Other devices can't reach the speaker |
| **On demand** | Connection is released after 30 seconds without input | The first command takes a few seconds |

If you use several Macs or also the supplied dial, **On demand** is the better choice.

### Using the supplied dial

In the app, click the disconnect button (radio waves). This frees the control connection. The next command from the app reconnects automatically.

## Troubleshooting

| Problem | Solution |
|---|---|
| Ring stays orange or "Speaker not found" | Check that the speaker is on. Disconnect the supplied dial or other Macs, as they may be holding the connection. If needed, turn the speaker off and on again. |
| "Command dropped" | The speaker was unreachable for more than 8 seconds. The command is deliberately not sent later, so the volume can't change unexpectedly. Try again. |
| "No permission" | Allow Puckless under **System Settings → Privacy & Security → Bluetooth**. |
| No sound from the Mac | Select the **BT** input and check that the speaker is selected as the output in the Mac's sound settings. |
| Keyboard shortcut doesn't respond | Check that shortcuts are turned on in the settings. Another app may be using the same shortcut. |
| App won't start on another Mac | See below. |

The log is at `~/Library/Logs/Puckless.log` and starts fresh each time the app launches. Save a copy before restarting if you want to trace an error.

## Installing on another Mac

1. On this Mac, create a ZIP of the app:

   ```bash
   ditto -c -k --keepParent "$HOME/Applications/Puckless.app" "$HOME/Desktop/Puckless.zip"
   ```

2. Transfer the ZIP, unpack it and drag the app into the **Applications** folder.
3. Open the app. If macOS blocks it, click **Open Anyway** under **System Settings → Privacy & Security**.
4. Allow Bluetooth access.
5. Select **On demand** on both Macs.

For the other Mac to play audio through the speaker as well, you also need to pair it over Bluetooth in the usual way.

## Updating or removing the app

**Rebuilding:** You need the Command Line Tools (`xcode-select --install`). Then run this in the `puckless` folder:

```bash
zsh scripts/build.sh
```

The script builds the app, installs it to `~/Applications` and starts it. macOS may ask for Bluetooth permission again afterwards.

**Removing:**

1. Turn off **Start at login** if it's on.
2. Quit the app with the power button.
3. Delete **Puckless** from `~/Applications`.

## Not yet tested

These points haven't been checked so far and may behave differently from what is described:

- Switching the language while the app is running
- **On demand** mode and start at login
- Mac sleep and wake
- Working alongside the supplied dial
- USB input, next and previous track
- Installation on a second Mac

Control relies on a protocol reverse-engineered by the community. The speaker manufacturer does not officially support it, and a firmware update could affect it.
