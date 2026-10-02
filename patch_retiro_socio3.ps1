$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$replacement2 = @'
        filtrados.forEach(c => {
          const monto = parseFloat(c.monto) || 0;
          const esIngreso = c.tipo === 'ingreso';
          const esRetiroSocio = c.categoria === 'Retiro Socio';

          if (esIngreso) totalIngresos += monto;
          else if (!esRetiroSocio) totalEgresos += monto;
'@

$html = [regex]::Replace($html, 'filtrados\.forEach\(c => \{\s*const monto = parseFloat\(c\.monto\) \|\| 0;\s*const esIngreso = c\.tipo === ''ingreso'';\s*if \(esIngreso\) totalIngresos \+= monto;\s*else totalEgresos \+= monto;', $replacement2)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
