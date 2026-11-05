# Puckless-Remote

A round menu bar remote for your Mac that controls a compatible Bluetooth speaker system without its supplied dial.

Compatible with the Logitech Z407. Puckless-Remote is not a Logitech product and is not affiliated with Logitech, see the [disclaimer](Disclaimer.md).

[![Support on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Frantastic007)

## Why I built this

It annoyed me that the battery in the supplied dial kept running out. That was especially disruptive when switching between my smart speaker and my laptop or smartphone. So I built a remote that runs on my Mac and needs no battery of its own.

## Features

- Volume and bass, by turning the ring, scrolling or using the + and − buttons
- Play/pause, next and previous track
- Input switching between Bluetooth, AUX and USB
- Global keyboard shortcuts
- Status color in the menu bar icon
- English and German interface

The speaker doesn't report its levels, so Puckless-Remote changes them in relative steps and shows no values.

## Requirements

- Mac with Apple silicon (M1 or later)
- macOS 13 or later
- Command Line Tools: `xcode-select --install`

## Build and run

```bash
zsh scripts/build.sh
```

The script builds the app, installs it to `~/Applications` as **Puckless** and starts it. Allow Bluetooth access when macOS asks. macOS may ask again after each rebuild.

## Documentation

- [User manual](User-Manual.md)
- [Disclaimer](Disclaimer.md)

## Project status

Puckless-Remote was created with the help of an AI (Claude, Anthropic). Basic functions have been tested with a single speaker and one Mac. Some functions are untested, see the [disclaimer](Disclaimer.md).

**There has been no independent security review.** An internal, AI-assisted review found open issues, see the [review report](Security-Review.md). The app is only signed locally and not notarized by Apple.

## Credits

The control protocol is based on the documentation in [logi-z407-reverse-engineering](https://github.com/freundTech/logi-z407-reverse-engineering) by freundTech. Puckless-Remote uses no code from that project.

## License

[MIT](LICENSE)

The license covers the code of this project only. It grants no rights to third-party names or trademarks.
