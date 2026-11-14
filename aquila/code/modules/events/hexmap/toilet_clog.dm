// AQUILA - Zatkane ubikacje na statku, w wariancie z zalaniem kilka toalet przelewa się raz po raz (port z Baystation12 code/modules/events/toilets.dm)
// Uses our own clog from aq33/AquilaStation#598 (aquila/code/modules/liquids/toilet_clog.dm): a clogged toilet overflows when flushed
// and a plunger fixes it. Bay has clog levels and fluid depth per tick; we have no clog levels, so the flood variant
// overflows every clogged toilet now and then (every ~30 s for 3 minutes) until someone plunges it. No announcement, like Bay.

/datum/round_event_control/aquila_hex_toilet_clog
	name = "Toilet Clog"
	typepath = /datum/round_event/aquila_hex_toilet_clog
	weight = 10
	min_players = 2
	max_occurrences = 3
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_toilet_clog
	fakeable = FALSE
	/// Fewest toilets to clog
	var/clog_min = 1
	/// Most toilets to clog
	var/clog_max = 3
	/// Do the clogged toilets overflow by themselves during the event
	var/flood = FALSE
	/// Toilets this event clogged
	var/list/clogged_toilets = list()

/datum/round_event/aquila_hex_toilet_clog/start()
	clog_toilets(ship_toilets(), rand(clog_min, clog_max))

/// Unclogged toilets in the ship's areas
/datum/round_event/aquila_hex_toilet_clog/proc/ship_toilets()
	. = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.type in GLOB.the_station_areas))
			continue
		for(var/obj/structure/toilet/toilet in A)
			if(!toilet.clogged)
				. += toilet

/// Clogs up to `amount` toilets from `toilets`, returns how many got clogged
/datum/round_event/aquila_hex_toilet_clog/proc/clog_toilets(list/toilets, amount)
	toilets = toilets.Copy()
	. = 0
	while(amount > 0 && length(toilets))
		var/obj/structure/toilet/toilet = pick_n_take(toilets)
		if(QDELETED(toilet) || toilet.clogged)
			continue
		toilet.clogged = TRUE
		clogged_toilets += toilet
		amount--
		.++
		if(flood)
			toilet.overflow()
	if(.)
		log_game("[control?.name || "Toilet Clog"]: clogged [.] toilet(s).")

/datum/round_event_control/aquila_hex_toilet_clog/flood
	name = "Toilet Flood"
	typepath = /datum/round_event/aquila_hex_toilet_clog/flood
	weight = 5
	min_players = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_toilet_clog/flood
	clog_min = 3
	clog_max = 5
	flood = TRUE
	endWhen = 90

/datum/round_event/aquila_hex_toilet_clog/flood/tick()
	if(activeFor % 15)
		return
	overflow_clogged()

/// Every toilet this event clogged and nobody has plunged yet overflows again
/datum/round_event/aquila_hex_toilet_clog/proc/overflow_clogged()
	for(var/obj/structure/toilet/toilet as anything in clogged_toilets.Copy())
		if(QDELETED(toilet) || !toilet.clogged)
			clogged_toilets -= toilet
			continue
		toilet.overflow()

/datum/round_event/aquila_hex_toilet_clog/kill()
	clogged_toilets.Cut()
	return ..()
