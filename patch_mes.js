const fs = require('fs');

let html = fs.readFileSync('index.html', 'utf8');

// 1. Add "notas" column input in Alumnos table
const infoClienteRegex = /(<div class="info-cliente">[\s\S]*?)(<\/div>\s*<div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">)/;
if (infoClienteRegex.test(html)) {
    html = html.replace(infoClienteRegex, `$1
                <div style="margin-top: 6px; display: flex; align-items: center; gap: 8px;">
                   <span style="font-size: 0.85rem; color: var(--text-dim);">Notas:</span>
                   <input type="text" id="notas-al-\${a.id}" value="\${a.notas || ''}" placeholder="Ej: debe mes pasado, a favor..." style="padding: 4px; font-size: 0.8rem; background: #14141D; border: 1px solid var(--border-color); color: #fff; border-radius: 4px; flex: 1;" onchange="guardarNotaAlumno(\${a.id}, this.value)">
                </div>
              $2`);
}

// Add the JS function for saving notas
const jsEnd = html.lastIndexOf('</script>');
if (jsEnd !== -1) {
    const fnNotas = `
      async function guardarNotaAlumno(id, nota) {
        const { error } = await _supabase.from('alumnos').update({ notas: nota }).eq('id', id);
        if (error) {
           alert('Error al guardar nota: ' + error.message);
        } else {
           const idx = alumnosData.findIndex(a => a.id == id);
           if(idx !== -1) alumnosData[idx].notas = nota;
        }
      }
    `;
    html = html.slice(0, jsEnd) + fnNotas + html.slice(jsEnd);
}

// 2. Add Month Filter to Libro Diario
const libroDiarioH3 = /<h3>Asientos Contables<\/h3>/;
if (libroDiarioH3.test(html)) {
    html = html.replace(libroDiarioH3, `<h3>Asientos Contables</h3>
            <div style="margin-bottom: 12px; display: flex; gap: 10px; align-items: center;">
              <label style="color: var(--text-dim); font-size: 0.9rem;">Ver mes:</label>
              <input type="month" id="filtroMesCaja" onchange="cargarLibroDiario()">
              <button class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;" onclick="document.getElementById('filtroMesCaja').value=''; cargarLibroDiario();">Todos</button>
            </div>`);
}

// Modify renderizarLibroDiario to use filtroMesCaja
const renderCajaFiltrosRegex = /(const filtroFecha = document.getElementById\('filtroFechaCaja'\)\?.value \|\| '';)/;
if (renderCajaFiltrosRegex.test(html)) {
    html = html.replace(renderCajaFiltrosRegex, `$1
        const filtroMesCaja = document.getElementById('filtroMesCaja')?.value || '';`);
        
    const cajaFilterLogic = /(const filtrados = cajaData\.filter\(c => \{[\s\S]*?)(return ok;)/;
    html = html.replace(cajaFilterLogic, `$1
           if (filtroMesCaja && c.fecha) {
              if (!c.fecha.startsWith(filtroMesCaja)) ok = false;
           }
           $2`);
}

// Set default month in initialization
const initFnRegex = /function setFechasDefault\(\) \{([\s\S]*?)\}/;
if (initFnRegex.test(html)) {
    html = html.replace(initFnRegex, `function setFechasDefault() {
        $1
        const mesActual = hoy.substring(0, 7);
        if(document.getElementById('filtroMesCaja')) document.getElementById('filtroMesCaja').value = mesActual;
        if(document.getElementById('filtroMesLiq')) document.getElementById('filtroMesLiq').value = mesActual;
      }`);
}


// 3. Add Month Filter to Liquidaciones
const liqH3 = /<h3>Historial de Liquidaciones Realizadas<\/h3>/;
if (liqH3.test(html)) {
    html = html.replace(liqH3, `<h3>Historial de Liquidaciones Realizadas</h3>
          <div style="margin-bottom: 12px; display: flex; gap: 10px; align-items: center;">
              <label style="color: var(--text-dim); font-size: 0.9rem;">Ver mes:</label>
              <input type="month" id="filtroMesLiq" onchange="renderizarHistorialLiquidaciones()">
              <button class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;" onclick="document.getElementById('filtroMesLiq').value=''; renderizarHistorialLiquidaciones();">Todos</button>
          </div>`);
}

// Modify cargarHistorialLiquidaciones to use filter
const cargarLiqRegex = /async function cargarHistorialLiquidaciones\(\) \{([\s\S]*?)liquidacionesData = data;\s*let totalSueldos = 0;([\s\S]*?)\}/;
if (cargarLiqRegex.test(html)) {
    html = html.replace(cargarLiqRegex, `async function cargarHistorialLiquidaciones() {
        const { data, error } = await _supabase.from('liquidaciones').select('*').order('created_at', { ascending: false });
        const ul = document.getElementById('historialLiquidaciones');
        if (!ul) return;
  
        if (error) {
          ul.innerHTML = '<li>Error cargando historial: ' + error.message + '</li>';
          return;
        }
  
        liquidacionesData = data || [];
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
        let totalIngresosProf = 0;
        data.forEach(l => {
           const valorMonto = parseFloat(l.monto) || parseFloat(l.total_a_pagar) || 0;
           if (l.detalle && l.detalle.toLowerCase().includes('ingreso comision')) {
               totalIngresosProf += valorMonto;
           } else if (l.detalle && l.detalle.toLowerCase().includes('liquidaci')) {
               totalSueldos += valorMonto;
           }
        });

        const headerTotales = \`
           <div style="background: rgba(255,255,255,0.03); border: 1px solid var(--border-color); padding: 12px; margin-bottom: 12px; border-radius: 8px; display: flex; gap: 20px; flex-wrap: wrap;">
               <div><strong>Total Sueldos (Profesores):</strong> <span style="color: var(--danger-red); margin-left: 4px;">-$\${totalSueldos.toLocaleString()}</span></div>
               <div><strong>Total Ingresos (Profesionales):</strong> <span style="color: var(--neon-green); margin-left: 4px;">+$\${totalIngresosProf.toLocaleString()}</span></div>
           </div>
        \`;

        ul.innerHTML = headerTotales + data.map(l => {
          const valorMonto = parseFloat(l.monto) || parseFloat(l.total_a_pagar) || 0;
          let colorMonto = 'var(--text-color)';
          let signoMonto = '';
          
          if (l.detalle && l.detalle.toLowerCase().includes('ingreso comision')) {
              colorMonto = 'var(--neon-green)';
              signoMonto = '+';
          } else {
              colorMonto = 'var(--danger-red)';
              signoMonto = '-';
          }

          let fStr = 'Fecha desconocida';
          if (l.fecha) {
             fStr = new Date(l.fecha + 'T12:00:00').toLocaleDateString('es-AR');
          } else if (l.created_at) {
             fStr = new Date(l.created_at).toLocaleDateString('es-AR');
          }

          return \`
          <li>
            <div>
              <strong>\${l.staff_nombre || 'Desconocido'}</strong> - <span style="color: \${colorMonto};">\${signoMonto}$\${valorMonto.toLocaleString()}</span>
              <div style="font-size: 0.8rem; color: var(--text-dim);">📅 \${fStr} | Pagó: <strong>\${l.operador}</strong> | \${l.detalle || 'Sin detalle (Registro Antiguo)'}</div>
            </div>
            <div style="display: flex; gap: 6px;">
                <button class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;" onclick="modificarLiquidacion(\${l.id})">Editar</button>
                <button class="btn btn-danger" style="padding: 4px 8px; font-size: 0.8rem;" onclick="borrarLiquidacion(\${l.id})">Borrar</button>
            </div>
          </li>
          \`;
        }).join('');
      }
    `);
}

// Make executing cierreMensual say "REINICIAR MES" prominently
const buttonCierreRegex = /<button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var\(--danger-red\);" onclick="ejecutarCierreMensual\(\)">Resetear Cuotas a Pendiente<\/button>/;
if (buttonCierreRegex.test(html)) {
    html = html.replace(buttonCierreRegex, `<button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var(--danger-red); width: 100%; border: 2px solid #ff4d4d; box-shadow: 0 0 10px rgba(255,0,0,0.3);" onclick="ejecutarCierreMensual()">⚠️ REINICIAR MES (Resetear todas las cuotas a Pendiente)</button>
    <p style="color: var(--text-dim); margin-top: 10px; font-size: 0.9rem;">Al presionar este botón, todas las cuotas de los clientes volverán a estar pendientes para el nuevo mes. Sus notas y montos se mantendrán. El Libro Diario y los Sueldos se reinician visualmente al seleccionar el nuevo mes en sus respectivos filtros.</p>`);
}

fs.writeFileSync('index.html', html, 'utf8');
console.log("SUCCESS");
