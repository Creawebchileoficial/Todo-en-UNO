# Script de verificacion - Comprobar que todos los archivos HTML tienen favicon
# Todo Universidad - Favicon Verification Script

Write-Host "Todo Universidad - Verificacion de Favicon" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Obtener todos los archivos HTML
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html"

Write-Host "Verificando $($htmlFiles.Count) archivos HTML..." -ForegroundColor Green
Write-Host ""

$withFavicon = 0
$withoutFavicon = 0

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    if ($content -match 'rel="icon"') {
        Write-Host "[OK] $($file.Name)" -ForegroundColor Green
        $withFavicon++
    } else {
        Write-Host "[NO] $($file.Name)" -ForegroundColor Red
        $withoutFavicon++
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Archivos CON favicon: $withFavicon" -ForegroundColor Green
Write-Host "Archivos SIN favicon: $withoutFavicon" -ForegroundColor Red

if ($withoutFavicon -eq 0) {
    Write-Host ""
    Write-Host "EXCELENTE! Todos los archivos HTML tienen favicon configurado." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Algunos archivos necesitan favicon. Ejecuta add_favicon.ps1 nuevamente." -ForegroundColor Yellow
}
