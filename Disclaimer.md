# Puckless: Disclaimer

Stand / As of: 5. November 2026 / November 5, 2026 · Version 1.2

[Deutsch](#deutsch) · [English](#english)

---

## Deutsch

### Sicherheitsprüfung

**Für Puckless wurde keine Sicherheitsprüfung durchgeführt.** Es gab keine Suche nach bekannten Sicherheitslücken, keine systematische Code-Analyse, keinen Penetrationstest, keinen Test der Bluetooth-Verbindung auf Angriffe und keine Prüfung durch unabhängige Dritte. Es besteht daher kein Prüfergebnis, das die Sicherheit der App bestätigt.

Die App wurde mit Unterstützung einer KI (Claude, Anthropic) erstellt. Die folgende Einschätzung stammt aus dem Entstehungsprozess, ist unverbindlich und wurde nicht unabhängig überprüft.

**Eigenschaften laut Entwurf:**

- Die App nutzt keine Fremdbibliotheken, nur Apple-Frameworks.
- Sie enthält keinen Netzwerkcode.
- Sie speichert keine Passwörter oder persönlichen Daten. Das Protokoll enthält nur Befehle und Verbindungsereignisse.

**Bekannte Schwachstellen:**

- Die App prüft nicht, ob das gefundene Gerät wirklich ein kompatibler Lautsprecher ist. Ein Gerät in der Nähe könnte sich als solcher ausgeben.
- Das Steuerprotokoll des Lautsprechers scheint weder Anmeldung noch Kopplung zu verlangen. Personen in Funkreichweite könnten den Lautsprecher vermutlich steuern, solange die Verbindung frei ist.
- Die App ist nur lokal signiert und nicht von Apple beglaubigt (notarisiert). Eine veränderte Kopie würde beim Weitergeben nicht auffallen.
- Die Hardened Runtime von macOS ist nicht aktiviert.

Diese Liste ist nicht abschließend. Es können weitere, unbekannte Schwachstellen bestehen.

### Funktion

Die Grundfunktionen wurden an einem einzelnen Lautsprecher und einem Mac getestet. Mehrere Funktionen sind ungetestet, siehe Abschnitt „Noch nicht getestet“ der Bedienungsanleitung.

### Keine Gewähr

Die App wird ohne Gewähr und im aktuellen Zustand bereitgestellt. Die Nutzung erfolgt auf eigenes Risiko. Für Funktion, Sicherheit und Eignung für einen bestimmten Zweck wird keine Zusicherung gegeben, auch nicht für Schäden an Geräten oder Daten, soweit gesetzlich zulässig.

### Kein Logitech-Produkt

Puckless ist kompatibel mit dem Logitech Z407, ist aber kein Produkt von Logitech und steht in keiner Verbindung zu Logitech. Logitech hat die App weder geprüft noch freigegeben. Sie beruht auf einem inoffiziellen, von der Community entschlüsselten Protokoll. Ein Firmware-Update des Z407 kann die Funktion beeinträchtigen. Logitech und Z407 sind Marken ihrer jeweiligen Inhaber.

---

## English

### Security review

**No security review has been carried out for Puckless.** There was no scan for known vulnerabilities, no systematic code analysis, no penetration test, no attack testing of the Bluetooth connection and no independent third-party review. There is therefore no review result confirming that the app is secure.

The app was created with the help of an AI (Claude, Anthropic). The assessment below comes from the development process, is non-binding and has not been independently verified.

**Properties by design:**

- The app uses no third-party libraries, only Apple frameworks.
- It contains no networking code.
- It stores no passwords or personal data. The log contains only commands and connection events.

**Known weaknesses:**

- The app does not check whether the device it finds really is a compatible speaker. A nearby device could pose as one.
- The speaker's control protocol appears to require neither sign-in nor pairing. People within radio range could probably control the speaker while the connection is free.
- The app is only signed locally and not notarized by Apple. A modified copy would go unnoticed when passed on.
- The macOS Hardened Runtime is not enabled.

This list is not exhaustive. Other, unknown weaknesses may exist.

### Functionality

The basic functions were tested with a single speaker and one Mac. Several functions are untested, see the "Not yet tested" section of the user manual.

### No warranty

The app is provided "as is", without warranty of any kind. You use it at your own risk. No assurance is given as to its functionality, security or fitness for a particular purpose, including for damage to devices or data, to the extent permitted by law.

### Not a Logitech product

Puckless is compatible with the Logitech Z407, but is not a Logitech product and is not affiliated with Logitech. Logitech has neither reviewed nor approved the app. It relies on an unofficial protocol reverse-engineered by the community. A Z407 firmware update may affect it. Logitech and Z407 are trademarks of their respective owners.
