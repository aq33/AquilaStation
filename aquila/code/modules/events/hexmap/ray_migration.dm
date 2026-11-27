// AQUILA - Przelot kosmicznych płaszczek: kilka płaszczek szybuje obok okrętu, oddają tylko zaczepione (port z VOREStation/VOREStation code/modules/events/ray_migration.dm)
// VORE keeps 2–3 rays alive in waves and sends them to the map centre. Ours: 3 waves every 10 s, 1–2 groups of 1–2, at most
// 3 alive, gliding past the hull on the shared flyby route (fauna_flyby.dm); they never hunt, only strike back.

/datum/round_event_control/aquila_hex_ray_migration
	name = "Przelot kosmicznych płaszczek"
	typepath = /datum/round_event/aquila_hex_fauna_flyby/rays
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_fauna_flyby/rays
	announceWhen = 10
	startWhen = 1
	endWhen = 75
	fauna_types = list(/mob/living/basic/aquila_void_fauna/ray = 1)
	groups_min = 1
	groups_max = 2
	group_min = 1
	group_max = 2
	waves = 3
	wave_interval = 5
	fauna_cap = 3

/datum/round_event/aquila_hex_fauna_flyby/rays/announce(fake)
	priority_announce("Obok [station_name()] szybują kosmiczne płaszczki. Mimo groźnego wyglądu są łagodne i nikogo nie zaczepiają, o ile nikt nie zaczepia ich. Działo nie jest odpowiedzią na każde pytanie.", "Alarm - formy życia")
