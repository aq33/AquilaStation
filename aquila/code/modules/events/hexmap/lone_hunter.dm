// AQUILA - samotny łowca: DRADIS wykrywa sygnaturę bluespace, a po kilku sekundach przy okręcie gracza wyskakuje jeden okręt
// Syndykatu (przywrócony event overmapy NSV13 lone_hunter.dm, usunięty w BeeStation/NSV13#1566).
// W NSV13 odpalał go handler eventów overmapy; u nas przychodzi z puli kafli mapy hex, rzadko i tylko poza sektorem Sol.
// Okręt nie należy do floty i nie daje nagrody za zestrzelenie (bounty = 0).

/// Okręt stoi na pograniczu (sektor neutralny) albo w sektorze Syndykatu: tam zapuszczają się samotni łowcy i szczury z pasa
/proc/aquila_hex_syndicate_space(obj/structure/overmap/ship)
	var/sector = ship?.current_system?.sector
	return sector == SECTOR_NEUTRAL || sector == SECTOR_SYNDICATE

/datum/round_event_control/aquila_hex_lone_hunter
	name = "Samotny łowca"
	typepath = /datum/round_event/aquila_hex_lone_hunter
	weight = 5
	min_players = 5
	max_occurrences = 2
	earliest_start = 20 MINUTES
	hex_pool_chance = 25

/datum/round_event_control/aquila_hex_lone_hunter/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(. && !aquila_hex_syndicate_space(SSstar_system.find_main_overmap()))
		return FALSE

/datum/round_event/aquila_hex_lone_hunter
	fakeable = FALSE
	startWhen = 1
	announceWhen = -1 // ostrzeżenie DRADIS idzie w start(), tylko gdy okręt stoi w układzie
	/// Okręt, przy którym wyskoczy łowca (weakref)
	var/datum/weakref/target_ref

/datum/round_event/aquila_hex_lone_hunter/setup()
	endWhen = startWhen + rand(2, 3) // 4–6 s od ostrzeżenia do wyskoku (jak 3–6 s w oryginale)

/datum/round_event/aquila_hex_lone_hunter/start()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!aquila_hex_ship_settled(main))
		log_game("Lone Hunter: the main ship is not in a star system, cancelling the event.")
		return kill()
	target_ref = WEAKREF(main)
	minor_announce("Wykryto sygnaturę bluespace.", "Łącze DRADIS")

/datum/round_event/aquila_hex_lone_hunter/end()
	var/obj/structure/overmap/hunter = spawn_hunter(target_ref?.resolve())
	if(hunter)
		announce_to_ghosts(hunter)

/datum/round_event/aquila_hex_lone_hunter/kill()
	target_ref = null
	return ..()

/**
 * Stawia jeden okręt Syndykatu kilkanaście pól od okrętu i kieruje go na okręt.
 * Gdy okręt nie stoi w układzie gwiezdnym (np. skoczył w czasie ostrzeżenia), nic nie robi i zwraca null.
 */
/datum/round_event/aquila_hex_lone_hunter/proc/spawn_hunter(obj/structure/overmap/near)
	if(!aquila_hex_ship_settled(near))
		return null
	var/turf/spot = aquila_hex_overmap_spot_beside(near, rand(12, 16), GLOB.alldirs)
	if(!spot)
		return null
	var/obj/structure/overmap/syndicate/ai/hunter = new /obj/structure/overmap/syndicate/ai(spot)
	hunter.bounty = 0
	aquila_hex_overmap_place(hunter, near, spot)
	hunter.add_enemy(near)
	log_game("Lone Hunter: [hunter] jumped in next to [near] in [near.current_system].")
	return hunter
