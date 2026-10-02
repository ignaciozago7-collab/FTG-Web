$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$targetBtn = '<button class="btn" onclick="abrirModalPresentesHoy()">'
$replacementBtn = @'
<button class="btn" onclick="abrirModalAsistenciaMasiva()" style="background: var(--blue-accent);">Carga Masiva</button>
            <button class="btn" onclick="abrirModalPresentesHoy()">
'@
$html = $html.Replace($targetBtn, $replacementBtn)

$targetModal = '  <!-- MODALES -->'
$replacementModal = @'
  <!-- MODALES -->

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

'@
$html = $html.Replace($targetModal, $replacementModal)

$targetJS = '    function abrirModalPresentesHoy() {'
$replacementJS = @'
    function abrirModalAsistenciaMasiva() {
      const fechaSel = document.getElementById('fechaAsistencia').value;
      if (!fechaSel) return alert('Selecciona una fecha primero.');
      
      const fechaFormateada = new Date(fechaSel + 'T12:00:00').toLocaleDateString('es-AR', {
        day: '2-digit', month: '2-digit', year: 'numeric'
      });
      document.getElementById('fechaAsistenciaMasivaTitulo').innerText = fechaFormateada;
      
      document.getElementById('buscadorMasivoAsistencia').value = '';
      renderizarListaMasivaAsistencia();
      document.getElementById('modalAsistenciaMasiva').style.display = 'flex';
    }
    
    function cerrarModalAsistenciaMasiva() {
      document.getElementById('modalAsistenciaMasiva').style.display = 'none';
      document.getElementById('buscadorMasivoAsistencia').value = '';
    }
    
    function renderizarListaMasivaAsistencia() {
       const filtro = document.getElementById('buscadorMasivoAsistencia').value.toLowerCase();
       const contenedor = document.getElementById('listaAsistenciaMasiva');
       const fechaSel = document.getElementById('fechaAsistencia').value;
       
       let html = '';
       const activos = alumnosData.filter(a => a.activo);
       
       activos.forEach(a => {
         if (filtro && !a.nombre.toLowerCase().includes(filtro)) return;
         
         // ver si ya tiene asistencia hoy
         const yaTiene = asistenciasMesData.some(as => String(as.alumno_id) === String(a.id) && as.fecha === fechaSel);
         if (yaTiene) return; // Ya esta presente
         
         html += `
           <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 6px; border-radius: 4px; background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.05);">
             <input type="checkbox" class="chk-masivo-asistencia" value="${a.id}">
             <span>${a.nombre}</span>
           </label>
         `;
       });
       
       if (html === '') html = '<div style="color: var(--text-dim); grid-column: 1/-1;">No hay alumnos disponibles o todos los coincidentes ya estan presentes hoy.</div>';
       contenedor.innerHTML = html;
    }
    
    function filtrarListaMasivaAsistencia() {
       renderizarListaMasivaAsistencia();
    }
    
    async function guardarAsistenciaMasiva() {
      const chks = document.querySelectorAll('.chk-masivo-asistencia:checked');
      if (chks.length === 0) return alert('Selecciona al menos un alumno.');
      
      const fechaSel = document.getElementById('fechaAsistencia').value;
      if (!fechaSel) return;
      
      const inserts = Array.from(chks).map(chk => ({
         alumno_id: parseInt(chk.value, 10),
         fecha: fechaSel
      }));
      
      const { error } = await _supabase.from('asistencias').insert(inserts);
      
      if (error) {
        alert('Error al guardar asistencias: ' + error.message);
      } else {
        alert(`Se registraron ${inserts.length} presentes correctamente!`);
        cerrarModalAsistenciaMasiva();
        cargarAsistencias();
      }
    }

    function abrirModalPresentesHoy() {
'@
$html = $html.Replace($targetJS, $replacementJS)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
