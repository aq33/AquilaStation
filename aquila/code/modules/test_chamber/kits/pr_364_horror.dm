// aq33/AquilaStation#364 - pradawny horror (Eldritch Horror z Yogstation)

/datum/test_chamber_kit/pr_364
	name = "PR 364: pradawny horror"
	pr = "aq33/AquilaStation#364"
	description = "Przenosi cię do horroru (trzeba być człowiekiem w komorze; stare ciało zostaje na arenie - wrócisz przez aghost i Assume direct control). Dwaj ludzie na arenie mają umysły i dusze, więc są celami. Horror startuje z 4 punktami dusz. \
	1) Szukaj duszy → oczekiwane: wybierasz jednego z ludzi, pojawia się wskaźnik celu. \
	2) Alt+klik na człowieku → oczekiwane: wchodzisz do jego głowy; zamroź ofiarę → oczekiwane: nosiciel nieruchomy. \
	3) Pożryj duszę na nosicielu, który NIE jest celem → oczekiwane: odmowa (\"To nie jest dusza twojego celu\"). \
	4) Pożryj duszę na celu (ok. 30 s, nie ruszaj się) → oczekiwane: +1 punkt dusz, nosiciel traci 20 maks. HP. \
	5) Okno Mutacja: kup mutacje za wszystkie punkty → oczekiwane: kolejny zakup przy 0 punktów odmawia, tej samej mutacji nie kupisz drugi raz. \
	6) Przejmij kontrolę nad nosicielem, oddaj ją, wydziel chemikalia, opuść nosiciela → oczekiwane: każde działa; horror przeciska się przez śluzę. \
	7) Zaawansowany analizator zdrowia na nosicielu → oczekiwane: wykrywa horrora; operacja manipulacji organami w głowie (kącik chirurgiczny) pozwala go wyjąć. \
	8) Transporter \"horror w pudełku\" (uplink Bibliotekarza): użyj w ręce → oczekiwane: ankieta duchów, horror budzi się jako sługa użytkownika (wymaga ducha: drugi gracz lub aghost admina)."
	items = list(
		/mob/living/simple_animal/horror/test_chamber = 1,
		/mob/living/carbon/human = 2,
		/obj/item/horrorspawner = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/machinery/door/airlock = 1,
	)

/datum/test_chamber_kit/pr_364/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Ludzie z umysłem i duszą - bez tego "Szukaj duszy" nie ma celów
	for(var/mob/living/carbon/human/dummy in spawned)
		if(!dummy.mind)
			dummy.mind_initialize()
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby wejść w horrora. Horror i tak leży na arenie (do przejęcia przez ducha).</span>")
		return
	var/mob/living/simple_animal/horror/horror = locate() in spawned
	if(!horror)
		return
	var/datum/mind/player_mind = H.mind
	player_mind.transfer_to(horror)
	if(!player_mind.has_antag_datum(/datum/antagonist/horror))
		player_mind.add_antag_datum(/datum/antagonist/horror)

/// Horror z komory: do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/horror/test_chamber/Initialize(mapload, gen = 1)
	. = ..()
	set_playable(ROLE_HORROR)

/mob/living/simple_animal/horror/test_chamber/Login()
	. = ..()
	if(mind && !mind.has_antag_datum(/datum/antagonist/horror))
		mind.add_antag_datum(/datum/antagonist/horror)
