/// AQUILA - wraki zestrzelonych okrętów (plan walki na overmapie, etap „wraki”). Wrak z portu shipbreakingu
/// (aquila/code/modules/shipbreaking/wrecks.dm) przejmuje wnętrze abordażu i moduły okrętu: konsola odzysku może go
/// abordażować, a we wnętrzu widać skutki walki (martwa załoga, rozbite moduły, dziury po trafieniach). Wraku nie rozbiera
/// się w całości: magnes wyciąga z niego promy i statki do złomowania (salvage_left, zależnie od klasy okrętu i ocalałych
/// ładowni i hangaru), a wrak zostaje. Działa rozbijają go na pole szczątków (PDC nic mu nie robi). W systemie zostaje
/// najwyżej SHIPBREAK_MAX_WRECKS wraków, najstarsze się rozpadają.

#define SHIPBREAK_MAX_WRECKS 8

/datum/ship_modules
	/// Moduły martwego okrętu (wraku): przy wczytaniu wnętrza nikt nie przeżył, a role duchów znikają
	var/derelict = FALSE

/obj/structure/overmap/asteroid/shipbreak_wreck
	/// Stan sprite'a okrętu, z którego został wrak (bez przyrostka uszkodzeń), do obrysu w skali wizualnej
	var/wreck_display_state

/obj/structure/overmap/asteroid/shipbreak_wreck/copy_ship(obj/structure/overmap/source)
	. = ..()
	// nowy sprite (ship_sprites.dm) nie ma stanów uszkodzeń, a frachtowce i małe jednostki zmieniają stan w grze
	overmap_native_sprite = source.uses_native_sprite()
	wreck_display_state = overmap_native_sprite ? source.icon_state : initial(source.icon_state)
	overmap_hitbox_icon = source.overmap_hitbox_icon || source.icon
	overmap_hitbox_state = source.overmap_hitbox_state || wreck_display_state
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

// ---- Wytrzymałość i promy do wyciągnięcia ----

/// Wytrzymałość wraku: część kadłuba okrętu, z którego powstał, ale nie mniej niż WRECK_MIN_INTEGRITY
#define WRECK_MIN_INTEGRITY 300
#define WRECK_INTEGRITY_SHARE 0.4

/obj/structure/overmap/asteroid/shipbreak_wreck
	max_integrity = WRECK_MIN_INTEGRITY
	obj_integrity = WRECK_MIN_INTEGRITY
	// PDC i lekkie działka go nie ruszają, działa tak (asteroida bierze tylko ciężkie)
	armor = list("overmap_light" = 80, "overmap_medium" = 0, "overmap_heavy" = 0)
	/// Ile promów i statków do złomowania magnes jeszcze z niego wyciągnie
	var/salvage_left = 1

/obj/structure/overmap/asteroid/shipbreak_wreck/Initialize(mapload)
	. = ..()
	salvage_left = rand(1, 2) // losowy wrak w układzie; zestrzelony okręt nadpisze to w copy_ship()

/obj/structure/overmap/asteroid/shipbreak_wreck/copy_ship(obj/structure/overmap/source)
	. = ..()
	max_integrity = max(WRECK_MIN_INTEGRITY, round(source.max_integrity * WRECK_INTEGRITY_SHARE))
	obj_integrity = max_integrity
	salvage_left = wreck_salvage_count(source, ship_modules)

/// Ile promów da się wyciągnąć z wraku: klasa okrętu (1-4) razy stan ładowni i hangaru (moduły z bitwy)
/proc/wreck_salvage_count(obj/structure/overmap/source, datum/ship_modules/modules)
	var/base = clamp(round(source.mass / 2), 1, 4)
	if(!modules || !(modules.has_kind("cargo") || modules.has_kind("hangar")))
		return base
	var/total = 0
	var/count = 0
	for(var/kind in list("cargo", "hangar"))
		if(modules.has_kind(kind))
			total += modules.kind_efficiency(kind)
			count++
	return max(1, round(base * (0.5 + 0.5 * total / count)))

/// Magnes wyciągnął prom: wrak zostaje, a gdy nic w nim nie ma, zmienia nazwę
/obj/structure/overmap/asteroid/shipbreak_wreck/proc/take_salvage()
	salvage_left = max(0, salvage_left - 1)
	if(!salvage_left && !findtext(name, "Wypatroszony"))
		name = "Wypatroszony [lowertext(name)]"

// ---- Wraki z bitew nie zostają w układzie ----

/obj/structure/overmap/asteroid/shipbreak_wreck
	/// Wrak po zestrzelonym okręcie (nie losowy wrak układu): znika, gdy okręt gracza opuści układ
	var/battle_wreck = FALSE

/obj/structure/overmap/asteroid/shipbreak_wreck/copy_ship(obj/structure/overmap/source)
	. = ..()
	battle_wreck = TRUE

/obj/structure/overmap
	/// AQUILA - układ, z którego okręt gracza właśnie skacze (wraki z bitew znikają z niego po skoku)
	var/datum/star_system/wreck_left_system

/obj/structure/overmap/begin_jump(datum/star_system/target_system, force = FALSE, misjump = FALSE)
	if(role == MAIN_OVERMAP)
		wreck_left_system = current_system
	return ..()

/obj/structure/overmap/jump_end(datum/star_system/target_system, misjump = FALSE)
	. = ..()
	if(role != MAIN_OVERMAP || !wreck_left_system)
		return
	var/datum/star_system/left = wreck_left_system
	wreck_left_system = null
	if(left != target_system)
		left.clear_battle_wrecks()

/// Usuwa wraki z bitew (bez wczytanego wnętrza, na którym ktoś mógłby zostać); nie zostają na mapie hex
/datum/star_system/proc/clear_battle_wrecks()
	for(var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck in system_contents)
		if(QDELETED(wreck) || !wreck.battle_wreck || length(wreck.occupying_levels))
			continue
		system_contents -= wreck
		qdel(wreck)

/// Rozbity działami: w jego miejscu zostaje pole szczątków
/obj/structure/overmap/asteroid/shipbreak_wreck/obj_destruction(damage_flag)
	if(z && current_system)
		var/obj/effect/overmap_anomaly/hazard/speed/debris_field/debris = new(get_turf(src), current_system)
		current_system.system_contents |= debris
		visible_message("<span class='warning'>[src] rozpada się na chmurę szczątków.</span>")
	return ..()

#undef WRECK_MIN_INTEGRITY
#undef WRECK_INTEGRITY_SHARE
#undef SHIPBREAK_MAX_WRECKS
