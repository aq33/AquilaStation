// AQUILA - koniec rundy na mapie hex: zamiast powrotu do Outpost 45 okręt skacze do najbliższej przyjaznej stacji
// i tam kończy rundę. Następna runda zaczyna się przy tej stacji (hex_persistence.dm).
// SSstar_system.return_system zawsze wskazuje najbliższą przyjazną stację, więc ogłoszenia i głosowanie mówią, dokąd lecimy.

/// Przyjazna stacja w PR A: układ ze stacją handlową, którego właściciel i obecny okupant są z bloku NT (stocznie i depoty dochodzą w PR D)
/datum/hexmap/proc/is_friendly_station(datum/star_system/S, faction = "nanotrasen")
	if(!S?.trader || !S.hex || S.hidden)
		return FALSE
	if(hex_factions_hostile(faction, S.alignment) || hex_factions_hostile(faction, S.owner))
		return FALSE
	return S.owner in list("nanotrasen", "solgov", "whiterapids")

/// Najbliższa przyjazna stacja po trasie skoków (przez bramy też)
/datum/hexmap/proc/nearest_friendly_station(datum/hex/from, faction = "nanotrasen")
	RETURN_TYPE(/datum/star_system)
	if(!from)
		return
	var/datum/star_system/best
	var/best_cost = INFINITY
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!is_friendly_station(S, faction))
			continue
		if(S.hex == from)
			return S
		var/list/route = route(from, S.hex, faction, 5000)
		if(route && route["cost"] < best_cost)
			best_cost = route["cost"]
			best = S
	return best

/obj/structure/overmap/proc/hex_update_return_station()
	if(role != MAIN_OVERMAP || !GLOB.hexmap?.built)
		return
	var/datum/star_system/station = GLOB.hexmap.nearest_friendly_station(current_hex(), faction)
	if(station)
		SSstar_system.return_system = station

/datum/star_system/after_enter(obj/structure/overmap/OM)
	. = ..()
	if(OM?.role == MAIN_OVERMAP && !SSovermap_mode?.already_ended)
		OM.hex_update_return_station()

/obj/structure/overmap/force_return_jump()
	if(role != MAIN_OVERMAP || !GLOB.hexmap?.built)
		return ..()
	var/datum/star_system/station = SSstar_system.return_system
	if(!GLOB.hexmap.is_friendly_station(station))
		hex_update_return_station()
		station = SSstar_system.return_system
	var/datum/hex/here = current_hex()
	if(here && station && station.hex == here && ftl_drive?.ftl_state != FTL_STATE_JUMPING)
		SSovermap_mode.already_ended = TRUE
		if(ftl_drive)
			ftl_drive.lockout = TRUE
		hex_end_round_at(station)
		return
	if(here && station?.hex)
		var/list/route = GLOB.hexmap.route(here, station.hex, faction, 5000)
		hex_set_pending(0, route ? route["hexes"] : 0)
		RegisterSignal(station, COMSIG_STAR_SYSTEM_AFTER_ENTER, PROC_REF(hex_return_arrived), override = TRUE)
	return ..()

/obj/structure/overmap/proc/hex_return_arrived(datum/star_system/source, obj/structure/overmap/entering)
	SIGNAL_HANDLER
	if(entering != src)
		return
	UnregisterSignal(source, COMSIG_STAR_SYSTEM_AFTER_ENTER)
	INVOKE_ASYNC(src, PROC_REF(hex_end_round_at), source)

/// To samo, co wejście do Outpost 45 (after_enter z STARSYSTEM_END_ON_ENTER)
/obj/structure/overmap/proc/hex_end_round_at(datum/star_system/station)
	priority_announce("[station_name()] z powodzeniem dotarła do [station] na uzupełnienia i wymianę personelu. Doskonała robota, załogo.", "Dowództwo Marynarki")
	GLOB.crew_transfer_risa = TRUE
	SSticker.mode.check_finished()
	SSticker.news_report = SHIP_VICTORY
	SSblackbox.record_feedback("text", "nsv_endings", 1, "succeeded")
