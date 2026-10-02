$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$target1 = @'
        const filtrados = cajaData.filter(c => {
           if (c.categoria === 'Retiro Socio') return false;
           let ok = true;
'@
$replacement1 = @'
        const filtrados = cajaData.filter(c => {
           let ok = true;
'@
$html = $html.Replace($target1, $replacement1)

$target2 = @'
          filtrados.forEach(c => {
            const monto = parseFloat(c.monto) || 0;
            const esIngreso = c.tipo === 'ingreso';
  
            if (esIngreso) totalIngresos += monto;
            else totalEgresos += monto;
'@
$replacement2 = @'
          filtrados.forEach(c => {
            const monto = parseFloat(c.monto) || 0;
            const esIngreso = c.tipo === 'ingreso';
            const esRetiroSocio = c.categoria === 'Retiro Socio';
  
            if (esIngreso) totalIngresos += monto;
            else if (!esRetiroSocio) totalEgresos += monto;
'@
$html = $html.Replace($target2, $replacement2)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
