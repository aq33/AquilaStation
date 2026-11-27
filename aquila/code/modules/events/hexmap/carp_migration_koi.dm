// AQUILA - Ławica koi: obok okrętu przepływa 12–30 niegroźnych kosmicznych koi, bardzo rzadko z koi-klaunem (port z ParadiseSS13/Paradise code/modules/events/koi_mirgration.dm)
// Paradise reuses its carp migration (koi spawned at carp landmarks and sent through the station). Ours fly past the hull
// on the shared flyby route (fauna_flyby.dm) in 4–6 groups of 3–5 and leave; the clown koi is 2% of the fish as in Paradise.

/datum/round_event_control/aquila_hex_carp_migration_koi
	name = "Ławica koi"
	typepath = /datum/round_event/aquila_hex_fauna_flyby/koi
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_fauna_flyby/koi
	endWhen = 75
	fauna_types = list(
		/mob/living/basic/aquila_void_fauna/koi = 98,
		/mob/living/basic/aquila_void_fauna/koi/honk = 2,
	)
	groups_min = 4
	groups_max = 6
	group_min = 3
	group_max = 5

/datum/round_event/aquila_hex_fauna_flyby/koi/announce(fake)
	priority_announce("Sensory biologiczne wykrywają ławicę kosmicznych koi przepływającą obok [station_name()]. Ryby są niegroźne i bardzo fotogeniczne. Przypominamy, że łowienie ich z luku towarowego nie jest przewidziane w regulaminie.", "Alarm - formy życia")
