# Runs DreamDaemon and starts it again after every round restart.
# A round restart (/world/Reboot) leaves data/watchdog_restart; the watchdog then kills the process,
# because a BYOND 516 soft reboot hangs for minutes, and starts a fresh one.
# If DreamDaemon exits without the marker (normal shutdown, closed window), the watchdog ends too.
param(
	[int]$Port = 1337,
	[string]$ByondBin = ""
)
$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $root
$marker = Join-Path $root "data\watchdog_restart"

if(-not $ByondBin) {
	foreach($dir in @($env:BYOND516, "${env:ProgramFiles(x86)}\byond 516\BYOND\bin", "${env:ProgramFiles(x86)}\BYOND\bin", "$env:ProgramFiles\BYOND\bin")) {
		if($dir -and (Test-Path (Join-Path $dir "dreamdaemon.exe"))) { $ByondBin = $dir; break }
	}
}
$dd = Join-Path $ByondBin "dreamdaemon.exe"
if(-not (Test-Path $dd)) { Write-Host "dreamdaemon.exe not found. Pass -ByondBin <BYOND bin folder>."; exit 1 }

$env:AQUILA_WATCHDOG = "1"
while($true) {
	Remove-Item $marker -ErrorAction SilentlyContinue
	Write-Host "[$(Get-Date -Format T)] Starting DreamDaemon on port $Port"
	$proc = Start-Process -FilePath $dd -ArgumentList "`"$root\nsv13.dmb`"", $Port, "-trusted" -PassThru
	while(-not $proc.HasExited -and -not (Test-Path $marker)) { Start-Sleep -Seconds 1 }
	if(-not (Test-Path $marker)) {
		Write-Host "[$(Get-Date -Format T)] DreamDaemon stopped without a restart request, watchdog ends."
		break
	}
	Write-Host "[$(Get-Date -Format T)] Round restart requested, restarting DreamDaemon"
	Start-Sleep -Seconds 1 # let the world finish writing its logs
	if(-not $proc.HasExited) { Stop-Process -Id $proc.Id -Force; $proc.WaitForExit() }
}
