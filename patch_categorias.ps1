$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Update the JS logic for categorical summaries
$js_target = 'let cantCuotas = 0;
          let egresosPorCategoria = {};'
$js_replace = 'let cantCuotas = 0;
          let resumenIngresos = {};
          let resumenEgresos = {};'
$html = $html.Replace($js_target, $js_replace)

$js_loop_target = '            if (esSueldo) {
              liquidacion[operador].sueldo += monto;
              totalEgresosGeneral += monto;
            } else if (tipo === ''ingreso'') {
              totalIngresos += monto;
              if (r.categoria === ''Cuota'') cantCuotas++;
              liquidacion[operador].cobrado += monto;
            } else if (tipo === ''egreso'') {
              totalEgresosGeneral += monto;
              liquidacion[operador].gastado += monto;

              if (operador === ''Gym'') {
                const categoriaNombre = r.categoria || ''Otros'';
                egresosPorCategoria[categoriaNombre] = (egresosPorCategoria[categoriaNombre] || 0) + monto;
              }
            }'

$js_loop_replace = '            const catNombre = r.categoria || ''Otros'';
            
            if (esSueldo) {
              liquidacion[operador].sueldo += monto;
              totalEgresosGeneral += monto;
              resumenEgresos[catNombre] = (resumenEgresos[catNombre] || 0) + monto;
            } else if (tipo === ''ingreso'') {
              totalIngresos += monto;
              if (catNombre === ''Cuota'') cantCuotas++;
              liquidacion[operador].cobrado += monto;
              resumenIngresos[catNombre] = (resumenIngresos[catNombre] || 0) + monto;
            } else if (tipo === ''egreso'') {
              totalEgresosGeneral += monto;
              liquidacion[operador].gastado += monto;
              resumenEgresos[catNombre] = (resumenEgresos[catNombre] || 0) + monto;
            }'
$html = $html.Replace($js_loop_target, $js_loop_replace)

$js_render_replace = '          const tbodyIngresos = document.getElementById(''tbodyCierreCatIngresos'');
          if (tbodyIngresos) {
            tbodyIngresos.innerHTML = '''';
            const keysIng = Object.keys(resumenIngresos);
            if (keysIng.length === 0) {
              tbodyIngresos.innerHTML = ''<tr><td colspan="2">No hay ingresos.</td></tr>'';
            } else {
              keysIng.forEach(cat => {
                tbodyIngresos.innerHTML += `<tr><td><strong>${cat}</strong></td><td style="color: var(--neon-green); font-weight:700;">+$${resumenIngresos[cat].toLocaleString()}</td></tr>`;
              });
            }
          }
          const tbodyEgresos = document.getElementById(''tbodyCierreCatEgresos'');
          if (tbodyEgresos) {
            tbodyEgresos.innerHTML = '''';
            const keysEgr = Object.keys(resumenEgresos);
            if (keysEgr.length === 0) {
              tbodyEgresos.innerHTML = ''<tr><td colspan="2">No hay egresos.</td></tr>'';
            } else {
              keysEgr.forEach(cat => {
                tbodyEgresos.innerHTML += `<tr><td><strong>${cat}</strong></td><td style="color: var(--danger-red); font-weight:700;">-$${resumenEgresos[cat].toLocaleString()}</td></tr>`;
              });
            }
          }'
$html = [regex]::Replace($html, '(?s)const tbodyCat = document\.getElementById\(''tbodyCierreCategorias''\);.*?}\s*}', $js_render_replace)


# 2. Update the HTML UI
$html_replace = '<div class="card" style="margin-top: 20px;">
          <h3>Resumen por Categor&iacute;as (Ingresos y Egresos)</h3>
          <div style="display: flex; gap: 20px; flex-wrap: wrap; margin-top: 10px;">
            <div style="flex: 1; min-width: 300px;">
              <h4 style="color: var(--neon-green); margin-bottom: 10px;">&#x1F4B5; Ingresos</h4>
              <table style="width: 100%; text-align: left; background: rgba(0,0,0,0.2); border-radius: 8px; overflow: hidden;">
                <thead>
                  <tr style="background: rgba(149, 255, 83, 0.1);">
                    <th style="padding: 10px;">Categor&iacute;a</th>
                    <th style="padding: 10px;">Monto Total</th>
                  </tr>
                </thead>
                <tbody id="tbodyCierreCatIngresos">
                  <tr><td colspan="2" style="padding: 10px;">Cargando...</td></tr>
                </tbody>
              </table>
            </div>
            <div style="flex: 1; min-width: 300px;">
              <h4 style="color: var(--danger-red); margin-bottom: 10px;">&#x1F4B8; Gastos / Egresos</h4>
              <table style="width: 100%; text-align: left; background: rgba(0,0,0,0.2); border-radius: 8px; overflow: hidden;">
                <thead>
                  <tr style="background: rgba(255, 77, 77, 0.1);">
                    <th style="padding: 10px;">Categor&iacute;a</th>
                    <th style="padding: 10px;">Monto Total</th>
                  </tr>
                </thead>
                <tbody id="tbodyCierreCatEgresos">
                  <tr><td colspan="2" style="padding: 10px;">Cargando...</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>'

$html = [regex]::Replace($html, '(?s)<div class="card" style="margin-top: 20px;">\s*<h3>Resumen de Gastos / Egresos por Categor.*?</table>\s*</div>', $html_replace)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
