// aq33/AquilaStation#696 - horror w nosicielu (mutacja, Stłum opór), sprite pękniętej czaszki, ikonka ubikacji

/datum/test_chamber_kit/pr_696
	name = "PR 696: horror w nosicielu, czaszka, ubikacja"
	pr = "aq33/AquilaStation#696"
	description = "Przenosi cię do horroru (trzeba być człowiekiem w komorze; stare ciało zostaje na arenie, wrócisz przez aghost i Assume direct control). Horror ma 250 chemikaliów i 4 punkty dusz. \
	1) Alt+klik na człowieku z umysłem → wchodzisz do głowy; przycisk Mutacja ma być widoczny także w nosicielu i otwierać okno mutacji. \
	2) Opis Ukrywania (poza nosicielem): ma mówić o chowaniu się pod stołami, nie o niewidzialności. \
	3) Przejmij kontrolę nad nosicielem; drugi gracz (albo admin w ciele uwięzionego umysłu) klika Opieraj się kontroli → horror dostaje komunikat. Stłum opór → -50 chemikaliów, odzyskanie ciała przesuwa się o 20 s (bez oporu: komunikat, że umysł się nie opiera, chemikalia bez zmian). \
	4) Człowiek z pękniętą czaszką: z przodu i z tyłu wgniecenie na czubku głowy (nad włosami), z boku nic; po zrośnięciu kości wgniecenie znika. \
	5) Ubikacja (wymaga SHITTING_ENABLED): na ludzkim ciele VV defecation = 120 → zwykła ikonka klopa; 145 → czerwona; popuszczenie dopiero od 200. \
	Rakiet AI w myśliwce nie da się sprawdzić w komorze: na overmapie okręt AI ma strzelać rakietą w myśliwiec dopiero z ok. 25 pól, a rakieta po 8 s gubi namiar i leci prosto."
	items = list(
		/mob/living/simple_animal/horror/test_chamber_696 = 1,
		/mob/living/carbon/human = 3,
		/obj/item/healthanalyzer/advanced = 1,
	)

/datum/test_chamber_kit/pr_696/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/cracked = FALSE
	for(var/mob/living/carbon/human/dummy in spawned)
		if(!dummy.mind)
			dummy.mind_initialize()
		if(!cracked)
			cracked = TRUE
			dummy.name = "pęknięta czaszka"
			dummy.real_name = dummy.name
			var/datum/wound/blunt/fracture/crack = new()
			crack.apply_wound(dummy.get_bodypart(BODY_ZONE_HEAD), silent = TRUE)
	var/mob/living/simple_animal/horror/horror = locate() in spawned
	if(horror)
		horror.chemicals = 250
		horror.available_points = 4
	var/mob/living/carbon/human/H = user
	if(!horror || !istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby wejść w horrora. Horror i tak leży na arenie (do przejęcia przez ducha).</span>")
		return
	var/datum/mind/player_mind = H.mind
	player_mind.transfer_to(horror)
	if(!player_mind.has_antag_datum(/datum/antagonist/horror))
		player_mind.add_antag_datum(/datum/antagonist/horror)

/// Horror z komory: do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/horror/test_chamber_696/Initialize(mapload, gen = 1)
	. = ..()
	set_playable(ROLE_HORROR)

/mob/living/simple_animal/horror/test_chamber_696/Login()
	. = ..()
	if(mind && !mind.has_antag_datum(/datum/antagonist/horror))
		mind.add_antag_datum(/datum/antagonist/horror)
