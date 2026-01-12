\# 🎰 ROULADETTI DELUXE v3.4 — Multi-Player + Kredit + Zinse

Terminal-Roulette in \*\*PowerShell\*\* mit \*\*Multi-Player\*\*, \*\*Save/Load\*\*, \*\*fairer Crypto-RNG\*\*, \*\*Kredit-System\*\* und \*\*Zins\*\*.

Einsatzgebiet: Mini-Game / Lernprojekt für PowerShell (Input-Parsing, State-Management, JSON, Funktionen, Control-Flow).

\---

\## 🧾 Kurze Beschreibung (Zweck & Einsatzgebiet)

\*\*Zweck:\*\*

Simuliert Roulette (0–36) mit einfachen Wettarten. Spieler:innen können Chips setzen, gewinnen/verlieren, und ihr Spielstand wird in einer JSON-Datei gespeichert.

\*\*Einsatzgebiet:\*\*

\- Üben von \*\*PowerShell Scripting\*\* (Funktionen, Regex, JSON, Parameter, Persistenz)

\- Demo-Projekt für \*\*CLI-Interaktion\*\*

\- Fun-Projekt (aber: House edge bleibt real 😉)

\---

\## ✅ Voraussetzungen

\- \*\*Windows PowerShell 5.1+\*\* oder \*\*PowerShell 7+\*\*

\- Lokale Ausführung von \`.ps1\` Scripts erlaubt

Falls es blockiert:

\`\`\`powershell

Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

Optional: Internetzugang für NPC Quotes (API). Ohne Internet nutzt das Script automatisch Fallback-Zitate.

▶️ Anleitung zur Ausführung

1) Script starten

.\\rouladetti.ps1

2) Mit Parametern starten (optional)

.\\rouladetti.ps1 -StartBalance 500 -StatePath ".\\my\_state.json"

⚙️ Parameter

ParameterTypOptionalDefaultBedeutung

StartBalanceint✅300Startguthaben pro neuem Player (z. B. bei reset oder player add)

StatePathstring✅.\\roulette\_state.json (im Script-Ordner)Pfad zur Save-Datei (JSON). Wenn leer → auto default

Hinweis: Wenn $PSScriptRoot vorhanden ist, wird standardmässig im Script-Ordner gespeichert, sonst im aktuellen Ordner.

🎮 Spiel-Flow (Kurz erklärt)

NPC Quote erscheint (API oder Fallback)

Du gibst entweder Command oder Wette ein

Bei Balance ≤ 0 → Script bietet Kredit an

Spin läuft (Animation)

Resultat wird angezeigt + Payout berechnet

Runde zählt hoch, alle 5 Runden: Zins falls Debt > 0 + Autosave

🎯 Wetten (Syntax)

Format:

Wettarten

TypWertAuszahlungNotes

colorred | black1:1 (im Script als amount\*2 inkl. Einsatz)0 ist grün → verliert

evenoddeven | odd1:1 (im Script amount\*2)0 zählt nicht als even/odd

number0–3635:1 (im Script amount\*35)Treffer ist selten, aber big win

⌨️ Befehle & Funktionen

Du kannst jederzeit statt einer Wette auch Commands tippen.

Allgemein

BefehlErklärung

helpZeigt Menü mit Wettarten & Beispielen

balZeigt Balance, Debt und Rounds vom aktiven Player

qQuit (beendet das Spiel)

Save / Load / Reset

BefehlErklärung

saveSpeichert aktuellen State in StatePath

loadLädt State aus StatePath (falls vorhanden)

resetSetzt Multi-Player-Setup zurück (erstellt Player Anna neu)

Player Management (Multi-Player)

BefehlErklärung

playersListet alle Player inkl. Balance/Debt/Rounds (⭐ = aktiv)

player add Fügt neuen Player hinzu (mit StartBalance)

player use Setzt aktiven Player

Kredit / Schulden

BefehlErklärung

creditNimmt Kredit auf (bis Limit, interaktiv)

repay Zahlt Debt zurück (nur wenn Balance reicht)

💳 Kredit & Zins System

Max Credit pro Player: CHF 1000

Zins: 1% alle 5 Runden pro Player (Rounds % 5 == 0)

Zins wird aufgerundet (Ceiling)

Wenn du broke bist (Balance ≤ 0), bietet das Script automatisch Kredit an.

🧪 Beispiele (konkret)

Wetten platzieren

text

Code kopieren

color red 10

➡️ Setzt CHF 10 auf Rot.

evenodd odd 20

➡️ Setzt CHF 20 auf Ungerade.

number 17 5

➡️ Setzt CHF 5 auf die Zahl 17.

Balance checken

bal

Save / Load

save

load

Multi-Player benutzen

players

player add Kevin

player use Kevin

Kredit aufnehmen & zurückzahlen

credit

➡️ Script fragt dich dann:

yes/no

Kreditbetrag

repay 50

➡️ Zahlt CHF 50 Debt ab (oder weniger, wenn Debt kleiner ist).

🖼️ Screenshots (Platzhalter)

Füge hier 2–4 Screenshots ein. Für GitHub: Screenshots in /assets speichern.

Beispiel-Struktur:

css

Code kopieren

repo/

├─ rouladetti.ps1

├─ roulette\_state.json

├─ README.md

└─ assets/

├─ menu.png

├─ spin.png

└─ players.png

Dann im README einbinden:

\### Menü / Hilfe

!\[Menü\](assets/menu.png)

\### Spin Resultat

!\[Spin\](assets/spin.png)

\### Multi-Player Übersicht

!\[Players\](assets/players.png)

📁 Savefile / State

Der State wird als JSON gespeichert (standard: roulette\_state.json) und enthält u.a.:

Version

Updated

ActivePlayer

Players (Balance, Debt, Rounds pro Player)

⚠️ Hinweis (real talk)

Roulette bleibt Roulette:

Langfristig gewinnt die Bank. Das Script zeigt das ziemlich ehrlich – besonders mit Kredit + Zins. 😅

📜 License

Optional: Add später, wenn du willst (z.B. MIT).

bash

Code kopieren

Wenn du willst, mach ich dir schnell auch noch:

\- ein \*\*assets/\*\* Template + Dummy-Screens (ASCII-mock)

\- oder ich kürz das README auf “GitHub-clean”, falls es dir zu lang wirkt.
