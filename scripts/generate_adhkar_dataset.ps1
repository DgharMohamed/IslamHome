Param(
  [string]$OutputPath = 'assets/adhkar/adhkar.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Repair-Mojibake {
  Param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
  $trimmed = $Text.Trim()

  $needsRepair = $false
  foreach ($charCode in @(216, 217, 195, 194, 226)) {
    if ($trimmed.Contains([string][char]$charCode)) {
      $needsRepair = $true
      break
    }
  }
  if (-not $needsRepair) { return $trimmed }

  try {
    $bytes = [System.Text.Encoding]::GetEncoding(1252).GetBytes($trimmed)
    $fixed = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ([string]::IsNullOrWhiteSpace($fixed)) { return $trimmed }
    return $fixed.Trim()
  } catch {
    return $trimmed
  }
}

function Normalize-SearchText {
  Param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
  $s = Repair-Mojibake $Text
  $s = $s.ToLowerInvariant()
  $s = $s -replace '[^\p{L}\p{Nd}\s]', ' '
  $s = $s -replace '\s+', ' '
  return $s.Trim()
}

function Resolve-Category {
  Param(
    [string]$RawCategory,
    [string]$Title,
    [string]$TextAr,
    [string]$TextEn
  )

  $combined = Normalize-SearchText("$RawCategory $Title $TextAr $TextEn")

  if ($combined -match 'after prayer|after salah|post prayer|taslim|after.*prayer|after.*salah|following.*prayer|what to say after completing the prayer') { return 'After Prayer' }
  if ($combined -match 'salah|salat|prayer|wudu|athan|iqama') { return 'Prayer' }
  if ($combined -match 'mosque|masjid') { return 'Mosque' }
  if ($combined -match 'morning|sunrise|fajr') { return 'Morning' }
  if ($combined -match 'evening|night|maghrib|isha') { return 'Evening' }
  if ($combined -match 'sleep|bed|wake up|waking') { return 'Sleep' }
  if ($combined -match 'food|eat|meal|drink|drinking|hungry|thirst') { return 'Food' }
  if ($combined -match 'travel|journey|riding|vehicle|trip') { return 'Travel' }
  if ($combined -match 'home|house|entering the home|leaving the home') { return 'Home' }
  if ($combined -match 'tasbeeh|tasbih|tahmid|takbir|tahleel|subhan') { return 'Tasbeeh' }
  if ($combined -match 'quran|ayah|surah|rabbana|verse') { return 'Quran Dua' }

  switch ((Normalize-SearchText $RawCategory)) {
    'morning_azkar' { return 'Morning' }
    'evening_azkar' { return 'Evening' }
    'sleep_azkar' { return 'Sleep' }
    'wake_up_azkar' { return 'Sleep' }
    'mosque_azkar' { return 'Mosque' }
    'adhan_azkar' { return 'Prayer' }
    'wudu_azkar' { return 'Prayer' }
    'quran_duas' { return 'Quran Dua' }
    'prophetic_duas' { return 'General' }
    'prophets_duas' { return 'General' }
    'miscellaneous_azkar' { return 'General' }
    '1' { return 'Morning' }
    '2' { return 'Evening' }
    '0' { return 'General' }
  }

  return 'General'
}

function Build-Title {
  Param(
    [string]$Title,
    [string]$FallbackCategory,
    [string]$Description
  )

  $raw = Repair-Mojibake $Title
  if ([string]::IsNullOrWhiteSpace($raw)) {
    $raw = Repair-Mojibake $Description
  }
  if ([string]::IsNullOrWhiteSpace($raw)) {
    return $FallbackCategory
  }
  return $raw
}

function Get-StringValue {
  Param(
    [object]$Obj,
    [string[]]$Names
  )
  foreach ($name in $Names) {
    if ($null -eq $Obj) { continue }
    if ($Obj.PSObject.Properties.Match($name).Count -gt 0) {
      $value = $Obj.$name
      if ($null -ne $value) {
        return [string]$value
      }
    }
  }
  return ''
}

function Get-IntValue {
  Param(
    [object]$Obj,
    [string[]]$Names,
    [int]$Default = 1
  )
  foreach ($name in $Names) {
    if ($null -eq $Obj) { continue }
    if ($Obj.PSObject.Properties.Match($name).Count -gt 0) {
      $value = $Obj.$name
      try {
        $parsed = [int]$value
        if ($parsed -gt 0) { return $parsed }
      } catch {}
    }
  }
  return $Default
}

$items = New-Object System.Collections.Generic.List[object]

function Add-Item {
  Param(
    [string]$RawCategory,
    [string]$Title,
    [string]$TextAr,
    [string]$TextEn,
    [string]$Reference,
    [int]$Repeat
  )

  $textArFixed = Repair-Mojibake $TextAr
  $textEnFixed = Repair-Mojibake $TextEn
  $referenceFixed = Repair-Mojibake $Reference

  if ([string]::IsNullOrWhiteSpace($textArFixed) -and [string]::IsNullOrWhiteSpace($textEnFixed)) {
    return
  }

  $category = Resolve-Category -RawCategory $RawCategory -Title $Title -TextAr $textArFixed -TextEn $textEnFixed
  $finalTitle = Build-Title -Title $Title -FallbackCategory $category -Description $RawCategory
  $finalRepeat = if ($Repeat -lt 1) { 1 } else { $Repeat }

  $items.Add([ordered]@{
      id = 0
      category = $category
      title = $finalTitle
      textAr = $textArFixed
      textEn = $textEnFixed
      reference = if ([string]::IsNullOrWhiteSpace($referenceFixed)) { 'Hisn Muslim' } else { $referenceFixed }
      repeat = $finalRepeat
      favorite = $false
    })
}

Write-Output 'Downloading Hisn-Muslim-Json...'
$hisnText = (Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/wafaaelmaandy/Hisn-Muslim-Json/master/husn_en.json' -TimeoutSec 180).Content
$hisnText = $hisnText.TrimStart([char]0xFEFF)
$hisn = $hisnText | ConvertFrom-Json

foreach ($section in $hisn.English) {
  $sectionTitle = Get-StringValue -Obj $section -Names @('TITLE', 'title')
  foreach ($entry in $section.TEXT) {
    $repeat = Get-IntValue -Obj $entry -Names @('REPEAT', 'repeat') -Default 1
    $entryId = Get-StringValue -Obj $entry -Names @('ID', 'id')
    $textAr = Get-StringValue -Obj $entry -Names @('ARABIC_TEXT', 'arabic', 'text')
    $textEn = Get-StringValue -Obj $entry -Names @('TRANSLATED_TEXT', 'translation', 'LANGUAGE_ARABIC_TRANSLATED_TEXT')
    $ref = "Hisn Muslim | Section: $sectionTitle | ID: $entryId"
    Add-Item -RawCategory $sectionTitle -Title $sectionTitle -TextAr $textAr -TextEn $textEn -Reference $ref -Repeat $repeat
  }
}

Write-Output 'Downloading Morning-And-Evening-Adhkar-DB...'
$seenAr = (Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/Seen-Arabic/Morning-And-Evening-Adhkar-DB/main/ar.json' -TimeoutSec 180).Content | ConvertFrom-Json
$seenEn = (Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/Seen-Arabic/Morning-And-Evening-Adhkar-DB/main/en.json' -TimeoutSec 180).Content | ConvertFrom-Json

$seenArByOrder = @{}
foreach ($row in $seenAr) {
  $seenArByOrder[[int]$row.order] = $row
}

foreach ($row in $seenEn) {
  $order = [int]$row.order
  $arRow = $null
  if ($seenArByOrder.ContainsKey($order)) {
    $arRow = $seenArByOrder[$order]
  }

  $arText = if ($null -ne $arRow) { Get-StringValue -Obj $arRow -Names @('content') } else { Get-StringValue -Obj $row -Names @('content') }
  $enText = Get-StringValue -Obj $row -Names @('translation', 'content')
  $title = "Morning and Evening Adhkar #$order"
  $sourceText = Get-StringValue -Obj $row -Names @('source')
  $ref = "Seen-Arabic DB | $sourceText"
  $repeat = Get-IntValue -Obj $row -Names @('count') -Default 1

  Add-Item -RawCategory ([string]$row.type) -Title $title -TextAr $arText -TextEn $enText -Reference $ref -Repeat $repeat
}

Write-Output 'Loading local adhkar sources...'
$localFiles = @(
  'assets/data/adhkar/adhkar_rn0x.json',
  'assets/data/adhkar/azkar_db.json',
  'assets/json/azkar.json',
  'assets/json/duas.json'
)

foreach ($file in $localFiles) {
  if (-not (Test-Path $file)) { continue }
  $obj = (Get-Content $file -Raw) | ConvertFrom-Json
  $categories = $obj.psobject.Properties.Name
  foreach ($cat in $categories) {
    $list = $obj.$cat
    foreach ($entry in $list) {
      $arText = Get-StringValue -Obj $entry -Names @('zikr', 'text', 'arabic')
      if ([string]::IsNullOrWhiteSpace($arText)) { $arText = [string]$entry.text }
      if ([string]::IsNullOrWhiteSpace($arText)) { $arText = [string]$entry.arabic }

      $enText = Get-StringValue -Obj $entry -Names @('english', 'textEn', 'translation')
      $title = Get-StringValue -Obj $entry -Names @('description', 'title')
      $ref = Get-StringValue -Obj $entry -Names @('reference', 'source')
      $repeat = Get-IntValue -Obj $entry -Names @('count', 'repeat') -Default 1

      Add-Item -RawCategory $cat -Title $title -TextAr $arText -TextEn $enText -Reference $ref -Repeat $repeat
    }
  }
}

Write-Output 'Deduplicating and merging...'
$dedup = @{}

foreach ($row in $items) {
  $keyAr = Normalize-SearchText ([string]$row.textAr)
  $keyEn = Normalize-SearchText ([string]$row.textEn)
  $key = if (-not [string]::IsNullOrWhiteSpace($keyAr)) { $keyAr } else { $keyEn }
  if ([string]::IsNullOrWhiteSpace($key)) { continue }

  if ($dedup.ContainsKey($key)) {
    $existing = $dedup[$key]

    if ([string]::IsNullOrWhiteSpace($existing.textEn) -and -not [string]::IsNullOrWhiteSpace($row.textEn)) {
      $existing.textEn = $row.textEn
    }

    if ($row.repeat -gt $existing.repeat) {
      $existing.repeat = $row.repeat
    }

    if (-not [string]::IsNullOrWhiteSpace($row.reference)) {
      $refs = @([string]$existing.reference -split '\s*\|\s*')
      if (-not ($refs -contains [string]$row.reference)) {
        $existing.reference = "$($existing.reference) | $($row.reference)"
      }
    }
  } else {
    $dedup[$key] = [ordered]@{
      id = 0
      category = [string]$row.category
      title = [string]$row.title
      textAr = [string]$row.textAr
      textEn = [string]$row.textEn
      reference = [string]$row.reference
      repeat = [int]$row.repeat
      favorite = $false
    }
  }
}

$categoryOrder = @{
  'Morning' = 1
  'Evening' = 2
  'Sleep' = 3
  'Prayer' = 4
  'After Prayer' = 5
  'Mosque' = 6
  'Food' = 7
  'Travel' = 8
  'Home' = 9
  'General' = 10
  'Tasbeeh' = 11
  'Quran Dua' = 12
}

$final = $dedup.Values |
  Sort-Object `
    @{ Expression = { if ($categoryOrder.ContainsKey($_.category)) { $categoryOrder[$_.category] } else { 99 } } }, `
    @{ Expression = { $_.title } } |
  ForEach-Object -Begin { $i = 1 } -Process {
    [ordered]@{
      id = $i
      category = $_.category
      title = $_.title
      textAr = $_.textAr
      textEn = $_.textEn
      reference = $_.reference
      repeat = $_.repeat
      favorite = $false
    }
    $i++
  }

$outputDir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDir) -and -not (Test-Path $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$json = $final | ConvertTo-Json -Depth 8
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutputPath, $json, $utf8NoBom)

$stats = $final | Group-Object { $_.category } | Sort-Object Name | ForEach-Object { "$($_.Name):$($_.Count)" }
Write-Output "Generated: $OutputPath"
Write-Output "Total entries: $($final.Count)"
Write-Output "Categories => $($stats -join ', ')"
