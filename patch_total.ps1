$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# Update insert to include total_a_pagar
$targetInsert = @'
      const { error: errLiq } = await _supabase.from('liquidaciones').insert([{
        fecha: fechaHoy,
        staff_nombre: integrante.nombre,
        operador: operadorPago,
        monto: montoTotal,
        detalle: detalleTexto
      }]);
'@
$replacementInsert = @'
      const { error: errLiq } = await _supabase.from('liquidaciones').insert([{
        fecha: fechaHoy,
        staff_nombre: integrante.nombre,
        operador: operadorPago,
        monto: montoTotal,
        total_a_pagar: montoTotal,
        detalle: detalleTexto
      }]);
'@
$html = $html.Replace($targetInsert, $replacementInsert)

# Update update to include total_a_pagar
$targetUpdate = @'
    async function actualizarLiquidacion(liq, nuevoMonto, nuevoDetalle) {
      const { error: errLiq } = await _supabase.from('liquidaciones')
          .update({ monto: nuevoMonto, detalle: nuevoDetalle })
          .eq('id', liq.id);
'@
$replacementUpdate = @'
    async function actualizarLiquidacion(liq, nuevoMonto, nuevoDetalle) {
      const { error: errLiq } = await _supabase.from('liquidaciones')
          .update({ monto: nuevoMonto, total_a_pagar: nuevoMonto, detalle: nuevoDetalle })
          .eq('id', liq.id);
'@
$html = $html.Replace($targetUpdate, $replacementUpdate)

# Update history to read total_a_pagar fallback
$targetHist = @'
      let totalSueldos = 0;
      let totalIngresosProf = 0;
      data.forEach(l => {
         if (l.detalle && l.detalle.toLowerCase().includes('ingreso comision')) {
             totalIngresosProf += parseFloat(l.monto) || 0;
         } else if (l.detalle && l.detalle.toLowerCase().includes('liquidaci')) {
             totalSueldos += parseFloat(l.monto) || 0;
         }
      });
'@
$replacementHist = @'
      let totalSueldos = 0;
      let totalIngresosProf = 0;
      data.forEach(l => {
         const valorMonto = parseFloat(l.monto) || parseFloat(l.total_a_pagar) || 0;
         if (l.detalle && l.detalle.toLowerCase().includes('ingreso comision')) {
             totalIngresosProf += valorMonto;
         } else if (l.detalle && l.detalle.toLowerCase().includes('liquidaci')) {
             totalSueldos += valorMonto;
         }
      });
'@
$html = $html.Replace($targetHist, $replacementHist)

# Update render list to use fallback
$targetRender = @'
      ul.innerHTML = data.map(l => {
        const fStr = new Date(l.fecha + 'T12:00:00').toLocaleDateString('es-AR');
        const esIngreso = l.detalle && l.detalle.toLowerCase().includes('ingreso comision');
        const colorMonto = esIngreso ? 'var(--neon-green)' : 'var(--danger-red)';
        const signoMonto = esIngreso ? '+' : '-';
        return `
          <li>
            <div>
              <strong>${l.staff_nombre}</strong> - <span style="color: ${colorMonto};">${signoMonto}$${l.monto.toLocaleString()}</span>
'@
$replacementRender = @'
      ul.innerHTML = data.map(l => {
        const fStr = new Date(l.fecha + 'T12:00:00').toLocaleDateString('es-AR');
        const esIngreso = l.detalle && l.detalle.toLowerCase().includes('ingreso comision');
        const colorMonto = esIngreso ? 'var(--neon-green)' : 'var(--danger-red)';
        const signoMonto = esIngreso ? '+' : '-';
        const valorMonto = parseFloat(l.monto) || parseFloat(l.total_a_pagar) || 0;
        return `
          <li>
            <div>
              <strong>${l.staff_nombre}</strong> - <span style="color: ${colorMonto};">${signoMonto}$${valorMonto.toLocaleString()}</span>
'@
$html = $html.Replace($targetRender, $replacementRender)


$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
