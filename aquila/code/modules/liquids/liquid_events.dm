// AQUILA - Ciecze: eventy z Monkestation 2.0.
// - przelewający się scrubber: event tg (code/modules/events/scrubber_overflow.dm) w wersji Monke
//   (monkestation/code/modules/events/scrubber_overflow.dm), czyli kałuże zamiast piany, które szybciej parują;
//   lista reagentów bez tych, których nie mamy (dywany w kolorach, multiver, kakao, jogurt, baldium, yuck)
// - anomalia płynów (code/game/objects/effects/anomalies/anomalies_fluid.dm + monkestation/code/modules/events/anomaly/anomaly_fluid.dm)

#define BASE_EVAPORATION_MULTIPLIER 10

/datum/round_event_control/scrubber_overflow
	name = "Scrubber Overflow: Normal"
	typepath = /datum/round_event/scrubber_overflow
	weight = 10
	max_occurrences = 3
	min_players = 10

/datum/round_event_control/scrubber_overflow/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		var/turf/scrubber_turf = get_turf(temp_vent)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !temp_vent.welded)
			return TRUE
	return FALSE

/datum/round_event/scrubber_overflow
	announceWhen = 1
	startWhen = 5
	/// The probability that the ejected reagents will be dangerous
	var/danger_chance = 1
	/// Amount of reagents ejected from each scrubber
	var/reagents_amount = 100
	/// Probability of an individual scrubber overflowing
	var/overflow_probability = 20
	/// Ile szybciej parują kałuże z tego eventu
	var/evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER
	/// Specific reagent to force all scrubbers to use, null for random reagent choice
	var/datum/reagent/forced_reagent_type
	/// A list of scrubbers that will have reagents ejected from them
	var/list/scrubbers = list()
	/// The list of chems that scrubbers can produce
	var/list/safer_chems = list(
		/datum/reagent/water,
		/datum/reagent/carbon,
		/datum/reagent/consumable/flour,
		/datum/reagent/space_cleaner,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/consumable/condensedcapsaicin,
		/datum/reagent/drug/mushroomhallucinogen,
		/datum/reagent/lube,
		/datum/reagent/glitter/blue,
		/datum/reagent/glitter/pink,
		/datum/reagent/cryptobiolin,
		/datum/reagent/blood,
		/datum/reagent/medicine/charcoal,
		/datum/reagent/water/holywater,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/consumable/tinlux,
		/datum/reagent/bluespace,
		/datum/reagent/pax,
		/datum/reagent/consumable/laughter,
		/datum/reagent/concentrated_barbers_aid,
		/datum/reagent/colorful_reagent,
		/datum/reagent/consumable/sodiumchloride,
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/hair_dye,
		/datum/reagent/consumable/sugar,
		/datum/reagent/glitter/white,
		/datum/reagent/gravitum,
		/datum/reagent/growthserum,
	)

/datum/round_event/scrubber_overflow/announce(fake)
	// kill() w setup() nie zatrzymuje eventu (round_event/New dodaje go do SSevents.running po setup), więc bez oczyszczaczy milczymy tutaj
	if(!fake && !length(scrubbers))
		return
	priority_announce("W sieci oczyszczaczy powietrza wystąpił skok ciśnienia zwrotnego. Możliwe wyrzuty zawartości.", "Dział inżynierii [command_name()]")

/datum/round_event/scrubber_overflow/setup()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		var/turf/scrubber_turf = get_turf(temp_vent)
		if(!scrubber_turf || !is_station_level(scrubber_turf.z) || temp_vent.welded)
			continue
		if(!prob(overflow_probability))
			continue
		scrubbers += temp_vent

/// proc that will run the prob check of the event and return a safe or dangerous reagent based off of that.
/datum/round_event/scrubber_overflow/proc/get_overflowing_reagent(dangerous)
	return dangerous ? get_random_reagent_id(CHEMICAL_RNG_GENERAL) : pick(safer_chems)

/datum/round_event/scrubber_overflow/start()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/vent as anything in scrubbers)
		if(QDELETED(vent) || vent.welded) // in case it was welded after setup() but before we got to it here
			continue
		var/turf/vent_turf = get_turf(vent)
		if(!isopenturf(vent_turf))
			continue
		var/dangerous = prob(danger_chance)
		var/reagent_type = forced_reagent_type || get_overflowing_reagent(dangerous)
		if(dangerous)
			new /mob/living/simple_animal/cockroach(vent_turf)
			new /mob/living/simple_animal/cockroach(vent_turf)
		vent_turf.add_liquid(reagent_type, reagents_amount, no_react = TRUE)
		if(vent_turf.liquids?.liquid_group)
			vent_turf.liquids.liquid_group.always_evaporates = TRUE
			vent_turf.liquids.liquid_group.evaporation_multiplier += evaporation_multiplier
		CHECK_TICK

/datum/round_event_control/scrubber_overflow/threatening
	name = "Scrubber Overflow: Threatening"
	typepath = /datum/round_event/scrubber_overflow/threatening
	weight = 4
	min_players = 25
	max_occurrences = 1
	earliest_start = 35 MINUTES

/datum/round_event/scrubber_overflow/threatening
	danger_chance = 10
	reagents_amount = 150
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 1.5

/datum/round_event_control/scrubber_overflow/catastrophic
	name = "Scrubber Overflow: Catastrophic"
	typepath = /datum/round_event/scrubber_overflow/catastrophic
	weight = 2
	min_players = 35
	max_occurrences = 1
	earliest_start = 45 MINUTES

/datum/round_event/scrubber_overflow/catastrophic
	danger_chance = 30
	reagents_amount = 200
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 2

/datum/round_event_control/scrubber_overflow/every_vent
	name = "Scrubber Overflow: Every Vent"
	typepath = /datum/round_event/scrubber_overflow/every_vent
	weight = 0
	max_occurrences = 0

/datum/round_event/scrubber_overflow/every_vent
	overflow_probability = 100
	reagents_amount = 150
	evaporation_multiplier = BASE_EVAPORATION_MULTIPLIER * 1.5

#undef BASE_EVAPORATION_MULTIPLIER

// Anomalia płynów

#define NORMAL_FLUID_AMOUNT 25
#define DANGEROUS_FLUID_AMOUNT 100

/datum/round_event_control/anomaly/anomaly_fluid
	name = "Anomaly: Fluidic"
	typepath = /datum/round_event/anomaly/anomaly_fluid
	max_occurrences = 3
	weight = 10
	min_players = 20

/datum/round_event/anomaly/anomaly_fluid
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/fluid

/datum/round_event/anomaly/anomaly_fluid/announce(fake)
	priority_announce("Anomalia płynów wykryta na skanerach długiego zasięgu. Spodziewany punkt uderzenia: [impact_area.name].", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())

//fully automated piss floods
/obj/effect/anomaly/fluid
	name = "anomalia płynów"
	desc = "Anomalia, która ściąga ciecze z niewiadomego miejsca. Lepiej przynieś mopa."
	icon = 'aquila/icons/effects/anomaly_fluid.dmi'
	icon_state = "bluestream_fade"
	var/dangerous = FALSE
	var/list/fluid_choices = list()

/obj/effect/anomaly/fluid/Initialize(mapload, new_lifespan)
	. = ..()
	if(prob(5))
		dangerous = TRUE //Unrestricts the reagent choice and increases fluid amounts

	for(var/i in 1 to rand(1, 5)) //Between 1 and 5 random chemicals
		fluid_choices += dangerous ? get_random_reagent_id(CHEMICAL_RNG_FUN) : get_random_reagent_id(CHEMICAL_RNG_GENERAL)

/obj/effect/anomaly/fluid/anomalyEffect(delta_time)
	..()
	var/turf/spawn_point = get_turf(src)
	if(!isopenturf(spawn_point) || isspaceturf(spawn_point) || !length(fluid_choices))
		return
	spawn_point.add_liquid(pick(fluid_choices), dangerous ? DANGEROUS_FLUID_AMOUNT : NORMAL_FLUID_AMOUNT, chem_temp = rand(BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT))

/obj/effect/anomaly/fluid/detonate()
	var/turf/spawn_point = get_turf(src)
	if(!isopenturf(spawn_point) || isspaceturf(spawn_point) || !length(fluid_choices))
		return
	spawn_point.add_liquid(pick(fluid_choices), (dangerous ? DANGEROUS_FLUID_AMOUNT : NORMAL_FLUID_AMOUNT) * 5, chem_temp = rand(BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT))

#undef NORMAL_FLUID_AMOUNT
#undef DANGEROUS_FLUID_AMOUNT
