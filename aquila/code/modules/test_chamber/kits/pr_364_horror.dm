// aq33/AquilaStation#364 - pradawny horror (Eldritch Horror z Yogstation)

/datum/test_chamber_kit/pr_364
	name = "PR 364: pradawny horror"
	pr = "aq33/AquilaStation#364"
	description = "Horror do przejęcia przez ducha (dostaje antagonistę po wejściu). Jako horror: Szukaj duszy wskazuje cel, wejdź do głowy człowieka (Alt+klik na nim), zamroź ofiarę, \
	Pożryj duszę na nosicielu - za dusze kupujesz mutacje w oknie Mutacja (nie da się kupować bez punktów ani w nieskończoność). Przejmij kontrolę, oddaj ją, wydziel chemikalia, opuść nosiciela. Horror przeciska się przez śluzę. \
	Zaawansowany analizator zdrowia na nosicielu ma wykryć horrora, a operacja manipulacji organami w głowie pozwala go wyjąć. \
	Transporter \"horror w pudełku\" (uplink Bibliotekarza): użyj w ręce - ankieta duchów, horror budzi się jako sługa użytkownika."
	items = list(
		/mob/living/simple_animal/horror/test_chamber = 1,
		/mob/living/carbon/human = 2,
		/obj/item/horrorspawner = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/structure/table/optable = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/surgical_drapes = 1,
		/obj/machinery/door/airlock = 1,
	)

/// Horror z komory: do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/horror/test_chamber/Initialize(mapload, gen = 1)
	. = ..()
	set_playable(ROLE_HORROR)

/mob/living/simple_animal/horror/test_chamber/Login()
	. = ..()
	if(mind && !mind.has_antag_datum(/datum/antagonist/horror))
		mind.add_antag_datum(/datum/antagonist/horror)
