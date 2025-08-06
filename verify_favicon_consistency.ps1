# Script para verificar que todos los archivos HTML usan el mismo favicon
# Todo Universidad - Favicon Consistency Verification

Write-Host "Todo Universidad - Verificacion de Consistencia de Favicon" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# Rutas correctas esperadas
$expectedFaviconPath = "./assets/favicon_iotodo/favicon.ico"
$expectedAppleTouchPath = "./assets/favicon_iotodo/apple-touch-icon.png"
$expectedFavicon32Path = "./assets/favicon_iotodo/favicon-32x32.png"
$expectedFavicon16Path = "./assets/favicon_iotodo/favicon-16x16.png"

# Obtener todos los archivos HTML
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html"
Write-Host "Verificando consistencia en $($htmlFiles.Count) archivos HTML..." -ForegroundColor Green
Write-Host ""

$correctCount = 0
$incorrectCount = 0
$incorrectFiles = @()

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $isCorrect = $true
    $issues = @()
    
    # Verificar favicon principal
    if (-not ($content -match 'href="\.\/assets\/favicon_iotodo\/favicon\.ico"')) {
        $isCorrect = $false
        $issues += "favicon.ico incorrecto"
    }
    
    # Verificar apple-touch-icon
    if (-not ($content -match 'href="\.\/assets\/favicon_iotodo\/apple-touch-icon\.png"')) {
        $isCorrect = $false
        $issues += "apple-touch-icon incorrecto"
    }
    
    # Verificar favicon 32x32
    if (-not ($content -match 'href="\.\/assets\/favicon_iotodo\/favicon-32x32\.png"')) {
        $isCorrect = $false
        $issues += "favicon-32x32 incorrecto"
    }
    
    # Verificar favicon 16x16
    if (-not ($content -match 'href="\.\/assets\/favicon_iotodo\/favicon-16x16\.png"')) {
        $isCorrect = $false
        $issues += "favicon-16x16 incorrecto"
    }
    
    if ($isCorrect) {
        Write-Host "[OK] $($file.Name)" -ForegroundColor Green
        $correctCount++
    } else {
        Write-Host "[ERROR] $($file.Name) - $($issues -join ', ')" -ForegroundColor Red
        $incorrectCount++
        $incorrectFiles += $file.Name
    }
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE VERIFICACION:" -ForegroundColor Cyan
Write-Host "Archivos CORRECTOS: $correctCount" -ForegroundColor Green
Write-Host "Archivos INCORRECTOS: $incorrectCount" -ForegroundColor Red

if ($incorrectCount -eq 0) {
    Write-Host ""
    Write-Host "PERFECTO! Todos los archivos usan exactamente el mismo favicon:" -ForegroundColor Green
    Write-Host "- $expectedFaviconPath" -ForegroundColor Cyan
    Write-Host "- $expectedAppleTouchPath" -ForegroundColor Cyan
    Write-Host "- $expectedFavicon32Path" -ForegroundColor Cyan
    Write-Host "- $expectedFavicon16Path" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Archivos que necesitan correccion:" -ForegroundColor Yellow
    foreach ($fileName in $incorrectFiles) {
        Write-Host "- $fileName" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Ejecuta unify_favicon.ps1 para corregir estos archivos." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Ruta esperada del favicon: C:\Users\benja\OneDrive\Escritorio\todo uni\assets\favicon_iotodo" -ForegroundColor Cyan
