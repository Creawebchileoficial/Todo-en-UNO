# Todo Universidad - Version Manager
# Gestor de versiones de la aplicacion

$currentVersion = "1.2.0"
$currentDate = Get-Date -Format "dd/MM/yyyy"
$buildTime = Get-Date -Format "HH:mm:ss"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  TODO UNIVERSIDAD" -ForegroundColor White
Write-Host "  VERSION MANAGER" -ForegroundColor White  
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Version actual: $currentVersion" -ForegroundColor Green
Write-Host "Fecha: $currentDate" -ForegroundColor Cyan
Write-Host "Build: $buildTime" -ForegroundColor Gray
Write-Host ""

# Mostrar changelog
Write-Host "CHANGELOG:" -ForegroundColor Yellow
Write-Host "==========" -ForegroundColor Yellow
Write-Host ""

Write-Host "v1.2.0 - 06/08/2025" -ForegroundColor White
Write-Host "- Favicon unificado en todos los archivos HTML" -ForegroundColor Green
Write-Host "- PWA completamente funcional" -ForegroundColor Green  
Write-Host "- Herramientas reorganizadas" -ForegroundColor Green
Write-Host "- Lectura.html mejorado con cronometro" -ForegroundColor Green
Write-Host "- Integracion con servicios externos (BibGuru, UniTools)" -ForegroundColor Green
Write-Host ""

Write-Host "v1.1.0 - 05/08/2025" -ForegroundColor White
Write-Host "- Implementacion de PWA" -ForegroundColor Cyan
Write-Host "- Service Worker agregado" -ForegroundColor Cyan
Write-Host "- Soporte para instalacion en dispositivos" -ForegroundColor Cyan
Write-Host ""

Write-Host "v1.0.0 - 01/08/2025" -ForegroundColor White
Write-Host "- Lanzamiento inicial" -ForegroundColor Gray
Write-Host "- 30+ herramientas academicas" -ForegroundColor Gray
Write-Host "- Diseno responsive" -ForegroundColor Gray
Write-Host ""

# Verificar archivos de version
Write-Host "VERIFICACION DE VERSION:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow

# Verificar manifest
$manifestPath = "./assets/favicon_iotodo/site.webmanifest"
if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    if ($manifestContent -match '"version":\s*"([^"]*)"') {
        $manifestVersion = $matches[1]
        if ($manifestVersion -eq $currentVersion) {
            Write-Host "Manifest: v$manifestVersion (OK)" -ForegroundColor Green
        } else {
            Write-Host "Manifest: v$manifestVersion (DESACTUALIZADO)" -ForegroundColor Red
        }
    } else {
        Write-Host "Manifest: Sin version (FALTA)" -ForegroundColor Red
    }
} else {
    Write-Host "Manifest: NO ENCONTRADO" -ForegroundColor Red
}

# Verificar index.html para meta tag de version
$indexPath = "./index.html"
if (Test-Path $indexPath) {
    $indexContent = Get-Content $indexPath -Raw
    if ($indexContent -match '<meta name="version" content="([^"]*)"') {
        $indexVersion = $matches[1]
        if ($indexVersion -eq $currentVersion) {
            Write-Host "Index.html: v$indexVersion (OK)" -ForegroundColor Green
        } else {
            Write-Host "Index.html: v$indexVersion (DESACTUALIZADO)" -ForegroundColor Red
        }
    } else {
        Write-Host "Index.html: Sin meta version (AGREGAR)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Index.html: NO ENCONTRADO" -ForegroundColor Red
}

Write-Host ""
Write-Host "ESTADISTICAS:" -ForegroundColor Yellow
Write-Host "=============" -ForegroundColor Yellow

# Contar archivos HTML
$htmlCount = (Get-ChildItem -Path "." -Filter "*.html").Count
Write-Host "Archivos HTML: $htmlCount" -ForegroundColor Cyan

# Contar herramientas (archivos HTML menos index y 404)
$toolsCount = $htmlCount - 2
Write-Host "Herramientas disponibles: $toolsCount" -ForegroundColor Cyan

# Verificar PWA
$swExists = Test-Path "./sw.js"
$manifestExists = Test-Path $manifestPath
if ($swExists -and $manifestExists) {
    Write-Host "PWA: HABILITADA" -ForegroundColor Green
} else {
    Write-Host "PWA: DESHABILITADA" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Todo Universidad v$currentVersion" -ForegroundColor White
Write-Host "Build: $currentDate $buildTime" -ForegroundColor Gray
Write-Host "================================" -ForegroundColor Cyan
