$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$html = [regex]::Replace($html, 'ðŸ“  Carga Masiva', 'Carga Masiva')

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
