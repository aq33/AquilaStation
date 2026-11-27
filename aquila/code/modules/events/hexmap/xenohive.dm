// AQUILA - Gniazdo obcych w technicznych: w tunelach technicznych wyrasta małe gniazdo z chwastami i żywicą, pilnowane przez dwa lub trzy ksenomorfy bez graczy (port z TauCetiStation/TauCetiClassic code/modules/events/xenohive.dm)
// TauCeti (a maintenance_spawn feature event) places a weed node, a xenomorph drone, a xenomorph, a resin membrane and
// an air plant in maintenance. Ours builds the nest on a free maintenance turf from our alien structures (weed node in
// the middle, resin walls and membranes around it) and puts two or three of our NPC xenomorphs on it
// (/mob/living/basic/alien: always a drone, which keeps planting weeds, and one or two hunters or sentinels). We have no
// air plant. Unannounced, like TauCeti. This is not the alien infestation event (ghosts as player xenomorphs).

/datum/round_event_control/aquila_hex_xenohive
	name = "Gniazdo obcych w technicznych"
	typepath = /datum/round_event/aquila_hex_xenohive
	weight = 5
	min_players = 15
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/aquila_hex_xenohive
	fakeable = FALSE
	startWhen = 1

/datum/round_event/aquila_hex_xenohive/start()
	var/list/hive = build_hive(aquila_hex_maint_turf())
	if(!length(hive))
		log_game("Xenohive: no free maintenance turf found, cancelling the event.")
		return kill()
	announce_to_ghosts(hive[1])

/**
 * Buduje gniazdo wokół center: węzeł chwastów, 2-4 kawałki żywicy, dron obcych i 1-2 łowców albo strażników.
 * Zwraca listę ksenomorfów (pierwszy to dron) albo pustą listę, gdy nie ma miejsca.
 */
/datum/round_event/aquila_hex_xenohive/proc/build_hive(turf/center)
	. = list()
	var/list/turfs = aquila_hex_free_turfs_near(center, 9, 2)
	if(length(turfs) < 3)
		return
	new /obj/structure/alien/weeds/node(center)
	turfs -= center
	var/list/aliens = list(/mob/living/basic/alien/drone)
	for(var/i in 1 to rand(1, 2))
		aliens += pick(/mob/living/basic/alien, /mob/living/basic/alien/sentinel)
	for(var/alien_type in aliens)
		var/turf/spot = length(turfs) > 2 ? pick_n_take(turfs) : center
		. += new alien_type(spot)
	for(var/i in 1 to min(rand(2, 4), length(turfs)))
		var/turf/resin_spot = pick_n_take(turfs)
		new /obj/structure/alien/weeds(resin_spot)
		var/resin_type = pick(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)
		new resin_type(resin_spot)
	message_admins("Gniazdo obcych w technicznych powstaje w [ADMIN_VERBOSEJMP(center)] ([length(.)] ksenomorfów).")
	log_game("Xenohive: a nest with [length(.)] NPC xenomorphs was built at [AREACOORD(center)].")
