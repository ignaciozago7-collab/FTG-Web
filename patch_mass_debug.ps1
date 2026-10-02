$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$targetMass = @'
    async function guardarAsistenciaMasiva() {
      const chks = document.querySelectorAll('.chk-masivo-asistencia:checked');
      if (chks.length === 0) return alert('Selecciona al menos un alumno.');
      
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
      
      alert(`Se registraron ${guardados} presentes correctamente!`);
      cerrarModalAsistenciaMasiva();
      cargarAsistencias();
    }
'@

$replacementMass = @'
    async function guardarAsistenciaMasiva() {
      const chks = document.querySelectorAll('.chk-masivo-asistencia:checked');
      if (chks.length === 0) return alert('Selecciona al menos un alumno.');
      
      const fechaSel = document.getElementById('fechaAsistencia').value;
      if (!fechaSel) return;
      
      let guardados = 0;
      let errores = [];
      console.log("Iniciando guardado masivo para", chks.length, "alumnos.");
      
      for (const chk of Array.from(chks)) {
          console.log("Guardando alumno_id:", chk.value, "fecha:", fechaSel);
          const { error } = await _supabase.from('asistencias').insert([{
              alumno_id: parseInt(chk.value, 10),
              fecha: fechaSel
          }]);
          if (!error) {
              guardados++;
          } else {
              console.error("Error al guardar alumno", chk.value, error);
              errores.push(error.message);
          }
      }
      
      if (errores.length > 0) {
          alert(`Se registraron ${guardados} presentes, pero hubo errores: \n` + errores.join('\n'));
      } else {
          alert(`Se registraron ${guardados} presentes correctamente!`);
      }
      cerrarModalAsistenciaMasiva();
      cargarAsistencias();
    }
'@

$html = $html.Replace($targetMass, $replacementMass)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
