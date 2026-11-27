// AQUILA - Pojawienie się artefaktu: na wolnej podłodze w losowym obszarze okrętu pojawia się obcy artefakt z naszej ksenoarcheologii (port z Monkestation monkestation/code/modules/events/artifact_spawn.dm)
// Monke spawns its own artifact type on a generic event spawn landmark; here it is our xenoarchaeology artifact
// (/obj/item/xenoartifact, random material and traits) on a free floor of a random station area, picked like an anomaly.
// Monke does not announce it at all; here the sensors report the area, so the science department knows where to look.

/datum/round_event_control/aquila_hex_artifact
	name = "Pojawienie się artefaktu"
	typepath = /datum/round_event/aquila_hex_anomaly/artifact
	weight = 10
	min_players = 3
	max_occurrences = 3

/datum/round_event/aquila_hex_anomaly/artifact
	startWhen = 1
	announceWhen = 2
	anomaly_path = /obj/item/xenoartifact

/datum/round_event/aquila_hex_anomaly/artifact/announce(fake)
	if(!impact_area)
		return
	priority_announce("Czujniki okrętu wykryły sygnaturę obcego artefaktu, który zmaterializował się w: [impact_area.name]. Dział naukowy proszony o zabezpieczenie znaleziska. Prosimy go nie lizać.", "Alarm: Anomalia", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_hex_anomaly/artifact/spawn_anomaly(turf/spawn_turf)
	var/obj/item/xenoartifact/artifact = new anomaly_path(spawn_turf)
	do_sparks(4, FALSE, artifact)
	return artifact
