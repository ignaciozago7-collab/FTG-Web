const fs = require('fs');

let html = fs.readFileSync('index.html', 'utf8');

const updateMatch = /async function actualizarEstadoPlan\(id, estado\) \{[\s\S]*?\}\s*\}/;
const newUpdate = `async function actualizarEstadoPlan(id, estado) {
      const { error } = await _supabase.from('planes').update({ estado }).eq('id', id);
      if (error) {
        alert('Error al actualizar estado: ' + error.message);
      } else {
        const plan = planesData.find(p => p.id === id);
        if (plan) plan.estado = estado;
        filtrarPlanes();
      }
    }`;
html = html.replace(updateMatch, newUpdate);

const filterMatch = /function filtrarPlanes\(\) \{[\s\S]*?\}[\s]*async function borrarPlan/m;
const newFilter = `function filtrarPlanes() {
      const cont = document.getElementById('tbodyPlanes');
      if (!cont) return;

      const profFiltro = document.getElementById('filtroProfesorPlan')?.value || '';
      const textoBuscador = document.getElementById('buscadorPlan')?.value.toLowerCase().trim() || '';

      const filtrados = planesData.filter(p => {
        const estado = p.estado || 'Sin hacer';
        if (estado === 'Hecho') return false; 
        
        const coincideProf = !profFiltro || p.profesor === profFiltro;
        const coincideTexto = !textoBuscador || 
          (p.alumno && p.alumno.toLowerCase().includes(textoBuscador)) || 
          (p.semana && p.semana.toLowerCase().includes(textoBuscador));
        return coincideProf && coincideTexto;
      });

      if (filtrados.length === 0) {
        cont.innerHTML = '<p style="color: var(--text-dim); padding: 12px 0;">No hay planes pendientes o coincidentes con la busqueda.</p>';
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
        if (!agrupados[p.profesor]) agrupados[p.profesor] = {};
        if (!agrupados[p.profesor][p.semana]) agrupados[p.profesor][p.semana] = [];
        agrupados[p.profesor][p.semana].push(p);
      });

      let htmlContent = '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; align-items: start;">';
      
      for (const prof in agrupados) {
        htmlContent += \`<div style="background: rgba(255,255,255,0.02); border: 1px solid var(--border-color); border-radius: 8px; padding: 15px;">\`;
        htmlContent += \`<h4 style="margin-top: 0; margin-bottom: 16px; color: var(--neon-green); font-size: 1.2rem; border-bottom: 1px solid var(--border-color); padding-bottom: 8px;">👨‍🏫 Prof: \${prof}</h4>\`;
        
        for (const sem in agrupados[prof]) {
           htmlContent += \`<div style="margin-bottom: 16px;">\`;
           htmlContent += \`<h5 style="color: #fff; margin-bottom: 10px; font-size: 1rem; background: rgba(0,0,0,0.2); padding: 4px 8px; border-radius: 4px; display: inline-block;">Semana: \${sem}</h5>\`;
           
           agrupados[prof][sem].forEach(p => {
             const estado = p.estado || 'Sin hacer';
             
             const esSinHacer = estado.includes('Sin hacer') ? 'selected' : '';
             const esFalta1 = estado.includes('Falta 1') ? 'selected' : '';
             const esFalta2 = estado.includes('Faltan 2') ? 'selected' : '';
             const esFalta3 = estado.includes('Faltan 3') ? 'selected' : '';
             const esFalta4 = estado.includes('Faltan 4') ? 'selected' : '';
             const esFalta5 = estado.includes('Faltan 5') ? 'selected' : '';
             
             htmlContent += \`
               <div style="background: #14141D; border: 1px solid var(--border-color); border-radius: 6px; padding: 12px; margin-bottom: 8px;">
                 <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; margin-bottom: 8px;">
                   <strong style="font-size: 1.05rem; color: #fff;">\${p.alumno}</strong>
                   <span class="badge-presente" style="font-size: 0.75rem;">\${p.dias_semana || 3} d/s</span>
                 </div>
                 
                 <div style="display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 8px;">
                   <select onchange="actualizarEstadoPlan(\${p.id}, this.value)" style="padding: 4px; font-size: 0.8rem; background: var(--bg-dark); border: 1px solid var(--border-color); color: #fff; border-radius: 4px; flex: 1;">
                     <option value="Sin hacer" \${esSinHacer}>Sin hacer</option>
                     <option value="Falta 1 dia" \${esFalta1}>Falta 1 dia</option>
                     <option value="Faltan 2 dias" \${esFalta2}>Faltan 2 dias</option>
                     <option value="Faltan 3 dias" \${esFalta3}>Faltan 3 dias</option>
                     <option value="Faltan 4 dias" \${esFalta4}>Faltan 4 dias</option>
                     <option value="Faltan 5 dias" \${esFalta5}>Faltan 5 dias</option>
                     <option value="Hecho">✔ Marcar Hecho</option>
                   </select>
                   <button class="btn btn-danger" style="padding: 4px 8px; font-size: 0.8rem;" onclick="borrarPlan(\${p.id})">🗑 Borrar</button>
                 </div>
                 
                 \${p.detalles ? \`<div style="font-size: 0.85rem; color: #aaa; background: rgba(255,255,255,0.03); padding: 6px; border-radius: 4px;">📝 \${p.detalles}</div>\` : ''}
               </div>
             \`;
           });
           htmlContent += \`</div>\`;
        }
        
        htmlContent += \`</div>\`;
      }
      
      htmlContent += '</div>';
      cont.innerHTML = htmlContent;
    }

    async function borrarPlan`;

html = html.replace(filterMatch, newFilter);

fs.writeFileSync('index.html', html, 'utf8');
console.log("Success");
