# 🎰 ROULADETTI DELUXE v3.3 — NPC Quotes jede Runde (mit Tag)

param(
  [int]$StartBalance = 300,
  [string]$StatePath
)

# --- Paths ---
if (-not $StatePath -or [string]::IsNullOrWhiteSpace($StatePath)) {
  $StatePath = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'roulette_state.json' } else { Join-Path (Get-Location) 'roulette_state.json' }
}

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
$closing = @("🎙️ *No more bets...*", "🎙️ *Euses nimmt kei Wette meh...*", "🎙️ Hands weg vo de Chips, it’s go time.")
$spinTalk = @("🎡 Wheel’s spinning… chhhhhrrrr…", "🎡 Und mir dreie… chrrrrr…", "🎡 Spin it to win it… chrrrr…")
$landTalk = @("🛑 *Ball is dropping…*", "🛑 *Ball gumpft…*", "🛑 *Come on, baby…*")
$winTalk = @("🏆 *BOOM!* Vegas-Kuss uf dini Stirn.", "💰 Cha-ching! De Cage liebt dich.", "🔥 Winner winner, fondue dinner.", "🤑 D’Bank verchlemmt, du nimmst mit.")
$loseTalk = @("😵 House said: *merci für dä Beitrag*.", "💸 Unlucky, Bro — d’Kasse lacht.", "🧊 Ice cold. Nöime.", "👋 Try again, high roller.")
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
  Shout "   save  | load  | reset  | bal  | help  | q" "DarkGray"
  Line
}

# --- Save / Load ---
function Save-State {
  param([string]$path, [int]$balance, [int]$rounds, [datetime]$ts)
  $state = [pscustomobject]@{ Balance=$balance; Rounds=$rounds; Updated=$ts.ToString("o"); Version=33 }
  $state | ConvertTo-Json -Depth 5 | Set-Content -Path $path -Encoding UTF8
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

# --- Start ---
$loaded = Load-State -path $StatePath
if ($loaded -and $loaded.Balance -gt 0) {
  $balance = [int]$loaded.Balance
  $round = [int]($loaded.Rounds ?? 0)
  Shout "♻️ Save geladen (CHF $balance, Runde $round)" "DarkGray"
} else { $balance = $StartBalance; $round = 0 }

Clear-Host
Line
Shout "🎰 ROULADETTI DELUXE — Balance: CHF $balance" "Cyan"
Show-Choices   # help shown at start

# --- Main Loop ---
while ($true) {
  # 🎭 NPC spricht am Start jeder Runde
  Shout (Get-NPCQuote) "DarkCyan"

  Say-Random $preBets "Magenta"
  $input = Read-Host "🎲 Setz dini Wette"
  if ($input -match '^\s*q\s*$') { break }

  switch -Regex ($input) {
    '^\s*help\s*$'  { Show-Choices; continue }
    '^\s*save\s*$'  { Save-State -path $StatePath -balance $balance -rounds $round -ts (Get-Date); continue }
    '^\s*load\s*$'  { $ld=Load-State -path $StatePath; if($ld){$balance=$ld.Balance;$round=$ld.Rounds;Shout "♻️ Geladen. CHF $balance" "Gray"}; continue }
    '^\s*reset\s*$' { $balance=$StartBalance;$round=0;Shout "🔁 Reset. CHF $balance" "Gray"; continue }
    '^\s*bal\s*$'   { Shout ("💰 Balance: CHF {0}" -f $balance) "Cyan"; continue }
  }

  if ([string]::IsNullOrWhiteSpace($input)) { Say-Random $tableTalk "DarkCyan"; continue }

  if ($input -match '^\s*(color|number|evenodd)\s+(\S+)\s+(\d+)\s*$') {
    $type,$val,$amt = $Matches[1],$Matches[2],[int]$Matches[3]
    $err = Validate-Bet -type $type -val $val -amt $amt -balance $balance
    if ($err) { Shout "$err  👉 Tipp: 'help' zeigt Beispiele." "Yellow"; continue }

    Shout ($closing | Get-Random) "DarkGray"
    $balance -= $amt
    Animate-Spin
    $res = Spin

    $col = switch ($res.Color) { "Red" {"Red"} "Black" {"White"} default {"Green"} }
    Shout ("➡️  Landed on {0} ({1})" -f $res.Number, $res.Color) $col

    $win = Payout -betType $type -betValue $val -amount $amt -result $res
    if ($win -gt 0) {
      $balance += $win
      Say-Random $winTalk "Green"
      Shout ("💵 Payout: CHF {0}  |  💰 Balance: CHF {1}" -f $win, $balance) "Green"
    } else {
      Say-Random $loseTalk "DarkRed"
      Shout ("💸 Einsatz weg. 💰 Balance: CHF {0}" -f $balance) "DarkRed"
    }

    $round++
    if ($round % 5 -eq 0) { Save-State -path $StatePath -balance $balance -rounds $round -ts (Get-Date) }
    if ($balance -le 0) { Shout "🧾 Cashier sagt: Game over, high roller." "DarkGray"; break }
    Line
  }
  else {
    Shout "❓ Ungültig. 👉 Tipp: 'help' zeigt Menü & Beispiele." "Yellow"
  }
}

Save-State -path $StatePath -balance $balance -rounds $round -ts (Get-Date)
Shout "🎤 Danke fürs Zocke. Trink Wasser, setz Limits. ✌️" "Cyan"
