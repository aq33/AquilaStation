// AQUILA - mgławica: przez kilka minut światła na statku migoczą (port z Shiptest code/modules/overmap/objects/events/nebula.dm)

/// Fraction of the ship's lights that start flickering on each event tick (2 s), so the load is spread over the whole event
#define NEBULA_FLICKER_SHARE 0.04

/datum/round_event_control/aquila_hex_nebula_flicker
	name = "Migotanie świateł w mgławicy"
	typepath = /datum/round_event/aquila_hex_nebula_flicker
	weight = 10
	min_players = 0
	max_occurrences = 3
	earliest_start = 5 MINUTES

/datum/round_event/aquila_hex_nebula_flicker
	announceWhen = 1
	startWhen = 1
	/// Weak references to the lights on the ship, gathered once in start()
	var/list/ship_lights

/datum/round_event/aquila_hex_nebula_flicker/setup()
	endWhen = startWhen + rand(60, 150) // 2-5 minutes

/datum/round_event/aquila_hex_nebula_flicker/announce(fake)
	priority_announce("Statek wleciał w mgławicę. Wyładowania w obłoku gazu mogą zakłócać pracę oświetlenia.", "Sensory statku")

/datum/round_event/aquila_hex_nebula_flicker/start()
	ship_lights = list()
	for(var/obj/machinery/light/light in GLOB.machines)
		if(is_station_level(light.z))
			ship_lights += WEAKREF(light)

/datum/round_event/aquila_hex_nebula_flicker/tick()
	flicker_some()

/// Starts a short flicker on a random share of the ship's lights
/datum/round_event/aquila_hex_nebula_flicker/proc/flicker_some()
	var/count = max(1, round(length(ship_lights) * NEBULA_FLICKER_SHARE))
	for(var/i in 1 to count)
		if(!length(ship_lights))
			return
		var/datum/weakref/light_ref = pick(ship_lights)
		var/obj/machinery/light/light = light_ref.resolve()
		if(!light)
			ship_lights -= light_ref
			continue
		light.flicker(rand(2, 6))

/datum/round_event/aquila_hex_nebula_flicker/kill()
	ship_lights = null
	return ..()

#undef NEBULA_FLICKER_SHARE
