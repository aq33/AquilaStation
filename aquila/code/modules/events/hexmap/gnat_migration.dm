// AQUILA - Rój kosmicznych muszek: falami nadlatują roje muszek, które kąsają ludzi na EVA (port z VOREStation/VOREStation code/modules/events/gnat_migration.dm)
// VORE spawns gnat groups every 10 s up to a cap (12/16 by severity) at gnat landmarks or the map edge and sends them to the
// map centre. Ours: 6 waves every 10 s, 2–3 groups of 1–3 gnats each, at most 8 alive, flying past the hull on the shared
// flyby route (fauna_flyby.dm); they hunt only people in space, so the crew inside just watches them through the windows.
// With weak bites (void_fauna.dm) a full swarm wears a suited spacewalker down over minutes, not seconds.

/datum/round_event_control/aquila_hex_gnat_migration
	name = "Rój kosmicznych muszek"
	typepath = /datum/round_event/aquila_hex_fauna_flyby/gnats
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_fauna_flyby/gnats
	announceWhen = 15
	startWhen = 1
	endWhen = 90
	fauna_types = list(/mob/living/basic/aquila_void_fauna/gnat = 1)
	groups_min = 2
	groups_max = 3
	group_min = 1
	group_max = 3
	waves = 6
	wave_interval = 5
	fauna_cap = 8
	clearance_min = 2
	clearance_max = 4

/datum/round_event/aquila_hex_fauna_flyby/gnats/announce(fake)
	priority_announce("Wokół [station_name()] krąży rój kosmicznych muszek. Pojedynczo niegroźne, w chmarze potrafią zamęczyć każdego na zewnątrz. Spacery po kadłubie odradzamy, a tym, którzy muszą wyjść, zalecamy pełne skafandry i dużo cierpliwości.", "Alarm - formy życia")
