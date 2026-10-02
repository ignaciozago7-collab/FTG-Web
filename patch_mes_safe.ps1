$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Alumnos - Notas UI (insert right before the date input block)
$targetDiv = '<div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
              <input type="date"'

$replacementDiv = '<div style="margin-top: 6px; display: flex; align-items: center; gap: 8px;">
                   <span style="font-size: 0.85rem; color: var(--text-dim);">Notas:</span>
                   <input type="text" id="notas-al-${a.id}" value="${a.notas || ''}" placeholder="Ej: debe mes pasado..." style="padding: 4px; font-size: 0.8rem; background: #14141D; border: 1px solid var(--border-color); color: #fff; border-radius: 4px; flex: 1;" onchange="guardarNotaAlumno(${a.id}, this.value)">
                </div>
              </div>
              <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
              <input type="date"'

$html = $html.Replace($targetDiv, $replacementDiv)

# 2. Reset Button
$targetResetBtn = '<button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var(--danger-red);" onclick="ejecutarCierreMensual()">Resetear Cuotas a Pendiente</button>'
$replacementResetBtn = '<button class="btn" style="padding: 16px 24px; font-size: 1.15rem; font-weight: bold; background: var(--danger-red); width: 100%; border: 2px solid #ff4d4d; box-shadow: 0 0 10px rgba(255,0,0,0.3);" onclick="ejecutarCierreMensual()">&#x26A0; REINICIAR MES (Resetear todas las cuotas a Pendiente)</button>
          <p style="color: var(--text-dim); margin-top: 10px; font-size: 0.9rem;">Al presionar este bot&oacute;n, todas las cuotas de los clientes volver&aacute;n a estar pendientes para el nuevo mes. <strong>Tus notas escritas y montos se mantienen intactos</strong> para que sepas qu&eacute; pas&oacute; el mes anterior.<br>El Libro Diario y los Sueldos se reinician visualmente al cambiar al nuevo mes en sus respectivos filtros superiores.</p>'

$html = $html.Replace($targetResetBtn, $replacementResetBtn)

# 3. setFechasDefault
$targetSetFechas = 'document.getElementById(''fechaAsistencia'').value = hoy;'
$replacementSetFechas = 'document.getElementById(''fechaAsistencia'').value = hoy;
      const mesActual = hoy.substring(0, 7);
      if (document.getElementById(''filtroMesCaja'')) document.getElementById(''filtroMesCaja'').value = mesActual;
      if (document.getElementById(''filtroMesLiq'')) document.getElementById(''filtroMesLiq'').value = mesActual;'

$html = $html.Replace($targetSetFechas, $replacementSetFechas)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
