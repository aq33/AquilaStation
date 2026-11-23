/datum/test_chamber_kit/pr_475
	name = "PR 475: standaryzacja combat mode"
	pr = "aq33/AquilaStation#475"
	description = "Karp, larwa robaka (z antagonistą po wejściu gracza) i cyborg są do przejęcia przez duchy (menu spawnerów); poza tym stoją dispenser chemii ze zlewką i śluza w głębi areny. Każdy krok powtórz w obu trybach: w Preferencjach przełączasz stare intencje i combat mode. \
		1) Na intencjach przejmij karpia → oczekiwane: w HUD są cztery intencje, skróty 1-4 je zmieniają, harm włącza tryb walki. W combat mode wskaźnik pokazuje stan trybu walki. \
		2) Przejmij larwę robaka i najedź kursorem na przedmiot albo drzwi → oczekiwane: podpowiedź mówi „Rozbrój+LPM” na intencjach i „PPM” w combat mode. \
		3) Larwa przy śluzie: na intencjach ustaw rozbrajanie i kliknij śluzę, w combat mode kliknij ją prawym przyciskiem → oczekiwane: w obu trybach wślizguje się pod śluzę. Negatyw: na intencji pomocy albo harm kliknij tę śluzę → oczekiwane: larwa się nie wślizguje. \
		4) Na rozbrajaniu użyj przycisku akcji z paska (np. Plucie krwią) → oczekiwane: robi akcję dodatkową jak PPM. \
		5) Cyborg na intencjach: kliknij PPM dispenser → oczekiwane: wysuwa zlewkę; Shift+PPM → oczekiwane: otwiera menu kontekstowe. W combat mode PPM też wysuwa zlewkę."
	items = list(
		/mob/living/basic/carp/test_chamber_cm = 1,
		/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber_cm = 1,
		/mob/living/silicon/robot/test_chamber_cm = 1,
		/obj/machinery/chem_dispenser = 1,
		/obj/item/reagent_containers/glass/beaker = 1,
	)

/datum/test_chamber_kit/pr_475/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/far = turfs.Copy(min(length(items) + 1, length(turfs)))
	if(!length(far))
		far = turfs
	new /obj/machinery/door/airlock(far[1])

/// Zwierzęta z komory do przejęcia przez duchy
/mob/living/basic/carp/test_chamber_cm/Initialize(mapload)
	. = ..()
	set_playable(ROLE_SENTIENCE)

/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber_cm/Initialize(mapload)
	. = ..()
	set_playable(ROLE_SENTIENCE)

/// Larwa dostaje antagonistę jak w zestawie krwawych robaków, bo bez niego nie ma swoich akcji
/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber_cm/Login()
	. = ..()
	give_test_chamber_antag()

/// Cyborg z komory do przejęcia przez duchy
/mob/living/silicon/robot/test_chamber_cm/Initialize(mapload)
	. = ..()
	set_playable(ROLE_SENTIENCE)
