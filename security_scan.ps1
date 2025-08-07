# Script simplificado para detectar redirecciones maliciosas
$workspacePath = '.'
$htmlFiles = Get-ChildItem -Path $workspacePath -Filter "*.html" -File

$suspiciousFound = @()

Write-Host "Buscando código malicioso en archivos HTML..." -ForegroundColor Yellow

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $found = @()
    
    Write-Host "Verificando: $($file.Name)" -ForegroundColor Cyan
    
    # Buscar redirecciones JavaScript
    if ($content -match 'window\.location\.replace') {
        $found += "window.location.replace detectado"
    }
    if ($content -match 'window\.location\.assign') {
        $found += "window.location.assign detectado"
    }
    if ($content -match 'document\.location') {
        $found += "document.location detectado"
    }
    if ($content -match 'setTimeout.*location') {
        $found += "setTimeout con location detectado"
    }
    if ($content -match 'setInterval.*location') {
        $found += "setInterval con location detectado"
    }
    
    # Buscar meta refresh
    if ($content -match '<meta.*refresh') {
        $found += "meta refresh detectado"
    }
    
    # Buscar eval o Function (código potencialmente malicioso)
    if ($content -match 'eval\s*\(') {
        $found += "eval() detectado"
    }
    if ($content -match 'Function\s*\(') {
        $found += "Function() detectado"
    }
    
    # Buscar dominios de redirección conocidos
    if ($content -match 'linkvertise\.com') {
        $found += "linkvertise.com detectado"
    }
    if ($content -match 'shorte\.st') {
        $found += "shorte.st detectado"
    }
    if ($content -match 'adf\.ly') {
        $found += "adf.ly detectado"
    }
    
    # Buscar window.open
    if ($content -match 'window\.open') {
        $found += "window.open detectado"
    }
    
    if ($found.Count -gt 0) {
        $suspiciousFound += @{
            File = $file.Name
            Issues = $found
        }
        Write-Host "  ⚠️ Problemas encontrados: $($found.Count)" -ForegroundColor Red
    } else {
        Write-Host "  ✅ Limpio" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== REPORTE DE SEGURIDAD ===" -ForegroundColor Cyan
Write-Host "Archivos verificados: $($htmlFiles.Count)" -ForegroundColor White
Write-Host "Archivos con problemas: $($suspiciousFound.Count)" -ForegroundColor Red

if ($suspiciousFound.Count -gt 0) {
    Write-Host ""
    Write-Host "ARCHIVOS CON CÓDIGO SOSPECHOSO:" -ForegroundColor Red
    foreach ($item in $suspiciousFound) {
        Write-Host "📁 $($item.File):" -ForegroundColor Yellow
        foreach ($issue in $item.Issues) {
            Write-Host "   - $issue" -ForegroundColor Red
        }
    }
} else {
    Write-Host ""
    Write-Host "✅ No se encontró código malicioso conocido" -ForegroundColor Green
}
