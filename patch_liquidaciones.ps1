$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Modificar calcularYGuardarLiquidacion
$target1 = 'categoria: ''Liquidacion'','
$replacement1 = @'
categoria: (['nacho','ignacio','zago','lea','leandro','villiani','ernesto','gomez','mariano','elias'].some(s => String(integrante.nombre).toLowerCase().trim().includes(s))) ? 'Retiro Socio' : 'Pago Staff',
'@
$html = $html.Replace($target1, $replacement1)


# 2. Modificar renderizarLibroDiario
$target2 = @'
      const filtrados = cajaData.filter(c => {
         let ok = true;
'@
$replacement2 = @'
      const filtrados = cajaData.filter(c => {
         if (c.categoria === 'Retiro Socio') return false;
         let ok = true;
'@
$html = $html.Replace($target2, $replacement2)


# 3. Modificar cargarAuditoriaCierreMensual (esSueldo)
$target3 = @'
          const esSueldo = tipo === 'sueldo' || 
                           cat.includes('sueldo') || 
                           cat.includes('honorario') || 
                           cat.includes('liquidac') || 
                           desc.includes('sueldo') || 
                           desc.includes('liquidac');
'@
$replacement3 = @'
          const listadoStrs = ['nacho','lea','mariano','elias','ernesto'];
          const esSocioText = listadoStrs.some(s => desc.includes(s) || cat.includes(s));
          const pareceSueldo = tipo === 'sueldo' || cat.includes('sueldo') || cat.includes('honorario') || cat.includes('liquidac') || desc.includes('sueldo') || desc.includes('liquidac');
          const esSueldo = cat === 'retiro socio' || (pareceSueldo && esSocioText);
'@
$html = $html.Replace($target3, $replacement3)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
