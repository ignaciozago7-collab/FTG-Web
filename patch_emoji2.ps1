$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$html = [regex]::Replace($html, 'background: #ff9800; color: #fff; font-weight: bold; border: 1px solid #e68a00;">.*Carga Masiva</button>', 'background: #ff9800; color: #fff; font-weight: bold; border: 1px solid #e68a00;">Carga Masiva</button>')

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
