const fs = require('fs');
let html = fs.readFileSync('index.html', 'utf8');

// Replace button
html = html.replace(/<button class="btn btn-warning" onclick="ejecutarCierreMensual\(\)">.*Resetear Cuotas a Pendiente<\/button>/, `<button class="btn" style="padding: 16px 24px; font-size: 1.15rem; font-weight: bold; background: var(--danger-red); width: 100%; border: 2px solid #ff4d4d; box-shadow: 0 0 10px rgba(255,0,0,0.3);" onclick="ejecutarCierreMensual()">&#x26A0; REINICIAR MES (Resetear todas las cuotas a Pendiente)</button>
          <p style="color: var(--text-dim); margin-top: 10px; font-size: 0.9rem;">Al presionar este bot&oacute;n, todas las cuotas de los clientes volver&aacute;n a estar pendientes para el nuevo mes. <strong>Tus notas escritas y montos se mantienen intactos</strong> para que sepas qu&eacute; pas&oacute; el mes anterior.<br>El Libro Diario y los Sueldos se reinician visualmente al cambiar al nuevo mes en sus respectivos filtros superiores.</p>`);

// Replace setFechasDefault
html = html.replace(/document\.getElementById\('fechaAsistencia'\)\.value = hoy;/, `document.getElementById('fechaAsistencia').value = hoy;
      const mesActual = hoy.substring(0, 7);
      if (document.getElementById('filtroMesCaja')) document.getElementById('filtroMesCaja').value = mesActual;
      if (document.getElementById('filtroMesLiq')) document.getElementById('filtroMesLiq').value = mesActual;`);

fs.writeFileSync('index.html', html, 'utf8');
