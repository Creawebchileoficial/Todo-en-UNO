# Script avanzado para eliminar TODOS los anuncios y redirecciones publicitarias
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
    if ($content -match "linkvertise|Linkvertise") {
        $content = $content -replace '\s*<!-- Linkvertise Integration -->\s*', ''
        $content = $content -replace '\s*<script src="https://publisher\.linkvertise\.com/cdn/linkvertise\.js"></script>\s*', ''
        $content = $content -replace '\s*<script>linkvertise\(.*?\);</script>\s*', ''
        $changes += "Linkvertise"
    }
    
    # 2. Eliminar Google AdSense
    if ($content -match "pagead2\.googlesyndication\.com|adsbygoogle") {
        $content = $content -replace '\s*<script async src="https://pagead2\.googlesyndication\.com/pagead/js/adsbygoogle\.js\?client=ca-pub-[0-9]+"[^>]*></script>\s*', ''
        $content = $content -replace '\s*<ins class="adsbygoogle"[^>]*></ins>\s*', ''
        $content = $content -replace '\s*<script>\s*\(adsbygoogle\s*=\s*window\.adsbygoogle\s*\|\|\s*\[\]\)\.push\(\{\}\);\s*</script>\s*', ''
        $changes += "Google AdSense"
    }
    
    # 3. Buscar y eliminar redirecciones con window.open que contengan 'ad'
    if ($content -match 'window\.open.*ad') {
        $content = $content -replace 'window\.open\([^)]*ad[^)]*\)', ''
        $changes += "Redirección window.open"
    }
    
    # 4. Eliminar redirecciones con location.href que contengan 'ad'
    if ($content -match 'location\.href.*ad') {
        $content = $content -replace 'location\.href\s*=\s*["\'][^"\']*ad[^"\']*["\']', ''
        $changes += "Redirección location.href"
    }
    
    # 5. Eliminar redirecciones con window.location que contengan 'ad'
    if ($content -match 'window\.location.*ad') {
        $content = $content -replace 'window\.location\s*=\s*["\'][^"\']*ad[^"\']*["\']', ''
        $changes += "Redirección window.location"
    }
    
    # 6. Eliminar event listeners de click sospechosos
    if ($content -match 'onclick.*(?:ad|link|redirect)') {
        $content = $content -replace 'onclick\s*=\s*["\'][^"\']*(?:ad|link|redirect)[^"\']*["\']', ''
        $changes += "Event listener sospechoso"
    }
    
    # 7. Eliminar scripts que contengan dominios de publicidad conocidos
    $adDomains = @(
        'doubleclick\.net',
        'googleadservices\.com',
        'googlesyndication\.com',
        'adsystem\.com',
        'amazon-adsystem\.com',
        'linkvertise\.com',
        'shorte\.st',
        'adf\.ly'
    )
    
    foreach ($domain in $adDomains) {
        if ($content -match $domain) {
            $content = $content -replace "<script[^>]*$domain[^>]*>.*?</script>", ''
            $content = $content -replace "<script[^>]*>.*?$domain.*?</script>", ''
            $changes += "Dominio publicitario: $domain"
        }
    }
    
    # 8. Limpiar referencias en Content-Security-Policy
    $content = $content -replace 'https://pagead2\.googlesyndication\.com\s*', ''
    $content = $content -replace 'https://publisher\.linkvertise\.com\s*', ''
    
    # 9. Limpiar espacios en blanco extra
    $content = $content -replace '\n\s*\n\s*\n', "`n`n"
    $content = $content -replace '\s+</head>', "`n</head>"
    $content = $content -replace '\s+</body>', "`n</body>"
    
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
Write-Host "Limpieza de anuncios completada!" -ForegroundColor Green
Write-Host "Si sigues viendo redirecciones, verifica el archivo sw.js" -ForegroundColor Yellow
