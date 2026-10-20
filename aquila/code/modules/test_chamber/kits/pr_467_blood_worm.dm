/datum/test_chamber_kit/pr_467
	name = "PR 467: krwawe robaki"
	pr = "aq33/AquilaStation#467"
	description = "Trzy robaki (larwa, młody, dorosły) do przejęcia przez duchy, każdy z antagonistą. Sprawdź: HUD krwi i oględziny (ile krwi, ile wzrostu), \
		Wysysanie krwi na człowieku, małpie i worku krwi (worek i małpa to krew syntetyczna), wejście w zwłoki (przycisk albo przeciągnięcie robaka na zwłoki), \
		w nosicielu: Wstrzyknięcie krwi, Plucie krwią (prawy klik rozpuszcza kajdanki), Opuszczenie nosiciela i Wskrzeszenie martwego nosiciela. \
		Skaner zdrowia na nosicielu ma pokazywać normalny poziom krwi. Larwa i młody wślizgują się pod śluzę prawym klikiem. Larwa ma już krew na dojrzewanie (kokon), \
		dorosły może się rozmnożyć (ankieta duchów). Tester hemopasożytów na nosicielu i na zwykłym człowieku. W skrzyni: zestaw mięsożernej krwi z uplinka."
	items = list(
		/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber = 1,
		/mob/living/simple_animal/hostile/blood_worm/juvenile/test_chamber = 1,
		/mob/living/simple_animal/hostile/blood_worm/adult/test_chamber = 1,
		/mob/living/carbon/human = 3,
		/mob/living/carbon/monkey = 2,
		/obj/item/reagent_containers/blood/OMinus = 2,
		/obj/item/blood_worm_tester = 3,
		/obj/item/restraints/handcuffs = 1,
		/obj/item/healthanalyzer = 1,
	)

/datum/test_chamber_kit/pr_467/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Jeden człowiek martwy na nosiciela
	var/killed = FALSE
	for(var/mob/living/carbon/human/human in spawned)
		if(!killed)
			human.name = "zwłoki na nosiciela"
			human.real_name = human.name
			human.death()
			killed = TRUE
	for(var/mob/living/simple_animal/hostile/blood_worm/hatchling/hatchling in spawned)
		hatchling.consumed_normal_blood = 500
		hatchling.cocoon_action?.update_cooldown_text()
	var/list/far = turfs.Copy(min(length(items) + 1, length(turfs)))
	if(length(far) < 2)
		far = turfs
	new /obj/machinery/door/airlock(far[1])
	var/obj/structure/closet/crate/chem_crate = new(far[2])
	chem_crate.name = "mięsożerna krew"
	new /obj/item/storage/box/syndie_kit/carnivorous_blood(chem_crate)
	new /obj/item/reagent_containers/glass/beaker/large(chem_crate)

/// Robaki z komory: do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber/Initialize(mapload)
	. = ..()
	set_playable(ROLE_BLOOD_WORM)

/mob/living/simple_animal/hostile/blood_worm/hatchling/test_chamber/Login()
	. = ..()
	give_test_chamber_antag()

/mob/living/simple_animal/hostile/blood_worm/juvenile/test_chamber/Initialize(mapload)
	. = ..()
	set_playable(ROLE_BLOOD_WORM)

/mob/living/simple_animal/hostile/blood_worm/juvenile/test_chamber/Login()
	. = ..()
	give_test_chamber_antag()

/mob/living/simple_animal/hostile/blood_worm/adult/test_chamber/Initialize(mapload)
	. = ..()
	set_playable(ROLE_BLOOD_WORM)

/mob/living/simple_animal/hostile/blood_worm/adult/test_chamber/Login()
	. = ..()
	give_test_chamber_antag()

/mob/living/simple_animal/hostile/blood_worm/proc/give_test_chamber_antag()
	if(mind && !mind.has_antag_datum(/datum/antagonist/blood_worm))
		mind.add_antag_datum(/datum/antagonist/blood_worm/infestation)
