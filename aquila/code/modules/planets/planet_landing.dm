// AQUILA - lądowanie promu z wnętrzem (Sabre i inne promy z shuttle_craft.dm) na planecie. Prom w trybie dokowania nad
// planetą czeka, aż powierzchnia się zbuduje, pilot wybiera jedno z lądowisk, a potem kamerą lądowania (jak przy
// asteroidzie) ustawia prom na gruncie w obrębie lądowiska. Bez wyboru komputer dokowania ląduje sam przy pierwszym
// lądowisku.

/// Jak długo komputer dokowania czeka na zbudowanie powierzchni planety
#define PLANET_SURFACE_WAIT (60 SECONDS)

/obj/structure/overmap/small_craft/transport
	/// Lądowisko wybrane przez pilota przy lądowaniu na planecie
	var/turf/planet_landing_zone

/obj/structure/overmap/small_craft/transport/Destroy()
	planet_landing_zone = null
	return ..()

/obj/structure/overmap/small_craft/transport/docking_act(obj/structure/overmap/OM)
	if(!istype(OM, /obj/structure/overmap/planet) || !shuttle_port)
		return ..()
	var/obj/structure/overmap/planet/planet = OM
	if(shuttle_docked_at || shuttle_landing_eye)
		return FALSE
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(!DC?.docking_mode || DC.docking_cooldown)
		return FALSE
	if(!planet.planet_type.can_land)
		shuttle_dock_hint(planet, "Na [planet] nie da się wylądować.")
		return FALSE
	DC.docking_cooldown = TRUE
	if(planet.ensure_surface())
		INVOKE_ASYNC(src, PROC_REF(shuttle_begin_landing), planet)
		return TRUE
	RegisterSignal(planet, COMSIG_PLANET_SURFACE_READY, PROC_REF(planet_surface_ready))
	addtimer(CALLBACK(src, PROC_REF(planet_surface_timeout), planet), PLANET_SURFACE_WAIT)
	if(pilot)
		to_chat(pilot, span_notice("Komputer dokowania mapuje powierzchnię [planet] i szuka lądowisk. To potrwa chwilę, zostań nad planetą."))
	return TRUE

/obj/structure/overmap/small_craft/transport/proc/planet_surface_ready(obj/structure/overmap/planet/planet, success)
	SIGNAL_HANDLER
	UnregisterSignal(planet, COMSIG_PLANET_SURFACE_READY)
	if(!success)
		var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
		if(DC)
			DC.docking_cooldown = FALSE
		if(pilot)
			to_chat(pilot, span_warning("Komputer dokowania nie znalazł miejsca do lądowania na [planet]."))
		return
	INVOKE_ASYNC(src, PROC_REF(shuttle_begin_landing), planet)

/obj/structure/overmap/small_craft/transport/proc/planet_surface_timeout(obj/structure/overmap/planet/planet)
	if(QDELETED(src) || shuttle_docked_at || shuttle_landing_eye)
		return
	if(!QDELETED(planet))
		UnregisterSignal(planet, COMSIG_PLANET_SURFACE_READY)
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(DC)
		DC.docking_cooldown = FALSE

/// Na planecie: najpierw wybór lądowiska, potem kamera lądowania nad nim
/obj/structure/overmap/small_craft/transport/shuttle_begin_landing(obj/structure/overmap/OM)
	if(!istype(OM, /obj/structure/overmap/planet))
		return ..()
	var/obj/structure/overmap/planet/planet = OM
	planet_landing_zone = choose_planet_landing_zone(planet)
	if(QDELETED(src) || QDELETED(planet) || shuttle_docked_at)
		return
	if(!planet_landing_zone)
		var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
		if(DC)
			DC.docking_cooldown = FALSE
		return
	if(shuttle_manual_landing(planet))
		return
	shuttle_try_land(planet)

/// Pilot wybiera lądowisko (pierwsze, jeśli nie ma pilota albo nie odpowie)
/obj/structure/overmap/small_craft/transport/proc/choose_planet_landing_zone(obj/structure/overmap/planet/planet)
	var/list/zones = planet.surface?.landing_zones
	if(!length(zones))
		return
	var/turf/default_zone = zones[1]
	var/mob/user = pilot
	if(!user?.client)
		return default_zone
	var/list/options = list()
	for(var/turf/zone as anything in zones)
		options[zones[zone]] = zone
	var/choice = tgui_input_list(user, "Gdzie lądujemy? Lądowiska są oczyszczone z lawy i skał.", "Lądowanie na [planet]", options, timeout = 30 SECONDS)
	if(!choice || !options[choice])
		return default_zone
	return options[choice]

/obj/structure/overmap/small_craft/transport/shuttle_landing_center(obj/structure/overmap/OM)
	if(istype(OM, /obj/structure/overmap/planet) && planet_landing_zone)
		return planet_landing_zone
	return ..()

/// Na planecie kadłub staje na gruncie (nie na lawie i nie w skale) w obrębie powierzchni
/obj/structure/overmap/small_craft/transport/shuttle_landing_turf_free(obj/structure/overmap/OM, turf/T)
	if(!istype(OM, /obj/structure/overmap/planet))
		return ..()
	var/obj/structure/overmap/planet/planet = OM
	if(!T || !planet.surface?.contains(T) || !isopenturf(T) || islava(T) || ischasm(T))
		return FALSE
	if(istype(T.loc, /area/shuttle) || T.loc != planet.surface.surface_area)
		return FALSE
	for(var/atom/movable/AM as anything in T)
		if(AM.density)
			return FALSE
	return TRUE

/// Na planecie wyjście z promu na grunt jest bezpieczne (nie ma tam kosmosu)
/obj/structure/overmap/small_craft/transport/shuttle_land(obj/structure/overmap/OM, obj/docking_port/stationary/port)
	. = ..()
	if(. && istype(OM, /obj/structure/overmap/planet))
		relay(message = span_notice("Podwozie dotyka gruntu [OM]. Na zewnątrz panuje atmosfera planety: sprawdźcie maski i kombinezony przed wyjściem."))

#undef PLANET_SURFACE_WAIT
