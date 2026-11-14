/// AQUILA - wraki zestrzelonych okrętów (plan walki na overmapie, etap „wraki”). Wrak z portu shipbreakingu
/// (aquila/code/modules/shipbreaking/wrecks.dm) przejmuje wnętrze abordażu i moduły okrętu: konsola odzysku może go
/// abordażować, a we wnętrzu widać skutki walki (martwa załoga, rozbite moduły, dziury po trafieniach). Magnes dalej
/// wciąga wrak do złomowania. W systemie zostaje najwyżej SHIPBREAK_MAX_WRECKS wraków, najstarsze się rozpadają.

#define SHIPBREAK_MAX_WRECKS 8

/datum/ship_modules
	/// Moduły martwego okrętu (wraku): przy wczytaniu wnętrza nikt nie przeżył, a role duchów znikają
	var/derelict = FALSE

/obj/structure/overmap/asteroid/shipbreak_wreck
	/// Stan sprite'a okrętu, z którego został wrak (bez przyrostka uszkodzeń), do obrysu w skali wizualnej
	var/wreck_display_state

/obj/structure/overmap/asteroid/shipbreak_wreck/copy_ship(obj/structure/overmap/source)
	. = ..()
	wreck_display_state = initial(source.icon_state)
	overmap_hitbox_icon = source.overmap_hitbox_icon || source.icon
	overmap_hitbox_state = source.overmap_hitbox_state || initial(source.icon_state)
	apply_overmap_hitbox()
	start_vfx() // obrys sprite'a jest dopiero po skopiowaniu okrętu (ship_vfx.dm)
	if(!length(source.possible_interior_maps))
		return
	possible_interior_maps = source.possible_interior_maps.Copy()
	interior_mode = INTERIOR_EXCLUSIVE
	// moduły okrętu przechodzą na wrak (stan po walce), a bez nich wrak dostaje świeże moduły z losowymi zniszczeniami
	if(source.ship_modules)
		ship_modules = source.ship_modules
		source.ship_modules = null
		ship_modules.ship = src
	else
		get_ship_modules()
		for(var/datum/ship_module/module as anything in ship_modules?.modules)
			module.integrity = round(module.max_integrity * rand(0, 60) / 100)
	if(!ship_modules)
		return
	deltimer(ship_modules.sim_timer)
	ship_modules.sim_timer = null
	ship_modules.derelict = TRUE
	for(var/datum/ship_module/module as anything in ship_modules.modules)
		module.crew_lost = 1
		module.fire = 0

/obj/structure/overmap/asteroid/shipbreak_wreck/overmap_display_bounds()
	if(wreck_display_state)
		return overmap_sprite_bounds_of(icon, wreck_display_state)
	return ..()

// Wrak to asteroida, ale moduły (wnętrze z bitwy) ma, jeśli przejął je od okrętu
/obj/structure/overmap/asteroid/shipbreak_wreck/uses_ship_modules()
	return length(possible_interior_maps) > 0

/datum/ship_modules/apply_module_to_turfs(datum/ship_module/module, list/turfs)
	. = ..()
	if(!derelict)
		return
	for(var/turf/T as anything in turfs)
		for(var/obj/effect/mob_spawn/spawner in T)
			qdel(spawner)

/// Najstarsze wraki w systemie rozpadają się, gdy jest ich więcej niż limit
/datum/star_system/proc/prune_shipbreak_wrecks(limit = SHIPBREAK_MAX_WRECKS)
	var/list/wrecks = list()
	for(var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck in system_contents)
		if(!QDELETED(wreck) && !length(wreck.occupying_levels))
			wrecks += wreck
	while(length(wrecks) > limit)
		var/obj/structure/overmap/asteroid/shipbreak_wreck/oldest = wrecks[1]
		wrecks.Cut(1, 2)
		qdel(oldest)

#undef SHIPBREAK_MAX_WRECKS
