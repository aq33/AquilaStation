param([string]$root, [string]$out, [int]$secs)
# CPU (s) procesu $root i wszystkich jego potomków (WebView2), co 0,5 s; kropka dziesiętna niezależnie od języka systemu
$inv = [System.Globalization.CultureInfo]::InvariantCulture
$end = (Get-Date).AddSeconds($secs)
"t_ds,root_s,webview_s,webview_procs" | Out-File -Encoding ascii $out
while ((Get-Date) -lt $end) {
  $all = Get-CimInstance Win32_Process -Property ProcessId, ParentProcessId, Name, KernelModeTime, UserModeTime
  $r = $all | Where-Object { $_.Name -eq $root } | Select-Object -First 1
  if ($r) {
    $ids = @{ $r.ProcessId = $true }
    $changed = $true
    while ($changed) {
      $changed = $false
      foreach ($p in $all) { if (-not $ids.ContainsKey($p.ProcessId) -and $ids.ContainsKey($p.ParentProcessId)) { $ids[$p.ProcessId] = $true; $changed = $true } }
    }
    $rootCpu = ($r.KernelModeTime + $r.UserModeTime) / 1e7
    $kids = $all | Where-Object { $ids.ContainsKey($_.ProcessId) -and $_.ProcessId -ne $r.ProcessId }
    $kidCpu = 0; foreach ($k in $kids) { $kidCpu += ($k.KernelModeTime + $k.UserModeTime) / 1e7 }
    $t = [math]::Round((Get-Date).ToUniversalTime().TimeOfDay.TotalSeconds * 10)
    [string]::Format($inv, "{0},{1:F3},{2:F3},{3}", $t, $rootCpu, $kidCpu, @($kids).Count) | Out-File -Append -Encoding ascii $out
  }
  Start-Sleep -Milliseconds 500
}
