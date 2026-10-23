// aq33/AquilaStation#423 - wędrowiec pustki (voidwalker) z tgstation

/datum/test_chamber_kit/pr_423
	name = "PR 423: wędrowiec pustki"
	pr = "aq33/AquilaStation#423"
	description = "Wejście w wędrowca: Aghost i kliknij powiadomienie „Można sterować” (albo Spawners) - po wejściu dostajesz antagonistę. \
	W komorze nie ma kosmosu, więc kamuflaż i leczenie w kosmosie oraz nurkowanie po wpadnięciu na ścianę sprawdź na zewnątrz statku (admin: przenieś moba). \
	Tutaj: przejdź przez okno i kratę (okno przez 5 s przepuszcza innych), lewy klik na człowieku dusi, prawy zadaje brute, ofiara przez 15 s nie umiera. \
	Nieprzytomny człowiek leży na mgławicowych wymiocinach - porwij go (6 s): wraca z klątwą pustki (kosmiczna skóra, pacyfizm, wymioty mgławicą). \
	Zanurkuj do drugiej plamy wymiocin i skacz między nimi przyciskiem. Niepokój na przytomnym człowieku (6 s patrzenia), prawy klik na zwykłej ścianie zamienia ją w okno pustki. \
	Kosmiczna czaszka zamienia klątwę w stabilną i daje pożeracza pustki (ramię rozbijające okna)."
	items = list(
		/mob/living/simple_animal/hostile/voidwalker/test_chamber = 1,
		/mob/living/carbon/human = 3,
		/obj/structure/window/fulltile = 1,
		/obj/structure/grille = 1,
		/obj/item/clothing/head/helmet/skull/cosmic = 1,
	)

/datum/test_chamber_kit/pr_423/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/far = turfs.Copy(min(length(items) + 1, length(turfs)))
	if(length(far) < 4)
		far = turfs
	// Ofiara do porwania: nieprzytomna, na wymiocinach
	// Trzeci człowiek z listy to ofiara
	var/mob/living/carbon/human/victim
	for(var/mob/living/carbon/human/H in spawned)
		victim = H
	victim.forceMove(far[1])
	victim.real_name = "ofiara do porwania"
	victim.name = victim.real_name
	new /obj/effect/decal/cleanable/vomit/nebula(far[1])
	victim.SetUnconscious(10 MINUTES)
	new /obj/effect/decal/cleanable/vomit/nebula(far[2])
	// Zwykła ściana do rozrostu (reset komory ją usunie)
	var/turf/wall_turf = far[length(far)]
	wall_turf.ChangeTurf(/turf/closed/wall)

/// Wędrowiec z komory: do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/hostile/voidwalker/test_chamber/Initialize(mapload)
	. = ..()
	set_playable(ROLE_VOIDWALKER)

/mob/living/simple_animal/hostile/voidwalker/test_chamber/Login()
	. = ..()
	if(mind && !mind.has_antag_datum(/datum/antagonist/voidwalker))
		mind.add_antag_datum(/datum/antagonist/voidwalker)
