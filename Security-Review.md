# Puckless-Remote: Security Review / Sicherheitsprüfung

As of / Stand: November 5, 2026 / 5. November 2026 · App version 1.2 · Commit `f422de1`

[Deutsch](#deutsch) · [English](#english)

---

## Deutsch

### Art und Grenzen der Prüfung

Dies ist eine **interne, KI-gestützte Prüfung** (Claude, Anthropic) durch dasselbe Werkzeug, das die App geschrieben hat. Sie ist **keine unabhängige Prüfung und kein Penetrationstest** und bestätigt nicht, dass die App frei von Schwachstellen ist.

**Geprüft:**

- Quellcode und Skripte des Projekts
- Das installierte App-Paket: Signatur, Berechtigungen, verknüpfte Bibliotheken, Zeichenketten
- Git-Historie auf Zugangsdaten und persönliche Daten
- Offene Netzwerkverbindungen der laufenden App zu einem einzelnen Zeitpunkt
- Apples Sicherheitshinweise zu macOS Tahoe 26.3 bis 26.7.2

**Nicht geprüft:**

- Angriffe über Funk, etwa mit einem gefälschten Lautsprecher oder durch Mitschneiden
- Fehlerhafte Eingaben per Fuzzing oder sonstige Laufzeittests
- Eine Prüfung auf Fehler in Apple-Frameworks
- Das Verhalten auf anderen Macs oder macOS-Versionen

### Befunde

| Nr. | Schwere | Befund | Maßnahme | Status |
|---|---|---|---|---|
| S-1 | **Hoch** (Umgebung, nicht die App) | Der Test-Mac läuft mit macOS 26.2. Spätere Versionen beheben Bluetooth-Lücken, siehe unten. Verfügbar ist 26.7.2. | macOS aktualisieren | Offen |
| S-2 | Mittel | Die App verbindet sich automatisch mit jedem Gerät, das den passenden BLE-Dienst anbietet. Das erleichtert das Fälschen und vergrößert möglicherweise die Angriffsfläche. | Bindung an den ersten gefundenen Lautsprecher | Offen |
| S-3 | Mittel bei Weitergabe | Nur lokale Signatur. Gatekeeper lehnt die App ab. Hardened Runtime und App Sandbox fehlen. | Hardened Runtime aktivieren, Sandbox prüfen, mit Developer-Konto notarisieren | Offen |
| S-4 | Niedrig | Die Protokolldatei wächst während der Laufzeit unbegrenzt, auch durch Benachrichtigungen eines fremden Geräts. Sie ist für andere Benutzer des Macs lesbar, enthält aber nur Befehle und Verbindungsereignisse. | Größe begrenzen, nur für den Besitzer lesbar machen | Offen |
| S-5 | Niedrig | Jedes `d40501` löst ein erneutes Senden von `8400` aus, auch außerhalb des Handshakes. Ein fremdes Gerät könnte so Schreibvorgänge auslösen. | Antwort nur während des Handshakes | Offen |
| S-6 | Niedrig bis mittel, in der App nicht lösbar | Das Steuerprotokoll des Lautsprechers verlangte in den Tests weder Kopplung noch Anmeldung. Personen in Funkreichweite könnten ihn vermutlich steuern, solange die Verbindung frei ist, laut Protokoll-Doku auch zurücksetzen. | Modus „Dauerhaft“ belegt die Verbindung und mindert das etwas | Hinweis |
| S-7 | Niedrig, nicht getestet | Ohne Kopplung ist die BLE-Verbindung vermutlich unverschlüsselt. Übertragen werden nur Steuerbefehle. | Keine | Hinweis |

### Apple-Sicherheitshinweise zu Bluetooth

Diese Einträge sind in der installierten Version 26.2 **nicht** behoben. Keiner der Bluetooth-Einträge nennt eine aktive Ausnutzung.

| Behoben in | CVE | Auswirkung laut Apple |
|---|---|---|
| [26.3](https://support.apple.com/en-us/126348) | CVE-2026-20650 | Denial-of-Service durch manipulierte Bluetooth-Pakete |
| [26.7](https://support.apple.com/en-us/149042) | CVE-2026-65414 | Absturz oder Ausführung von Code durch einen entfernten Angreifer |
| 26.7 | CVE-2026-84547 | Speicherbeschädigung durch einen Angreifer in der Nähe |
| 26.7 | CVE-2026-84613 | Systemabsturz durch einen Angreifer in Funkreichweite |
| 26.7 | CVE-2026-86891 | Eine App kann auf Bluetooth-Geräteinformationen zugreifen |
| 26.7 | CVE-2026-86919 | Codeausführung durch einen Angreifer mit gekoppeltem Gerät |
| [26.7.2](https://support.apple.com/en-us/149522) | CVE-2026-112566 | Denial-of-Service durch einen Angreifer in der Nähe |

Diese Lücken liegen in macOS und nicht im Code von Puckless-Remote. Ob und wie weit die App sie zusätzlich erreichbar macht, wurde nicht getestet.

### Keine Auffälligkeiten

- **Kein Netzwerkcode:** keine Netzwerk-Schnittstellen im Quellcode, keine fremden Adressen im Programm, zum Prüfzeitpunkt keine offenen Netzwerkverbindungen.
- **Keine Fremdbibliotheken:** nur Apple-Frameworks und die Swift-Laufzeit.
- **Keine Tastaturüberwachung:** Die globalen Kürzel sind einzeln registriert. Die globale Ereignisüberwachung reagiert nur auf Mausklicks, solange die Fernbedienung offen ist.
- **Keine riskanten Aufrufe:** keine Prozessstarts, kein Nachladen von Code, keine Skriptausführung.
- **Begrenzter Befehlssatz:** Der Werksreset ist nicht enthalten, die Warteschlange ist auf fünf Befehle begrenzt, und alte Befehle verfallen.
- **Keine Zugangsdaten:** keine Treffer in Code und Git-Historie, die Commits enthalten nur die Noreply-Adresse.

Die Signaturprüfung des installierten Pakets war gültig. Das belegt nur die Unversehrtheit des Pakets, nicht die Herkunft.

---

## English

### Type and limits of this review

This is an **internal, AI-assisted review** (Claude, Anthropic), carried out by the same tool that wrote the app. It is **not an independent audit or a penetration test**, and it does not confirm that the app is free of vulnerabilities.

**Reviewed:**

- The project's source code and scripts
- The installed app bundle: signature, entitlements, linked libraries, strings
- Git history, for credentials and personal data
- Open network connections of the running app at a single point in time
- Apple's security notes for macOS Tahoe 26.3 to 26.7.2

**Not reviewed:**

- Radio attacks, such as a spoofed speaker or eavesdropping
- Malformed input through fuzzing, or other runtime testing
- Flaws in Apple's frameworks
- Behavior on other Macs or macOS versions

### Findings

| No. | Severity | Finding | Action | Status |
|---|---|---|---|---|
| S-1 | **High** (environment, not the app) | The test Mac runs macOS 26.2. Later versions fix Bluetooth flaws, see below. Version 26.7.2 is available. | Update macOS | Open |
| S-2 | Medium | The app automatically connects to any device offering the matching BLE service. This makes spoofing easier and may increase the attack surface. | Bind to the first speaker found | Open |
| S-3 | Medium when distributed | Local signature only. Gatekeeper rejects the app. Hardened Runtime and App Sandbox are missing. | Enable Hardened Runtime, evaluate the sandbox, notarize with a developer account | Open |
| S-4 | Low | The log file grows without limit while running, including from notifications sent by a foreign device. Other users on the Mac can read it, but it contains only commands and connection events. | Limit its size, make it readable by the owner only | Open |
| S-5 | Low | Every `d40501` triggers `8400` again, even outside the handshake. A foreign device could use this to trigger writes. | Respond only during the handshake | Open |
| S-6 | Low to medium, can't be fixed in the app | The speaker's control protocol required neither pairing nor sign-in during testing. People within radio range could probably control it while the connection is free and, according to the protocol documentation, reset it. | **Always on** mode holds the connection, which helps somewhat | Note |
| S-7 | Low, not tested | Without pairing, the BLE link is probably unencrypted. Only control commands are transmitted. | None | Note |

### Apple security notes on Bluetooth

These entries are **not** fixed in the installed version 26.2. None of the Bluetooth entries mentions active exploitation.

| Fixed in | CVE | Impact according to Apple |
|---|---|---|
| [26.3](https://support.apple.com/en-us/126348) | CVE-2026-20650 | Denial of service using crafted Bluetooth packets |
| [26.7](https://support.apple.com/en-us/149042) | CVE-2026-65414 | App termination or code execution by a remote attacker |
| 26.7 | CVE-2026-84547 | Process memory corruption by an attacker in physical proximity |
| 26.7 | CVE-2026-84613 | System termination by an attacker in radio range |
| 26.7 | CVE-2026-86891 | An app may access Bluetooth device information |
| 26.7 | CVE-2026-86919 | Code execution by an attacker with a paired device |
| [26.7.2](https://support.apple.com/en-us/149522) | CVE-2026-112566 | Denial of service by an attacker in physical proximity |

These flaws are in macOS, not in Puckless-Remote's code. Whether and how far the app makes them more reachable has not been tested.

### No issues found

- **No networking code:** no network APIs in the source, no third-party addresses in the binary, no open network connections at the time of the check.
- **No third-party libraries:** only Apple frameworks and the Swift runtime.
- **No keyboard monitoring:** global shortcuts are registered individually. The global event monitor reacts only to mouse clicks, and only while the remote is open.
- **No risky calls:** no process launches, no dynamic code loading, no script execution.
- **Limited command set:** factory reset is not included, the queue is limited to five commands, and old commands expire.
- **No credentials:** no matches in the code or Git history, and commits contain only the noreply address.

The signature check of the installed bundle was valid. This only shows that the bundle is intact, not where it came from.
