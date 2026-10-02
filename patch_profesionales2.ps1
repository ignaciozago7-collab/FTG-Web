$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Update the HTML to add the total summary placeholder
$targetHTML = @'
        <div class="card">
          <h3>Historial de Liquidaciones Realizadas</h3>
          <ul id="historialLiquidaciones">Cargando historial...</ul>
        </div>
'@
$replacementHTML = @'
        <div class="card">
          <h3>Historial de Liquidaciones Realizadas</h3>
          <div id="totalesLiquidaciones" style="margin-bottom: 15px; font-weight: bold; background: rgba(255,255,255,0.05); padding: 10px; border-radius: 6px; display: flex; gap: 20px; flex-wrap: wrap;"></div>
          <ul id="historialLiquidaciones">Cargando historial...</ul>
        </div>
'@
$html = $html.Replace($targetHTML, $replacementHTML)


# 2. Regex replace for actualizarModoCalculo
$replacementModo = @'
    function actualizarModoCalculo() {
      const staffId = document.getElementById('selectStaff').value;
      const integrante = staffData.find(s => s.id == staffId);
      if (!integrante) return;

      document.getElementById('wrapperHoras').style.display = integrante.rol === 'profesor' ? 'flex' : 'none';
      const wRec = document.getElementById('wrapperRecaudacion');
      wRec.style.display = integrante.rol === 'profesional' ? 'flex' : 'none';
      
      if (integrante.rol === 'profesional') {
          document.getElementById('inputRecaudacion').placeholder = `Monto a ingresar al Gym ($)`;
          let pctText = document.getElementById('infoPorcentaje');
          if (!pctText) {
             pctText = document.createElement('div');
             pctText.id = 'infoPorcentaje';
             pctText.style = 'font-size: 0.85rem; color: var(--neon-green); margin-top: 5px; width: 100%;';
             wRec.style.flexDirection = 'column';
             wRec.appendChild(pctText);
          }
          pctText.innerText = `Nos corresponde el ${integrante.porcentaje || 0}% de su recaudacion.`;
      }
    }
'@
$html = [regex]::Replace($html, 'function actualizarModoCalculo\(\) \{[\s\S]*?\}[\s]*async function calcularYGuardarLiquidacion', "$replacementModo`n`n    async function calcularYGuardarLiquidacion")


# 3. Regex replace for calcularYGuardarLiquidacion
$replacementJS = @'
    async function calcularYGuardarLiquidacion() {
      const staffId = document.getElementById('selectStaff').value;
      const operadorPago = document.getElementById('selectOperadorLiquidacion').value;
      const integrante = staffData.find(s => s.id == staffId);

      if (!integrante) {
        alert('Selecciona un miembro del staff.');
        return;
      }

      let montoTotal = 0;
      let detalleTexto = '';
      let tipoCaja = 'egreso';
      let catCaja = 'Pago Staff';

      if (integrante.rol === 'profesor') {
        const horas = parseFloat(document.getElementById('inputHoras').value) || 0;
        if (horas <= 0) {
          alert('Ingresa las horas trabajadas.');
          return;
        }
        montoTotal = horas * (integrante.tarifa_hora || 0);
        detalleTexto = `Liquidacion Sueldo Profesor (${horas} hrs) - ${integrante.nombre}`;
        const isOwner = ['nacho','ignacio','zago','lea','leandro','villiani','ernesto','gomez','mariano','elias'].some(s => String(integrante.nombre).toLowerCase().trim().includes(s));
        catCaja = isOwner ? 'Retiro Socio' : 'Pago Staff';
        tipoCaja = 'egreso';
      } else {
        const ingresoDirecto = parseFloat(document.getElementById('inputRecaudacion').value) || 0;
        if (ingresoDirecto <= 0) {
          alert('Ingresa el monto que el profesional rinde al gym.');
          return;
        }
        montoTotal = ingresoDirecto;
        detalleTexto = `Ingreso Comision Profesional (${integrante.porcentaje}%) - ${integrante.nombre}`;
        tipoCaja = 'ingreso';
        catCaja = 'Ingreso Profesional';
      }

      const fechaHoy = new Date().toISOString().split('T')[0];

      const { error: errCaja } = await _supabase.from('caja_diaria').insert([{
        fecha: fechaHoy,
        tipo: tipoCaja,
        persona: operadorPago,
        detalle: detalleTexto,
        categoria: catCaja,
        cobrador: operadorPago,
        monto: montoTotal
      }]);
'@

$html = [regex]::Replace($html, 'async function calcularYGuardarLiquidacion\(\) \{[\s\S]*?monto:\s*montoTotal\s*\}\]\);', $replacementJS)


# 4. Modificar cargarHistorialLiquidaciones to compute totals
$targetHist = @'
      liquidacionesData = data;
      ul.innerHTML = data.map(l => {
        const fStr = new Date(l.fecha + 'T12:00:00').toLocaleDateString('es-AR');
'@

$replacementHist = @'
      liquidacionesData = data;
      
      let totalSueldos = 0;
      let totalIngresosProf = 0;
      data.forEach(l => {
         if (l.detalle && l.detalle.toLowerCase().includes('ingreso comision')) {
             totalIngresosProf += parseFloat(l.monto) || 0;
         } else if (l.detalle && l.detalle.toLowerCase().includes('liquidaci')) {
             totalSueldos += parseFloat(l.monto) || 0;
         }
      });
      
      const divTotales = document.getElementById('totalesLiquidaciones');
      if (divTotales) {
          divTotales.innerHTML = `
              <div style="color: var(--danger-red);">Total Sueldos (Profesores): $${totalSueldos.toLocaleString()}</div>
              <div style="color: var(--neon-green);">Total Ingresos (Profesionales): $${totalIngresosProf.toLocaleString()}</div>
          `;
      }
      
      ul.innerHTML = data.map(l => {
        const fStr = new Date(l.fecha + 'T12:00:00').toLocaleDateString('es-AR');
        const esIngreso = l.detalle && l.detalle.toLowerCase().includes('ingreso comision');
        const colorMonto = esIngreso ? 'var(--neon-green)' : 'var(--danger-red)';
        const signoMonto = esIngreso ? '+' : '-';
'@

$html = $html.Replace($targetHist, $replacementHist)

# Update the render of monto in history
$targetMonto = '<span style="color: var(--neon-green);">$${l.monto.toLocaleString()}</span>'
$replacementMonto = '<span style="color: ${colorMonto};">${signoMonto}$${l.monto.toLocaleString()}</span>'
$html = $html.Replace($targetMonto, $replacementMonto)


$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
