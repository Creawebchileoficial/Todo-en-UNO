# Script mejorado para añadir Linkvertise a todas las páginas HTML
# Ejecutar este script en el directorio raíz del proyecto

$directory = "c:\Users\benja\OneDrive\Escritorio\todo universidad\Todo-en-UNO"
$htmlFiles = Get-ChildItem -Path $directory -Filter "*.html" -File

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Comprobar si el script ya está presente
    if ($content -match "linkvertise\(1246134") {
        Write-Host "El script Linkvertise ya está presente en $($file.Name). Omitiendo..."
        continue
    }
    
    # Preparar el script a insertar
    $linkvertiseScript = "`n    <!-- Linkvertise Integration -->`n    <script src=`"https://publisher.linkvertise.com/cdn/linkvertise.js`"></script>`n    <script>linkvertise(1246134, {whitelist: [], blacklist: [``]});</script>"
    
    # Intentar añadir el script antes de </head> o después de la última etiqueta <meta> o <link>
    if ($content -match "</head>") {
        # Insertar el script antes del cierre de head
        $content = $content -replace "</head>", "$linkvertiseScript`n</head>"
    } 
    elseif ($content -match "(<meta[^>]*>|<link[^>]*>)(?![\s\S]*<meta[^>]*>|<link[^>]*>)") {
        # Si no hay </head>, insertar después de la última etiqueta meta o link
        $content = $content -replace "(<meta[^>]*>|<link[^>]*>)(?![\s\S]*<meta[^>]*>|<link[^>]*>)", "`$1$linkvertiseScript"
    }
    elseif ($content -match "<head[^>]*>") {
        # Si hay apertura de head pero no cierre, insertar después de la apertura
        $content = $content -replace "<head[^>]*>", "<head>`n$linkvertiseScript"
    }
    else {
        # Si no hay nada de lo anterior, insertar después de <!DOCTYPE html>
        $content = $content -replace "<!DOCTYPE html>", "<!DOCTYPE html>`n$linkvertiseScript"
    }
    
    # Si existe una política de seguridad de contenido, actualizarla
    if ($content -match 'Content-Security-Policy') {
        # Verificar si ya tiene script-src
        if ($content -match 'script-src\s+[^;]*') {
            # Si no incluye ya publisher.linkvertise.com, añadirlo
            if (-not ($content -match 'script-src[^;]*https://publisher\.linkvertise\.com')) {
                $content = $content -replace '(script-src\s+[^;]*)', '$1 https://publisher.linkvertise.com'
            }
        } else {
            # Si no tiene script-src, añadirlo
            $content = $content -replace '(Content-Security-Policy[^"]+")', '$1 script-src ''self'' ''unsafe-inline'' https://publisher.linkvertise.com;'
        }
    }
    
    # Guardar el archivo modificado
    Set-Content -Path $file.FullName -Value $content
    Write-Host "Se ha añadido el script Linkvertise a $($file.Name)"
}

Write-Host "Proceso completado. Se ha añadido el script Linkvertise a todas las páginas HTML disponibles."
