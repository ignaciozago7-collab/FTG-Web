$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$targetModal = '  <!-- MODAL EDICIÓN ASIENTO DE CAJA -->'
$replacementModal = @'
  <!-- MODAL ASISTENCIA MASIVA -->
  <div class="modal-overlay" id="modalAsistenciaMasiva">
    <div class="modal-content" style="max-width: 600px;">
      <h2>Carga Masiva de Asistencias</h2>
      <p style="color: var(--text-dim); margin-bottom: 12px;">Selecciona los clientes que deseas marcar como PRESENTES para la fecha: <strong id="fechaAsistenciaMasivaTitulo"></strong></p>
      
      <input type="text" id="buscadorMasivoAsistencia" placeholder="Filtrar nombres..." oninput="filtrarListaMasivaAsistencia()" style="width: 100%; margin-bottom: 16px;">
      
      <div id="listaAsistenciaMasiva" style="max-height: 400px; overflow-y: auto; border: 1px solid var(--border-color); border-radius: 8px; padding: 12px; display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 8px; background: #14141D;">
        <!-- Checkboxes se generan por JS -->
      </div>
      
      <div style="display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px;">
        <button class="btn btn-outline" onclick="cerrarModalAsistenciaMasiva()">Cancelar</button>
        <button class="btn" onclick="guardarAsistenciaMasiva()">Guardar Presentes</button>
      </div>
    </div>
  </div>

  <!-- MODAL EDICIÓN ASIENTO DE CAJA -->
'@
$html = $html.Replace($targetModal, $replacementModal)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
