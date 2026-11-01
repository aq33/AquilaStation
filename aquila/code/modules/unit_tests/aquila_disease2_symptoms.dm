// AQUILA - objawy z disease2 Monkestation przeniesione na nasz advance disease.
// Makra asercji z upstreamu są #undef'owane na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny nosi własne kopie.
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Zwraca wszystkie objawy z disease2, które mają być losowalne
/proc/disease2_symptom_types()
	var/list/types = list()
	for(var/datum/symptom/symptom_type as anything in subtypesof(/datum/symptom))
		if(initial(symptom_type.from_disease2) && initial(symptom_type.level) >= 0)
			types += symptom_type
	return types

/// Każdy nowy objaw da się stworzyć, dostaje ID i ma sensowne statystyki oraz polski opis
/datum/unit_test/disease2_symptom_metadata

/datum/unit_test/disease2_symptom_metadata/Run()
	var/list/types = disease2_symptom_types()
	TEST_ASSERT(length(types) >= 40, "Spodziewałem się co najmniej 40 objawów z disease2, znalazłem [length(types)]")
	for(var/symptom_type in types)
		var/datum/symptom/symptom = new symptom_type
		TEST_ASSERT(symptom.id, "[symptom_type] nie dostał ID z SSdisease.list_symptoms")
		TEST_ASSERT(symptom.name, "[symptom_type] nie ma nazwy")
		TEST_ASSERT(symptom.desc, "[symptom_type] nie ma opisu")
		TEST_ASSERT(symptom.level >= 1 && symptom.level <= 9, "[symptom_type] ma poziom [symptom.level], a powinien 1-9")
		TEST_ASSERT(symptom.symptom_delay_min <= symptom.symptom_delay_max, "[symptom_type] ma odwrócone opóźnienia")
		TEST_ASSERT(symptom.naturally_occuring, "[symptom_type] nie jest losowalny, a ma poziom [symptom.level]")
		qdel(symptom)

/// Objawy z disease2 trafiają do losowania chorób i do katalogu w PANDEMIC
/datum/unit_test/disease2_symptom_generation

/datum/unit_test/disease2_symptom_generation/Run()
	var/list/types = disease2_symptom_types()
	for(var/symptom_type in types)
		TEST_ASSERT(symptom_type in SSdisease.list_symptoms, "[symptom_type] nie jest w SSdisease.list_symptoms")

	// Każdy poziom, na którym siedzą nasze objawy, musi dać się wylosować
	var/list/levels = list()
	for(var/datum/symptom/symptom_type as anything in types)
		levels |= initial(symptom_type.level)
	for(var/level in levels)
		var/datum/disease/advance/virus = new
		var/list/generated = virus.GenerateSymptoms(level, level, 1)
		TEST_ASSERT(length(generated), "GenerateSymptoms nie zwróciło nic dla poziomu [level]")
		qdel(virus)

	// Katalog PANDEMIC zna nasze objawy
	var/list/catalog_names = list()
	for(var/list/entry as anything in get_symptom_catalog())
		catalog_names[entry["id"]] = TRUE
	for(var/symptom_type in types)
		TEST_ASSERT(catalog_names["[symptom_type]"], "[symptom_type] nie trafił do katalogu PANDEMIC")

/// Objawy, które zmieniają nosiciela na stałe, muszą cofać zmianę po wyleczeniu choroby
/datum/unit_test/disease2_symptom_cleanup

/datum/unit_test/disease2_symptom_cleanup/Run()
	// Adaptacja kosmiczna: traity dochodzą i schodzą
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/virus = new
	virus.AddSymptom(new /datum/symptom/spaceadapt)
	virus.Refresh()
	host.ForceContractDisease(virus, FALSE, TRUE)
	var/datum/symptom/spaceadapt/space = locate() in virus.symptoms
	TEST_ASSERT(space, "Choroba nie ma objawu adaptacji kosmicznej")
	virus.stage = 5
	virus.stage_act()
	space.next_activation = 0
	space.Activate(virus)
	TEST_ASSERT(HAS_TRAIT(host, TRAIT_RESISTLOWPRESSURE), "Adaptacja kosmiczna nie dała odporności na podciśnienie")
	TEST_ASSERT(HAS_TRAIT(host, TRAIT_RESISTCOLD), "Adaptacja kosmiczna nie dała odporności na zimno")
	virus.cure(FALSE)
	TEST_ASSERT(!HAS_TRAIT(host, TRAIT_RESISTLOWPRESSURE), "Odporność na podciśnienie została po wyleczeniu")
	TEST_ASSERT(!HAS_TRAIT(host, TRAIT_RESISTCOLD), "Odporność na zimno została po wyleczeniu")

	// Zespół kruchej osoby: wytrzymałość części ciała wraca po wyleczeniu
	var/mob/living/carbon/human/brittle_host = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/sample = brittle_host.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(sample, "Nosiciel nie ma tułowia")
	var/original_max = sample.max_damage
	var/datum/disease/advance/brittle_virus = new
	brittle_virus.AddSymptom(new /datum/symptom/fragile_bones)
	brittle_virus.Refresh()
	brittle_host.ForceContractDisease(brittle_virus, FALSE, TRUE)
	var/datum/symptom/fragile_bones/bones = locate() in brittle_virus.symptoms
	TEST_ASSERT(bones, "Choroba nie ma objawu kruchej osoby")
	brittle_virus.stage = 5
	brittle_virus.stage_act()
	bones.next_activation = 0
	bones.Activate(brittle_virus)
	TEST_ASSERT(sample.max_damage < original_max, "Kości nie zrobiły się kruche")
	brittle_virus.cure(FALSE)
	TEST_ASSERT_EQUAL(sample.max_damage, original_max, "Wytrzymałość tułowia nie wróciła po wyleczeniu")

	// Zespół długowieczności: leczy, a po wyleczeniu oddaje obrażenia
	var/mob/living/carbon/human/immortal_host = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/immortal_virus = new
	immortal_virus.AddSymptom(new /datum/symptom/heal/immortal)
	immortal_virus.Refresh()
	immortal_host.ForceContractDisease(immortal_virus, FALSE, TRUE)
	var/datum/symptom/heal/immortal/immortal = locate() in immortal_virus.symptoms
	TEST_ASSERT(immortal, "Choroba nie ma objawu długowieczności")
	immortal_virus.stage = 5
	immortal_virus.stage_act()
	immortal_host.adjustBruteLoss(40)
	var/brute_before = immortal_host.getBruteLoss()
	immortal.next_activation = 0
	immortal.Activate(immortal_virus)
	TEST_ASSERT(immortal_host.getBruteLoss() < brute_before, "Długowieczność nie wyleczyła obrażeń")
	TEST_ASSERT(immortal.total_healed > 0, "Długowieczność nie zapamiętała, ile wyleczyła")
	var/brute_healed = immortal_host.getBruteLoss()
	immortal_virus.cure(FALSE)
	TEST_ASSERT(immortal_host.getBruteLoss() > brute_healed, "Wyleczenie długowieczności nie dało nawrotu obrażeń")

/// Objawy reagujące na dotyk ranią przy zderzeniu i odpinają sygnały po wyleczeniu
/datum/unit_test/disease2_symptom_touch

/datum/unit_test/disease2_symptom_touch/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/virus = new
	virus.AddSymptom(new /datum/symptom/touch_reactive/spiky_skin)
	virus.Refresh()
	host.ForceContractDisease(virus, FALSE, TRUE)
	var/datum/symptom/touch_reactive/spiky_skin/spikes = locate() in virus.symptoms
	TEST_ASSERT(spikes, "Choroba nie ma objawu rogowacenia kolczastego")
	virus.stage = 5
	virus.stage_act()
	spikes.next_activation = 0
	spikes.Activate(virus)
	TEST_ASSERT(spikes.hooked, "Kolce nie podpięły sygnałów dotyku")

	var/damage_before = other.getBruteLoss()
	SEND_SIGNAL(host, COMSIG_MOVABLE_BUMP, other)
	TEST_ASSERT(other.getBruteLoss() > damage_before, "Wpadnięcie na kogoś nie zraniło go kolcami")

	virus.cure(FALSE)
	TEST_ASSERT(!spikes.hooked, "Kolce nie odpięły sygnałów po wyleczeniu")
	var/damage_after_cure = other.getBruteLoss()
	SEND_SIGNAL(host, COMSIG_MOVABLE_BUMP, other)
	TEST_ASSERT_EQUAL(other.getBruteLoss(), damage_after_cure, "Kolce ranią dalej po wyleczeniu choroby")

/// Progi statystyk opisane w threshold_desc faktycznie coś zmieniają
/datum/unit_test/disease2_symptom_thresholds

/datum/unit_test/disease2_symptom_thresholds/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/virus = new
	virus.affected_mob = host

	// Nadkwasota: szybkość stadiów podnosi siłę
	var/datum/symptom/toxins/weak_acid = new
	virus.stage_rate = 1
	weak_acid.Start(virus)
	TEST_ASSERT_EQUAL(weak_acid.power, 1, "Nadkwasota ma nie tę siłę bazową")
	var/datum/symptom/toxins/strong_acid = new
	virus.stage_rate = 9
	strong_acid.Start(virus)
	TEST_ASSERT_EQUAL(strong_acid.power, 3, "Szybkość stadiów 9 nie wzmocniła nadkwasoty")

	// Nawodnienie tkanek: odporność przyspiesza wchłanianie, szybkość stadiów leczenie
	var/datum/symptom/heal/water/water = new
	virus.stage_rate = 7
	virus.resistance = 5
	water.Start(virus)
	TEST_ASSERT_EQUAL(water.absorption_coeff, 2, "Odporność 5 nie przyspieszyła wchłaniania wody")
	TEST_ASSERT_EQUAL(water.power, 2, "Szybkość stadiów 7 nie wzmocniła leczenia wodą")

	// Nawodnienie faktycznie zużywa wodę i leczy oparzenia
	host.adjustFireLoss(30)
	host.reagents.add_reagent(/datum/reagent/water, 20)
	var/water_before = host.reagents.get_reagent_amount(/datum/reagent/water)
	var/burn_before = host.getFireLoss()
	var/effectiveness = water.CanHeal(virus)
	TEST_ASSERT(effectiveness, "Nawodnienie nie zadziałało, choć nosiciel ma wodę we krwi")
	TEST_ASSERT(host.reagents.get_reagent_amount(/datum/reagent/water) < water_before, "Nawodnienie nie zużyło wody")
	water.Heal(host, virus, effectiveness)
	TEST_ASSERT(host.getFireLoss() < burn_before, "Nawodnienie nie wyleczyło oparzeń")

	qdel(weak_acid)
	qdel(strong_acid)
	qdel(water)
	virus.affected_mob = null
	qdel(virus)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

