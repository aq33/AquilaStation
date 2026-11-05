/**
 * Odświeżanie monitora gracza. Panel czatu (tgui-panel, refreshRate.ts) mierzy rytm requestAnimationFrame
 * i wysyła go jako "display/refresh_rate". Przy FPS „Zalecane” klient dostaje FPS równe odświeżaniu:
 * 100 FPS na monitorze 144 Hz pokazywało co drugą klatkę przez dwa odświeżenia i ruch drżał
 * (pomiar: raport/perf_02_przyciecia_animacja_chodu.md).
 */
/client/var/monitor_refresh_rate

/// Zamienia zmierzone odświeżanie na FPS klienta; null, gdy pomiar jest niewiarygodny.
/proc/monitor_refresh_to_fps(hz)
	hz = text2num("[hz]")
	if(!isnum(hz) || hz < 30 || hz > 500)
		return null
	return clamp(round(hz, 1), 30, 240) // round() z jednym argumentem zaokrągla w dół

/client/proc/set_monitor_refresh_rate(hz)
	var/new_fps = monitor_refresh_to_fps(hz)
	if(!new_fps)
		return
	monitor_refresh_rate = new_fps
	if(prefs && prefs.clientfps < 0)
		fps = prefs.get_client_fps()
