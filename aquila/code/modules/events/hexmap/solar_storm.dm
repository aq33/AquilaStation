// AQUILA - burza słoneczna: ostrzeżenie, a potem przez 2–6 minut co 10 sekund żar parzy wszystkich w kosmosie, a panele słoneczne dają więcej prądu (port z Baystation12 code/modules/events/solar_storm.dm)

/// Event ticks (2 s each) between bursts of heat, as in Bay
#define SOLAR_STORM_INTERVAL 5
/// Body heat added to humans per burst
#define SOLAR_STORM_HEAT 100
/// Burn damage for other mobs per burst
#define SOLAR_STORM_BURN 40
/// Base solar panel output, SOLARGENRATE from code/modules/power/solar.dm (#undef'd there)
#define SOLAR_STORM_BASE_GEN 1500

/// Solar panel output multiplier while a solar storm is close (1 = normal)
GLOBAL_VAR_INIT(aquila_hex_solar_multiplier, 1)

/datum/round_event_control/aquila_hex_solar_storm
	name = "Solar Storm"
	typepath = /datum/round_event/aquila_hex_solar_storm
	weight = 10
	min_players = 0
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_solar_storm
	announceWhen = 1
	startWhen = 45 // 90 s warning

/datum/round_event/aquila_hex_solar_storm/setup()
	endWhen = startWhen + rand(30, 90) + rand(30, 90) // 2-6 minutes

/datum/round_event/aquila_hex_solar_storm/announce(fake)
	priority_announce("Wykryto burzę słoneczną zbliżającą się do statku. Natychmiast przerwać wszelkie EVA i wrócić do środka.", "Sensory statku")
	if(!fake)
		GLOB.aquila_hex_solar_multiplier = 1.5

/datum/round_event/aquila_hex_solar_storm/start()
	priority_announce("Burza słoneczna dotarła do statku. Nie wychodzić na EVA i pozostać wewnątrz, dopóki nie minie.", "Sensory statku")
	GLOB.aquila_hex_solar_multiplier = 5

/datum/round_event/aquila_hex_solar_storm/tick()
	if(activeFor % SOLAR_STORM_INTERVAL == 0)
		radiate()

/datum/round_event/aquila_hex_solar_storm/end()
	priority_announce("Burza słoneczna minęła statek. Można bezpiecznie wznowić EVA.", "Sensory statku")
	GLOB.aquila_hex_solar_multiplier = 1

/datum/round_event/aquila_hex_solar_storm/kill()
	if(activeFor < endWhen) // stopped before end(), panels go back to normal
		GLOB.aquila_hex_solar_multiplier = 1
	return ..()

/// Heats up everyone in space on the ship's levels
/datum/round_event/aquila_hex_solar_storm/proc/radiate()
	for(var/mob/living/victim as anything in GLOB.alive_mob_list)
		var/turf/T = get_turf(victim)
		if(T && is_station_level(T.z))
			expose(victim)

/// Burns one mob if it stands in space (space turf or space area). Mobs inside something (mechs, fighters, closets) are shielded.
/datum/round_event/aquila_hex_solar_storm/proc/expose(mob/living/victim)
	var/turf/T = victim.loc
	if(!isturf(T) || (!isspaceturf(T) && !istype(T.loc, /area/space)))
		return FALSE
	if(ishuman(victim))
		victim.adjust_bodytemperature(SOLAR_STORM_HEAT)
	else
		victim.adjustFireLoss(SOLAR_STORM_BURN)
	return TRUE

/obj/machinery/power/solar/process()
	. = ..()
	if(GLOB.aquila_hex_solar_multiplier <= 1 || . == PROCESS_KILL)
		return
	if((machine_stat & BROKEN) || !control || !powernet || powernet != control.powernet || obscured)
		return
	var/bonus = SOLAR_STORM_BASE_GEN * sunfrac * (GLOB.aquila_hex_solar_multiplier - 1)
	add_avail(bonus)
	control.gen += bonus

#undef SOLAR_STORM_INTERVAL
#undef SOLAR_STORM_HEAT
#undef SOLAR_STORM_BURN
#undef SOLAR_STORM_BASE_GEN
