# 🎰 ROULETTE— Multi-Player + Kredit + Zinse

param(
  [int]$StartBalance = 300,
  [string]$StatePath
)

# --- Paths ---
if (-not $StatePath -or [string]::IsNullOrWhiteSpace($StatePath)) {
  $StatePath = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'roulette_state.json' } else { Join-Path (Get-Location) 'roulette_state.json' }
}

# --- Config ---
$MaxCredit = 1000
$InterestRate = 0.01  # 1% jede 5. Runde pro Spieler

# --- Utils ---
function Shout($msg, $color="White") { Write-Host $msg -ForegroundColor $color }
function Line($c="-"){ Shout ($c * 50) "DarkGray" }
function Say-Random($arr, $color="White"){ Shout ($arr | Get-Random) $color }

# --- Voice Lines ---
$preBets = @(
 "🎙️ *Place your bets, ladies and gentlemen!*",
 "🎙️ Chips uf Tisch, Baby. Bisch ready?",
 "🎙️ Feeling lucky, darling? Setz dini Wette.",
 "🎙️ Don’t be shy — Money likes confidence."
)
$closing = @("🎙️ *No more bets...*", "🎙️ *Mir nemmet kei Wette meh...*", "🎙️ Händ weg vo de Chips, it’s go time.")
$spinTalk = @("🎡 Wheel’s spinning… chhhhhrrrr…", "🎡 Und mir dreiet… chrrrrr…", "🎡 Spin it to win it… chrrrr…")
$landTalk = @("🛑 *Ball is dropping…*", "🛑 *Ball gumpt…*", "🛑 *Come on, baby…*")
$winTalk = @("🏆 *BOOM!* Vegas-Küsst uf dini Stirn.", "💰 Cha-ching! De Cage liebt dich.", "🔥 Winner winner, fondue dinner.", "🤑 D’Bank verchlemmt, du nimmst mit.")
$loseTalk = @("😵 House said: *merci für dä Beitrag*.", "💸 Unlucky, Bro — d’Kasse lacht.", "🧊 Ice cold. Noime.", "👋 Try again, high roller.")
$tableTalk = @(
 "💬 Tip: Rot/Schwarz isch 1:1 — sicher aber lame.",
 "💬 Zahl (0–36) isch 35x — s’fühlt sich an wie Magie.",
 "💬 Bankroll-Rule: verlür nid meh als dir egal isch.",
 "💬 Martingale? Nur wenn dini Nerven stah wie Beton."
)

# --- Fair RNG (Crypto) ---
Add-Type -AssemblyName System.Security
function Get-FairInt([int]$minInclusive, [int]$maxExclusive) {
  [System.Security.Cryptography.RandomNumberGenerator]::GetInt32($minInclusive, $maxExclusive)
}

# --- Quotable API plain statement (NPC tagged) ---
function Get-NPCQuote {
  try {
    $q = Invoke-RestMethod -UseBasicParsing -Uri 'https://api.quotable.io/random' -Method GET -TimeoutSec 5
    if ($q.content) { return "NPC: $($q.content)" }
  } catch { }
  $fallbacks = @(
    "NPC: Glück liebt Mut.",
    "NPC: Setz nur, was du verdauen kannst.",
    "NPC: Kalt bleiben, klar spielen.",
    "NPC: Chancen sind Chancen, kein Plan.",
    "NPC: Bankroll zuerst, Ego später."
  )
  return ($fallbacks | Get-Random)
}

# --- Roulette Colors ---
$red   = @(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36)
$black = @(2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35)

# --- Menü ---
function Show-Choices {
  Line
  Shout "📋 WAS DU WÄHLEN KANNST" "Cyan"
  Shout "🎯 Wetten (Typ  Wert  Betrag)" "Gray"
  Shout "   • color   red|black     → 1:1" "Gray"
  Shout "   • evenodd even|odd      → 1:1  (0 zählt ned)" "Gray"
  Shout "   • number  0–36          → 35:1" "Gray"
  Shout "🧮 Beispiel" "Gray"
  Shout "   color red 10   |   evenodd odd 20   |   number 17 5" "DarkGray"
  Shout "🔧 Commands" "Gray"
  Shout "   save | load | reset | bal | help | q" "DarkGray"
  Shout "   players | player add <name> | player use <name>" "DarkGray"
  Shout "   credit (Kredit ufneh) | repay <amount> (Kredit abzahle)" "DarkGray"
  Line
}

# --- Save / Load ---
function Save-State {
  param([string]$path, $stateObj)
  $stateObj | ConvertTo-Json -Depth 8 | Set-Content -Path $path -Encoding UTF8
  Shout "💾 Saved → $path" "DarkGray"
}
function Load-State {
  param([string]$path)
  if (Test-Path $path) {
    try { return (Get-Content -Raw -Path $path | ConvertFrom-Json) }
    catch { Shout "⚠️ Savefile korrupt. Neuer Start." "Yellow" }
  }
  return $null
}

# --- Spin / Anim ---
function Spin {
  $num = Get-FairInt 0 37
  $color = if ($num -eq 0) { "Green" }
           elseif ($red -contains $num) { "Red" }
           else { "Black" }
  [pscustomobject]@{ Number=$num; Color=$color }
}
function Animate-Spin {
  Shout (" " + ($spinTalk | Get-Random)) "Yellow"
  1..3 | ForEach-Object { Start-Sleep -Milliseconds 300; Write-Host -NoNewline "." }
  Write-Host ""
  Shout ($landTalk | Get-Random) "DarkYellow"
  Start-Sleep -Milliseconds 400
}

# --- Payout ---
function Payout {
  param($betType, $betValue, $amount, $result)
  switch ($betType.ToLower()) {
    "number"  { if ($result.Number -eq [int]$betValue) { return $amount * 35 } }
    "color"   { if ($result.Color.ToLower() -eq $betValue.ToLower()) { return $amount * 2 } }
    "evenodd" {
      if ($result.Number -eq 0) { return 0 }
      $isEven = ($result.Number % 2 -eq 0)
      if (($betValue -eq "even" -and $isEven) -or ($betValue -eq "odd" -and -not $isEven)) { return $amount * 2 }
    }
  }
  return 0
}

# --- Kredit / Zinse ---
function Apply-InterestIfNeeded {
  param($player)
  if ($player.Debt -gt 0 -and ($player.Rounds % 5 -eq 0)) {
    $before = [decimal]$player.Debt
    $after  = [math]::Ceiling(($before * (1 + $InterestRate)))
    $player.Debt = [int]$after
    Shout ("📈 Zinse hit: Debt CHF {0} → CHF {1} (+{2}%)" -f $before, $after, ([int]($InterestRate*100))) "DarkYellow"
  }
}

function Offer-Credit {
  param($player)

  $room = $MaxCredit - [int]$player.Debt
  if ($room -le 0) {
    Shout "🚫 Kredit-Limit erreicht (max CHF $MaxCredit). Du muesch abzahle." "Yellow"
    return
  }

  Shout ("🏦 Du bisch broke. Wotsch Kredit ufneh? (max no CHF {0})" -f $room) "Cyan"
  $ans = Read-Host "Tippe: yes / no"
  if ($ans -notmatch '^(y|yes)$') {
    Shout "🧾 Okey. Denn chasch imfall grad nöd witer setze bis wieder Cash hesch." "DarkGray"
    return
  }

  $amtRaw = Read-Host "Wie vil Kredit? (1-$room)"
  if ($amtRaw -notmatch '^\d+$') { Shout "❌ Zahl bitte." "Yellow"; return }
  $amt = [int]$amtRaw
  if ($amt -le 0 -or $amt -gt $room) { Shout "❌ Usgserhalb vom Limit." "Yellow"; return }

  $player.Balance += $amt
  $player.Debt    += $amt
  Shout ("✅ Kredit gno: +CHF {0} | Debt jetzt CHF {1} | Balance CHF {2}" -f $amt, $player.Debt, $player.Balance) "Green"
}

function Repay-Debt {
  param($player, [int]$amt)
  if ($player.Debt -le 0) { Shout "💤 Du hesch kei Debt." "DarkGray"; return }
  if ($amt -le 0) { Shout "❌ repay > 0, Bro." "Yellow"; return }
  if ($player.Balance -lt $amt) { Shout ("❌ Z’wenig Balance zum abzahle. Balance CHF {0}" -f $player.Balance) "Yellow"; return }

  $pay = [math]::Min($amt, [int]$player.Debt)
  $player.Balance -= $pay
  $player.Debt    -= $pay
  Shout ("✅ Abzahlt: CHF {0} | Debt CHF {1} | Balance CHF {2}" -f $pay, $player.Debt, $player.Balance) "Green"
}

# --- Validate ---
function Validate-Bet {
  param([string]$type, [string]$val, [int]$amt, [int]$balance)
  if ($amt -le 0) { return "❌ Bet > 0, Bro." }
  if ($amt -gt $balance) { return "❌ Zu wenig Guthabe. CHF $balance" }
  switch ($type.ToLower()) {
    "number"  { if ($val -notmatch '^\d+$' -or [int]$val -lt 0 -or [int]$val -gt 36) { return "❌ Zahl 0–36 only." } }
    "color"   { if ($val.ToLower() -notin @("red","black")) { return "❌ Color: red|black." } }
    "evenodd" { if ($val.ToLower() -notin @("even","odd")) { return "❌ evenodd: even|odd." } }
    default   { return "❌ Ungültig." }
  }
  return $null
}

# --- State Init ---
$loaded = Load-State -path $StatePath

if (-not $loaded) {
  $state = [pscustomobject]@{
    Version = 34
    Updated = (Get-Date).ToString("o")
    ActivePlayer = "Anna"
    Players = @{
      "Anna" = [pscustomobject]@{ Balance = $StartBalance; Debt = 0; Rounds = 0 }
    }
  }
} else {
  # migrate-ish / normalize
  $state = $loaded
  if (-not $state.Players) {
    $state = [pscustomobject]@{
      Version = 34
      Updated = (Get-Date).ToString("o")
      ActivePlayer = "Player1"
      Players = @{
        "Player1" = [pscustomobject]@{ Balance = [int]($loaded.Balance ?? $StartBalance); Debt = 0; Rounds = [int]($loaded.Rounds ?? 0) }
      }
    }
  }
  if (-not $state.ActivePlayer) { $state.ActivePlayer = ($state.Players.PSObject.Properties.Name | Select-Object -First 1) }
}

function Get-Player {
  $name = [string]$state.ActivePlayer
  if (-not $state.Players.$name) {
    $state.ActivePlayer = ($state.Players.PSObject.Properties.Name | Select-Object -First 1)
    $name = [string]$state.ActivePlayer
  }
  return $state.Players.$name
}

Clear-Host
Line
$player = Get-Player
Shout ("🎰 ROULADETTI DELUXE — Player: {0} | Balance: CHF {1} | Debt: CHF {2}" -f $state.ActivePlayer, $player.Balance, $player.Debt) "Cyan"
Show-Choices

# --- Main Loop ---
while ($true) {
  $player = Get-Player

  # 🎭 NPC spricht am Start jeder Runde
  Shout (Get-NPCQuote) "DarkCyan"

  # Auto: wenn broke -> Kredit-Option
  if ($player.Balance -le 0) {
    Offer-Credit -player $player
    if ($player.Balance -le 0) {
      Shout "🧾 Kein Cash. Du muesch entweder Kredit neh oder abzahle/Player wechsle." "DarkGray"
    }
  }

  Say-Random $preBets "Magenta"
  $input = Read-Host ("🎲 [{0}] Setz dini Wette" -f $state.ActivePlayer)
  if ($input -match '^\s*q\s*$') { break }

  switch -Regex ($input) {
    '^\s*help\s*$'     { Show-Choices; continue }
    '^\s*save\s*$'     { $state.Updated=(Get-Date).ToString("o"); Save-State -path $StatePath -stateObj $state; continue }
    '^\s*load\s*$'     { $ld=Load-State -path $StatePath; if($ld){$state=$ld;Shout "♻️ Geladen." "Gray"}; continue }
    '^\s*reset\s*$'    {
      $state.Players = @{}
      $state.Players["Anna"] = [pscustomobject]@{ Balance = $StartBalance; Debt=0; Rounds=0 }
      $state.ActivePlayer = "Anna"
      Shout "🔁 Reset (Multi-Player). Player Anna neu." "Gray"
      continue
    }
    '^\s*bal\s*$'      {
      $p=Get-Player
      Shout ("💰 [{0}] Balance: CHF {1} | Debt: CHF {2} | Rounds: {3}" -f $state.ActivePlayer, $p.Balance, $p.Debt, $p.Rounds) "Cyan"
      continue
    }
    '^\s*players\s*$'  {
      Line
      Shout "👥 PLAYERS" "Cyan"
      foreach($n in $state.Players.PSObject.Properties.Name) {
        $p = $state.Players.$n
        $tag = if ($n -eq $state.ActivePlayer) { "⭐" } else { "  " }
        Shout ("{0} {1} | Bal CHF {2} | Debt CHF {3} | R {4}" -f $tag, $n, $p.Balance, $p.Debt, $p.Rounds) "Gray"
      }
      Line
      continue
    }
    '^\s*player\s+add\s+(.+?)\s*$' {
      $name = $Matches[1].Trim()
      if ([string]::IsNullOrWhiteSpace($name)) { Shout "❌ Name fehlt." "Yellow"; continue }
      if ($state.Players.$name) { Shout "⚠️ Dä Player git’s scho." "Yellow"; continue }
      $state.Players | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]@{ Balance=$StartBalance; Debt=0; Rounds=0 })
      Shout "✅ Player added: $name (CHF $StartBalance)" "Green"
      continue
    }
    '^\s*player\s+use\s+(.+?)\s*$' {
      $name = $Matches[1].Trim()
      if (-not $state.Players.$name) { Shout "❌ Kenn i nöd. Mach: players" "Yellow"; continue }
      $state.ActivePlayer = $name
      $p=Get-Player
      Shout ("🔄 Active: {0} | Bal CHF {1} | Debt CHF {2}" -f $name, $p.Balance, $p.Debt) "Cyan"
      continue
    }
    '^\s*credit\s*$' {
      Offer-Credit -player (Get-Player)
      continue
    }
    '^\s*repay\s+(\d+)\s*$' {
      Repay-Debt -player (Get-Player) -amt ([int]$Matches[1])
      continue
    }
  }

  if ([string]::IsNullOrWhiteSpace($input)) { Say-Random $tableTalk "DarkCyan"; continue }

  if ($input -match '^\s*(color|number|evenodd)\s+(\S+)\s+(\d+)\s*$') {
    $type,$val,$amt = $Matches[1],$Matches[2],[int]$Matches[3]

    # wenn Balance z’wenig -> Kredit anbieten (aber nur bis Limit)
    $player = Get-Player
    if ($player.Balance -lt $amt) {
      Shout ("💳 Z’wenig Cash (Bal CHF {0}). Wotsch Kredit, zum setze?" -f $player.Balance) "Yellow"
      Offer-Credit -player $player
    }

    $err = Validate-Bet -type $type -val $val -amt $amt -balance $player.Balance
    if ($err) { Shout "$err  👉 Tipp: 'help' zeigt Beispiele." "Yellow"; continue }

    Shout ($closing | Get-Random) "DarkGray"
    $player.Balance -= $amt
    Animate-Spin
    $res = Spin

    $col = switch ($res.Color) { "Red" {"Red"} "Black" {"White"} default {"Green"} }
    Shout ("➡️  Landed on {0} ({1})" -f $res.Number, $res.Color) $col

    $win = Payout -betType $type -betValue $val -amount $amt -result $res
    if ($win -gt 0) {
      $player.Balance += $win
      Say-Random $winTalk "Green"
      Shout ("💵 Payout: CHF {0}  |  💰 Balance: CHF {1}  |  🧾 Debt: CHF {2}" -f $win, $player.Balance, $player.Debt) "Green"
    } else {
      Say-Random $loseTalk "DarkRed"
      Shout ("💸 Einsatz weg. 💰 Balance: CHF {0}  |  🧾 Debt: CHF {1}" -f $player.Balance, $player.Debt) "DarkRed"
    }

    # Runde zählen + evtl. Zinse
    $player.Rounds++
    Apply-InterestIfNeeded -player $player

    # autosave jede 5. Runde (global: irgend e Player spielt)
    if (($player.Rounds % 5) -eq 0) {
      $state.Updated=(Get-Date).ToString("o")
      Save-State -path $StatePath -stateObj $state
    }

    Line
  }
  else {
    Shout "❓ Ungültig. 👉 Tipp: 'help' zeigt Menü & Beispiele." "Yellow"
  }
}

$state.Updated=(Get-Date).ToString("o")
Save-State -path $StatePath -stateObj $state
Shout "🎤 Danke fürs Zocke. Trink Wasser, setz Limits. ✌️" "Cyan"
