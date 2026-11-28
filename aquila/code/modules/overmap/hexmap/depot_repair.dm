// AQUILA - sojuszniczy depot za darmo naprawia okręt gracza (kadłub i płyty pancerza), tak jak floty NPC w war_core.dm depots().
// Naprawa rusza po wejściu do układu z depotem bloku NT i idzie co DEPOT_REPAIR_INTERVAL, dopóki okręt stoi w układzie,
// depot należy do sojusznika i nie ma wrogich flot. Wnętrza (ścian, maszyn) depot nie naprawia.

/// Co ile depot dokłada naprawę
#define DEPOT_REPAIR_INTERVAL (10 SECONDS)
/// Ile procent kadłuba i każdej płyty pancerza na raz (od zera do pełna ok. 3 minuty)
#define DEPOT_REPAIR_PERCENT 5

/obj/structure/overmap
	/// Układ, którego depot naprawia teraz okręt (null = brak naprawy)
	var/datum/star_system/depot_repair_system

/datum/star_system/after_enter(obj/structure/overmap/OM)
	. = ..()
	if(OM?.role == MAIN_OVERMAP)
		OM.try_start_depot_repair(src)

/// Okręt uszkodzony już w układzie z depotem (np. po odparciu ataku) łapie naprawę przy turze wojny
/datum/hex_war/depots()
	. = ..()
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	main_ship?.try_start_depot_repair(main_ship.current_system)

/// Czy depot w układzie S naprawi teraz ten okręt
/obj/structure/overmap/proc/can_depot_repair(datum/star_system/S)
	if(!S || current_system != S || !S.has_facility(HEX_FAC_DEPOT))
		return FALSE
	if(!hex_factions_allied(S.owner, faction) || hex_factions_hostile(faction, S.alignment))
		return FALSE
	return !length(hex_hostile_fleets_in(S, faction))

/obj/structure/overmap/proc/needs_depot_repair()
	if(obj_integrity < max_integrity)
		return TRUE
	if(use_armour_quadrants)
		for(var/quadrant in armour_quadrants)
			if(armour_quadrants[quadrant]["current_armour"] < armour_quadrants[quadrant]["max_armour"])
				return TRUE
	return FALSE

/obj/structure/overmap/proc/try_start_depot_repair(datum/star_system/S)
	if(depot_repair_system == S || !can_depot_repair(S) || !needs_depot_repair())
		return
	depot_repair_system = S
	relay(null, "<span class='notice'><b>Depot w układzie [S] przyjmuje nas do darmowej naprawy kadłuba i pancerza.</b></span>")
	addtimer(CALLBACK(src, PROC_REF(depot_repair_tick)), DEPOT_REPAIR_INTERVAL)

/obj/structure/overmap/proc/depot_repair_tick()
	var/datum/star_system/S = depot_repair_system
	if(QDELETED(src) || !S)
		return
	if(!can_depot_repair(S))
		depot_repair_system = null
		if(current_system == S)
			relay(null, "<span class='warning'>Depot w układzie [S] przerywa naprawę.</span>")
		return
	repair_structure(DEPOT_REPAIR_PERCENT)
	repair_all_quadrants(DEPOT_REPAIR_PERCENT)
	if(!needs_depot_repair())
		depot_repair_system = null
		relay(null, "<span class='notice'><b>Depot w układzie [S] zakończył naprawę. Kadłub i pancerz są sprawne.</b></span>")
		return
	addtimer(CALLBACK(src, PROC_REF(depot_repair_tick)), DEPOT_REPAIR_INTERVAL)

#undef DEPOT_REPAIR_INTERVAL
#undef DEPOT_REPAIR_PERCENT
