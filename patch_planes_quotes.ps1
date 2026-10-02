$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# Quote `p.id` in `actualizarEstadoPlan`
$html = [regex]::Replace($html, 'onchange="actualizarEstadoPlan\(\$\{p\.id\}, this\.value\)"', 'onchange="actualizarEstadoPlan(''${p.id}'', this.value)"')

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
