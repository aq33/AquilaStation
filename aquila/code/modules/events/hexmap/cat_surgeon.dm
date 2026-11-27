// AQUILA - Kocichirurg: zbiegły pacjent oddziału psychiatrycznego Nanotrasen ląduje w tunelach technicznych okrętu, a ochrona dostaje faks z ostrzeżeniem (port z BlueMoon-Labs/BlueMoon-Station code/modules/events/living_entity/cat_surgeon.dm)
// BlueMoon spawns our shared cat butcherer mob (/mob/living/simple_animal/hostile/cat_butcherer) on a safe xeno spawn
// landmark with the cat scream (ours: our meow, we have no scream) and faxes the security department a warning from the Nanotrasen psychiatric ward.
// Ours spawns the same mob on a free maintenance turf (our maps do not always have xeno spawns; they are used first if
// one is safe) and faxes the warning to a security fax, or to any ship fax; with no fax the warning is announced.
// The fax text is written anew in Polish.

/datum/round_event_control/aquila_hex_cat_surgeon
	name = "Kocichirurg"
	typepath = /datum/round_event/aquila_hex_cat_surgeon
	weight = 10
	min_players = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_cat_surgeon
	fakeable = FALSE
	startWhen = 1
	announceWhen = 3
	/// Kocichirurg się pojawił
	var/spawned = FALSE

/datum/round_event/aquila_hex_cat_surgeon/start()
	var/mob/living/simple_animal/hostile/cat_butcherer/surgeon = spawn_surgeon(find_spawn())
	if(!surgeon)
		log_game("Cat Surgeon: no free maintenance turf found, cancelling the event.")
		return kill()
	spawned = TRUE
	announce_to_ghosts(surgeon)

/datum/round_event/aquila_hex_cat_surgeon/announce(fake)
	if(!spawned && !fake)
		return
	if(!send_warning(find_fax()))
		priority_announce("Jeden z naszych... szczególnych pacjentów opuścił oddział bez wypisu. Jego nadajnik zgasł w pobliżu waszego okrętu. Prosimy o ostrożność w tunelach technicznych. I jeszcze jedno: czy ktoś z was widział nasze koty?", "Oddział Psychiatryczny Nanotrasen")

/// Bezpieczny punkt pojawiania się obcych na statku, a gdy go nie ma, wolne pole w tunelach technicznych
/datum/round_event/aquila_hex_cat_surgeon/proc/find_spawn()
	var/list/safe_spawns = list()
	for(var/turf/T in GLOB.xeno_spawn)
		if(is_station_level(T.z) && aquila_hex_free_safe_turf(T))
			safe_spawns += T
	if(length(safe_spawns))
		return pick(safe_spawns)
	return aquila_hex_maint_turf()

/datum/round_event/aquila_hex_cat_surgeon/proc/spawn_surgeon(turf/spot)
	if(!isturf(spot))
		return null
	var/mob/living/simple_animal/hostile/cat_butcherer/surgeon = new(spot)
	playsound(surgeon, 'sound/effects/meow1.ogg', 75, TRUE, 10)
	message_admins("Kocichirurg pojawia się w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Cat Surgeon: a cat surgeon spawned at [AREACOORD(spot)].")
	return surgeon

/// Działający faks ochrony, a gdy go nie ma, dowolny działający faks statku
/datum/round_event/aquila_hex_cat_surgeon/proc/find_fax()
	var/obj/machinery/fax/target
	for(var/obj/machinery/fax/fax in GLOB.machines)
		if(!fax.visible_to_network || fax.syndicate_network || !fax.is_operational)
			continue
		var/turf/T = get_turf(fax)
		if(!T || !is_station_level(T.z))
			continue
		if(istype(get_area(fax), /area/security))
			target = fax
			break
		if(!target)
			target = fax
	return target

/// Faks z ostrzeżeniem; zwraca wydruk albo null
/datum/round_event/aquila_hex_cat_surgeon/proc/send_warning(obj/machinery/fax/target)
	if(QDELETED(target))
		return null
	var/obj/item/paper/warning = new
	warning.name = "pilne: zbiegły pacjent"
	warning.add_raw_text("<center><b>ODDZIAŁ PSYCHIATRYCZNY NANOTRASEN</b><br>Do: ochrona okrętu</center><br>\
		Uprzejmie informujemy, że pacjent nr 9 (pseudonim „Doktor Mruczek”) opuścił nasz oddział bez wypisu, \
		zabierając ze sobą piłę chirurgiczną, wyrzutnię strzykawek i nasz zapas środków usypiających. \
		Ostatni sygnał jego nadajnika pochodzi z waszego okrętu, najpewniej z tuneli technicznych.<br><br>\
		Pacjent uważa, że każdy członek załogi jest niedokończonym kotem, i bardzo chce to naprawić. \
		Prosimy o zatrzymanie go, najlepiej zanim kogoś uszyje.<br><br>\
		<i>PS Jeśli zobaczycie koty, nie pytajcie ich, skąd się wzięły.</i>")
	warning.update_appearance()
	target.receive(warning, "Oddział Psychiatryczny Nanotrasen")
	log_game("Cat Surgeon: warning faxed to [target.fax_name] at [AREACOORD(target)].")
	return warning
