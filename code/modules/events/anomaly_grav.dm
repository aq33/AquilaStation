/datum/round_event_control/anomaly/anomaly_grav
	name = "Anomaly: Gravitational"
	typepath = /datum/round_event/anomaly/anomaly_grav

	max_occurrences = 5
	weight = 10

/datum/round_event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	anomaly_path = /obj/effect/anomaly/grav

/datum/round_event/anomaly/anomaly_grav/announce(fake)
	priority_announce("Anomalia grawitacyjna wykryta na skanerach dalekiego zasięgu. Spodziewany punkt uderzenia: [impact_area.name].", "Alarm: Anomalia", 'aquila/sound/ai/events/anomaly_grav.ogg') // AQ EDIT - własne nagranie ogłoszenia
