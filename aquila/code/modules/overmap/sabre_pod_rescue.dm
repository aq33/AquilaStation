// AQUILA - Sabre przechwytuje kapsuły ratunkowe (zgłoszenie graczy): kapsuła nie zadokuje do promu, bo Sabre nie ma
// punktów dokowania, a z kapsuły w kosmosie nie da się wyjść. Przy zetknięciu z Sabre ludzie z kapsuły przechodzą
// do wnętrza promu przy włazie, a pusta kapsuła znika. Działa w obie strony: kapsuła wpada na Sabre albo Sabre na kapsułę.
// Tylko kapsuły tej samej frakcji: wrogi pilot nie może wejść na prom, taranując go kapsułą.

/obj/structure/overmap/small_craft/escapepod/docking_act(obj/structure/overmap/OM)
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = OM
	if(istype(sabre) && sabre.rescue_escape_pod(src))
		return TRUE
	return ..()

/obj/structure/overmap/small_craft/transport/sabre/shuttle/docking_act(obj/structure/overmap/OM)
	if(istype(OM, /obj/structure/overmap/small_craft/escapepod))
		return rescue_escape_pod(OM)
	return ..()

/// Przenosi wszystkich z kapsuły do wnętrza promu i usuwa kapsułę. FALSE, gdy nie ma kogo albo dokąd zabrać.
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/rescue_escape_pod(obj/structure/overmap/small_craft/escapepod/pod)
	if(QDELETED(pod) || QDELETED(src) || shuttle_docked_at || !length(interior_entry_points) || pod.faction != faction)
		return FALSE
	var/list/survivors = list()
	for(var/mob/living/M in pod.mobs_in_ship)
		if(M.loc == pod)
			survivors += M
	if(!length(survivors))
		return FALSE
	for(var/mob/living/M as anything in survivors)
		pod.stop_piloting(M, eject_mob = FALSE, force = TRUE) // poza poziomem z ZTRAIT_BOARDABLE kapsuła bez force nie zwalnia sterów
		pod.mobs_in_ship -= M
		M.stop_sound_channel(CHANNEL_SHIP_ALERT)
		enter(M)
		to_chat(M, span_notice("Załoga [src] wciąga cię przez właz z kapsuły ratunkowej."))
	// Reszta zawartości (przedmioty, MMI) też trafia do promu; części kapsuły znikają razem z nią
	var/turf/hatch = get_turf(pick(interior_entry_points))
	for(var/obj/item/thing in pod)
		if(!istype(thing, /obj/item/fighter_component))
			thing.forceMove(hatch)
	relay('nsv13/sound/effects/ship/freespace2/crane_short.ogg', span_notice("Przechwycono kapsułę ratunkową. Rozbitkowie wchodzą na pokład przez właz: [length(survivors)]."))
	qdel(pod)
	return TRUE
