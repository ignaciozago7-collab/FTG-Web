$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Update button
$targetBtn = '<button class="btn" onclick="abrirModalAsistenciaMasiva()" style="background: var(--blue-accent);">Carga Masiva</button>'
$replacementBtn = '<button class="btn" onclick="abrirModalAsistenciaMasiva()" style="background: #ff9800; color: #fff; font-weight: bold; border: 1px solid #e68a00;">📝 Carga Masiva</button>'
$html = $html.Replace($targetBtn, $replacementBtn)

# 2. Update guardarAsistenciaMasiva
$targetJS = @'
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
'@

$replacementJS = @'
    async function guardarAsistenciaMasiva() {
      const chks = document.querySelectorAll('.chk-masivo-asistencia:checked');
      if (chks.length === 0) return alert('Seleccioná al menos un alumno.');
      
      const fechaSel = document.getElementById('fechaAsistencia').value;
      if (!fechaSel) return;
      
      let guardados = 0;
      for (const chk of Array.from(chks)) {
          const { error } = await _supabase.from('asistencias').insert([{
              alumno_id: parseInt(chk.value, 10),
              fecha: fechaSel
          }]);
          if (!error) guardados++;
      }
      
      alert(`¡Se registraron ${guardados} presentes correctamente!`);
      cerrarModalAsistenciaMasiva();
      cargarAsistencias();
    }
'@

$html = $html.Replace($targetJS, $replacementJS)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
