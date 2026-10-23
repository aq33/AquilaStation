// aq33/AquilaStation#426 - pająki z tgstation zastępują stare pająki

/datum/test_chamber_kit/pr_426
	name = "PR 426: pająki z tg"
	pr = "aq33/AquilaStation#426"
	description = "Pająki stoją bez AI. Wejście w pająka: Aghost i kliknij powiadomienie „Można sterować” (albo Spawners) - po wejściu dostajesz antagonistę z rozkazem. \
	Matka: sieci (zwykła/uszczelniająca, twarda, przejście, lepka, kolce), rozkazy do roju, owinięcie małpy w kokon (wysysanie daje ładunek na wzbogacone jaja), jaja zwykłe/nietypowe/wzbogacone. \
	Pielęgniarz: klik bez trybu walki opatruje innego pająka. Tarantula: szarża (też prawym przyciskiem). Żmija: tryb obronny. Wyłamywacz: rozerwij zwykłą ścianę. \
	Młody pająk i pajączek rosną (pajączek chodzi wentylacją). Sprawdź, że pająki są szybsze na sieci, a człowiek wolniejszy, i że ściana z sieci trzyma powietrze. \
	Gniazdo jaj szybko dojrzewa: jako duch kliknij je, wybierz pająka z menu. Jeśli nikt go nie weźmie przez 150 s, wykluje 1-3 pajączki pod AI."
	items = list(
		/mob/living/simple_animal/hostile/spider/giant/midwife/test_chamber = 1,
		/mob/living/simple_animal/hostile/spider/giant/nurse/test_chamber = 1,
		/mob/living/simple_animal/hostile/spider/giant/tarantula/test_chamber = 1,
		/mob/living/simple_animal/hostile/spider/giant/viper/test_chamber = 1,
		/mob/living/simple_animal/hostile/spider/giant/breacher/test_chamber = 1,
		/mob/living/simple_animal/hostile/spider/growing/young/hunter/test_chamber = 1,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/scout/test_chamber = 1,
		/obj/structure/spider/eggcluster/midwife = 1,
		/obj/structure/spider/stickyweb = 3,
		/mob/living/carbon/monkey = 2,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_426/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/structure/spider/eggcluster/eggs in spawned)
		eggs.amount_grown = 100
	// Zwykła ściana dla wyłamywacza (reset komory ją usunie)
	var/turf/wall_turf = turfs[length(turfs)]
	wall_turf.ChangeTurf(/turf/closed/wall)

/// Pająki z komory: bez AI, do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/hostile/spider/proc/test_chamber_init()
	toggle_ai(AI_OFF)
	set_playable(ROLE_SPIDER)

/mob/living/simple_animal/hostile/spider/proc/test_chamber_login()
	if(!mind || mind.has_antag_datum(/datum/antagonist/spider))
		return
	mind.assigned_role = ROLE_SPIDER
	mind.special_role = ROLE_SPIDER
	mind.add_antag_datum(new /datum/antagonist/spider("Testuj zdolności w komorze testowej."))

/mob/living/simple_animal/hostile/spider/giant/midwife/test_chamber/Initialize(mapload)
	. = ..()
	test_chamber_init()

/mob/living/simple_animal/hostile/spider/giant/midwife/test_chamber/Login()
	. = ..()
	test_chamber_login()

/mob/living/simple_animal/hostile/spider/giant/nurse/test_chamber/Initialize(mapload)
	. = ..()
	test_chamber_init()

/mob/living/simple_animal/hostile/spider/giant/nurse/test_chamber/Login()
	. = ..()
	test_chamber_login()

/mob/living/simple_animal/hostile/spider/giant/tarantula/test_chamber/Initialize(mapload)
	. = ..()
	test_chamber_init()

/mob/living/simple_animal/hostile/spider/giant/tarantula/test_chamber/Login()
	. = ..()
	test_chamber_login()

/mob/living/simple_animal/hostile/spider/giant/viper/test_chamber/Initialize(mapload)
	. = ..()
	test_chamber_init()

/mob/living/simple_animal/hostile/spider/giant/viper/test_chamber/Login()
	. = ..()
	test_chamber_login()

/mob/living/simple_animal/hostile/spider/giant/breacher/test_chamber/Initialize(mapload)
	. = ..()
	test_chamber_init()

/mob/living/simple_animal/hostile/spider/giant/breacher/test_chamber/Login()
	. = ..()
	test_chamber_login()

/mob/living/simple_animal/hostile/spider/growing/young/hunter/test_chamber/Initialize(mapload)
	. = ..()
	test_chamber_init()

/mob/living/simple_animal/hostile/spider/growing/young/hunter/test_chamber/Login()
	. = ..()
	test_chamber_login()

/mob/living/simple_animal/hostile/spider/growing/spiderling/scout/test_chamber/Initialize(mapload)
	. = ..()
	test_chamber_init()

/mob/living/simple_animal/hostile/spider/growing/spiderling/scout/test_chamber/Login()
	. = ..()
	test_chamber_login()

// Bez gracza nie rośnie, inaczej po minucie zrobiłby się z niego dorosły pająk pod AI
/mob/living/simple_animal/hostile/spider/growing/young/hunter/test_chamber/ready_to_grow()
	return ..() && client

/mob/living/simple_animal/hostile/spider/growing/spiderling/scout/test_chamber/ready_to_grow()
	return ..() && client
