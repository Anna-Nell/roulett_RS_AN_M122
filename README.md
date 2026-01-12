Projektdokumentation — 🎰 ROULADETTI DELUXE v3.4 (PowerShell)
=============================================================

1) Kurzbeschrieb (Zweck & Einsatzgebiet)
----------------------------------------

**ROULADETTI DELUXE** isch es terminal-basierts Roulette-Spiel in **PowerShell**.Es isch fürs Üebe/Showcase vo Scripting gedacht (Input-Parsing, State-Handling, RNG, JSON Save/Load) und chan im Team/Schuel-Umfeld als Demo-Projekt bruucht werde.

**Highlights:**

*   Multi-Player (mehreri Spieler im gliche Save)
    
*   Persistente Speicherung (JSON-Statefile)
    
*   Kredit-System mit Limit + Zins (1% jede 5. Runde pro Spieler)
    
*   Faire Zufallszahl (Crypto RNG)
    
*   Command-Menü + praktische Befehle
    

2) Voraussetzungen / Umgebung
-----------------------------

### Betriebssystem

*   Windows 10/11 (empfohlen)
    
*   PowerShell Core (7.x) funktioniert i de Regel au
    

### PowerShell Version

*   Minimum: **Windows PowerShell 5.1** oder **PowerShell 7+**
    

### Netzwerk

*   Optional: Internet, nur für **NPC-Quotes** via API (https://api.quotable.io/random)→ Wenn offline: Script nutzt automatisch Fallback-Sprüche (keine Fehlfunktion)
    

### Berechtigungen (Execution Policy)

Wenn Scripts blockiert sind:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   `

Oder nur temporär für die aktuelle Session:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   powershell -ExecutionPolicy Bypass -File .\roulette.ps1   `

3) Installation / Projektstruktur
---------------------------------

Lege das Script z.B. so ab:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   /Roulettetti    roulette.ps1    roulette_state.json   (wird automatisch erstellt)   `

4) Start / Ausführung
---------------------

### Standardstart

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   .\roulette.ps1   `

Beim Start wird (wenn kein Savefile vorhanden ist) automatisch ein Default-State erstellt:

*   ActivePlayer = "Anna"
    
*   Balance = CHF 300 (oder dein StartBalance)
    

### Start mit Parametern

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   .\roulette.ps1 -StartBalance 500   `

### Start mit eigenem Statefile-Pfad

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   .\roulette.ps1 -StatePath "C:\Temp\roulette_state.json"   `

5) Parameter (CLI-Parameter)
----------------------------

ParameterTypPflichtDefaultBeschreibung-StartBalanceintoptional300Startguthaben pro neuem Spieler / bei Reset-StatePathstringoptional.\\roulette\_state.jsonSpeicherort fürs JSON Savefile

**Wichtig:**Wenn -StatePath leer isch, setzt das Script automatisch:

*   Wenn $PSScriptRoot existiert → Savefile im Script-Ordner
    
*   Sonst → Savefile im aktuellen Arbeitsverzeichnis
    

6) Bedienung im Spiel (Input & Flow)
------------------------------------

Das Script läuft in ere Endlosschlaufe. Pro Runde:

1.  NPC Quote (online oder fallback)
    
2.  Wenn Balance ≤ 0 → Kreditangebot
    
3.  Anzeige “Place your bets…”
    
4.  User input (Wette oder Command)
    
5.  Spin + Resultat
    
6.  Auszahlung oder Verlust
    
7.  Runden-Zähler + evtl. Zins (jede 5 Runde)
    
8.  Auto-Save jede 5 Runde
    

Beenden mit q.

7) Befehle & Funktionen (In-Game Commands)
------------------------------------------

### Hilfe / Übersicht

*   helpZeigt Menü, Wettarten, Beispiele und Commands.
    

### Save/Load/Reset

*   saveSpeichert aktuellen State (Players, Balances, Debts, Rounds).
    
*   loadLädt vorhandenes Savefile.
    
*   resetSetzt Multi-Player State zurück und erstellt neu nur Spieler “Anna”.
    

### Status

*   balZeigt Balance, Debt und Rounds vom aktiven Spieler.
    

### Multi-Player Verwaltung

*   playersListet alle Spieler + markiert aktiven Spieler mit ⭐
    
*   player add Erstellt neuen Spieler mit StartBalance.
    
*   player use Wechselt aktiven Spieler.
    

### Kredit / Schulden

*   creditÖffnet Kredit-Dialog: Kredit aufnehmen bis max. Kreditlimit.
    
*   repay Zahlt Schulden ab (wenn Balance genügt).
    

### Quit

*   qBeendet das Spiel (State wird vor Exit gespeichert).
    

8) Wettarten (Syntax & Auszahlungen)
------------------------------------

**Syntax allgemein:**

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML  

### 8.1 color (Rot/Schwarz)

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   color red 10  color black 50   `

*   Auszahlung: **2x Einsatz** (1:1 + Einsatz retour)
    
*   0 zählt als **Green** → verliert bei color
    

### 8.2 evenodd (Gerade/Ungerade)

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   evenodd even 20  evenodd odd 20   `

*   Auszahlung: **2x Einsatz**
    
*   **0 zählt nicht** als even/odd → immer Verlust
    

### 8.3 number (Zahl 0–36)

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   number 17 5  number 0 10   `

*   Auszahlung: **35x Einsatz** (klassisch Roulette)
    

9) Kredit-System (Regeln)
-------------------------

*   Max Kredit pro Spieler: **CHF 1000**
    
*   Wenn Balance ≤ 0, wird automatisch Offer-Credit ausgelöst.
    
*   Kredit erhöht:
    
    *   Balance += Kreditbetrag
        
    *   Debt += Kreditbetrag
        

### Zins (Interest)

*   Wenn Debt > 0 und **Rounds % 5 == 0**→ Zins wird gerechnet:
    
    *   Debt = Ceiling(Debt \* 1.01)
        
*   Ausgabe im Terminal:
    
    *   “📈 Zinse hit: Debt CHF X → CHF Y (+1%)”
        

### Rückzahlung

*   repay reduziert:
    
    *   Balance -= pay
        
    *   Debt -= pay
        
*   Pay ist minimal von und aktueller Debt.
    

10) Validierung & Fehlermeldungen
---------------------------------

Das Script validiert:

*   Betrag > 0
    
*   Betrag ≤ Balance (oder Kredit anbieten)
    
*   Wertebereiche:
    
    *   number: 0–36
        
    *   color: red|black
        
    *   evenodd: even|odd
        

Beispiele für Fehler:

*   “❌ Zu wenig Guthabe”
    
*   “❌ Zahl 0–36 only.”
    
*   “❓ Ungültig. Tipp: help”
    

11) Beispiele (konkret & verständlich)
--------------------------------------

### Beispiel A — Standardrunde

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   🎲 [Anna] Setz dini Wette: color red 10  ➡️ Landed on 32 (Red)  💵 Payout: CHF 20 | Balance: CHF 310   `

### Beispiel B — Zahlwette (High risk)

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   🎲 [Anna] Setz dini Wette: number 17 5  ➡️ Landed on 17 (Black)  💵 Payout: CHF 175 | Balance: CHF 470   `

### Beispiel C — Spieler hinzufügen & wechseln

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   player add Marco  player use Marco  bal   `

### Beispiel D — Kredit aufnehmen (wenn broke)

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   balance = 0  credit  yes  200   `

### Beispiel E — Schulden zurückzahlen

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   repay 50   `

### Beispiel F — Save & Load

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   save  load   `

12) Screenshots (Platzhalter + was sinnvoll ist)
------------------------------------------------

Du chasch 2–3 Screenshots mache (das reicht völlig):

1.  **Startscreen + Menü**
    
    *   Zeigt Player, Balance, Debt, Commands
        
2.  **Eine Runde mit Resultat**
    
    *   Wette → Spin → Landed on → payout/lose
        
3.  **Players-Liste oder Kredit/Repay**
    
    *   Spielerwechsel oder Kreditaufnahme mit Debt-Anzeige
        

**Tipp:** Screenshot direkt im Terminal (Windows Terminal / PowerShell) und i GitHub in /docs/screens/ ablege, z.B.:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   /docs/screens/start.png  /docs/screens/round_win.png  /docs/screens/credit.png   `

Dann im README einbinde (Markdown):

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   ![Startscreen](docs/screens/start.png)   `

13) Troubleshooting (kurz aber nützlich)
----------------------------------------

### Script startet nicht (Policy)

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   `

### Savefile kaputt / JSON Fehler

Lösche roulette\_state.json oder benutz reset.

### Keine NPC Quotes

Kei Problem — offline fallback wird automatisch genutzt.

14) Lizenz / Hinweis
--------------------

Projekt isch fürs Lernen/Demo gedacht. Kein echtes Gambling, kei Echtgeld.
