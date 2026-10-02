$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Modificar el render para agregar el botón de Modificar
$replacementRender = @'
              <div style="display: flex; gap: 6px;">
                <button class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;" onclick="modificarLiquidacion(${l.id})">Editar</button>
                <button class="btn btn-danger" style="padding: 4px 8px; font-size: 0.8rem;" onclick="borrarLiquidacion(${l.id})">Borrar</button>
              </div>
            </li>
'@
$html = [regex]::Replace($html, '<button[^>]+onclick="borrarLiquidacion\(\$\{l\.id\}\)"[^>]*>.*?<\/button>\s*<\/li>', $replacementRender)

# 2. Reemplazar borrarLiquidacion y añadir modificarLiquidacion / actualizarLiquidacion
$replacementJS = @'
    async function modificarLiquidacion(id) {
      const liq = liquidacionesData.find(x => x.id === id);
      if (!liq) return;
      const integrante = staffData.find(s => s.nombre === liq.staff_nombre);
      if (!integrante) {
        alert('No se encontro el staff en la base de datos.');
        return;
      }

      if (integrante.rol === 'profesor') {
          const horas = prompt(`Tarifa actual: $${integrante.tarifa_hora}/hr.\nIngresa las nuevas horas trabajadas:`);
          if (!horas || isNaN(horas)) return;
          const monto = parseFloat(horas) * (integrante.tarifa_hora || 0);
          const detalle = `Liquidacion Sueldo Profesor (${horas} hrs) - ${integrante.nombre}`;
          await actualizarLiquidacion(liq, monto, detalle);
      } else {
          const recaudacion = prompt(`Porcentaje actual: ${integrante.porcentaje}%.\nIngresa la nueva recaudacion total:`);
          if (!recaudacion || isNaN(recaudacion)) return;
          const monto = parseFloat(recaudacion) * ((integrante.porcentaje || 0) / 100);
          const detalle = `Liquidacion Comision Profesional (${integrante.porcentaje}%) - ${integrante.nombre}`;
          await actualizarLiquidacion(liq, monto, detalle);
      }
    }

    async function actualizarLiquidacion(liq, nuevoMonto, nuevoDetalle) {
      const { error: errLiq } = await _supabase.from('liquidaciones')
          .update({ monto: nuevoMonto, detalle: nuevoDetalle })
          .eq('id', liq.id);
      if (errLiq) return alert('Error al actualizar: ' + errLiq.message);

      // Actualizar también en caja_diaria
      await _supabase.from('caja_diaria')
          .update({ monto: nuevoMonto, detalle: nuevoDetalle })
          .match({ fecha: liq.fecha, monto: liq.monto, persona: liq.operador, detalle: liq.detalle });
          
      alert('Liquidacion modificada con exito.');
      cargarHistorialLiquidaciones();
      cargarLibroDiario();
    }

    async function borrarLiquidacion(id) {
      if (!confirm('Seguro que deseas eliminar esta liquidacion?')) return;
      const liq = liquidacionesData.find(x => x.id === id);
      if (liq) {
         // Borrar también de caja_diaria
         await _supabase.from('caja_diaria').delete().match({ fecha: liq.fecha, monto: liq.monto, persona: liq.operador, detalle: liq.detalle });
      }
      const { error } = await _supabase.from('liquidaciones').delete().eq('id', id);
      if (error) {
         alert('Error al borrar: ' + error.message);
      } else {
         cargarHistorialLiquidaciones();
         cargarLibroDiario();
      }
    }
'@

$html = [regex]::Replace($html, 'async function borrarLiquidacion\(id\) \{[\s\S]*?cargarHistorialLiquidaciones\(\);\s*\}', $replacementJS)


$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
