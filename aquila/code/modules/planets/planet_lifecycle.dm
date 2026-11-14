// AQUILA - życie powierzchni planety. Kiedy okręt odlatuje z układu, planeta trafia z resztą układu do nullspace,
// a jej powierzchnia znika, jak tylko nie ma na niej nikogo żywego (pozostawieni czekają na powrót okrętu). Przed skokiem
// ludzie na powierzchni i mostek dostają ostrzeżenie.

/// Co ile sekund planeta poza mapą sprawdza, czy może zwolnić powierzchnię
#define PLANET_UNLOAD_CHECK_EVERY 10

/obj/structure/overmap/planet
	var/unload_check_counter = 0

/obj/structure/overmap/planet/check_landing_craft()
	if(z)
		return ..()
	// Układ jest pusty (okręt odleciał): powierzchnia znika, kiedy nikt żywy na niej nie został
	if(++unload_check_counter < PLANET_UNLOAD_CHECK_EVERY)
		return
	unload_check_counter = 0
	if(surface?.state != PLANET_SURFACE_READY || length(surface.living_players()))
		return
	log_game("Planet [src] surface unloaded: the system is empty and nobody alive is on it")
	surface.unload()

/obj/structure/overmap/warn_small_craft_before_jump(datum/star_system/target_system)
	. = ..()
	if(istype(src, /obj/structure/overmap/small_craft) || ai_controlled || !current_system)
		return
	var/stranded = 0
	for(var/obj/structure/overmap/planet/planet in current_system.system_contents)
		if(planet.surface?.state != PLANET_SURFACE_READY)
			continue
		for(var/mob/living/M as anything in planet.surface.living_players())
			stranded++
			SEND_SOUND(M, sound('sound/misc/notice1.ogg'))
			to_chat(M, "<span class='userdanger'>[src] rozpoczyna skok FTL do [target_system]!</span> <span class='warning'>Jeśli zostaniecie na [planet], będziecie tu czekać, aż okręt wróci do układu. Prom z napędem FTL musi wystartować przed skokiem: z orbity wróci sam („Rozkręć napęd”, a potem „Powrót” w panelu jednostki).</span>")
	if(stranded)
		relay(message = "<span class='warning'>Na powierzchni planet tego układu zostało [stranded] osób z załogi.</span>")

/// Z planety poza mapą nie ma dokąd wystartować
/obj/structure/overmap/small_craft/transport/shuttle_can_launch(mob/user)
	var/obj/structure/overmap/planet/planet = get_overmap()
	if(istype(planet) && !planet.z)
		to_chat(user, span_warning("Okręt opuścił układ, a komputer nawigacyjny [src] nie ma do czego się odnieść na orbicie. Trzeba czekać, aż okręt wróci."))
		return FALSE
	return ..()

#undef PLANET_UNLOAD_CHECK_EVERY
