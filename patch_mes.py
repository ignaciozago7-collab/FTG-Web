import re

with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Fix the broken quote:
html = html.replace('value="${a.notas || \'}"', 'value="${a.notas || \'\'}"')

# Replace the "Reset" button using a regex that ignores whitespace
btn_pattern = re.compile(r'<button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var\(--danger-red\);" onclick="ejecutarCierreMensual\(\)">Resetear Cuotas a Pendiente</button>', re.DOTALL)
new_btn = """<button class="btn" style="padding: 16px 24px; font-size: 1.15rem; font-weight: bold; background: var(--danger-red); width: 100%; border: 2px solid #ff4d4d; box-shadow: 0 0 10px rgba(255,0,0,0.3);" onclick="ejecutarCierreMensual()">⚠️ REINICIAR MES (Resetear todas las cuotas a Pendiente)</button>
          <p style="color: var(--text-dim); margin-top: 10px; font-size: 0.9rem;">Al presionar este botón, todas las cuotas de los clientes volverán a estar pendientes para el nuevo mes. <strong>Tus notas escritas y montos se mantienen intactos</strong> para que sepas qué pasó el mes anterior.<br>El Libro Diario y los Sueldos se reinician visualmente al cambiar al nuevo mes en sus respectivos filtros superiores.</p>"""
html = btn_pattern.sub(new_btn, html)

# Replace setFechasDefault
fechas_pattern = re.compile(r"document\.getElementById\('fechaAsistencia'\)\.value = hoy;", re.DOTALL)
new_fechas = """document.getElementById('fechaAsistencia').value = hoy;
      const mesActual = hoy.substring(0, 7);
      if (document.getElementById('filtroMesCaja')) document.getElementById('filtroMesCaja').value = mesActual;
      if (document.getElementById('filtroMesLiq')) document.getElementById('filtroMesLiq').value = mesActual;"""
html = fechas_pattern.sub(new_fechas, html)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print("SUCCESS")
