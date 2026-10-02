const fs = require('fs');
let html = fs.readFileSync('index.html', 'utf-8');

// 1. Fix checkbox mass attendance
html = html.replace(/function renderizarListaMasivaAsistencia\(\) \{[\s\S]*?function filtrarListaMasivaAsistencia\(\) \{[\s\S]*?\}/, `function renderizarListaMasivaAsistencia() {
       const contenedor = document.getElementById('listaAsistenciaMasiva');
       const fechaSel = document.getElementById('fechaAsistencia').value;
       
       let html = '';
       const activos = alumnosData.filter(a => a.activo);
       let cantidadRenderizados = 0;
       
       activos.forEach(a => {
         const yaTiene = asistenciasMesData.some(as => String(as.alumno_id) === String(a.id) && as.fecha === fechaSel);
         if (yaTiene) return;
         
         cantidadRenderizados++;
         html += \`
           <label class="item-masivo-asistencia" style="display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 6px; border-radius: 4px; background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.05);" data-nombre="\${a.nombre.toLowerCase()}">
             <input type="checkbox" class="chk-masivo-asistencia" value="\${a.id}">
             <span>\${a.nombre}</span>
           </label>
         \`;
       });
       
       if (cantidadRenderizados === 0) {
           html = '<div style="color: var(--text-dim); grid-column: 1/-1;">No hay alumnos disponibles o todos ya estan presentes hoy.</div>';
       }
       contenedor.innerHTML = html;
       filtrarListaMasivaAsistencia();
    }

    function filtrarListaMasivaAsistencia() {
       const filtro = document.getElementById('buscadorMasivoAsistencia').value.toLowerCase();
       const items = document.querySelectorAll('.item-masivo-asistencia');
       items.forEach(item => {
           const nombre = item.getAttribute('data-nombre');
           if (filtro && !nombre.includes(filtro)) {
               item.style.display = 'none';
           } else {
               item.style.display = 'flex';
           }
       });
    }`);

// 2. Fix empty options for operators
html = html.replace(/<select id="cobrador-\$\{a\.id\}" style="padding: 8px;">[\s\S]*?<\/select>/g, `<select id="cobrador-\${a.id}" style="padding: 8px;">
                  <option value="" disabled selected>Seleccione...</option>
                  <option value="Nacho">Recibe: Nacho</option>
                  <option value="Lea">Recibe: Lea</option>
                  <option value="Ernesto">Recibe: Ernesto</option>
                  <option value="Mariano">Recibe: Mariano</option>
                  <option value="Elias">Recibe: Elias</option>
                </select>`);

html = html.replace(/const cobrador = cobradorEl \? cobradorEl\.value : 'Nacho';[\s\S]*?if \(estado && !fechaPagoSeleccionada\) \{/, `const cobrador = cobradorEl ? cobradorEl.value : null;
        
        const fechaEl = tabActivo.querySelector(\`[id="fecha-\${id}"]\`);
        const fechaPagoSeleccionada = fechaEl ? fechaEl.value : new Date().toISOString().split('T')[0];

        if (estado && !cobrador) {
          alert('Por favor, seleccione quien recibe el pago.');
          return;
        }

        if (estado && !fechaPagoSeleccionada) {`);

html = html.replace(/<select id="cajaOperadorManual" style="flex: 1;">[\s\S]*?<\/select>/, `<select id="cajaOperadorManual" style="flex: 1;">
              <option value="" disabled selected>Seleccione operador...</option>
              <option value="Nacho">Operó: Nacho</option>
              <option value="Lea">Operó: Lea</option>
              <option value="Ernesto">Operó: Ernesto</option>
              <option value="Mariano">Operó: Mariano</option>
              <option value="Elias">Operó: Elias</option>
            </select>`);

html = html.replace(/if \(!fecha \|\| !persona \|\| !detalle \|\| monto <= 0\) \{[\s\S]*?\}/, `if (!fecha || !persona || !detalle || monto <= 0 || !cobrador) {
          alert('Por favor completá todos los campos requeridos correctamente, incluyendo quién operó.');
          return;
        }`);

fs.writeFileSync('index.html', html, 'utf-8');
