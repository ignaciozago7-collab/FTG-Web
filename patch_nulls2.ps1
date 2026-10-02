$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# Simpler regex to match the map function inner return
$html = [regex]::Replace($html, '<strong>\$\{l.staff_nombre\}</strong>', '<strong>${l.staff_nombre || ''Desconocido''}</strong>')
$html = [regex]::Replace($html, 'Pagó: <strong>\$\{l.operador\}</strong>', 'Pagó: <strong>${l.operador || ''N/A''}</strong>')
$html = [regex]::Replace($html, '\| \$\{l.detalle\}</div>', '| ${l.detalle || ''Sin detalle (Registro Antiguo)''}</div>')

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
