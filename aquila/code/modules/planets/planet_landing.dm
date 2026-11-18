// AQUILA - lądowanie promu z wnętrzem (Sabre i inne promy z shuttle_craft.dm) na planecie. Prom w trybie dokowania nad
// planetą czeka, aż powierzchnia się zbuduje, pilot wybiera jedno z lądowisk, a potem kamerą lądowania (jak przy
// asteroidzie) ustawia prom na gruncie w obrębie lądowiska. Lądowanie zaczyna się tylko z pilotem za sterem (prom tuż po
// starcie z planety nie siada z powrotem sam), zamknięcie okna wyboru lądowiska je przerywa, a bez wyboru miejsca w kamerze
// komputer dokowania ląduje sam w obrębie lądowiska.

/// Przerwa po anulowaniu lądowania przez pilota (inaczej planeta co sekundę pytałaby od nowa)
#define PLANET_LANDING_ABORT_COOLDOWN (20 SECONDS)

/// Jak długo komputer dokowania czeka na zbudowanie powierzchni planety
#define PLANET_SURFACE_WAIT (60 SECONDS)

/obj/structure/overmap/small_craft/transport
	/// Lądowisko wybrane przez pilota przy lądowaniu na planecie
	var/turf/planet_landing_zone
	/// Timer czekania na zbudowanie powierzchni (kasowany, gdy powierzchnia jest gotowa)
	var/planet_wait_timer

/obj/structure/overmap/small_craft/transport/Destroy()
	planet_landing_zone = null
	if(planet_wait_timer)
		deltimer(planet_wait_timer)
		planet_wait_timer = null
	return ..()

/obj/structure/overmap/small_craft/transport/docking_act(obj/structure/overmap/OM)
	if(!istype(OM, /obj/structure/overmap/planet) || !shuttle_port)
		return ..()
	var/obj/structure/overmap/planet/planet = OM
	if(shuttle_docked_at || shuttle_landing_eye || shuttle_just_launched_from(planet))
		return FALSE
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(!DC?.docking_mode || DC.docking_cooldown)
		return FALSE
	// Bez pilota za sterem (np. tuż po starcie z planety) prom tylko wisi nad planetą
	if(!pilot)
		return FALSE
	if(!planet.planet_type.can_land)
		shuttle_dock_hint(planet, "Na [planet] nie da się wylądować.")
		return FALSE
	DC.docking_cooldown = TRUE
	if(planet.ensure_surface())
		INVOKE_ASYNC(src, PROC_REF(shuttle_begin_landing), planet)
		return TRUE
	RegisterSignal(planet, COMSIG_PLANET_SURFACE_READY, PROC_REF(planet_surface_ready))
	planet_wait_timer = addtimer(CALLBACK(src, PROC_REF(planet_surface_timeout), planet), PLANET_SURFACE_WAIT, TIMER_STOPPABLE)
	if(pilot)
		to_chat(pilot, span_notice("Komputer dokowania mapuje powierzchnię [planet] i szuka lądowisk. To potrwa chwilę, zostań nad planetą."))
	return TRUE

/obj/structure/overmap/small_craft/transport/proc/planet_surface_ready(obj/structure/overmap/planet/planet, success)
	SIGNAL_HANDLER
	UnregisterSignal(planet, COMSIG_PLANET_SURFACE_READY)
	// Timeout dotyczy tylko czekania na powierzchnię: nie może zwolnić blokady w trakcie wyboru lądowiska
	if(planet_wait_timer)
		deltimer(planet_wait_timer)
		planet_wait_timer = null
	if(!success)
		var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
		if(DC)
			DC.docking_cooldown = FALSE
		if(pilot)
			to_chat(pilot, span_warning("Komputer dokowania nie znalazł miejsca do lądowania na [planet]."))
		return
	INVOKE_ASYNC(src, PROC_REF(shuttle_begin_landing), planet)

/obj/structure/overmap/small_craft/transport/proc/planet_surface_timeout(obj/structure/overmap/planet/planet)
	planet_wait_timer = null
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
	// Powierzchnia budowała się kilkanaście sekund: prom mógł w tym czasie odlecieć albo wyłączyć tryb dokowania
	if(!planet.craft_over_planet(src))
		planet_landing_cancelled(planet)
		return
	planet_landing_zone = choose_planet_landing_zone(planet)
	if(QDELETED(src) || QDELETED(planet) || shuttle_docked_at)
		return
	if(!planet_landing_zone)
		planet_landing_aborted(planet)
		return
	// Okno wyboru lądowiska czeka na pilota do 30 s: sprawdzamy jeszcze raz
	if(!planet.craft_over_planet(src))
		planet_landing_cancelled(planet)
		return
	if(shuttle_manual_landing(planet))
		return
	shuttle_try_land(planet)

/// Lądowanie przerwane: komputer dokowania znów jest gotowy
/obj/structure/overmap/small_craft/transport/proc/planet_landing_cancelled(obj/structure/overmap/planet/planet)
	planet_landing_zone = null
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(DC)
		DC.docking_cooldown = FALSE
	if(pilot)
		to_chat(pilot, span_warning("Lądowanie przerwane: prom nie jest już nad [planet] w trybie dokowania."))

/// Pilot przerwał lądowanie (zamknął okno wyboru albo nie odpowiedział): przez chwilę planeta nie pyta od nowa
/obj/structure/overmap/small_craft/transport/proc/planet_landing_aborted(obj/structure/overmap/planet/planet)
	planet_landing_zone = null
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(DC)
		DC.docking_cooldown = TRUE
		addtimer(VARSET_CALLBACK(DC, docking_cooldown, FALSE), PLANET_LANDING_ABORT_COOLDOWN)
	if(pilot)
		to_chat(pilot, span_notice("Lądowanie na [planet] anulowane. Komputer dokowania zapyta ponownie za [DisplayTimeText(PLANET_LANDING_ABORT_COOLDOWN)], jeśli prom zostanie nad planetą w trybie dokowania."))

/// Pilot wybiera lądowisko (pierwsze, jeśli nikt nie siedzi za sterem z klientem). Zamknięte okno = null, czyli przerwanie.
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
		return
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
	if(!T || !planet.surface?.contains(T) || is_planet_hazard_turf(T))
		return FALSE
	if(istype(T.loc, /area/shuttle) || T.loc != planet.surface.surface_area)
		return FALSE
	if(planet_descent_reserved(T, src)) // lądowisko innego promu, który właśnie schodzi
		return FALSE
	for(var/atom/movable/AM as anything in T)
		// Żyła nie jest gęsta, ale przelot promu kasuje zakotwiczone obiekty pod kadłubem (żyła misji by przepadła)
		if(AM.density || istype(AM, /obj/structure/vein))
			return FALSE
	return TRUE

/// Wybór miejsca w kamerze trwał do minuty: okręt mógł w tym czasie skoczyć (planeta w nullspace) albo prom odlecieć.
/// Bez tego prom lądował na powierzchni rozładowanego układu, a start z niej był potem zablokowany.
/obj/structure/overmap/small_craft/transport/shuttle_manual_landing_fallback(obj/structure/overmap/OM)
	if(istype(OM, /obj/structure/overmap/planet) && !QDELETED(OM) && !QDELETED(src) && !shuttle_docked_at)
		var/obj/structure/overmap/planet/planet = OM
		if(!planet.craft_over_planet(src))
			planet_landing_cancelled(planet)
			return
	return ..()

/// Na planecie wyjście z promu na grunt jest bezpieczne (nie ma tam kosmosu)
/obj/structure/overmap/small_craft/transport/shuttle_land(obj/structure/overmap/OM, obj/docking_port/stationary/port)
	if(istype(OM, /obj/structure/overmap/planet))
		var/obj/structure/overmap/planet/planet = OM
		if(!planet.craft_over_planet(src))
			if(istype(port, /obj/docking_port/stationary/shuttle_craft_spot) && !port.docked)
				qdel(port, TRUE)
			return FALSE
	. = ..()
	if(. && istype(OM, /obj/structure/overmap/planet))
		relay(message = span_notice("Podwozie dotyka gruntu [OM]. Na zewnątrz panuje atmosfera planety: sprawdźcie maski i kombinezony przed wyjściem."))

#undef PLANET_SURFACE_WAIT
#undef PLANET_LANDING_ABORT_COOLDOWN
