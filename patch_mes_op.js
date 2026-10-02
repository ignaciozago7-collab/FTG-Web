const fs = require('fs');

let html = fs.readFileSync('index.html', 'utf8');

// 1. In DOMContentLoaded, use localStorage
const initRegex = /const mesActual = hoy\.slice\(0, 7\);\s*const elFechaAsistencia = document\.getElementById\('fechaAsistencia'\);\s*if \(elFechaAsistencia\) elFechaAsistencia\.value = hoy;\s*const elFiltro = document\.getElementById\('cierreMesFiltro'\);\s*if \(elFiltro\) elFiltro\.value = mesActual;\s*if \(document\.getElementById\('filtroMesCaja'\)\) document\.getElementById\('filtroMesCaja'\)\.value = mesActual;\s*if \(document\.getElementById\('filtroMesLiq'\)\) document\.getElementById\('filtroMesLiq'\)\.value = mesActual;/;

const replacementInit = `const mesActual = localStorage.getItem('mesOperativo') || hoy.slice(0, 7);
        
        const elFechaAsistencia = document.getElementById('fechaAsistencia');
        if (elFechaAsistencia) elFechaAsistencia.value = hoy;

        const elFiltro = document.getElementById('cierreMesFiltro');
        if (elFiltro) elFiltro.value = mesActual;
        if (document.getElementById('filtroMesCaja')) document.getElementById('filtroMesCaja').value = mesActual;
        if (document.getElementById('filtroMesLiq')) document.getElementById('filtroMesLiq').value = mesActual;
        
        // Sincronizar todos cuando uno cambia
        const syncMes = (e) => {
            const val = e.target.value;
            localStorage.setItem('mesOperativo', val);
            if (elFiltro && elFiltro !== e.target) elFiltro.value = val;
            if (document.getElementById('filtroMesCaja') && document.getElementById('filtroMesCaja') !== e.target) document.getElementById('filtroMesCaja').value = val;
            if (document.getElementById('filtroMesLiq') && document.getElementById('filtroMesLiq') !== e.target) document.getElementById('filtroMesLiq').value = val;
        };
        
        if (elFiltro) elFiltro.addEventListener('change', syncMes);
        if (document.getElementById('filtroMesCaja')) document.getElementById('filtroMesCaja').addEventListener('change', syncMes);
        if (document.getElementById('filtroMesLiq')) document.getElementById('filtroMesLiq').addEventListener('change', syncMes);`;

html = html.replace(initRegex, replacementInit);

fs.writeFileSync('index.html', html, 'utf8');
console.log('SUCCESS');
