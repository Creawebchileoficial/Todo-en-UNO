# Script de verificacion completa del favicon
# Todo Universidad - Final Favicon Verification

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  TODO UNIVERSIDAD" -ForegroundColor White
Write-Host "  VERIFICACION COMPLETA FAVICON" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar que la carpeta de favicon existe
$faviconFolder = "C:\Users\benja\OneDrive\Escritorio\todo uni\assets\favicon_iotodo"
Write-Host "1. Verificando carpeta de favicon..." -ForegroundColor Yellow

if (Test-Path $faviconFolder) {
    Write-Host "   Carpeta favicon_iotodo: EXISTE" -ForegroundColor Green
    
    # Verificar archivos individuales
    $requiredFiles = @(
        "favicon.ico",
        "apple-touch-icon.png", 
        "favicon-16x16.png",
        "favicon-32x32.png",
        "android-chrome-192x192.png",
        "android-chrome-512x512.png"
    )
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $faviconFolder $file
        if (Test-Path $filePath) {
            Write-Host "   ${file}: EXISTE" -ForegroundColor Green
        } else {
            Write-Host "   ${file}: FALTA" -ForegroundColor Red
            $missingFiles += $file
        }
    }
} else {
    Write-Host "   ERROR: Carpeta favicon_iotodo NO EXISTE" -ForegroundColor Red
}

Write-Host ""

# 2. Verificar configuracion en archivos HTML
Write-Host "2. Verificando configuracion en archivos HTML..." -ForegroundColor Yellow

$htmlFiles = Get-ChildItem -Path "." -Filter "*.html"
$correctFiles = 0
$totalFiles = $htmlFiles.Count

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Verificar que tiene las 4 lineas correctas del favicon
    $hasCorrectFavicon = (
        ($content -match 'href="\.\/assets\/favicon_iotodo\/favicon\.ico"') -and
        ($content -match 'href="\.\/assets\/favicon_iotodo\/apple-touch-icon\.png"') -and
        ($content -match 'href="\.\/assets\/favicon_iotodo\/favicon-32x32\.png"') -and
        ($content -match 'href="\.\/assets\/favicon_iotodo\/favicon-16x16\.png"')
    )
    
    if ($hasCorrectFavicon) {
        $correctFiles++
    }
}

Write-Host "   Archivos con favicon correcto: $correctFiles de $totalFiles" -ForegroundColor Green

# 3. Resumen final
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "RESUMEN FINAL:" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan

if ($correctFiles -eq $totalFiles -and $missingFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "EXCELENTE! TODO ESTA PERFECTO" -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuracion unificada exitosa:" -ForegroundColor Green
    Write-Host "- Todos los $totalFiles archivos HTML usan el mismo favicon" -ForegroundColor Cyan
    Write-Host "- Ruta unificada: ./assets/favicon_iotodo/" -ForegroundColor Cyan
    Write-Host "- Incluye: favicon.ico, apple-touch-icon.png, favicon-32x32.png, favicon-16x16.png" -ForegroundColor Cyan
    Write-Host "- Compatible con: Chrome, Firefox, Safari, Edge, iOS, Android" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tu sitio web Todo Universidad ahora tiene:" -ForegroundColor Green
    Write-Host "- Favicon consistente en todas las paginas" -ForegroundColor White
    Write-Host "- Soporte completo para dispositivos moviles" -ForegroundColor White  
    Write-Host "- Branding profesional unificado" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "ATENCION: Se encontraron problemas" -ForegroundColor Red
    if ($correctFiles -ne $totalFiles) {
        Write-Host "- $($totalFiles - $correctFiles) archivos HTML tienen favicon incorrecto" -ForegroundColor Red
    }
    if ($missingFiles.Count -gt 0) {
        Write-Host "- Faltan archivos de favicon: $($missingFiles -join ', ')" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Ejecuta unify_favicon.ps1 nuevamente para corregir." -ForegroundColor Yellow
}

Write-Host "================================" -ForegroundColor Cyan
