# Script para añadir Linkvertise a todas las páginas HTML
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
    $linkvertiseScript = "`n    <!-- Linkvertise Integration -->`n    <script src=`"https://publisher.linkvertise.com/cdn/linkvertise.js`"></script>`n    <script>linkvertise(1246134, {whitelist: [], blacklist: [``]});</script>`n"
    
    # Buscar el final de la sección head
    if ($content -match "</head>") {
        # Insertar el script antes del cierre de head
        $content = $content -replace "</head>", "$linkvertiseScript</head>"
        
        # Si existe una política de seguridad de contenido, actualizarla
        if ($content -match 'Content-Security-Policy') {
            $content = $content -replace '(Content-Security-Policy.*?script-src\s+[^;]*)', '$1 https://publisher.linkvertise.com'
        }
        
        # Guardar el archivo modificado
        Set-Content -Path $file.FullName -Value $content
        Write-Host "Se ha añadido el script Linkvertise a $($file.Name)"
    } else {
        Write-Host "No se pudo encontrar la etiqueta </head> en $($file.Name). Omitiendo..."
    }
}

Write-Host "Proceso completado. Se ha añadido el script Linkvertise a todas las páginas HTML disponibles."
