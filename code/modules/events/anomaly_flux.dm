/datum/round_event_control/anomaly/anomaly_flux
	name = "Anomaly: Hyper-Energetic Flux"
	typepath = /datum/round_event/anomaly/anomaly_flux

	min_players = 15
	max_occurrences = 1
	weight = 5

/datum/round_event/anomaly/anomaly_flux
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/flux

/datum/round_event/anomaly/anomaly_flux/announce(fake)
	priority_announce("Fala strumieni hiperenergetycznych zlokalizowana na skanerach dalekiego zasięgu. Spodziewany punkt uderzenia: [impact_area.name].", "Alarm: Anomalia", 'aquila/sound/ai/events/anomaly_flux.ogg') // AQ EDIT - własne nagranie ogłoszenia
