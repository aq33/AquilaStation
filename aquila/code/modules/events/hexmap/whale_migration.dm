// AQUILA - Migracja kosmicznych wielorybów: spokojne stado dorosłych wielorybów z młodymi przepływa obok okrętu (port z Baystation12/Baystation12 code/modules/events/mob_spawning/whale.dm)
// Bay throws 2–3 whales (adults and calves 2:1) at each station level and announces both the arrival and the departure.
// Ours: one pod of 2–3 adults and 1–2 calves following their mothers, on the shared flyby route (fauna_flyby.dm) further
// from the hull (big sprites), with the same two announcements; the whales only fight back when someone hurts the pod.

/datum/round_event_control/aquila_hex_whale_migration
	name = "Migracja kosmicznych wielorybów"
	typepath = /datum/round_event/aquila_hex_fauna_flyby/whales
	weight = 6
	max_occurrences = 1
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_fauna_flyby/whales
	announceWhen = 1
	startWhen = 10
	endWhen = 150
	fauna_types = list(/mob/living/basic/aquila_void_fauna/space_whale = 1)
	clearance_min = 6
	clearance_max = 9
	/// Ile dorosłych (od, do)
	var/adults_min = 2
	var/adults_max = 3
	/// Ile młodych (od, do)
	var/calves_min = 1
	var/calves_max = 2

/datum/round_event/aquila_hex_fauna_flyby/whales/setup()
	group_min = rand(adults_min, adults_max)
	group_max = group_min

/datum/round_event/aquila_hex_fauna_flyby/whales/announce(fake)
	priority_announce("Sensory [station_name()] wykrywają stado migrujących kosmicznych wielorybów, w tym młode. Przelot nastąpi w bezpiecznej odległości od kadłuba. Dowództwo zachęca załogę do udania się do najbliższego okna. Prosimy nie celować w stado z dział, nawet „na próbę”.", "Sensory dalekiego zasięgu")

/// Dorosłe na polach spots, a przy nich 1–2 młode, każde przy losowej matce
/datum/round_event/aquila_hex_fauna_flyby/whales/spawn_at(list/spots, list/route)
	. = ..()
	var/list/adults = .
	adults = adults.Copy() // . rośnie o młode, a matką ma być tylko dorosły
	if(!length(adults))
		return
	for(var/i in 1 to rand(calves_min, calves_max))
		var/mob/living/basic/aquila_void_fauna/space_whale/mother = pick(adults)
		var/mob/living/basic/aquila_void_fauna/space_whale/calf/calf = new(get_turf(mother))
		calf.follow_mother(mother)
		. += add_fauna(calf, route)

/datum/round_event/aquila_hex_fauna_flyby/whales/end()
	..()
	priority_announce("Stado kosmicznych wielorybów minęło [station_name()] i odpłynęło w głąb sektora. Prosimy wrócić do obowiązków.", "Sensory dalekiego zasięgu")
