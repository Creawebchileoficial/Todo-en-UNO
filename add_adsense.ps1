$adSenseScript = '<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-1273212656995497" crossorigin="anonymous"></script>'
$workspacePath = 'c:\Users\benja\OneDrive\Escritorio\webs creadas\Todo-en-UNO'
$htmlFiles = Get-ChildItem -Path $workspacePath -Filter "*.html" -File

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Comprobar si el script de AdSense ya existe en el archivo
    if (-not $content.Contains($adSenseScript)) {
        # Buscar la etiqueta de cierre </head>
        if ($content -match "</head>") {
            # Insertar el script antes de </head>
            $newContent = $content -replace "</head>", "$adSenseScript`n</head>"
            
            # Actualizar el Content-Security-Policy si existe
            if ($content -match '<meta http-equiv="Content-Security-Policy" content="([^"]+)">') {
                $csp = $Matches[1]
                if (-not $csp.Contains("https://pagead2.googlesyndication.com")) {
                    $newCsp = $csp -replace "script-src ([^;]+);", "script-src `$1 https://pagead2.googlesyndication.com;"
                    $newContent = $newContent -replace '<meta http-equiv="Content-Security-Policy" content="([^"]+)">', "<meta http-equiv=`"Content-Security-Policy`" content=`"$newCsp`">"
                }
            }
            
            # Guardar el archivo modificado
            $newContent | Set-Content -Path $file.FullName -NoNewline
            Write-Host "Script de AdSense agregado a $($file.Name)"
        } else {
            Write-Host "No se encontró la etiqueta </head> en $($file.Name)"
        }
    } else {
        Write-Host "El script de AdSense ya existe en $($file.Name)"
    }
}

Write-Host "Proceso completado. Se procesaron $($htmlFiles.Count) archivos HTML."
