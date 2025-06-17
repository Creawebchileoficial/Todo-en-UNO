$adSenseScript = 'client=ca-pub-1273212656995497'
$workspacePath = '.'
$htmlFiles = Get-ChildItem -Path $workspacePath -Filter "*.html" -File

$filesWithAdsense = @()
$filesWithoutAdsense = @()

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    if ($content -match $adSenseScript) {
        $filesWithAdsense += $file.Name
    } else {
        $filesWithoutAdsense += $file.Name
    }
}

Write-Host "Archivos con Google AdSense ($($filesWithAdsense.Count)):"
$filesWithAdsense | ForEach-Object { Write-Host "- $_" }

Write-Host "`nArchivos sin Google AdSense ($($filesWithoutAdsense.Count)):"
$filesWithoutAdsense | ForEach-Object { Write-Host "- $_" }
