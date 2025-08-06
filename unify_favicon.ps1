# Script para unificar favicon en todos los archivos HTML
# Todo Universidad - Favicon Unification Script
# Version 1.2.0 - Agosto 2025

$appVersion = "1.2.0"
$buildDate = Get-Date -Format "dd/MM/yyyy HH:mm"

Write-Host "Todo Universidad - Unificar Favicon v$appVersion" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "Build: $buildDate" -ForegroundColor Gray

# Configuracion del favicon correcto (como en index.html)
$correctFaviconLines = @(
    '    <link rel="icon" type="image/x-icon" href="./assets/favicon_iotodo/favicon.ico">',
    '    <link rel="apple-touch-icon" sizes="180x180" href="./assets/favicon_iotodo/apple-touch-icon.png">',
    '    <link rel="icon" type="image/png" sizes="32x32" href="./assets/favicon_iotodo/favicon-32x32.png">',
    '    <link rel="icon" type="image/png" sizes="16x16" href="./assets/favicon_iotodo/favicon-16x16.png">'
)

# Patrones de favicon incorrectos a reemplazar
$incorrectPatterns = @(
    'href="assets/favicon\.ico"',
    'href="\.\/assets\/favicon\.ico"',
    '<link rel="icon"[^>]*href="(?!\.\/assets\/favicon_iotodo\/)[^"]*"[^>]*>',
    '<link rel="apple-touch-icon"[^>]*href="(?!\.\/assets\/favicon_iotodo\/)[^"]*"[^>]*>'
)

# Obtener todos los archivos HTML
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html"
Write-Host "Procesando $($htmlFiles.Count) archivos HTML..." -ForegroundColor Green
Write-Host ""

$processedCount = 0
$unchangedCount = 0

foreach ($file in $htmlFiles) {
    Write-Host "Procesando: $($file.Name)" -ForegroundColor Yellow
    
    # Leer contenido
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $changed = $false
    
    # Verificar si ya tiene la configuracion correcta
    if ($content -match 'href="\.\/assets\/favicon_iotodo\/favicon\.ico"' -and
        $content -match 'href="\.\/assets\/favicon_iotodo\/apple-touch-icon\.png"' -and
        $content -match 'href="\.\/assets\/favicon_iotodo\/favicon-32x32\.png"' -and
        $content -match 'href="\.\/assets\/favicon_iotodo\/favicon-16x16\.png"') {
        
        # Para index.html, verificar y actualizar la version visible
        if ($file.Name -eq "index.html") {
            $versionUpdated = $false
            
            # Actualizar version en meta tag
            if ($content -match '<meta name="version" content="[^"]*">') {
                $content = $content -replace '<meta name="version" content="[^"]*">', "<meta name=`"version`" content=`"$appVersion`">"
                $versionUpdated = $true
            }
            
            # Actualizar build date en meta tag
            if ($content -match '<meta name="build-date" content="[^"]*">') {
                $content = $content -replace '<meta name="build-date" content="[^"]*">', "<meta name=`"build-date`" content=`"$(Get-Date -Format 'dd/MM/yyyy')`">"
                $versionUpdated = $true
            }
            
            # Actualizar version visible en footer
            if ($content -match '<span style="color: #64748b;">Versión [^<]*</span>') {
                $content = $content -replace '<span style="color: #64748b;">Versión [^<]*</span>', "<span style=`"color: #64748b;`">Versión $appVersion</span>"
                $versionUpdated = $true
            }
            
            # Actualizar build date visible en footer
            if ($content -match '<span style="color: #64748b;">Build: [^<]*</span>') {
                $content = $content -replace '<span style="color: #64748b;">Build: [^<]*</span>', "<span style=`"color: #64748b;`">Build: $(Get-Date -Format 'dd/MM/yyyy')</span>"
                $versionUpdated = $true
            }
            
            if ($versionUpdated -and ($content -ne $originalContent)) {
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8
                Write-Host "   Ya tiene configuracion correcta - Version actualizada" -ForegroundColor Green
                $processedCount++
                continue
            }
        }
        
        Write-Host "   Ya tiene configuracion correcta - Omitiendo" -ForegroundColor Green
        $unchangedCount++
        continue
    }
    
    # Eliminar todas las lineas de favicon existentes
    $content = $content -replace '<link rel="icon"[^>]*>', ''
    $content = $content -replace '<link rel="apple-touch-icon"[^>]*>', ''
    $content = $content -replace '<link rel="shortcut icon"[^>]*>', ''
    
    # Limpiar lineas vacias adicionales
    $content = $content -replace '(\r?\n\s*){3,}', "`n`n"
    
    # Encontrar donde insertar el nuevo favicon (despues de viewport o charset)
    $insertAfter = $null
    
    if ($content -match '<meta name="viewport"[^>]*>') {
        $insertAfter = $matches[0]
    } elseif ($content -match '<meta charset[^>]*>') {
        $insertAfter = $matches[0]
    } elseif ($content -match '<head[^>]*>') {
        $insertAfter = $matches[0]
    }
    
    if ($insertAfter) {
        # Construir bloque de favicon
        $faviconBlock = "`n" + ($correctFaviconLines -join "`n")
        
        # Insertar el favicon
        $content = $content -replace [regex]::Escape($insertAfter), "$insertAfter$faviconBlock"
        
        # Guardar solo si hay cambios
        if ($content -ne $originalContent) {
            try {
                Set-Content -Path $file.FullName -Value $content -Encoding UTF8
                Write-Host "   Favicon actualizado exitosamente" -ForegroundColor Green
                $processedCount++
                $changed = $true
            }
            catch {
                Write-Host "   Error al guardar: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "   No se encontro estructura head valida" -ForegroundColor Red
    }
    
    if (-not $changed) {
        $unchangedCount++
    }
}

Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "Proceso completado! v$appVersion" -ForegroundColor Cyan
Write-Host "Archivos actualizados: $processedCount" -ForegroundColor Green
Write-Host "Archivos sin cambios: $unchangedCount" -ForegroundColor Yellow
Write-Host "Total archivos: $($htmlFiles.Count)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuracion de favicon unificada:" -ForegroundColor Green
Write-Host "- favicon.ico: ./assets/favicon_iotodo/favicon.ico" -ForegroundColor Cyan
Write-Host "- apple-touch-icon: ./assets/favicon_iotodo/apple-touch-icon.png" -ForegroundColor Cyan
Write-Host "- favicon-32x32: ./assets/favicon_iotodo/favicon-32x32.png" -ForegroundColor Cyan
Write-Host "- favicon-16x16: ./assets/favicon_iotodo/favicon-16x16.png" -ForegroundColor Cyan
Write-Host ""
Write-Host "Todos los archivos HTML ahora usan el mismo favicon!" -ForegroundColor Green
Write-Host "Todo Universidad v$appVersion - $(Get-Date -Format 'dd/MM/yyyy')" -ForegroundColor Cyan
