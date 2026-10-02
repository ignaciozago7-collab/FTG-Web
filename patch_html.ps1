$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$replacement1 = @'
<div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <input type="text" id="buscador" placeholder="Buscar cliente..." oninput="filtrarAlumnos()" style="width: 200px;">
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
$html = [regex]::Replace($html, '<input type="text" id="buscador" [^>]+>', $replacement1)

$replacement3 = @'
<div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <input type="text" id="buscadorCaja" placeholder="Filtrar movimientos..." oninput="cargarLibroDiario()" style="width: 200px;">
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
$html = [regex]::Replace($html, '<input type="text" id="buscadorCaja" [^>]+>', $replacement3)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
