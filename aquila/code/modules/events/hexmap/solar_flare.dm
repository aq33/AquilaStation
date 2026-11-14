// AQUILA - rozbłysk słoneczny: ostrzeżenie, a po 2 sekundach pożar w losowym miejscu statku i błysk dla załogi w pobliżu (port z Shiptest code/modules/overmap/objects/events/solar_flare.dm)

/datum/round_event_control/aquila_hex_solar_flare
	name = "Solar Flare"
	typepath = /datum/round_event/aquila_hex_solar_flare
	weight = 10
	min_players = 5
	max_occurrences = 3
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_solar_flare
	announceWhen = 1
	startWhen = 2 // one event tick (2 s) after the warning, like the 2 s timer in Shiptest
	/// Flare strength: 2 (minor), 4 (moderate) or 8 (major), as in Shiptest
	var/strength = 4

/datum/round_event/aquila_hex_solar_flare/setup()
	strength = pick(2, 4, 4, 8) // minor 25%, moderate 50%, major 25%

/datum/round_event/aquila_hex_solar_flare/announce(fake)
	priority_announce("UWAGA: przygotować się na nadchodzący rozbłysk słoneczny.", "Rozbłysk słoneczny")

/datum/round_event/aquila_hex_solar_flare/start()
	// The engine, magazines and the AI core would turn a small fire into a disaster, so the flare skips them
	var/static/list/unsafe_area_types = typecacheof(list(
		/area/ai_monitored/turret_protected,
		/area/engine,
		/area/nsv/engine,
		/area/nsv/magazine,
		/area/nsv/weapons,
	))
	var/turf/epicenter = aquila_hex_random_ship_turf(unsafe_area_types)
	if(epicenter)
		flare(epicenter)

/// Sets turfs around the epicenter on fire (Shiptest flame_radius), flashes people nearby, a flare sound for everyone on the ship
/datum/round_event/aquila_hex_solar_flare/proc/flare(turf/epicenter)
	var/radius = clamp(round(rand(strength / 2, strength)), 1, 50)
	var/power = rand(strength, strength * 2)
	for(var/turf/open/T in circlerangeturfs(epicenter, radius))
		T.IgniteTurf(power)
	for(var/mob/living/carbon/victim in range(round(strength * 2), epicenter))
		victim.flash_act(1, 1)
	for(var/mob/living/crew as anything in aquila_hex_ship_crew())
		crew.playsound_local(get_turf(crew), 'sound/magic/fireball.ogg', 100)
	log_game("Solar Flare (strength [strength]) ignited [radius] tiles around [AREACOORD(epicenter)].")
