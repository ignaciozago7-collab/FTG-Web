$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

# 1. Add "notas" column input in Alumnos table
$infoClienteRegex = '(?s)(<div class="info-cliente">.*?)(</div>\s*<div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">)'
$html = [regex]::Replace($html, $infoClienteRegex, '$1
                <div style="margin-top: 6px; display: flex; align-items: center; gap: 8px;">
                   <span style="font-size: 0.85rem; color: var(--text-dim);">Notas:</span>
                   <input type="text" id="notas-al-${a.id}" value="${a.notas || ''}" placeholder="Ej: debe mes pasado..." style="padding: 4px; font-size: 0.8rem; background: #14141D; border: 1px solid var(--border-color); color: #fff; border-radius: 4px; flex: 1;" onchange="guardarNotaAlumno(${a.id}, this.value)">
                </div>
              $2')

# Add the JS function for saving notas
$fnNotas = @'
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
'@
$html = $html.Replace("</script>", $fnNotas)

# 2. Add Month Filter to Libro Diario
$libroDiarioH3 = '<h3>Asientos Contables</h3>'
$html = $html.Replace($libroDiarioH3, '<h3>Asientos Contables</h3>
            <div style="margin-bottom: 12px; display: flex; gap: 10px; align-items: center;">
              <label style="color: var(--text-dim); font-size: 0.9rem;">Ver mes:</label>
              <input type="month" id="filtroMesCaja" onchange="cargarLibroDiario()">
              <button class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;" onclick="document.getElementById(''filtroMesCaja'').value=''''; cargarLibroDiario();">Todos</button>
            </div>')

# Modify renderizarLibroDiario to use filtroMesCaja
$html = $html.Replace("const filtroFecha = document.getElementById('filtroFechaCaja')?.value || '';", "const filtroMesCaja = document.getElementById('filtroMesCaja')?.value || '';`n        const filtroFecha = document.getElementById('filtroFechaCaja')?.value || '';")
$cajaFilterLogic = '(?s)(const filtrados = cajaData\.filter\(c => \{.*?)(return ok;)'
$html = [regex]::Replace($html, $cajaFilterLogic, '$1
           if (filtroMesCaja && c.fecha) {
              if (!c.fecha.startsWith(filtroMesCaja)) ok = false;
           }
           $2')

# Set default month in initialization
$initFnRegex = '(?s)function setFechasDefault\(\) \{(.*?)\}'
$html = [regex]::Replace($html, $initFnRegex, 'function setFechasDefault() {$1
        const mesActual = hoy.substring(0, 7);
        if(document.getElementById(''filtroMesCaja'')) document.getElementById(''filtroMesCaja'').value = mesActual;
        if(document.getElementById(''filtroMesLiq'')) document.getElementById(''filtroMesLiq'').value = mesActual;
      }')

# 3. Add Month Filter to Liquidaciones
$liqH3 = '<h3>Historial de Liquidaciones Realizadas</h3>'
$html = $html.Replace($liqH3, '<h3>Historial de Liquidaciones Realizadas</h3>
          <div style="margin-bottom: 12px; display: flex; gap: 10px; align-items: center;">
              <label style="color: var(--text-dim); font-size: 0.9rem;">Ver mes:</label>
              <input type="month" id="filtroMesLiq" onchange="renderizarHistorialLiquidaciones()">
              <button class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;" onclick="document.getElementById(''filtroMesLiq'').value=''''; renderizarHistorialLiquidaciones();">Todos</button>
          </div>')

# Modify cargarHistorialLiquidaciones to use filter
$cargarLiqRegex = '(?s)async function cargarHistorialLiquidaciones\(\) \{(.*?)liquidacionesData = data;\s*let totalSueldos = 0;(.*?)\}'

$replacementLiq = @'
async function cargarHistorialLiquidaciones() {$1liquidacionesData = data || [];
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
        let totalIngresosProf = 0;$2}
'@
$html = [regex]::Replace($html, $cargarLiqRegex, $replacementLiq)

# Make executing cierreMensual say "REINICIAR MES" prominently
$html = [regex]::Replace($html, '(?s)<button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var\(--danger-red\);" onclick="ejecutarCierreMensual\(\)">Resetear Cuotas a Pendiente</button>', '<button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var(--danger-red); width: 100%; border: 2px solid #ff4d4d; box-shadow: 0 0 10px rgba(255,0,0,0.3);" onclick="ejecutarCierreMensual()">REINICIAR MES (Resetear todas las cuotas a Pendiente)</button>
    <p style="color: var(--text-dim); margin-top: 10px; font-size: 0.9rem;">Al presionar este boton, todas las cuotas de los clientes volveran a estar pendientes para el nuevo mes. Sus notas y montos se mantendran. El Libro Diario y los Sueldos se reinician visualmente al seleccionar el nuevo mes en sus respectivos filtros.</p>')

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
