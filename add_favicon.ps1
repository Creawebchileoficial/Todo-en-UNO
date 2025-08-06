# Script para agregar favicon automaticamente a todos los archivos HTML
# Todo Universidad - Favicon Automation Script

Write-Host "Todo Universidad - Agregar Favicon Automaticamente" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Definir las lineas del favicon que queremos agregar
$faviconLines = @(
    '    <link rel="icon" type="image/x-icon" href="./assets/favicon_iotodo/favicon.ico">',
    '    <link rel="apple-touch-icon" sizes="180x180" href="./assets/favicon_iotodo/apple-touch-icon.png">',
    '    <link rel="icon" type="image/png" sizes="32x32" href="./assets/favicon_iotodo/favicon-32x32.png">',
    '    <link rel="icon" type="image/png" sizes="16x16" href="./assets/favicon_iotodo/favicon-16x16.png">'
)

# Obtener todos los archivos HTML en el directorio actual
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" | Where-Object { $_.Name -ne "index.html" }

Write-Host "Archivos HTML encontrados: $($htmlFiles.Count)" -ForegroundColor Green

$processedCount = 0
$skippedCount = 0

foreach ($file in $htmlFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor Yellow
    
    # Leer el contenido del archivo
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Verificar si ya tiene favicon
    if ($content -match 'rel="icon"' -or $content -match 'favicon') {
        Write-Host "   Ya tiene favicon - Omitiendo" -ForegroundColor Gray
        $skippedCount++
        continue
    }
    
    # Verificar si tiene estructura HTML valida
    if (-not ($content -match '<head>' -and $content -match '</head>')) {
        Write-Host "   No tiene estructura head valida - Omitiendo" -ForegroundColor Red
        $skippedCount++
        continue
    }
    
    # Buscar la posicion despues de head para insertar el favicon
    $headPattern = '(<head[^>]*>)'
    
    if ($content -match $headPattern) {
        # Encontrar donde insertar el favicon (despues de viewport si existe, o despues de charset)
        $insertPosition = '<head>'
        
        # Si tiene viewport, insertar despues
        if ($content -match '<meta name="viewport"[^>]*>') {
            $insertPosition = $matches[0]
        }
        # Si tiene charset, insertar despues
        elseif ($content -match '<meta charset[^>]*>') {
            $insertPosition = $matches[0]
        }
        # Si tiene title, insertar antes
        elseif ($content -match '<title[^>]*>') {
            $insertPosition = $matches[0]
            $insertBefore = $true
        }
        
        # Construir las lineas del favicon con saltos de linea apropiados
        $faviconBlock = "`n" + ($faviconLines -join "`n") + "`n"
        
        # Insertar el favicon
        if ($insertBefore) {
            $newContent = $content -replace [regex]::Escape($insertPosition), "$faviconBlock    $insertPosition"
        } else {
            $newContent = $content -replace [regex]::Escape($insertPosition), "$insertPosition$faviconBlock"
        }
        
        # Guardar el archivo
        try {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
            Write-Host "   Favicon agregado exitosamente" -ForegroundColor Green
            $processedCount++
        }
        catch {
            Write-Host "   Error al guardar: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "   No se pudo encontrar head - Omitiendo" -ForegroundColor Red
        $skippedCount++
    }
}

# Resumen final
Write-Host "Proceso completado!" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Archivos procesados: $processedCount" -ForegroundColor Green
Write-Host "Archivos omitidos: $skippedCount" -ForegroundColor Yellow
Write-Host "Total archivos HTML: $($htmlFiles.Count)" -ForegroundColor Cyan

if ($processedCount -gt 0) {
    Write-Host "El favicon se ha agregado automaticamente a todos los archivos HTML." -ForegroundColor Green
    Write-Host "Favicon utilizado: ./assets/favicon_iotodo/favicon.ico" -ForegroundColor Cyan
}

Write-Host "Todo listo! Tu sitio web ahora tiene favicon en todas las paginas." -ForegroundColor Green
