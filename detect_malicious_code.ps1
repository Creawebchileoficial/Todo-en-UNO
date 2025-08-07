# Script para detectar y eliminar cualquier código de redirección maliciosa
$workspacePath = '.'
$htmlFiles = Get-ChildItem -Path $workspacePath -Filter "*.html" -File

$suspiciousFound = @()
$totalChecked = 0

Write-Host "Buscando código malicioso en archivos HTML..." -ForegroundColor Yellow

foreach ($file in $htmlFiles) {
    $filePath = $file.FullName
    $content = Get-Content -Path $filePath -Raw
    $originalContent = $content
    $found = @()
    $totalChecked++
    
    # Buscar patrones específicos de redirección
    $suspiciousPatterns = @(
        'window\.location\.replace',
        'window\.location\.assign',
        'window\.location\.reload',
        'document\.location',
        'top\.location',
        'parent\.location',
        'setTimeout.*location',
        'setInterval.*location',
        'window\.open\s*\(',
        'document\.write.*location',
        'eval\s*\(',
        'Function\s*\(',
        'onclick\s*=\s*["\'].*location',
        'onload\s*=\s*["\'].*location',
        'http-equiv\s*=\s*["\']refresh["\']',
        '<meta.*refresh',
        'window\.history\.replaceState',
        'window\.history\.pushState'
    )
    
    # Buscar dominios de publicidad/redirección conocidos
    $adDomains = @(
        'linkvertise\.com',
        'shorte\.st',
        'adf\.ly',
        'bit\.ly',
        'tinyurl\.com',
        'ow\.ly',
        'goo\.gl',
        't\.co',
        'short\.link',
        'link\.ly',
        'rebrand\.ly',
        'cutt\.ly',
        'tiny\.cc'
    )
    
    Write-Host "Verificando: $($file.Name)" -ForegroundColor Cyan
    
    # Buscar patrones sospechosos
    foreach ($pattern in $suspiciousPatterns) {
        if ($content -match $pattern) {
            $found += "Patrón sospechoso: $pattern"
            Write-Host "  ⚠️ Encontrado: $pattern" -ForegroundColor Red
        }
    }
    
    # Buscar dominios de publicidad
    foreach ($domain in $adDomains) {
        if ($content -match $domain) {
            $found += "Dominio publicitario: $domain"
            Write-Host "  ⚠️ Dominio encontrado: $domain" -ForegroundColor Red
        }
    }
    
    # Buscar scripts externos sospechosos
    if ($content -match '<script[^>]*src=["\'][^"\']*(?:ad|ads|banner|popup|redirect)[^"\']*["\']') {
        $found += "Script externo sospechoso"
        Write-Host "  ⚠️ Script externo sospechoso encontrado" -ForegroundColor Red
    }
    
    # Buscar iframes ocultos
    if ($content -match '<iframe[^>]*(?:display\s*:\s*none|visibility\s*:\s*hidden|width\s*=\s*["\']0["\']|height\s*=\s*["\']0["\'])') {
        $found += "iframe oculto"
        Write-Host "  ⚠️ iframe oculto encontrado" -ForegroundColor Red
    }
    
    if ($found.Count -gt 0) {
        $suspiciousFound += @{
            File = $file.Name
            Issues = $found
        }
    } else {
        Write-Host "  ✅ Limpio" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== REPORTE DE SEGURIDAD ===" -ForegroundColor Cyan
Write-Host "Archivos verificados: $totalChecked" -ForegroundColor White
Write-Host "Archivos con problemas: $($suspiciousFound.Count)" -ForegroundColor $(if ($suspiciousFound.Count -gt 0) { 'Red' } else { 'Green' })

if ($suspiciousFound.Count -gt 0) {
    Write-Host ""
    Write-Host "ARCHIVOS CON CÓDIGO SOSPECHOSO:" -ForegroundColor Red
    foreach ($item in $suspiciousFound) {
        Write-Host "📁 $($item.File):" -ForegroundColor Yellow
        foreach ($issue in $item.Issues) {
            Write-Host "   - $issue" -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "⚠️ Se requiere revisión manual de estos archivos" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "✅ No se encontró código malicioso" -ForegroundColor Green
}

Write-Host ""
Write-Host "RECOMENDACIONES:" -ForegroundColor Cyan
Write-Host "1. Revisa manualmente los archivos marcados como sospechosos" -ForegroundColor White
Write-Host "2. Elimina cualquier código de redirección no deseado" -ForegroundColor White
Write-Host "3. Verifica que todos los enlaces vayan a las páginas correctas" -ForegroundColor White
Write-Host "4. Considera usar un Content Security Policy más estricto" -ForegroundColor White
