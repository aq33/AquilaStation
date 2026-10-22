// AQUILA: port sieci transmisji TV z Monkestation (tg telescreen.dm, spesstv.dm)

/// Kto ogląda które transmisje: REF(oglądającego) -> c_tag kamery
GLOBAL_LIST(spesstv_viewers)

/// Sieć kamer -> lista nadawców (REF), żeby wyłączenie jednej kamery nie gasiło sieci, w której nadaje druga
GLOBAL_LIST_EMPTY(broadcast_network_sources)

/**
 * Dodaje sieć kamer do wszystkich telewizorów rozrywkowych i Spess.tv.
 *
 * * camera_net - sieć (albo lista sieci) do dodania
 * * announcement - opcjonalny komunikat, który powiedzą telewizory
 * * source - nadawca (kamera, serwer kwantowy); sieć gaśnie dopiero po zatrzymaniu ostatniego nadawcy
 */
/proc/start_broadcasting_network(camera_net, announcement, datum/source)
	var/source_key = source ? REF(source) : "global"
	for(var/net in islist(camera_net) ? camera_net : list(camera_net))
		var/list/sources = LAZYACCESS(GLOB.broadcast_network_sources, net)
		if(!(source_key in sources))
			LAZYADDASSOCLIST(GLOB.broadcast_network_sources, net, source_key)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, camera_net, TRUE, announcement)

/**
 * Zdejmuje nadawcę z sieci kamer. Telewizory i Spess.tv tracą sieć, gdy nie nadaje w niej już nikt.
 *
 * * camera_net - sieć (albo lista sieci) do zdjęcia
 * * announcement - opcjonalny komunikat na koniec programu
 * * source - nadawca podany przy starcie
 */
/proc/stop_broadcasting_network(camera_net, announcement, datum/source)
	var/source_key = source ? REF(source) : "global"
	var/list/ended = list()
	for(var/net in islist(camera_net) ? camera_net : list(camera_net))
		LAZYREMOVEASSOC(GLOB.broadcast_network_sources, net, source_key)
		if(!LAZYACCESS(GLOB.broadcast_network_sources, net))
			ended += net
	if(length(ended))
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, islist(camera_net) ? ended : ended[1], FALSE, announcement)

/**
 * Ustawia stan sieci na wszystkich telewizorach, gdy nie wiadomo, w jakim jest teraz.
 * Komunikat zostanie powiedziany niezależnie od poprzedniego stanu.
 */
/proc/set_network_broadcast_status(camera_net, is_show_active, announcement)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, camera_net, is_show_active, announcement)

/// Zapisuje, którą kamerę ogląda dany telewizor albo PDA (do licznika widzów)
/proc/update_spesstv_watcher_list(key, obj/machinery/camera/active_camera)
	if(QDELETED(active_camera) || !active_camera.can_use())
		LAZYREMOVE(GLOB.spesstv_viewers, key)
	else
		LAZYSET(GLOB.spesstv_viewers, key, active_camera.c_tag)

/// Ilu widzów ogląda tę kamerę przez telewizory i Spess.tv
/obj/machinery/camera/proc/count_spesstv_viewers()
	. = 0
	var/list/spesstv_viewers = GLOB.spesstv_viewers
	for(var/key in spesstv_viewers)
		if(spesstv_viewers[key] == c_tag)
			.++
