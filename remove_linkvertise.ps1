# Script para eliminar todas las referencias a Linkvertise de los archivos HTML
$workspacePath = '.'
$htmlFiles = Get-ChildItem -Path $workspacePath -Filter "*.html" -File

$filesModified = @()
$totalModifications = 0

foreach ($file in $htmlFiles) {
    $filePath = $file.FullName
    $content = Get-Content -Path $filePath -Raw
    $originalContent = $content
    
    Write-Host "Procesando: $($file.Name)"
    
    # Eliminar comentarios de Linkvertise
    $content = $content -replace '\s*<!-- Linkvertise Integration -->\s*', ''
    
    # Eliminar script de Linkvertise
    $content = $content -replace '\s*<script src="https://publisher\.linkvertise\.com/cdn/linkvertise\.js"></script>\s*', ''
    
    # Eliminar llamadas a linkvertise()
    $content = $content -replace '\s*<script>linkvertise\(.*?\);</script>\s*', ''
    
    # Eliminar referencias a linkvertise en Content-Security-Policy
    $content = $content -replace '\s*https://publisher\.linkvertise\.com\s*', ''
    $content = $content -replace 'script-src\s+([^"]*?)\s*;\s*', 'script-src $1; '
    
    # Limpiar espacios en blanco extra que puedan quedar
    $content = $content -replace '\n\s*\n\s*\n', "`n`n"
    
    if ($content -ne $originalContent) {
        Set-Content -Path $filePath -Value $content -Encoding UTF8
        $filesModified += $file.Name
        $totalModifications++
        Write-Host "Linkvertise eliminado de: $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "No se encontro Linkvertise en: $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $($htmlFiles.Count)" -ForegroundColor White
Write-Host "Archivos modificados: $totalModifications" -ForegroundColor Green

if ($filesModified.Count -gt 0) {
    Write-Host ""
    Write-Host "Archivos donde se elimino Linkvertise:" -ForegroundColor Green
    $filesModified | ForEach-Object { Write-Host "- $_" -ForegroundColor Green }
}

Write-Host ""
Write-Host "Linkvertise ha sido eliminado completamente!" -ForegroundColor Green
