// AQUILA - atak na frachtowiec: w układzie statku piraci napadają na frachtowiec Nanotrasen, który wzywa pomocy (port z DS13 code/modules/overmap/events.dm, /datum/overmap_event)

/// Nieuzbrojony (poza PDC) frachtowiec Nanotrasen sterowany przez AI
/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter
	name = "frachtowiec Nanotrasen"
	desc = "Powolny frachtowiec Nanotrasen z ładowniami pełnymi zaopatrzenia. Ma tylko działka obrony punktowej."
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE

/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/apply_weapons()
	new /datum/overmap_ship_weapon/pdc_mount(src)

/datum/round_event_control/aquila_hex_freighter_attack
	name = "Atak na frachtowiec"
	typepath = /datum/round_event/aquila_hex_freighter_attack
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_freighter_attack
	startWhen = 1
	announceWhen = 2
	endWhen = 450 // 15 minut na odsiecz
	/// Nagroda dla zaopatrzenia za zniszczenie wszystkich piratów, gdy frachtowiec przeżył (jak w oryginale)
	var/reward = 10000
	/// Frachtowiec (weakref, bo zniszczony okręt nie może tu wisieć przez kwadrans)
	var/datum/weakref/freighter_ref
	/// Piraci (weakrefy)
	var/list/pirate_refs = list()
	/// Wynik już ogłoszony
	var/resolved = FALSE
	var/static/list/pirate_types = list(
		/obj/structure/overmap/spacepirate/ai,
		/obj/structure/overmap/spacepirate/ai/nt_missile,
		/obj/structure/overmap/spacepirate/ai/syndie_gunboat,
	)

/datum/round_event/aquila_hex_freighter_attack/start()
	if(!spawn_attack(SSstar_system.find_main_overmap()))
		log_game("Freighter Under Attack: the main ship is not in a star system, cancelling the event.")
		return kill()
	announce_to_ghosts(freighter_ref.resolve())

/datum/round_event/aquila_hex_freighter_attack/announce(fake)
	if(!fake && !freighter_ref?.resolve())
		return
	priority_announce("Odebrano wezwanie pomocy: frachtowiec Nanotrasen w waszym układzie jest atakowany przez piratów. \
		Dowództwo prosi [station_name()] o natychmiastowe wsparcie.", "Wezwanie pomocy")

/datum/round_event/aquila_hex_freighter_attack/tick()
	if(resolved)
		return
	if(!freighter_ref?.resolve())
		resolved = TRUE
		priority_announce("Frachtowiec Nanotrasen został zniszczony przez piratów. Dowództwo jest rozczarowane.", "Wezwanie pomocy")
		endWhen = activeFor + 1
		return
	for(var/datum/weakref/pirate_ref as anything in pirate_refs)
		if(pirate_ref.resolve())
			return
	resolved = TRUE
	var/datum/bank_account/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo?.adjust_money(reward)
	priority_announce("Piraci atakujący frachtowiec zostali zniszczeni. Nanotrasen dziękuje za eskortę: na konto zaopatrzenia przelano [reward] kr.", "Wezwanie pomocy")
	endWhen = activeFor + 1

/datum/round_event/aquila_hex_freighter_attack/kill()
	freighter_ref = null
	pirate_refs = list()
	return ..()

/**
 * Stawia frachtowiec kilkanaście pól od okrętu i 1–2 piratów obok niego, wycelowanych we frachtowiec.
 * Bez okrętu w układzie gwiezdnym nic nie robi i zwraca FALSE.
 */
/datum/round_event/aquila_hex_freighter_attack/proc/spawn_attack(obj/structure/overmap/near)
	if(!aquila_hex_ship_settled(near))
		return FALSE
	var/turf/spot = aquila_hex_overmap_spot_beside(near, rand(14, 18), GLOB.alldirs)
	if(!spot)
		return FALSE
	var/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/freighter = new(spot)
	aquila_hex_overmap_place(freighter, near, spot)
	freighter_ref = WEAKREF(freighter)
	pirate_refs = list()
	for(var/i in 1 to rand(1, 2))
		var/turf/pirate_spot = aquila_hex_overmap_spot_beside(freighter, rand(5, 7), GLOB.alldirs)
		if(!pirate_spot)
			continue
		var/pirate_type = pick(pirate_types)
		var/obj/structure/overmap/pirate = new pirate_type(pirate_spot)
		aquila_hex_overmap_place(pirate, near, pirate_spot)
		pirate.add_enemy(freighter)
		pirate_refs += WEAKREF(pirate)
	return TRUE
