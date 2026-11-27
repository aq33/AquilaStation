// AQUILA - Stado kosmicznych rekinów: kilka rekinów krąży obok okrętu i poluje na ludzi na EVA (port z VOREStation/VOREStation code/modules/events/shark_migration.dm)
// VORE keeps 2–3 event sharks alive in waves and sends them to the map centre. Ours: 3 waves every 10 s, 1–2 groups of 1–2,
// at most 3 alive, flying past the hull on the shared flyby route (fauna_flyby.dm); they hunt only people in space and
// cannot break in, so the warning tells the crew to stay inside.

/datum/round_event_control/aquila_hex_shark_migration
	name = "Stado kosmicznych rekinów"
	typepath = /datum/round_event/aquila_hex_fauna_flyby/sharks
	weight = 6
	min_players = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_fauna_flyby/sharks
	startWhen = 1
	announceWhen = 2
	endWhen = 100
	fauna_types = list(/mob/living/basic/aquila_void_fauna/shark = 1)
	groups_min = 1
	groups_max = 2
	group_min = 1
	group_max = 2
	waves = 3
	wave_interval = 5
	fauna_cap = 3
	clearance_min = 2
	clearance_max = 4

/datum/round_event/aquila_hex_fauna_flyby/sharks/announce(fake)
	priority_announce("Uwaga: wokół [station_name()] krąży stado kosmicznych rekinów. Wszystkie prace na zewnątrz kadłuba wstrzymane do odwołania. Rekiny nie przebiją kadłuba, ale skafander to dla nich tylko opakowanie.", "Alarm - formy życia", ANNOUNCER_ALIENS)
