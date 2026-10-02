$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$targetRender = @'
        return `
          <li>
            <div>
              <strong>${l.staff_nombre}</strong> - <span style="color: ${colorMonto};">${signoMonto}$${valorMonto.toLocaleString()}</span>
              <div style="font-size: 0.8rem; color: var(--text-dim);">📅 ${fStr} | Pagó: <strong>${l.operador}</strong> | ${l.detalle}</div>
            </div>
'@

$replacementRender = @'
        return `
          <li>
            <div>
              <strong>${l.staff_nombre || 'Desconocido'}</strong> - <span style="color: ${colorMonto};">${signoMonto}$${valorMonto.toLocaleString()}</span>
              <div style="font-size: 0.8rem; color: var(--text-dim);">📅 ${fStr} | Pagó: <strong>${l.operador || 'N/A'}</strong> | ${l.detalle || 'Sin detalle (Registro Antiguo)'}</div>
            </div>
'@

$html = $html.Replace($targetRender, $replacementRender)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
