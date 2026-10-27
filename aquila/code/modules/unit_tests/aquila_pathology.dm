// AQUILA - wirusologia disease2 (port Monkestation2.0): antygeny, przeciwciała, zakażenie, szalki.
// Makra TEST_ASSERT* z rdzenia są #undef'owane na końcu code/modules/unit_tests/_unit_tests.dm,
// więc ten test modularny ma własne kopie (wzór: aquila_viruses.dm).
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Patogen ma antygeny, objaw na każdy stopień i zaraża nosiciela bez przeciwciał.
/datum/unit_test/pathology_infection

/datum/unit_test/pathology_infection/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	TEST_ASSERT(patient.immune_system, "Człowiek nie ma układu odpornościowego")

	var/datum/disease/acute/virus/pathogen = new
	pathogen.makerandom(list(60, 60), list(50, 50), list(ANTIGEN_COMMON = 1), list(EFFECT_DANGER_FLAVOR = 1), null)

	TEST_ASSERT(length(pathogen.antigen), "Patogen nie dostał antygenów")
	TEST_ASSERT_EQUAL(pathogen.strength, 60, "Siła wylosowana poza zadanym zakresem")
	TEST_ASSERT_EQUAL(pathogen.robustness, 50, "Wytrzymałość wylosowana poza zadanym zakresem")
	TEST_ASSERT(length(pathogen.symptoms), "Patogen nie dostał objawów")

	// przeciwciała poniżej siły patogenu nie chronią
	for(var/antigen in pathogen.antigen)
		patient.immune_system.antibodies[antigen] = 0
	TEST_ASSERT(patient.immune_system.CanInfect(pathogen), "Układ odpornościowy bez przeciwciał zablokował zakażenie")

	patient.infect_disease(pathogen, forced = TRUE, notes = "(test jednostkowy)")
	var/datum/disease/acute/carried = locate(/datum/disease/acute) in patient.diseases
	TEST_ASSERT(carried, "Nosiciel nie został zakażony")
	TEST_ASSERT_EQUAL(carried.affected_mob, patient, "Patogen nie zna swojego nosiciela")

	// kopia zachowuje pola disease2 (nasz /datum/disease/Copy() ich nie zna)
	TEST_ASSERT_EQUAL(carried.strength, pathogen.strength, "Kopia zgubiła siłę")
	TEST_ASSERT_EQUAL(length(carried.antigen), length(pathogen.antigen), "Kopia zgubiła antygeny")
	TEST_ASSERT(length(carried.symptoms), "Kopia zgubiła objawy")

	// wyleczenie podnosi przeciwciała na antygen patogenu
	carried.cure(add_resistance = TRUE, target = patient)
	TEST_ASSERT(!(carried in patient.diseases), "Patogen został w nosicielu po wyleczeniu")
	var/boosted = FALSE
	for(var/antigen in carried.antigen)
		if(patient.immune_system.antibodies[antigen] >= carried.strength)
			boosted = TRUE
	TEST_ASSERT(boosted, "Wyleczenie nie podniosło przeciwciał")

/// Przeciwciała na poziomie siły patogenu nie wpuszczają go do ciała.
/datum/unit_test/pathology_immunity

/datum/unit_test/pathology_immunity/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/disease/acute/virus/pathogen = new
	pathogen.makerandom(list(50, 50), list(50, 50), list(ANTIGEN_COMMON = 1), list(EFFECT_DANGER_FLAVOR = 1), null)

	for(var/antigen in pathogen.antigen)
		patient.immune_system.antibodies[antigen] = pathogen.strength + 10

	TEST_ASSERT(!patient.immune_system.CanInfect(pathogen), "Przeciwciała nie zablokowały zakażenia")
	patient.infect_disease(pathogen, forced = TRUE, notes = "(test jednostkowy)")
	TEST_ASSERT(!length(patient.diseases), "Odporny nosiciel i tak się zaraził")

/// Szczepionka z przeciwciał podnosi je na wskazane antygeny.
/datum/unit_test/pathology_vaccine

/datum/unit_test/pathology_vaccine/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.immune_system.antibodies[ANTIGEN_Q] = 0
	patient.immune_system.ApplyVaccine(list(ANTIGEN_Q), 5, 1 MINUTES)
	TEST_ASSERT(patient.immune_system.antibodies[ANTIGEN_Q] > 0, "Szczepionka nie podniosła przeciwciał")

/// Szalka trzyma patogen i rośnie w inkubatorze.
/datum/unit_test/pathology_dish

/datum/unit_test/pathology_dish/Run()
	var/obj/item/weapon/virusdish/dish = allocate(/obj/item/weapon/virusdish)
	var/datum/disease/acute/virus/pathogen = new
	pathogen.makerandom(list(50, 50), list(50, 50), list(ANTIGEN_COMMON = 1), list(EFFECT_DANGER_FLAVOR = 1), null)
	dish.contained_virus = pathogen
	dish.growth = 0

	dish.reagents.add_reagent(/datum/reagent/consumable/virus_food, 5)
	dish.incubate(0, 3)
	TEST_ASSERT(dish.growth > 0, "Szalka nie rosła na pożywce")
	TEST_ASSERT_EQUAL(dish.contained_virus, pathogen, "Szalka zgubiła patogen")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
