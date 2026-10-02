$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$html = [regex]::Replace($html, "if \(!confirm\('.*eliminar esta planificaci.*'\)\) return;", "if (!confirm('Seguro que deseas eliminar esta planificacion?')) return;")

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
