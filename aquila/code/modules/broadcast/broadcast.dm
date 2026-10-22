// AQUILA: port sieci transmisji TV z Monkestation (tg telescreen.dm, spesstv.dm)

/// Kto ogląda które transmisje: REF(oglądającego) -> c_tag kamery
GLOBAL_LIST(spesstv_viewers)

/**
 * Dodaje sieć kamer do wszystkich telewizorów rozrywkowych i Spess.tv.
 *
 * * camera_net - sieć (albo lista sieci) do dodania
 * * announcement - opcjonalny komunikat, który powiedzą telewizory
 */
/proc/start_broadcasting_network(camera_net, announcement)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, camera_net, TRUE, announcement)

/**
 * Zdejmuje sieć kamer ze wszystkich telewizorów rozrywkowych i Spess.tv.
 *
 * * camera_net - sieć (albo lista sieci) do zdjęcia
 * * announcement - opcjonalny komunikat na koniec programu
 */
/proc/stop_broadcasting_network(camera_net, announcement)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, camera_net, FALSE, announcement)

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
