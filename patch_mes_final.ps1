$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$html = $html.Replace('value="${a.notas || ''}"', 'value="${a.notas || ''''}"')

$targetBtn = '<button class="btn" style="padding: 12px 24px; font-size: 1.1rem; background: var(--danger-red);" onclick="ejecutarCierreMensual()">Resetear Cuotas a Pendiente</button>'
$newBtn = '<button class="btn" style="padding: 16px 24px; font-size: 1.15rem; font-weight: bold; background: var(--danger-red); width: 100%; border: 2px solid #ff4d4d; box-shadow: 0 0 10px rgba(255,0,0,0.3);" onclick="ejecutarCierreMensual()">&#x26A0; REINICIAR MES (Resetear todas las cuotas a Pendiente)</button>
          <p style="color: var(--text-dim); margin-top: 10px; font-size: 0.9rem;">Al presionar este bot&oacute;n, todas las cuotas de los clientes volver&aacute;n a estar pendientes para el nuevo mes. <strong>Tus notas escritas y montos se mantienen intactos</strong> para que sepas qu&eacute; pas&oacute; el mes anterior.<br>El Libro Diario y los Sueldos se reinician visualmente al cambiar al nuevo mes en sus respectivos filtros superiores.</p>'
$html = $html.Replace($targetBtn, $newBtn)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
