$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$html = [regex]::Replace($html, 'if \(c\.categoria === ''Retiro Socio''\) return false;\s*', '')

$target2 = @'
            if (esIngreso) totalIngresos += monto;
            else totalEgresos += monto;
'@
$replacement2 = @'
            const esRetiroSocio = c.categoria === 'Retiro Socio';
            if (esIngreso) totalIngresos += monto;
            else if (!esRetiroSocio) totalEgresos += monto;
'@
$html = $html.Replace($target2, $replacement2)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
