// AQUILA - wyładowanie burzy elektrycznej: łuk Tesli uderza w statek z losowej burty, a załoga słyszy grzmot (port z Shiptest code/modules/overmap/objects/events/electrical_storm.dm)

/// How far the arc looks for its first target. Shiptest starts at the edge of the ship's level with range 32, we start right at the hull.
#define STORM_DISCHARGE_RANGE 12

/datum/round_event_control/aquila_hex_storm_discharge
	name = "Storm Discharge"
	typepath = /datum/round_event/aquila_hex_storm_discharge
	weight = 10
	min_players = 3
	max_occurrences = 3
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_storm_discharge
	startWhen = 1
	/// Storm strength: "minor", "moderate" or "major"
	var/strength
	var/min_power
	var/max_power

/datum/round_event/aquila_hex_storm_discharge/setup()
	set_strength(pickweight(list("minor" = 20, "moderate" = 40, "major" = 20)))

/datum/round_event/aquila_hex_storm_discharge/proc/set_strength(new_strength)
	strength = new_strength
	switch(strength)
		if("minor")
			min_power = 1000
			max_power = 2500
		if("major")
			min_power = 5000
			max_power = 10000
		else
			min_power = 2500
			max_power = 5000

/datum/round_event/aquila_hex_storm_discharge/start()
	var/turf/source = aquila_hex_ship_hull_turf(pick(GLOB.cardinals))
	if(source)
		discharge(source)

/// Arc from source plus thunder for everyone on the ship
/datum/round_event/aquila_hex_storm_discharge/proc/discharge(turf/source)
	var/power = rand(min_power, max_power)
	tesla_zap(source, STORM_DISCHARGE_RANGE, power, TESLA_FUSION_FLAGS)
	for(var/mob/living/crew as anything in aquila_hex_ship_crew())
		crew.playsound_local(get_turf(crew), 'aquila/sound/effects/thunder.ogg', 100)
	log_game("Storm Discharge ([strength]) zapped from [AREACOORD(source)] with [power] power.")

#undef STORM_DISCHARGE_RANGE
