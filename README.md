🎰 ROULADETTI DELUXE v3.4
=========================

**Multi-Player Roulette in PowerShell — with Credit & Interest**

A terminal-based roulette game written in **PowerShell**, featuring multiple players, persistent save states, fair RNG, credit mechanics, and a bit of casino attitude.

Built for fun, not for profit. The house _will_ win long-term.

✨ Features
----------

*   🎯 **Classic Roulette Bets**
    
    *   Color (red / black) → 1:1
        
    *   Even / Odd → 1:1 (0 always loses)
        
    *   Single Number (0–36) → 35:1
        
*   👥 **Multi-Player Support**
    
    *   Add players
        
    *   Switch active player
        
    *   Each player has their own balance, debt & round count
        
*   💾 **Persistent Save System**
    
    *   Auto-save every 5 rounds
        
    *   Manual save / load
        
    *   JSON-based state file
        
*   💳 **Credit System**
    
    *   Take credit up to a global limit
        
    *   Repay anytime (if you have cash)
        
    *   Automatic interest every 5 rounds
        
*   📈 **Interest Mechanics**
    
    *   1% interest on outstanding debt
        
    *   Applied every 5 rounds per player
        
    *   Rounded up (casino rules)
        
*   🎲 **Fair RNG**
    
    *   Uses System.Security.Cryptography.RandomNumberGenerator
        
    *   No shady Get-Random
        
*   🎭 **NPC Quotes & Voice Lines**
    
    *   Random casino chatter
        
    *   External quote API with fallback lines
        

🛠 Requirements
---------------

*   **Windows PowerShell 5.1+** or **PowerShell 7+**
    
*   Internet connection (optional, only for NPC quotes)
    

🚀 How to Run
-------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   .\rouladetti.ps1   `

Optional parameters:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   .\rouladetti.ps1 -StartBalance 500 -StatePath ".\roulette_state.json"   `

### Parameters

ParameterDescriptionStartBalanceStarting cash per new player (default: 300)StatePathPath to save file (default: script directory)

🎯 Betting Syntax
-----------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML  

### Examples

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   color red 10  evenodd odd 20  number 17 5   `

📋 Commands
-----------

CommandActionhelpShow betting & command menubalShow balance, debt & roundssaveSave game stateloadLoad saved stateresetReset game (keeps multi-player)playersList all playersplayer add Add new playerplayer use Switch active playercreditTake a loanrepay Repay debtqQuit game

💳 Credit & Interest Rules
--------------------------

*   Max total credit per player: **CHF 1000**
    
*   Interest rate: **1%**
    
*   Interest applies **every 5 rounds**
    
*   Interest is rounded **up**
    
*   No balance = no betting (unless you take credit)
    

This is intentional. Play smart or pay interest.

📂 Save File
------------

*   Stored as roulette\_state.json
    
*   Includes:
    
    *   Game version
        
    *   Timestamp
        
    *   Active player
        
    *   All player balances, debts & rounds
        

Safe to delete if you want a fresh start.

⚠️ Disclaimer
-------------

This game **simulates gambling mechanics**.No real money involved.If you wouldn’t bet it IRL — don’t bet it here.

Drink water. Set limits. Touch grass.
