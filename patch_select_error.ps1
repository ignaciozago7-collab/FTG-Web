$html = [System.IO.File]::ReadAllText("index.html", [System.Text.Encoding]::UTF8)

$targetSelect = @'
    async function cargarHistorialLiquidaciones() {
      const { data, error } = await _supabase.from('liquidaciones').select('*').order('created_at', { ascending: false });
      const ul = document.getElementById('historialLiquidaciones');
      if (!ul) return;

      if (error || !data || data.length === 0) {
        ul.innerHTML = '<li>No hay liquidaciones registradas.</li>';
        return;
      }
'@

$replacementSelect = @'
    async function cargarHistorialLiquidaciones() {
      const { data, error } = await _supabase.from('liquidaciones').select('*').order('created_at', { ascending: false });
      const ul = document.getElementById('historialLiquidaciones');
      if (!ul) return;

      if (error) {
        ul.innerHTML = `<li>Error cargando historial: ${error.message}</li>`;
        console.error("Supabase Select Error:", error);
        return;
      }

      if (!data || data.length === 0) {
        ul.innerHTML = '<li>No hay liquidaciones registradas.</li>';
        return;
      }
'@
$html = $html.Replace($targetSelect, $replacementSelect)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("index.html", $html, $utf8NoBom)
Write-Host "Success!"
