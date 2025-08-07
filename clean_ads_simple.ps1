# Script simplificado para eliminar anuncios y redirecciones
$workspacePath = '.'
$htmlFiles = Get-ChildItem -Path $workspacePath -Filter "*.html" -File

$filesModified = @()
$totalModifications = 0

foreach ($file in $htmlFiles) {
    $filePath = $file.FullName
    $content = Get-Content -Path $filePath -Raw
    $originalContent = $content
    $changes = @()
    
    Write-Host "Analizando: $($file.Name)" -ForegroundColor Cyan
    
    # 1. Eliminar Linkvertise completamente
    if ($content -match "linkvertise") {
        $content = $content -replace '<!-- Linkvertise Integration -->', ''
        $content = $content -replace '<script src="https://publisher\.linkvertise\.com/cdn/linkvertise\.js"></script>', ''
        $content = $content -replace '<script>linkvertise\([^)]*\);</script>', ''
        $changes += "Linkvertise"
    }
    
    # 2. Eliminar Google AdSense scripts
    if ($content -match "pagead2\.googlesyndication\.com") {
        $content = $content -replace '<script async src="https://pagead2\.googlesyndication\.com[^>]*></script>', ''
        $changes += "Google AdSense Scripts"
    }
    
    # 3. Eliminar elementos adsbygoogle
    if ($content -match "adsbygoogle") {
        $content = $content -replace '<ins class="adsbygoogle"[^>]*></ins>', ''
        $content = $content -replace '\(adsbygoogle = window\.adsbygoogle \|\| \[\]\)\.push\(\{\}\);', ''
        $changes += "AdSense Elements"
    }
    
    # 4. Eliminar redirecciones sospechosas simples
    $content = $content -replace 'window\.open\([^)]*ad[^)]*\)', ''
    $content = $content -replace 'location\.href.*ad.*', ''
    $content = $content -replace 'window\.location.*ad.*', ''
    
    # 5. Limpiar Content-Security-Policy
    $content = $content -replace 'https://pagead2\.googlesyndication\.com', ''
    $content = $content -replace 'https://publisher\.linkvertise\.com', ''
    
    # 6. Limpiar espacios en blanco extra
    $content = $content -replace '\n\s*\n\s*\n', "`n`n"
    $content = $content -replace '  +', ' '
    
    if ($content -ne $originalContent) {
        Set-Content -Path $filePath -Value $content -Encoding UTF8
        $filesModified += $file.Name
        $totalModifications++
        Write-Host "Limpiado: $($file.Name)" -ForegroundColor Green
        if ($changes.Count -gt 0) {
            Write-Host "  Elementos eliminados: $($changes -join ', ')" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Sin cambios: $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== RESUMEN DE LIMPIEZA ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $($htmlFiles.Count)" -ForegroundColor White
Write-Host "Archivos modificados: $totalModifications" -ForegroundColor Green

if ($filesModified.Count -gt 0) {
    Write-Host ""
    Write-Host "Archivos limpiados:" -ForegroundColor Green
    $filesModified | ForEach-Object { Write-Host "- $_" -ForegroundColor Green }
}

Write-Host ""
Write-Host "Limpieza completada!" -ForegroundColor Green
