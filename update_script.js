const fs = require('fs');

let html = fs.readFileSync('index.html', 'utf8');
const start = 'function filtrarPlanes() {';
const end = '      `).join(\\'\\');\n    }';

const startIndex = html.indexOf(start);
const endIndex = html.indexOf(end) + end.length;

if (startIndex === -1 || endIndex === -1) {
    console.log("Could not find block");
    process.exit(1);
}

const replacement = `    function parsearFechaSemana(str) {
      if (!str) return 0;
      const match = str.match(/(\\d{1,2})\\/(\\d{1,2})/);
      if (match) {
        const d = parseInt(match[1], 10);
        const m = parseInt(match[2], 10);
        const date = new Date(new Date().getFullYear(), m - 1, d);
        return date.getTime();
      }
      return 0;
    }

    async function actualizarEstadoPlan(id, estado) {
      const { error } = await _supabase.from('planes').update({ estado }).eq('id', id);
      if (error) {
        alert('Error al actualizar estado. ¿Agregaste la columna estado en la base de datos? ' + error.message);
      } else {
        const plan = planesData.find(p => p.id === id);
        if (plan) plan.estado = estado;
      }
    }

    function filtrarPlanes() {
      const cont = document.getElementById('tbodyPlanes');
      if (!cont) return;

      const profFiltro = document.getElementById('filtroProfesorPlan')?.value || '';
      const textoBuscador = document.getElementById('buscadorPlan')?.value.toLowerCase().trim() || '';

      let filtrados = planesData.filter(p => {
        const coincideProf = !profFiltro || p.profesor === profFiltro;
        const coincideTexto = !textoBuscador || 
          (p.alumno && p.alumno.toLowerCase().includes(textoBuscador)) || 
          (p.semana && p.semana.toLowerCase().includes(textoBuscador));
        return coincideProf && coincideTexto;
      });

      if (filtrados.length === 0) {
        cont.innerHTML = '<p style="color: var(--text-dim); padding: 12px 0;">No hay planes registrados o coincidentes con la búsqueda.</p>';
        return;
      }

      filtrados.sort((a, b) => {
         const timeA = parsearFechaSemana(a.semana);
         const timeB = parsearFechaSemana(b.semana);
         if (timeA === 0 && timeB !== 0) return 1;
         if (timeB === 0 && timeA !== 0) return -1;
         return timeA - timeB;
      });

      const agrupados = {};
      filtrados.forEach(p => {
        if (!agrupados[p.profesor]) agrupados[p.profesor] = [];
        agrupados[p.profesor].push(p);
      });

      let htmlContent = '';
      for (const prof in agrupados) {
        htmlContent += \`<h4 style="margin-top: 20px; margin-bottom: 12px; color: var(--neon-green); border-bottom: 1px solid var(--border-color); padding-bottom: 6px;">Profesor: \${prof}</h4>\`;
        
        agrupados[prof].forEach(p => {
          const estado = p.estado || 'Sin hacer';
          htmlContent += \`
            <div style="background: #14141D; border: 1px solid var(--border-color); border-radius: 8px; padding: 12px 16px; margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
              <div style="flex: 1;">
                <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                  <strong style="font-size: 1.05rem;">\${p.alumno}</strong>
                  <span class="badge-presente" style="font-size: 0.75rem;">\${p.dias_semana || 3} días/sem</span>
                  <span style="font-size: 0.85rem; color: var(--neon-green); background: rgba(149,255,83,0.1); padding: 2px 6px; border-radius: 4px;">Semana: \${p.semana}</span>
                </div>
                <div style="font-size: 0.85rem; color: var(--text-dim); margin-top: 6px;">
                   <span style="margin-right: 8px;">Estado del plan:</span>
                   <select onchange="actualizarEstadoPlan(\${p.id}, this.value)" style="padding: 4px; font-size: 0.8rem; background: var(--bg-dark); border: 1px solid var(--border-color); color: #fff; border-radius: 4px;">
                     <option value="Sin hacer" \${estado === 'Sin hacer' ? 'selected' : ''}>Sin hacer</option>
                     <option value="Falta 1 día" \${estado === 'Falta 1 día' ? 'selected' : ''}>Falta 1 día</option>
                     <option value="Faltan 2 días" \${estado === 'Faltan 2 días' ? 'selected' : ''}>Faltan 2 días</option>
                     <option value="Faltan 3 días" \${estado === 'Faltan 3 días' ? 'selected' : ''}>Faltan 3 días</option>
                     <option value="Faltan 4 días" \${estado === 'Faltan 4 días' ? 'selected' : ''}>Faltan 4 días</option>
                     <option value="Faltan 5 días" \${estado === 'Faltan 5 días' ? 'selected' : ''}>Faltan 5 días</option>
                     <option value="Hecho" \${estado === 'Hecho' ? 'selected' : ''}>Hecho</option>
                   </select>
                </div>
                \${p.detalles ? \`<div style="font-size: 0.85rem; color: #fff; margin-top: 8px; background: rgba(255,255,255,0.03); padding: 6px 10px; border-radius: 4px;">📝 \${p.detalles}</div>\` : ''}
              </div>
              <button class="btn btn-danger" style="padding: 6px 12px;" onclick="borrarPlan(\${p.id})">Eliminar</button>
            </div>
          \`;
        });
      }

      cont.innerHTML = htmlContent;
    }`;

html = html.substring(0, startIndex) + replacement + html.substring(endIndex);
fs.writeFileSync('index.html', html);
console.log('Done');
