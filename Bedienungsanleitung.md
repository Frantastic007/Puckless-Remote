# Puckless: Bedienungsanleitung

Puckless ist eine Fernbedienung für den Mac, kompatibel mit dem Logitech Z407. Sie ist kein Produkt von Logitech, siehe [Disclaimer](Disclaimer.md). Die App läuft in der Menüleiste deines Macs und steuert Lautstärke, Bass, Wiedergabe und Eingang.

**Voraussetzungen:** Mac mit Apple Silicon (M1 oder neuer), macOS 13 oder neuer, Bluetooth eingeschaltet.

## Erste Schritte

1. Starte **Puckless** aus dem Ordner `~/Applications`.
2. Erlaube beim ersten Start den Bluetooth-Zugriff.
3. Oben in der Menüleiste erscheint ein runder Drehregler. Sobald sein Ring grün ist, ist die App verbunden.
4. Klicke auf das Symbol, um die Fernbedienung zu öffnen.

Die App braucht keine eigene Bluetooth-Kopplung. Sie findet den Lautsprecher von selbst, solange er eingeschaltet ist und die Steuerverbindung frei ist.

## Symbol in der Menüleiste

| Ringfarbe | Bedeutung |
|---|---|
| Grün | Verbunden |
| Orange | Suche oder Verbindungsaufbau |
| Rot | Getrennt, Bluetooth aus oder keine Berechtigung |

## Fernbedienung

### Lautstärke und Bass

Wähle oben **Lautstärke** oder **Bass**. Danach hast du drei Möglichkeiten:

- **Ring drehen:** Ziehe den farbigen Ring mit der Maus im Kreis. Alle 15° gibt es eine Stufe. Im Uhrzeigersinn wird der Wert höher.
- **Scrollen:** Scrolle mit dem Zeiger über der Fernbedienung. Nach oben wird der Wert höher.
- **Tasten + und −:** Ein Klick ist eine Stufe. Hältst du die Taste gedrückt, wiederholt sie sich.

Der Bass-Modus springt nach 15 Sekunden ohne Eingabe zurück auf Lautstärke.

Der Lautsprecher meldet seine aktuelle Lautstärke und seinen Bass nicht zurück. Darum zeigt die App keine Werte an, und die Position des Rings sagt nichts über den Pegel aus.

### Wiedergabe

| Taste | Funktion |
|---|---|
| Play/Pause (Mitte) | Wiedergabe starten oder anhalten |
| Doppelpfeil links | Vorheriger Titel |
| Doppelpfeil rechts | Nächster Titel |

Diese Tasten wirken auf das Gerät, das gerade per Bluetooth Ton an den Lautsprecher sendet.

### Eingang

Wähle **BT** (Bluetooth), **AUX** oder **USB**. Der aktive Eingang wird farbig markiert.

Die App kennt den aktiven Eingang erst nach dem ersten Wechsel seit dem Verbinden. Bis dahin ist keine Taste markiert.

Wechselst du weg von Bluetooth, ist der Ton vom Mac nicht mehr zu hören, bis du wieder **BT** wählst.

### Untere Tastenreihe

| Symbol | Funktion |
|---|---|
| Zahnrad | Einstellungen öffnen |
| Funkwellen | Verbindung trennen oder herstellen |
| Power | App beenden |

### Fernbedienung schließen

Klicke daneben, drücke **Esc** oder klicke erneut auf das Symbol in der Menüleiste. Die App läuft danach weiter.

## Tastenkürzel

Die Kürzel funktionieren überall, auch bei geschlossener Fernbedienung. Jeder Druck ist eine Stufe.

| Kürzel | Funktion |
|---|---|
| ⌃⌥↑ / ⌃⌥↓ | Lautstärke rauf / runter |
| ⌃⌥⇧↑ / ⌃⌥⇧↓ | Bass rauf / runter |
| ⌃⌥Leertaste | Wiedergabe oder Pause |
| ⌃⌥← / ⌃⌥→ | Vorheriger / nächster Titel |

⌃ ist Control, ⌥ ist Option, ⇧ ist Umschalt.

## Einstellungen

- **Deutsch / English:** stellt die Sprache der App um. Die Änderung gilt sofort. Beim ersten Start richtet sich die Sprache nach deinem System: Deutsch auf deutschen Systemen, sonst Englisch.
- **Dauerhaft / Bei Bedarf:** legt fest, wie die App die Verbindung hält, siehe unten.
- **Tastenkürzel:** schaltet die Kürzel ein oder aus.
- **Beim Anmelden starten:** startet die App automatisch nach der Anmeldung am Mac.
- **Kopplungsmodus:** versetzt den Lautsprecher in den Bluetooth-Kopplungsmodus, um ein neues Audiogerät zu verbinden. Die App fragt vorher nach.

Einen Werksreset kann die App bewusst nicht auslösen.

Die Bluetooth-Abfrage von macOS richtet sich immer nach der Systemsprache, nicht nach dieser Einstellung.

### Dauerhaft oder bei Bedarf?

Der Lautsprecher nimmt nur **eine Steuerverbindung gleichzeitig** an. Das betrifft die App, weitere Macs und die mitgelieferte Fernbedienung.

| Modus | Vorteil | Nachteil |
|---|---|---|
| **Dauerhaft** (Standard) | Reagiert sofort | Andere Geräte kommen nicht an den Lautsprecher |
| **Bei Bedarf** | Verbindung wird nach 30 Sekunden ohne Eingabe wieder frei | Der erste Befehl dauert einige Sekunden |

Nutzt du mehrere Macs oder auch die mitgelieferte Fernbedienung, ist **Bei Bedarf** die bessere Wahl.

### Mitgelieferte Fernbedienung nutzen

Klicke in der App auf **Trennen** (Funkwellen). Damit wird die Steuerverbindung frei. Der nächste Befehl aus der App verbindet automatisch wieder.

## Wenn etwas nicht klappt

| Problem | Lösung |
|---|---|
| Ring bleibt orange oder „Lautsprecher nicht gefunden“ | Prüfe, ob der Lautsprecher eingeschaltet ist. Trenne die mitgelieferte Fernbedienung oder andere Macs, da sie die Verbindung belegen könnten. Schalte den Lautsprecher notfalls einmal aus und wieder ein. |
| „Befehl verworfen“ | Der Lautsprecher war länger als 8 Sekunden nicht erreichbar. Der Befehl wird absichtlich nicht nachgeholt, damit sich die Lautstärke nicht verspätet ändert. Versuche es erneut. |
| „Keine Berechtigung“ | Erlaube Puckless unter **Systemeinstellungen → Datenschutz & Sicherheit → Bluetooth**. |
| Kein Ton vom Mac | Wähle den Eingang **BT** und prüfe, ob der Lautsprecher in den Mac-Toneinstellungen als Ausgabe gewählt ist. |
| Tastenkürzel reagiert nicht | Prüfe, ob die Kürzel in den Einstellungen eingeschaltet sind. Eine andere App könnte dasselbe Kürzel belegen. |
| App startet auf einem anderen Mac nicht | Siehe unten. |

Das Protokoll liegt unter `~/Library/Logs/Puckless.log` und wird bei jedem App-Start neu begonnen. Sichere es also vor einem Neustart, wenn du einen Fehler nachvollziehen willst.

## Auf einem anderen Mac installieren

1. Erstelle auf diesem Mac ein ZIP der App:

   ```bash
   ditto -c -k --keepParent "$HOME/Applications/Puckless.app" "$HOME/Desktop/Puckless.zip"
   ```

2. Übertrage das ZIP, entpacke es und ziehe die App in den Ordner **Programme**.
3. Öffne die App. Blockiert macOS sie, klicke unter **Systemeinstellungen → Datenschutz & Sicherheit** auf **Dennoch öffnen**.
4. Erlaube den Bluetooth-Zugriff.
5. Stelle auf beiden Macs **Bei Bedarf** ein.

Damit der andere Mac auch Ton über den Lautsprecher abspielen kann, musst du ihn zusätzlich normal per Bluetooth koppeln.

## App aktualisieren oder entfernen

**Neu bauen:** Dafür brauchst du die Command Line Tools (`xcode-select --install`). Führe dann im Ordner `puckless` aus:

```bash
zsh scripts/build.sh
```

Das Skript baut die App, installiert sie nach `~/Applications` und startet sie. macOS kann danach erneut nach der Bluetooth-Berechtigung fragen.

**Entfernen:**

1. Schalte **Beim Anmelden starten** aus, falls aktiv.
2. Beende die App mit der Power-Taste.
3. Lösche **Puckless** aus `~/Applications`.

## Noch nicht getestet

Diese Punkte wurden bisher nicht geprüft und können sich anders verhalten als beschrieben:

- Umschalten der Sprache im laufenden Betrieb
- Modus **Bei Bedarf** und Autostart
- Ruhezustand und Aufwachen des Macs
- Zusammenspiel mit der mitgelieferten Fernbedienung
- Eingang USB, nächster und vorheriger Titel
- Installation auf einem zweiten Mac

Die Steuerung beruht auf einem von der Community entschlüsselten Protokoll. Der Hersteller des Lautsprechers unterstützt sie nicht offiziell, und ein Firmware-Update könnte sie beeinträchtigen.
