# Script para verificar si Linkvertise está presente en los archivos HTML
# Ejecutar este script en el directorio raíz del proyecto

$directory = "c:\Users\benja\OneDrive\Escritorio\todo universidad\Todo-en-UNO"
$htmlFiles = Get-ChildItem -Path $directory -Filter "*.html" -File

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Comprobar si el script ya está presente
    if ($content -match "linkvertise") {
        Write-Host "Linkvertise ESTÁ presente en $($file.Name)"
    } else {
        Write-Host "Linkvertise NO está presente en $($file.Name)"
    }
}

Write-Host "Verificación completada."
