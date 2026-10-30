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

/// Stare choroby (wyrostek, katar) i patogen disease2 w jednej liście diseases:
/// skaner przeciwciał, izolator, dotyk i Life bez runtime'ów, a stare ścieżki zarażania szanują odporność.
/datum/unit_test/pathology_mixed_diseases

/datum/unit_test/pathology_mixed_diseases/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/immune = allocate(/mob/living/carbon/human)

	patient.ForceContractDisease(new /datum/disease/appendicitis, FALSE, TRUE)
	patient.ForceContractDisease(new /datum/disease/cold, FALSE, TRUE)
	TEST_ASSERT_EQUAL(length(patient.diseases), 2, "Nie udało się zarazić wyrostkiem i katarem")

	var/datum/disease/acute/virus/pathogen = new
	pathogen.makerandom(list(60, 60), list(50, 50), list(ANTIGEN_COMMON = 1), list(EFFECT_DANGER_FLAVOR = 1), null)
	pathogen.spread_flags = DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_BLOOD
	for(var/antigen in pathogen.antigen)
		patient.immune_system.antibodies[antigen] = 0
	patient.infect_disease(pathogen, forced = TRUE, notes = "(test jednostkowy)")
	var/datum/disease/acute/carried = locate(/datum/disease/acute) in patient.diseases
	TEST_ASSERT(carried, "Patogen disease2 nie zaraził nosiciela starych chorób")
	var/carried_id = "[carried.uniqueID]-[carried.subID]"
	carried.addToDB()

	var/runtimes_before = GLOB.total_runtimes

	// filtry rozsiewu biorą tylko patogeny disease2 (stary katar jest airborne)
	for(var/datum/disease/D as anything in filter_disease_by_spread(patient.diseases, required = DISEASE_SPREAD_AIRBORNE))
		TEST_ASSERT(istype(D, /datum/disease/acute), "Filtr rozsiewu przepuścił starą chorobę [D.type]")

	// skaner przeciwciał przechodzi po wszystkich chorobach pacjenta
	var/obj/item/device/antibody_scanner/scanner = allocate(/obj/item/device/antibody_scanner)
	scanner.attack(patient, doctor)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtime w skanerze przeciwciał")

	// izolator: strzykawka z krwią, menu, wyizolowanie na szalkę
	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)
	syringe.reagents.add_reagent(/datum/reagent/blood, 10, patient.get_blood_data(/datum/reagent/blood))
	var/datum/reagent/blood/sample = locate() in syringe.reagents.reagent_list
	TEST_ASSERT(sample, "Strzykawka nie ma krwi")
	var/list/isolated = virus_copylist(sample.data["viruses"])
	TEST_ASSERT_EQUAL(length(isolated), 1, "Z krwi powinien dać się wyizolować tylko patogen disease2")
	doctor.put_in_hands(syringe)
	var/obj/machinery/disease2/isolator/isolator = allocate(/obj/machinery/disease2/isolator)
	isolator.attackby(syringe, doctor)
	TEST_ASSERT_EQUAL(isolator.beaker, syringe, "Izolator nie przyjął strzykawki")
	isolator.attack_hand(doctor)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtime w menu izolatora")
	isolator.isolated_disease = isolated[1]
	isolator.isolating = 1
	isolator.process()
	var/obj/item/weapon/virusdish/dish = locate() in isolator.loc
	TEST_ASSERT(dish?.contained_virus, "Izolator nie wydał szalki z patogenem")
	allocated += dish

	// analizator ze strzykawką tylko podpowiada izolator
	var/obj/item/reagent_containers/syringe/second = allocate(/obj/item/reagent_containers/syringe)
	doctor.put_in_hands(second)
	var/obj/machinery/disease2/diseaseanalyser/analyser = allocate(/obj/machinery/disease2/diseaseanalyser)
	analyser.attackby(second, doctor)
	TEST_ASSERT(!analyser.dish && second.loc == doctor, "Analizator wziął strzykawkę")

	// dotyk w obie strony i stara ścieżka kontaktu z rdzenia
	patient.attack_hand(doctor)
	doctor.attack_hand(patient)
	var/acute_on_doctor = 0
	for(var/datum/disease/acute/D in doctor.diseases)
		acute_on_doctor++
	TEST_ASSERT(acute_on_doctor <= 1, "Lekarz dostał ten sam patogen więcej niż raz")
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtime przy dotyku")

	// ForceContractDisease (ugryzienia, admin) przechodzi przez układ odpornościowy
	for(var/antigen in carried.antigen)
		immune.immune_system.antibodies[antigen] = carried.strength + 10
	immune.ForceContractDisease(carried, TRUE)
	TEST_ASSERT(!(locate(/datum/disease/acute) in immune.diseases), "ForceContractDisease ominął przeciwciała")

	// kilka ticków życia z trzema chorobami naraz
	for(var/i in 1 to 5)
		patient.Life(2, i)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtime w Life przy mieszanych chorobach")

	GLOB.virusDB -= carried_id

/// Maszyny wirusologii dają się obsłużyć z okna: wirówka, izolator i maszyna lecząca.
/// Stare okna browse() nie odświeżały się przez updateUsrDialog(), więc klikanie w nich nic nie dawało.
/datum/unit_test/pathology_machine_ui

/datum/unit_test/pathology_machine_ui/Run()
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	// tgui woła ui_act z ustawionym usr, więc w teście robimy to samo
	usr = doctor

	var/runtimes_before = GLOB.total_runtimes

	// --- wirówka ---
	var/obj/machinery/disease2/centrifuge/centrifuge = allocate(/obj/machinery/disease2/centrifuge)
	var/obj/item/reagent_containers/glass/tube/tube = allocate(/obj/item/reagent_containers/glass/tube)
	tube.reagents.add_reagent(/datum/reagent/blood, 20, list(
		"blood_DNA" = "test",
		"blood_type" = get_blood_type(BLOOD_TYPE_O_MINUS),
		"viruses" = list(),
		"immunity" = list(100, list(ANTIGEN_COMMON = 70)),
	))

	var/datum/tgui/centrifuge_ui = new(doctor, centrifuge, "DiseaseCentrifuge")
	TEST_ASSERT(islist(centrifuge.ui_data(doctor)), "Wirówka nie oddała danych do okna")

	centrifuge.ui_act("power", list(), centrifuge_ui)
	TEST_ASSERT(centrifuge.on, "Wirówka nie włączyła się z okna")
	centrifuge.ui_act("power", list(), centrifuge_ui)
	TEST_ASSERT(!centrifuge.on, "Wirówki nie dało się wyłączyć z okna")

	doctor.drop_all_held_items()
	doctor.put_in_active_hand(tube, forced = TRUE)
	centrifuge.ui_act("insert_tube", list("slot" = "1"), centrifuge_ui)
	TEST_ASSERT_EQUAL(centrifuge.tubes[1], tube, "Probówka nie trafiła do wirówki z okna")
	TEST_ASSERT(centrifuge.tube_valid[1], "Wirówka nie wykryła przeciwciał w probówce")

	var/list/tube_data = centrifuge.tube_ui_data(1)
	TEST_ASSERT(tube_data["has_blood"], "Okno wirówki nie pokazuje krwi w probówce")
	TEST_ASSERT(tube_data["has_antibodies"], "Okno wirówki nie pokazuje przeciwciał")

	centrifuge.ui_act("eject_tube", list("slot" = "1"), centrifuge_ui)
	TEST_ASSERT(isnull(centrifuge.tubes[1]), "Probówki nie dało się wyjąć z okna")
	qdel(centrifuge_ui)

	// --- inkubator ---
	var/obj/machinery/disease2/incubator/incubator = allocate(/obj/machinery/disease2/incubator)
	var/obj/item/weapon/virusdish/incubator_dish = allocate(/obj/item/weapon/virusdish)
	incubator_dish.open = TRUE // inkubator nie przyjmuje zamkniętej szalki
	doctor.drop_all_held_items()
	doctor.put_in_active_hand(incubator_dish, forced = TRUE)
	var/datum/tgui/incubator_ui = new(doctor, incubator, "DiseaseIncubator")
	incubator.ui_act("insertdish", list("slot" = "1"), incubator_ui)
	var/datum/dish_incubator_dish/inserted = incubator.dish_data[1]
	TEST_ASSERT_EQUAL(inserted?.dish, incubator_dish, "Szalka nie trafiła do inkubatora z okna")
	incubator.ui_act("ejectdish", list("slot" = "1"), incubator_ui)
	TEST_ASSERT(isnull(incubator.dish_data[1]), "Szalki nie dało się wyjąć z okna inkubatora")
	qdel(incubator_ui)

	// --- izolator ---
	var/obj/machinery/disease2/isolator/isolator = allocate(/obj/machinery/disease2/isolator)
	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)
	var/datum/disease/acute/virus/pathogen = new
	pathogen.makerandom(list(50, 50), list(50, 50), list(ANTIGEN_COMMON = 1), list(EFFECT_DANGER_FLAVOR = 1), null)
	syringe.reagents.add_reagent(/datum/reagent/blood, 10, list(
		"blood_DNA" = "test",
		"blood_type" = get_blood_type(BLOOD_TYPE_O_MINUS),
		"viruses" = list(pathogen),
		"immunity" = list(),
	))
	doctor.drop_all_held_items()
	doctor.put_in_active_hand(syringe, forced = TRUE)
	isolator.attackby(syringe, doctor)
	TEST_ASSERT_EQUAL(isolator.beaker, syringe, "Izolator nie przyjął strzykawki")

	var/datum/tgui/isolator_ui = new(doctor, isolator, "DiseaseIsolator")
	var/list/isolator_data = isolator.ui_data(doctor)
	TEST_ASSERT_EQUAL(length(isolator_data["pathogens"]), 1, "Okno izolatora nie pokazuje patogenu z krwi")

	isolator.ui_act("isolate", list("id" = "[pathogen.uniqueID]"), isolator_ui)
	TEST_ASSERT(isolator.isolating > 0, "Izolator nie zaczął izolowania z okna")
	for(var/i in 1 to 50)
		isolator.process()
	// na tej kratce lezy juz szalka wyjeta z inkubatora, wiec szukamy tej z patogenem
	var/obj/item/weapon/virusdish/printed
	for(var/obj/item/weapon/virusdish/candidate in isolator.loc)
		if(candidate.contained_virus)
			printed = candidate
			break
	TEST_ASSERT(printed, "Izolator nie wydał szalki z patogenem")
	allocated += printed

	isolator.ui_act("eject", list(), isolator_ui)
	TEST_ASSERT(isnull(isolator.beaker), "Strzykawki nie dało się wyjąć z okna izolatora")
	qdel(isolator_ui)

	// --- maszyna lecząca ---
	var/obj/machinery/computer/curer/curer = allocate(/obj/machinery/computer/curer)
	var/obj/item/reagent_containers/glass/tube/sample = allocate(/obj/item/reagent_containers/glass/tube)
	sample.reagents.add_reagent(/datum/reagent/blood, 20, list(
		"blood_DNA" = "test",
		"blood_type" = get_blood_type(BLOOD_TYPE_O_MINUS),
		"viruses" = list(),
		"immunity" = list(100, list(ANTIGEN_COMMON = 70)),
	))
	doctor.drop_all_held_items()
	doctor.put_in_active_hand(sample, forced = TRUE)
	curer.attackby(sample, doctor)
	TEST_ASSERT_EQUAL(curer.container, sample, "Maszyna lecząca nie przyjęła probówki")

	var/datum/tgui/curer_ui = new(doctor, curer, "DiseaseCurer")
	var/list/curer_data = curer.ui_data(doctor)
	TEST_ASSERT(curer_data["has_blood"], "Okno maszyny leczącej nie widzi krwi")
	TEST_ASSERT_EQUAL(length(curer_data["antibodies"]), 1, "Okno maszyny leczącej nie pokazuje przeciwciał")

	curer.ui_act("antibody", list(), curer_ui)
	TEST_ASSERT(curer.curing > 0, "Maszyna lecząca nie ruszyła z produkcją z okna")
	curer.curing = 1
	curer.process()
	// tak samo tutaj: obok lezy probowka z wirowki, wiec szukamy tej ze szczepionka
	var/found_vaccine = FALSE
	for(var/obj/item/reagent_containers/glass/tube/candidate in curer.loc)
		if(locate(/datum/reagent/vaccine) in candidate.reagents.reagent_list)
			found_vaccine = TRUE
			break
	TEST_ASSERT(found_vaccine, "Maszyna lecząca nie wydała szczepionki")

	curer.ui_act("eject", list(), curer_ui)
	TEST_ASSERT(isnull(curer.container), "Probówki nie dało się wyjąć z okna maszyny leczącej")
	qdel(curer_ui)

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtime przy obsłudze maszyn z okien")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
