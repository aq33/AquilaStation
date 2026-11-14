// AQUILA - szczeliny bluespace: 1–5 par dwukierunkowych portali między tunelami technicznymi okrętu, każda para znika po kilku przejściach (port z CEV-Eris code/game/gamemodes/events/hidden_events/bluespace_rift.dm)

/datum/round_event_control/aquila_hex_bluespace_rifts
	name = "Szczeliny bluespace"
	typepath = /datum/round_event/aquila_hex_bluespace_rifts
	weight = 10
	min_players = 0
	max_occurrences = 3
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_bluespace_rifts
	announceWhen = 2
	startWhen = 1
	/// Ile par szczelin otworzyć
	var/pair_number = 1

/datum/round_event/aquila_hex_bluespace_rifts/setup()
	pair_number = rand(1, 5)

/datum/round_event/aquila_hex_bluespace_rifts/announce(fake)
	priority_announce("Czujniki wykryły niestabilne szczeliny bluespace w tunelach technicznych okrętu. Szczeliny łączą odległe miejsca i zamkną się po kilku przejściach.", "Szczeliny bluespace", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_hex_bluespace_rifts/start()
	var/list/areas = maintenance_areas()
	var/list/rifts = list()
	for(var/i in 1 to pair_number)
		if(length(areas) < 2)
			break
		var/turf/entrance = free_turf(pick_n_take(areas))
		var/turf/exit = free_turf(pick_n_take(areas))
		if(!entrance || !exit)
			continue
		var/list/pair = open_rift_pair(entrance, exit, rand(3, 10))
		if(pair)
			rifts += pair
	if(length(rifts))
		announce_to_ghosts(rifts[1])
		log_game("Bluespace Rifts opened [length(rifts) / 2] rift pairs.")

/// Obszary techniczne okrętu
/datum/round_event/aquila_hex_bluespace_rifts/proc/maintenance_areas()
	. = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(istype(A, /area/maintenance) && (A.type in GLOB.the_station_areas))
			. += A

/// Wolna podłoga w obszarze, na której nie stoi już portal
/datum/round_event/aquila_hex_bluespace_rifts/proc/free_turf(area/A)
	var/list/turfs = list()
	for(var/turf/open/T in A)
		if(isspaceturf(T) || is_blocked_turf(T, TRUE) || (locate(/obj/effect/portal) in T))
			continue
		turfs += T
	if(length(turfs))
		return pick(turfs)

/// Otwiera parę połączonych szczelin, która wytrzyma podaną liczbę przejść. Zwraca obie szczeliny.
/datum/round_event/aquila_hex_bluespace_rifts/proc/open_rift_pair(turf/entrance, turf/exit, uses)
	var/list/pair = create_portal_pair(entrance, exit, null, 0, 0, /obj/effect/portal/aquila_hex_rift)
	if(length(pair) != 2)
		return
	for(var/obj/effect/portal/aquila_hex_rift/rift as anything in pair)
		rift.uses_left = uses
	return pair

/obj/effect/portal/aquila_hex_rift
	name = "szczelina bluespace"
	desc = "Drgająca rozpadlina w przestrzeni. Prowadzi gdzieś indziej, ale nie wygląda na trwałą."
	mech_sized = TRUE
	/// Ile przejść wytrzyma jeszcze para (obie strony mają tę samą liczbę)
	var/uses_left = 5

/obj/effect/portal/aquila_hex_rift/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(!. || isobserver(M) || QDELETED(src))
		return
	uses_left--
	var/obj/effect/portal/aquila_hex_rift/partner = linked
	if(istype(partner))
		partner.uses_left = uses_left
	if(uses_left > 0)
		return
	visible_message("<span class='warning'>[src] zapada się w sobie i znika.</span>")
	if(istype(partner))
		partner.visible_message("<span class='warning'>[partner] zapada się w sobie i znika.</span>")
	qdel(src) // para jest twardo połączona, więc znika też druga strona
