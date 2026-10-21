/datum/test_chamber_kit/pr_475
	name = "PR 475: standaryzacja combat mode"
	pr = "aq33/AquilaStation#475"
	description = "Sprawdź oba tryby: w Preferencjach przełącz stare intencje i wróć. Karp i larwa robaka są do przejęcia przez duchy. \
	Na intencjach: zwierzę ma w HUD cztery intencje (skróty 1-4), harm włącza tryb walki. Larwa wślizguje się pod śluzę na rozbrajaniu, \
	w combat mode prawym przyciskiem. Na rozbrajaniu przycisk akcji robi akcję dodatkową jak PPM. Podpowiedzi przy kursorze pokazują Rozbrój+LPM zamiast PPM. \
	Borg na intencjach: PPM na dispenserze wysuwa zlewkę, Shift+PPM otwiera menu."
	items = list(
		/mob/living/simple_animal/hostile/carp/test_chamber_cm = 1,
		/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber_cm = 1,
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
/mob/living/simple_animal/hostile/carp/test_chamber_cm/Initialize(mapload)
	. = ..()
	set_playable(ROLE_SENTIENCE)

/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber_cm/Initialize(mapload)
	. = ..()
	set_playable(ROLE_SENTIENCE)
