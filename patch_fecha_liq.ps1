$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$targetMap = @'
      ul.innerHTML = data.map(l => {
        const fStr = new Date(l.fecha + 'T12:00:00').toLocaleDateString('es-AR');
'@
$replacementMap = @'
      ul.innerHTML = data.map(l => {
        let fStr = '-';
        try {
            if (l.fecha) fStr = new Date(l.fecha + 'T12:00:00').toLocaleDateString('es-AR');
            else if (l.created_at) fStr = new Date(l.created_at).toLocaleDateString('es-AR');
        } catch(e) {}
'@

$html = $html.Replace($targetMap, $replacementMap)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
