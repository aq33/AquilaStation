// AQUILA - zagłuszenie czujników: przez 0,5–6 minut monitor załogi i inne odczyty czujników kombinezonów nic nie pokazują (port z Baystation12 code/modules/events/sensor_suit_jamming.dm)

/// Running sensor jamming events; while above 0 suit sensors report nothing
GLOBAL_VAR_INIT(aquila_hex_sensor_jams, 0)

/datum/round_event_control/aquila_hex_sensor_jamming
	name = "Suit Sensor Jamming"
	typepath = /datum/round_event/aquila_hex_sensor_jamming
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_sensor_jamming
	startWhen = 1
	announceWhen = 10
	announceChance = 75
	/// This event currently holds a jam
	var/jamming = FALSE

/datum/round_event/aquila_hex_sensor_jamming/setup()
	endWhen = rand(15, 180) // 30 s - 6 min

/datum/round_event/aquila_hex_sensor_jamming/announce(fake)
	priority_announce("Statek przeleciał przez burzę jonową. Prosimy obserwować sprzęt elektroniczny pod kątem usterek.", "Alarm: Anomalia", ANNOUNCER_IONSTORM)

/datum/round_event/aquila_hex_sensor_jamming/start()
	start_jamming()

/datum/round_event/aquila_hex_sensor_jamming/end()
	stop_jamming()

/datum/round_event/aquila_hex_sensor_jamming/kill()
	stop_jamming() // an event stopped early never leaves the sensors jammed
	return ..()

/datum/round_event/aquila_hex_sensor_jamming/proc/start_jamming()
	if(jamming)
		return
	jamming = TRUE
	GLOB.aquila_hex_sensor_jams++

/datum/round_event/aquila_hex_sensor_jamming/proc/stop_jamming()
	if(!jamming)
		return
	jamming = FALSE
	GLOB.aquila_hex_sensor_jams = max(GLOB.aquila_hex_sensor_jams - 1, 0)

// Readers of suit sensors: the crew monitor (consoles, handheld monitor, AI, cyborgs, circuits), Lifeline in PDAs and the crew pinpointer

/datum/crewmonitor/update_data(z, zlevel)
	if(GLOB.aquila_hex_sensor_jams > 0)
		return list()
	return ..()

/datum/computer_file/program/radar/lifeline/trackable(atom/movable/signal)
	if(GLOB.aquila_hex_sensor_jams > 0)
		return FALSE
	return ..()

/obj/item/pinpointer/crew/trackable(mob/living/carbon/human/H)
	if(GLOB.aquila_hex_sensor_jams > 0)
		return FALSE
	return ..()
