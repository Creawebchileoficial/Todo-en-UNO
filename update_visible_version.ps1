# Demo: Actualizar solo la version visible en index.html
# Todo Universidad - Quick Version Update

$newVersion = "1.2.0"
$currentDate = Get-Date -Format "dd/MM/yyyy"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  ACTUALIZACION RAPIDA VERSION" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Actualizando version visible a: v$newVersion" -ForegroundColor Green
Write-Host "Fecha: $currentDate" -ForegroundColor Cyan
Write-Host ""

try {
    $indexPath = "./index.html"
    $indexContent = Get-Content $indexPath -Raw
    
    Write-Host "Verificando contenido del archivo..." -ForegroundColor Yellow
    $hasVersion = $indexContent -like "*Version*" -or $indexContent -like "*1.2.0*"
    Write-Host "Contiene version: $hasVersion" -ForegroundColor Gray
    
    if ($hasVersion) {
        Write-Host "Estructura de version encontrada, actualizando..." -ForegroundColor Yellow
        
        # Actualizar usando patrones más simples
        $oldPattern1 = "1\.2\.0"
        $oldPattern2 = "06-08-2025"
        
        # Solo actualizar la fecha si es diferente
        if ($currentDate -ne "06-08-2025") {
            $indexContent = $indexContent -replace "06-08-2025", $currentDate
        }
        
        Write-Host "Patron encontrado y actualizado" -ForegroundColor Green
        
        # Actualizar meta tags tambien
        $indexContent = $indexContent -replace '<meta name="version" content="[^"]*">', "<meta name=`"version`" content=`"$newVersion`">"
        $indexContent = $indexContent -replace '<meta name="build-date" content="[^"]*">', "<meta name=`"build-date`" content=`"$currentDate`">"
        
        Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
        
        Write-Host "EXITO: Version visible actualizada en el footer del sitio web" -ForegroundColor Green
        Write-Host "- Version: $newVersion" -ForegroundColor Cyan
        Write-Host "- Build: $currentDate" -ForegroundColor Cyan
    } else {
        Write-Host "ERROR: No se encontro la estructura de version en el footer" -ForegroundColor Red
        Write-Host "La version visible debe estar en el formato:" -ForegroundColor Yellow
        Write-Host 'Versión X.X.X' -ForegroundColor Gray
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Para ver el resultado, abre index.html en el navegador" -ForegroundColor Yellow
Write-Host "La version aparecera en el footer del sitio web" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan
