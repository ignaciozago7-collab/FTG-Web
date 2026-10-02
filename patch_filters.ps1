$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$target1 = '<input type="text" id="buscador" placeholder="🔎 Buscar cliente..." oninput="filtrarAlumnos()" style="width: 250px;">'
$replacement1 = @'
<div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <input type="text" id="buscador" placeholder="🔎 Buscar cliente..." oninput="filtrarAlumnos()" style="width: 200px;">
            <input type="date" id="filtroFechaAlumnos" oninput="filtrarAlumnos()">
            <select id="filtroCobradorAlumnos" onchange="filtrarAlumnos()">
              <option value="">Cualquier Operador</option>
              <option value="Nacho">Nacho</option>
              <option value="Lea">Lea</option>
              <option value="Ernesto">Ernesto</option>
              <option value="Mariano">Mariano</option>
              <option value="Elias">Elias</option>
            </select>
            <input type="number" id="filtroMontoAlumnos" placeholder="Valor $" oninput="filtrarAlumnos()" style="width: 100px;">
          </div>
'@
$html = $html.Replace($target1, $replacement1)

$target2 = @'
    function filtrarAlumnos() {
      const texto = document.getElementById('buscador')?.value.toLowerCase() || '';
      const filtrados = alumnosData.filter(a => a.nombre.toLowerCase().includes(texto));
      renderizarListaAlumnos(filtrados);
    }
'@
$replacement2 = @'
    function filtrarAlumnos() {
      const texto = document.getElementById('buscador')?.value.toLowerCase() || '';
      const fechaFiltro = document.getElementById('filtroFechaAlumnos')?.value || '';
      const cobradorFiltro = document.getElementById('filtroCobradorAlumnos')?.value || '';
      const montoFiltro = parseFloat(document.getElementById('filtroMontoAlumnos')?.value) || 0;

      const filtrados = alumnosData.filter(a => {
        let ok = true;
        if (texto && !a.nombre.toLowerCase().includes(texto)) ok = false;
        if (fechaFiltro && a.fecha_pago !== fechaFiltro) ok = false;
        if (cobradorFiltro && a.ultimo_cobrador !== cobradorFiltro) ok = false;
        if (montoFiltro > 0 && parseFloat(a.monto) !== montoFiltro) ok = false;
        return ok;
      });
      renderizarListaAlumnos(filtrados);
    }
'@
$html = $html.Replace($target2, $replacement2)

$target3 = '<input type="text" id="buscadorCaja" placeholder="🔎 Filtrar movimientos..." oninput="cargarLibroDiario()" style="width: 250px;">'
$replacement3 = @'
<div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <input type="text" id="buscadorCaja" placeholder="🔎 Filtrar movimientos..." oninput="cargarLibroDiario()" style="width: 200px;">
            <input type="date" id="filtroFechaCaja" oninput="cargarLibroDiario()">
            <select id="filtroCobradorCaja" onchange="cargarLibroDiario()">
              <option value="">Cualquier Operador</option>
              <option value="Nacho">Nacho</option>
              <option value="Lea">Lea</option>
              <option value="Ernesto">Ernesto</option>
              <option value="Mariano">Mariano</option>
              <option value="Elias">Elias</option>
            </select>
            <input type="number" id="filtroMontoCaja" placeholder="Valor $" oninput="cargarLibroDiario()" style="width: 100px;">
          </div>
'@
$html = $html.Replace($target3, $replacement3)

$target4 = @'
      const filtro = document.getElementById('buscadorCaja')?.value.toLowerCase() || '';
      tbody.innerHTML = '';

      let totalIngresos = 0;
      let totalEgresos = 0;

      const filtrados = cajaData.filter(c => 
        (c.persona && c.persona.toLowerCase().includes(filtro)) ||
        (c.detalle && c.detalle.toLowerCase().includes(filtro)) ||
        (c.categoria && c.categoria.toLowerCase().includes(filtro)) ||
        (c.cobrador && c.cobrador.toLowerCase().includes(filtro))
      );
'@
$replacement4 = @'
      const filtro = document.getElementById('buscadorCaja')?.value.toLowerCase() || '';
      const filtroFecha = document.getElementById('filtroFechaCaja')?.value || '';
      const filtroCobrador = document.getElementById('filtroCobradorCaja')?.value || '';
      const filtroMonto = parseFloat(document.getElementById('filtroMontoCaja')?.value) || 0;
      
      tbody.innerHTML = '';

      let totalIngresos = 0;
      let totalEgresos = 0;

      const filtrados = cajaData.filter(c => {
         let ok = true;
         if (filtro && !((c.persona && c.persona.toLowerCase().includes(filtro)) ||
                         (c.detalle && c.detalle.toLowerCase().includes(filtro)) ||
                         (c.categoria && c.categoria.toLowerCase().includes(filtro)) ||
                         (c.cobrador && c.cobrador.toLowerCase().includes(filtro)))) {
             ok = false;
         }
         if (filtroFecha && c.fecha !== filtroFecha) ok = false;
         if (filtroCobrador && c.cobrador !== filtroCobrador) ok = false;
         if (filtroMonto > 0 && parseFloat(c.monto) !== filtroMonto) ok = false;
         return ok;
      });
'@
$html = $html.Replace($target4, $replacement4)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
