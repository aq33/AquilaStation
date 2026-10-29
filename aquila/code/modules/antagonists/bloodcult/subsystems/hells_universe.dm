// Wizualia Zaćmienia kultu krwi (w drafcie Monke na SSoutdoor_effects, którego nie mamy).
// U nas: tłuczenie świateł na poziomach stacji (statku), czerwone gwiazdy (światło kosmosu przy kadłubie) i czerwony parallax.
SUBSYSTEM_DEF(hell_universe)
	name = "Hell Universe Processing"
	flags = SS_NO_INIT | SS_BACKGROUND
	wait = 1 SECONDS

	var/hell_time = FALSE
	/// Światła na poziomach stacji, które jeszcze trzeba stłuc
	var/list/lights_to_break = list()
	/// Turfy kosmosu przy kadłubie, którym trzeba przebarwić światło gwiazd
	var/list/starlight_to_update = list()
	/// Turfy kosmosu, które dostały czerwone światło (do przywrócenia po Zaćmieniu)
	var/list/reddened_starlight = list()

/datum/controller/subsystem/hell_universe/proc/start_hell()
	if(hell_time)
		return
	hell_time = TRUE

	bloodcult_update_all_parallax()

	for(var/obj/machinery/light/light_to_break in GLOB.machines)
		if(is_station_level(light_to_break.z))
			lights_to_break += light_to_break

	starlight_to_update = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/open/space/space in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(space.light_range)
				starlight_to_update += space
		CHECK_TICK

/// Koniec Zaćmienia bez Nar'Sie: przywraca niebo (stłuczone świetlówki zostają stłuczone).
/datum/controller/subsystem/hell_universe/proc/stop_hell()
	if(!hell_time)
		return
	hell_time = FALSE
	lights_to_break.Cut()
	starlight_to_update.Cut()
	bloodcult_update_all_parallax()
	for(var/turf/open/space/space as anything in reddened_starlight)
		if(QDELETED(space) || !isspaceturf(space))
			continue
		space.set_light(l_color = null)
		CHECK_TICK
	reddened_starlight.Cut()

/datum/controller/subsystem/hell_universe/fire(resumed)
	if(!hell_time)
		return

	while(length(starlight_to_update))
		var/turf/open/space/space = starlight_to_update[length(starlight_to_update)]
		starlight_to_update.len--
		if(!QDELETED(space) && isspaceturf(space) && space.light_range)
			space.set_light(l_color = COLOR_BLOOD)
			reddened_starlight += space
		if(MC_TICK_CHECK)
			return

	while(length(lights_to_break))
		var/obj/machinery/light/light_to_break = lights_to_break[length(lights_to_break)]
		lights_to_break.len--
		if(!QDELETED(light_to_break))
			light_to_break.break_light_tube(skip_sound_and_sparks = prob(75))//nie chcemy tysiąca dźwięków naraz
		if(MC_TICK_CHECK)
			return
