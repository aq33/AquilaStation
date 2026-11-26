// AQUILA - Pas komet: okręt mija pas komet, światło gwiazd za oknami zmienia barwy, a obok kadłuba przelatują świecące komety (port z BlueMoon-Labs/BlueMoon-Station code/modules/events/comet_belt.dm)
// BlueMoon drives a 4-minute client-side show synced to music: per-client screen overlays with particles, a flash, forced
// insane parallax, muted ambience and pacifism for the whole crew. Ours is the light version in the pattern of our
// aurora_caelus: starlight on lit space turfs shifts through the comet colours, harmless comet streaks fly past the hull
// (temporary visuals, no damage), no music, overlays, parallax changes or pacifism.

/datum/round_event_control/aquila_hex_comet_belt
	name = "Pas komet"
	typepath = /datum/round_event/aquila_hex_comet_belt
	weight = 8
	max_occurrences = 1
	earliest_start = 10 MINUTES

/datum/round_event_control/aquila_hex_comet_belt/canSpawnEvent(players_amt, gamemode)
	if(!CONFIG_GET(flag/starlight))
		return FALSE
	return ..()

/datum/round_event/aquila_hex_comet_belt
	announceWhen = 1
	startWhen = 5
	endWhen = 80
	/// Barwy światła gwiazd w kolejnych fazach przelotu
	var/list/belt_colors = list("#50C8FF", "#FFD040", "#FF9020", "#6090B8")
	/// Która faza teraz
	var/phase = 0
	/// Co ile ticków kolejna faza
	var/phase_length = 18
	/// Oświetlone pola kosmosu, którym event zmienia barwę
	var/list/lit_space

/datum/round_event/aquila_hex_comet_belt/announce(fake)
	priority_announce("[station_name()]: Okręt mija pas komet. Zderzenia nie przewidujemy, komety przelecą w bezpiecznej odległości. Pracownia Astronomiczna Nanotrasen zachęca załogę do krótkiej przerwy przy najbliższym oknie. Życzenia przy spadających kometach składać we własnym zakresie, Nanotrasen nie odpowiada za ich spełnienie.", "Pracownia Astronomiczna Nanotrasen")

/datum/round_event/aquila_hex_comet_belt/start()
	lit_space = starlit_space()
	next_phase()

/datum/round_event/aquila_hex_comet_belt/tick()
	if(activeFor % phase_length == 0)
		next_phase()
	if(activeFor % 2 == 0)
		for(var/i in 1 to rand(1, 3))
			spawn_streak(comet_turf())

/datum/round_event/aquila_hex_comet_belt/end()
	tint_space(lit_space, null)
	lit_space = null
	priority_announce("Pas komet zostaje za rufą. Światło gwiazd wraca do normy. Prosimy wrócić do obowiązków i dziękujemy za wspólne oglądanie.", "Pracownia Astronomiczna Nanotrasen")

/// Kolejna faza: nowa barwa światła gwiazd
/datum/round_event/aquila_hex_comet_belt/proc/next_phase()
	phase = min(phase + 1, length(belt_colors))
	tint_space(lit_space, belt_colors[phase])

/// Oświetlone pola kosmosu w obszarach ze światłem gwiazd (jak w aurora_caelus)
/datum/round_event/aquila_hex_comet_belt/proc/starlit_space()
	. = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(initial(A.dynamic_lighting) != DYNAMIC_LIGHTING_IFSTARLIGHT)
			continue
		for(var/turf/open/space/S in A)
			if(S.light_range > 0)
				. += S

/// Barwi światło podanych pól; null przywraca barwę początkową
/datum/round_event/aquila_hex_comet_belt/proc/tint_space(list/turfs, tint)
	for(var/turf/T as anything in turfs)
		// set_light() bierze null jako brak argumentu, więc barwa idzie wprost
		T.set_light_color(tint || initial(T.light_color))
		T.update_light()

/// Pole kosmosu kilka pól od losowej burty
/datum/round_event/aquila_hex_comet_belt/proc/comet_turf()
	var/side = pick(GLOB.cardinals)
	var/turf/hull = aquila_hex_ship_hull_turf(side)
	if(!isspaceturf(hull))
		return null
	return aquila_hex_inside_map(get_ranged_target_turf(hull, side, rand(2, 8)))

/// Świecąca kometa, która przelatuje obok i gaśnie
/datum/round_event/aquila_hex_comet_belt/proc/spawn_streak(turf/spot)
	if(!isspaceturf(spot))
		return null
	var/obj/effect/temp_visual/aquila_comet_streak/streak = new(spot)
	streak.color = belt_colors[max(phase, 1)]
	return streak

/// Kometa z pasa: przelatuje kilka pól i znika, nikogo nie rani
/obj/effect/temp_visual/aquila_comet_streak
	name = "kometa"
	desc = "Lodowa kula z długim, świecącym warkoczem. Leci daleko od kadłuba."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "glowing"
	duration = 3 SECONDS
	randomdir = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/aquila_comet_streak/Initialize(mapload)
	. = ..()
	var/flight_dir = pick(GLOB.alldirs)
	setDir(flight_dir)
	var/dx = (flight_dir & EAST) ? 1 : ((flight_dir & WEST) ? -1 : 0)
	var/dy = (flight_dir & NORTH) ? 1 : ((flight_dir & SOUTH) ? -1 : 0)
	var/distance = world.icon_size * rand(5, 9)
	transform = matrix() * 0.6
	animate(src, pixel_x = dx * distance, pixel_y = dy * distance, alpha = 0, time = duration)
