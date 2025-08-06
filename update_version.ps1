# Todo Universidad - Update Version Script
# Script para actualizar version en todos los archivos

param(
    [Parameter(Mandatory=$true)]
    [string]$NewVersion,
    [string]$ReleaseNotes = ""
)

$currentDate = Get-Date -Format "dd/MM/yyyy"
$buildTime = Get-Date -Format "HH:mm:ss"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  TODO UNIVERSIDAD" -ForegroundColor White
Write-Host "  UPDATE VERSION" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Actualizando a version: $NewVersion" -ForegroundColor Green
Write-Host "Fecha: $currentDate" -ForegroundColor Cyan
Write-Host "Build: $buildTime" -ForegroundColor Gray
Write-Host ""

$updatedFiles = 0
$errors = 0

# 1. Actualizar index.html
Write-Host "1. Actualizando index.html..." -ForegroundColor Yellow
try {
    $indexPath = "./index.html"
    $indexContent = Get-Content $indexPath -Raw
    
    # Actualizar version en meta tags
    $indexContent = $indexContent -replace '<meta name="version" content="[^"]*">', "<meta name=`"version`" content=`"$NewVersion`">"
    $indexContent = $indexContent -replace '<meta name="build-date" content="[^"]*">', "<meta name=`"build-date`" content=`"$currentDate`">"
    
    # Actualizar version visible en footer
    $indexContent = $indexContent -replace '<span style="color: #64748b;">Versión [^<]*</span>', "<span style=`"color: #64748b;`">Versión $NewVersion</span>"
    $indexContent = $indexContent -replace '<span style="color: #64748b;">Build: [^<]*</span>', "<span style=`"color: #64748b;`">Build: $currentDate</span>"
    
    Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
    Write-Host "   index.html actualizado (meta tags y version visible)" -ForegroundColor Green
    $updatedFiles++
}
catch {
    Write-Host "   Error en index.html: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# 2. Actualizar manifest
Write-Host "2. Actualizando site.webmanifest..." -ForegroundColor Yellow
try {
    $manifestPath = "./assets/favicon_iotodo/site.webmanifest"
    $manifestContent = Get-Content $manifestPath -Raw
    
    # Actualizar version en manifest
    $manifestContent = $manifestContent -replace '"version":\s*"[^"]*"', "`"version`": `"$NewVersion`""
    $manifestContent = $manifestContent -replace '"version_name":\s*"[^"]*"', "`"version_name`": `"$NewVersion - $(Get-Date -Format 'MMMM yyyy')`""
    
    Set-Content -Path $manifestPath -Value $manifestContent -Encoding UTF8
    Write-Host "   site.webmanifest actualizado" -ForegroundColor Green
    $updatedFiles++
}
catch {
    Write-Host "   Error en site.webmanifest: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# 3. Actualizar Service Worker
Write-Host "3. Actualizando sw.js..." -ForegroundColor Yellow
try {
    $swPath = "./sw.js"
    $swContent = Get-Content $swPath -Raw
    
    # Actualizar version en SW
    $swContent = $swContent -replace 'const APP_VERSION = ''[^'']*'';', "const APP_VERSION = '$NewVersion';"
    $swContent = $swContent -replace '// Build: [^\r\n]*', "// Build: $currentDate"
    $swContent = $swContent -replace '// Todo Universidad Service Worker v[^\r\n]*', "// Todo Universidad Service Worker v$NewVersion"
    
    Set-Content -Path $swPath -Value $swContent -Encoding UTF8
    Write-Host "   sw.js actualizado" -ForegroundColor Green
    $updatedFiles++
}
catch {
    Write-Host "   Error en sw.js: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# 4. Actualizar scripts de version
Write-Host "4. Actualizando version_info.ps1..." -ForegroundColor Yellow
try {
    $versionScriptPath = "./version_info.ps1"
    if (Test-Path $versionScriptPath) {
        $versionContent = Get-Content $versionScriptPath -Raw
        $versionContent = $versionContent -replace '\$currentVersion = "[^"]*"', "`$currentVersion = `"$NewVersion`""
        
        Set-Content -Path $versionScriptPath -Value $versionContent -Encoding UTF8
        Write-Host "   version_info.ps1 actualizado" -ForegroundColor Green
        $updatedFiles++
    } else {
        Write-Host "   version_info.ps1 no encontrado" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "   Error en version_info.ps1: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# 5. Actualizar unify_favicon.ps1
Write-Host "5. Actualizando unify_favicon.ps1..." -ForegroundColor Yellow
try {
    $faviconScriptPath = "./unify_favicon.ps1"
    if (Test-Path $faviconScriptPath) {
        $faviconContent = Get-Content $faviconScriptPath -Raw
        $faviconContent = $faviconContent -replace '\$appVersion = "[^"]*"', "`$appVersion = `"$NewVersion`""
        $faviconContent = $faviconContent -replace '# Version [^\r\n]*', "# Version $NewVersion - $(Get-Date -Format 'MMMM yyyy')"
        
        Set-Content -Path $faviconScriptPath -Value $faviconContent -Encoding UTF8
        Write-Host "   unify_favicon.ps1 actualizado" -ForegroundColor Green
        $updatedFiles++
    } else {
        Write-Host "   unify_favicon.ps1 no encontrado" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "   Error en unify_favicon.ps1: $($_.Exception.Message)" -ForegroundColor Red
    $errors++
}

# 6. Crear entry de changelog si se proporcionaron notas
if ($ReleaseNotes -ne "") {
    Write-Host "6. Creando entrada de changelog..." -ForegroundColor Yellow
    try {
        $changelogEntry = @"

v$NewVersion - $currentDate
$ReleaseNotes

"@
        $changelogPath = "./CHANGELOG.md"
        if (Test-Path $changelogPath) {
            $existingChangelog = Get-Content $changelogPath -Raw
            $newChangelog = "# Changelog`n$changelogEntry`n$existingChangelog"
        } else {
            $newChangelog = "# Changelog`n$changelogEntry"
        }
        
        Set-Content -Path $changelogPath -Value $newChangelog -Encoding UTF8
        Write-Host "   CHANGELOG.md actualizado" -ForegroundColor Green
        $updatedFiles++
    }
    catch {
        Write-Host "   Error en CHANGELOG.md: $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "ACTUALIZACION COMPLETADA" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Archivos actualizados: $updatedFiles" -ForegroundColor Green
Write-Host "Errores: $errors" -ForegroundColor $(if($errors -eq 0) {"Green"} else {"Red"})
Write-Host ""

if ($errors -eq 0) {
    Write-Host "VERSION $NewVersion APLICADA EXITOSAMENTE" -ForegroundColor Green
    Write-Host "Build: $currentDate $buildTime" -ForegroundColor Cyan
} else {
    Write-Host "ATENCION: Se encontraron $errors errores" -ForegroundColor Red
}

Write-Host ""
Write-Host "Para verificar los cambios, ejecuta: .\version_info.ps1" -ForegroundColor Yellow
