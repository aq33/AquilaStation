// AQUILA - Ławica kosmicznych meduz: wokół okrętu dryfują świecące meduzy, które parzą ludzi na EVA (port z VOREStation/VOREStation code/modules/events/jellyfish_migration.dm)
// VORE spawns its vore jellyfish (energy drain, breeding) in waves up to a cap and sends them to the map centre. Ours: 4 waves
// every 10 s, 2–3 groups of 1–3, at most 10 alive, slow and glowing, flying past the hull on the shared flyby route
// (fauna_flyby.dm); the sting burns and tires, and they only go after people in space.

/datum/round_event_control/aquila_hex_jellyfish_migration
	name = "Ławica kosmicznych meduz"
	typepath = /datum/round_event/aquila_hex_fauna_flyby/jellyfish
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_fauna_flyby/jellyfish
	announceWhen = 15
	startWhen = 1
	endWhen = 120
	fauna_types = list(/mob/living/basic/aquila_void_fauna/jellyfish = 1)
	groups_min = 2
	groups_max = 3
	group_min = 1
	group_max = 3
	waves = 4
	wave_interval = 5
	fauna_cap = 10
	clearance_min = 2
	clearance_max = 5

/datum/round_event/aquila_hex_fauna_flyby/jellyfish/announce(fake)
	priority_announce("Za burtą [station_name()] dryfuje ławica kosmicznych meduz. Wyglądają pięknie, zwłaszcza z mostka, ale ich macki parzą nawet przez skafander. Prosimy podziwiać je zza szyby.", "Alarm - formy życia")
