$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$targetSelect = @'
                     <option value="Sin hacer" ${esSinHacer}>Sin hacer</option>
                     <option value="Falta 1 dia" ${esFalta1}>Falta 1 dia</option>
                     <option value="Faltan 2 dias" ${esFalta2}>Faltan 2 dias</option>
                     <option value="Hecho">? Marcar como Hecho</option>
'@

$replacementSelect = @'
                     <option value="Sin hacer" ${esSinHacer}>Sin hacer</option>
                     <option value="Falta 1 dia" ${esFalta1}>Falta 1 dia</option>
                     <option value="Faltan 2 dias" ${esFalta2}>Faltan 2 dias</option>
                     <option value="Faltan 3 dias" ${estado.includes('Faltan 3') ? 'selected' : ''}>Faltan 3 dias</option>
                     <option value="Faltan 4 dias" ${estado.includes('Faltan 4') ? 'selected' : ''}>Faltan 4 dias</option>
                     <option value="Faltan 5 dias" ${estado.includes('Faltan 5') ? 'selected' : ''}>Faltan 5 dias</option>
                     <option value="Hecho">✔ Marcar Hecho</option>
'@
$html = $html.Replace($targetSelect, $replacementSelect)

# Fix emojis
$html = [regex]::Replace($html, '\?\? Prof:', '👨‍🏫 Prof:')
$html = [regex]::Replace($html, '\? Borrar', '🗑 Borrar')
$html = [regex]::Replace($html, '\? \$\{p.detalles\}', '📝 ${p.detalles}')


$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
