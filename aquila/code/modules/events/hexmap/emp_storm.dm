// AQUILA - burza elektromagnetyczna: ostrzeżenie, a po 2 sekundach impuls EMP w losowym miejscu statku (port z Shiptest code/modules/overmap/objects/events/emp_storm.dm)

/datum/round_event_control/aquila_hex_emp_storm
	name = "EMP Storm"
	typepath = /datum/round_event/aquila_hex_emp_storm
	weight = 10
	min_players = 5
	max_occurrences = 3
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_emp_storm
	announceWhen = 1
	startWhen = 2 // one event tick (2 s) after the warning, like the 2 s timer in Shiptest
	/// Storm strength: 2 (minor), 4 (moderate) or 8 (major), as in Shiptest
	var/strength = 4

/datum/round_event/aquila_hex_emp_storm/setup()
	strength = pick(2, 4, 4, 8) // minor 25%, moderate 50%, major 25%

/datum/round_event/aquila_hex_emp_storm/announce(fake)
	priority_announce("UWAGA: przygotować się na nadchodzący impuls elektromagnetyczny.", "Burza elektromagnetyczna", ANNOUNCER_IONSTORM)

/datum/round_event/aquila_hex_emp_storm/start()
	var/turf/epicenter = aquila_hex_random_ship_turf()
	if(epicenter)
		pulse(epicenter)

/// EMP and flash around the epicenter, a pulse sound for everyone on the ship
/datum/round_event/aquila_hex_emp_storm/proc/pulse(turf/epicenter)
	var/heavy_range = round(rand(strength / 4, strength))
	var/light_range = rand(strength, strength * 2)
	empulse(epicenter, heavy_range, light_range)
	for(var/mob/living/carbon/victim in range(round(strength * 2), epicenter))
		victim.flash_act(1, 1)
	for(var/mob/living/crew as anything in aquila_hex_ship_crew())
		crew.playsound_local(get_turf(crew), 'sound/effects/empulse.ogg', 100)
	log_game("EMP Storm (strength [strength]) pulsed at [AREACOORD(epicenter)] ([heavy_range], [light_range]).")
