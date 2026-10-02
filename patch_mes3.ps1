$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Alumnos - Notas UI
$targetInfoCliente = @'
                ${estaPagado ? `
                  <div class="meta-pago" style="margin-top: 6px;">
                    📅 Fecha de pago: <strong>${fechaFormateada}</strong> | 👤 Recibió el pago: <strong>${a.ultimo_cobrador || 'No especificado'}</strong>
                  </div>
                ` : ''}
              </div>
              <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
'@
$replacementInfoCliente = @'
                ${estaPagado ? `
                  <div class="meta-pago" style="margin-top: 6px;">
                    📅 Fecha de pago: <strong>${fechaFormateada}</strong> | 👤 Recibió el pago: <strong>${a.ultimo_cobrador || 'No especificado'}</strong>
                  </div>
                ` : ''}
                <div style="margin-top: 6px; display: flex; align-items: center; gap: 8px;">
                   <span style="font-size: 0.85rem; color: var(--text-dim);">Notas:</span>
                   <input type="text" id="notas-al-${a.id}" value="${a.notas || ''}" placeholder="Ej: debe mes pasado..." style="padding: 4px; font-size: 0.8rem; background: #14141D; border: 1px solid var(--border-color); color: #fff; border-radius: 4px; flex: 1;" onchange="guardarNotaAlumno(${a.id}, this.value)">
                </div>
              </div>
              <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
'@
$html = $html.Replace($targetInfoCliente, $replacementInfoCliente)

# 2. Libro Diario - Filter UI
$targetLibroDiarioUI = @'
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
          <h3>Asientos Contables</h3>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
'@
$replacementLibroDiarioUI = @'
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
          <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
              <h3>Asientos Contables</h3>
              <div style="display: flex; gap: 10px; align-items: center; background: rgba(255,255,255,0.05); padding: 4px 10px; border-radius: 6px;">
                <label style="color: var(--text-dim); font-size: 0.85rem;">Ver mes:</label>
                <input type="month" id="filtroMesCaja" onchange="cargarLibroDiario()" style="padding: 2px;">
                <button class="btn btn-outline" style="padding: 2px 6px; font-size: 0.75rem;" onclick="document.getElementById('filtroMesCaja').value=''; cargarLibroDiario();">Todos</button>
              </div>
          </div>
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
'@
$html = $html.Replace($targetLibroDiarioUI, $replacementLibroDiarioUI)

# 3. Libro Diario - JS Logic
$targetCajaVars = @'
      const filtro = document.getElementById('buscadorCaja')?.value.toLowerCase() || '';
      const filtroFecha = document.getElementById('filtroFechaCaja')?.value || '';
'@
$replacementCajaVars = @'
      const filtro = document.getElementById('buscadorCaja')?.value.toLowerCase() || '';
      const filtroMesCaja = document.getElementById('filtroMesCaja')?.value || '';
      const filtroFecha = document.getElementById('filtroFechaCaja')?.value || '';
'@
$html = $html.Replace($targetCajaVars, $replacementCajaVars)

$targetCajaFilter = @'
         if (filtroMonto > 0 && parseFloat(c.monto) !== filtroMonto) ok = false;
         return ok;
      });
'@
$replacementCajaFilter = @'
         if (filtroMonto > 0 && parseFloat(c.monto) !== filtroMonto) ok = false;
         if (filtroMesCaja && c.fecha && !c.fecha.startsWith(filtroMesCaja)) ok = false;
         return ok;
      });
'@
$html = $html.Replace($targetCajaFilter, $replacementCajaFilter)

# 4. Liquidaciones - Filter UI
$targetLiqUI = @'
      <div class="card">
        <h3>Historial de Liquidaciones Realizadas</h3>
        <ul id="historialLiquidaciones">Cargando historial...</ul>
      </div>
'@
$replacementLiqUI = @'
      <div class="card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 10px;">
            <h3 style="margin: 0;">Historial de Liquidaciones</h3>
            <div style="display: flex; gap: 10px; align-items: center; background: rgba(255,255,255,0.05); padding: 4px 10px; border-radius: 6px;">
                <label style="color: var(--text-dim); font-size: 0.85rem;">Ver mes:</label>
                <input type="month" id="filtroMesLiq" onchange="renderizarHistorialLiquidaciones()" style="padding: 2px;">
                <button class="btn btn-outline" style="padding: 2px 6px; font-size: 0.75rem;" onclick="document.getElementById('filtroMesLiq').value=''; renderizarHistorialLiquidaciones();">Todos</button>
            </div>
        </div>
        <ul id="historialLiquidaciones">Cargando historial...</ul>
      </div>
'@
$html = $html.Replace($targetLiqUI, $replacementLiqUI)

# 5. Liquidaciones - JS Logic
$targetLiqFn = @'
    async function cargarHistorialLiquidaciones() {
      const { data, error } = await _supabase.from('liquidaciones').select('*').order('created_at', { ascending: false });
      const ul = document.getElementById('historialLiquidaciones');
      if (!ul) return;

      if (error) {
        ul.innerHTML = `<li>Error cargando historial: ${error.message}</li>`;
        console.error("Supabase Select Error:", error);
        return;
      }

      if (!data || data.length === 0) {
        ul.innerHTML = '<li>No hay liquidaciones registradas.</li>';
        return;
      }

      liquidacionesData = data;
      
      let totalSueldos = 0;
'@
$replacementLiqFn = @'
    async function cargarHistorialLiquidaciones() {
      const { data, error } = await _supabase.from('liquidaciones').select('*').order('created_at', { ascending: false });
      const ul = document.getElementById('historialLiquidaciones');
      if (!ul) return;

      if (error) {
        ul.innerHTML = `<li>Error cargando historial: ${error.message}</li>`;
        console.error("Supabase Select Error:", error);
        return;
      }
      
      liquidacionesData = data || [];
      renderizarHistorialLiquidaciones();
    }

    function renderizarHistorialLiquidaciones() {
      const ul = document.getElementById('historialLiquidaciones');
      if (!ul) return;

      if (liquidacionesData.length === 0) {
        ul.innerHTML = '<li>No hay liquidaciones registradas.</li>';
        return;
      }

      const mesFiltro = document.getElementById('filtroMesLiq')?.value || '';
      const data = liquidacionesData.filter(l => {
         if (!mesFiltro) return true;
         const d = l.fecha || l.created_at;
         if (!d) return true;
         return d.startsWith(mesFiltro);
      });

      if (data.length === 0) {
        ul.innerHTML = '<li>No hay liquidaciones en este mes.</li>';
        return;
      }

      let totalSueldos = 0;
'@
$html = $html.Replace($targetLiqFn, $replacementLiqFn)

# 6. Change "Reset" UI button to be huge
$targetResetBtn = @'
          <button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var(--danger-red);" onclick="ejecutarCierreMensual()">Resetear Cuotas a Pendiente</button>
'@
$replacementResetBtn = @'
          <button class="btn" style="padding: 16px 24px; font-size: 1.15rem; font-weight: bold; background: var(--danger-red); width: 100%; border: 2px solid #ff4d4d; box-shadow: 0 0 10px rgba(255,0,0,0.3);" onclick="ejecutarCierreMensual()">⚠️ REINICIAR MES (Resetear todas las cuotas a Pendiente)</button>
          <p style="color: var(--text-dim); margin-top: 10px; font-size: 0.9rem;">Al presionar este botón, todas las cuotas de los clientes volverán a estar pendientes para el nuevo mes. <strong>Tus notas escritas y montos se mantienen intactos</strong> para que sepas qué pasó el mes anterior.<br>El Libro Diario y los Sueldos se reinician visualmente al cambiar al nuevo mes en sus respectivos filtros superiores.</p>
'@
$html = $html.Replace($targetResetBtn, $replacementResetBtn)


# 7. Default dates and add guardarNotaAlumno function at the end
$targetSetFechas = @'
    function setFechasDefault() {
      const hoy = new Date().toISOString().split('T')[0];
      document.getElementById('fechaAsistencia').value = hoy;
'@
$replacementSetFechas = @'
    function setFechasDefault() {
      const hoy = new Date().toISOString().split('T')[0];
      const mesActual = hoy.substring(0, 7);
      
      document.getElementById('fechaAsistencia').value = hoy;
      if (document.getElementById('filtroMesCaja')) document.getElementById('filtroMesCaja').value = mesActual;
      if (document.getElementById('filtroMesLiq')) document.getElementById('filtroMesLiq').value = mesActual;
'@
$html = $html.Replace($targetSetFechas, $replacementSetFechas)


$targetEndScript = @'
      renderizarAvisosDiarios();
    }
  </script>
</body>
</html>
'@
$replacementEndScript = @'
      renderizarAvisosDiarios();
    }
    
    async function guardarNotaAlumno(id, nota) {
      const { error } = await _supabase.from('alumnos').update({ notas: nota }).eq('id', id);
      if (error) {
         alert('Error al guardar nota: ' + error.message);
      } else {
         const idx = alumnosData.findIndex(a => a.id == id);
         if(idx !== -1) alumnosData[idx].notas = nota;
      }
    }
  </script>
</body>
</html>
'@
$html = $html.Replace($targetEndScript, $replacementEndScript)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
