// AQUILA - szczury z pasa: kilka myśliwców Syndykatu wylatuje z pola asteroid na okręt gracza (przywrócony event overmapy
// NSV13 belt_rats.dm, usunięty w BeeStation/NSV13#1566). W NSV13 1–2 myśliwce napadały statek górniczy; u nas go nie ma
// (mapy górnicze usunięte w aq33/AquilaStation#436), więc 2–3 myśliwce atakują okręt gracza na polu asteroid.
// Przychodzi z puli kafli mapy hex, rzadko i tylko poza sektorem Sol (aquila_hex_syndicate_space() w lone_hunter.dm).
// Myśliwce nie należą do floty i nie dają nagrody za zestrzelenie (bounty = 0).

/datum/round_event_control/aquila_hex_belt_rats
	name = "Szczury z pasa"
	typepath = /datum/round_event/aquila_hex_belt_rats
	weight = 5
	min_players = 5
	max_occurrences = 2
	earliest_start = 20 MINUTES
	hex_pool_chance = 25

/datum/round_event_control/aquila_hex_belt_rats/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(. && !aquila_hex_syndicate_space(SSstar_system.find_main_overmap()))
		return FALSE

/datum/round_event/aquila_hex_belt_rats
	fakeable = FALSE
	startWhen = 1
	endWhen = 1

/datum/round_event/aquila_hex_belt_rats/start()
	var/list/rats = spawn_rats(SSstar_system.find_main_overmap())
	if(!length(rats))
		log_game("Belt Rats: the main ship is not in a star system, cancelling the event.")
		return kill()
	announce_to_ghosts(rats[1])

/**
 * Stawia 2–3 myśliwce Syndykatu w różnych kierunkach 10–14 pól od okrętu i kieruje je na okręt.
 * Bez okrętu w układzie gwiezdnym nic nie robi i zwraca pustą listę.
 */
/datum/round_event/aquila_hex_belt_rats/proc/spawn_rats(obj/structure/overmap/near)
	. = list()
	if(!aquila_hex_ship_settled(near))
		return
	for(var/i in 1 to rand(2, 3))
		var/turf/spot = aquila_hex_overmap_spot_beside(near, rand(10, 14), GLOB.alldirs)
		if(!spot)
			continue
		var/obj/structure/overmap/syndicate/ai/fighter/rat = new /obj/structure/overmap/syndicate/ai/fighter(spot)
		rat.bounty = 0
		aquila_hex_overmap_place(rat, near, spot)
		rat.add_enemy(near)
		. += rat
	log_game("Belt Rats: [length(.)] Syndicate fighter(s) attack [near] in [near.current_system].")
