// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Drużyna o danej nazwie z GLOB.squad_manager
/datum/unit_test/proc/aq_squad(name)
	return GLOB.squad_manager.get_squad(name)

/// Nazwy Alpha-Delta, stare nazwy z zapisanych postaci i kanały pagera
/datum/unit_test/aquila_squad_names

/datum/unit_test/aquila_squad_names/Run()
	for(var/name in list("Alpha", "Bravo", "Charlie", "Delta"))
		var/datum/squad/squad = aq_squad(name)
		TEST_ASSERT(squad, "Brak drużyny [name]")
		TEST_ASSERT(squad.squad_channel, "Drużyna [name] nie ma kanału pagera (typ /datum/component/simple_teamchat/radio_dependent/squad/[name])")
	TEST_ASSERT(aq_squad("Able") == aq_squad("Alpha"), "Stara nazwa Able z zapisu postaci nie prowadzi do drużyny Alpha")
	TEST_ASSERT(aq_squad("Duff") == aq_squad("Delta"), "Stara nazwa Duff z zapisu postaci nie prowadzi do drużyny Delta")

/// Auto-przydział według zawodu: medyk do drużyny medycznej, inżynier do kontroli uszkodzeń, dowództwo nigdzie
/datum/unit_test/aquila_squad_auto_assign

/datum/unit_test/aquila_squad_auto_assign/Run()
	var/datum/job/medic_job = SSjob.GetJobType(/datum/job/medical_doctor)
	var/datum/squad/medic_squad = GLOB.squad_manager.aq_pick_squad(medic_job, null)
	TEST_ASSERT(medic_squad?.role == MEDICAL_SQUAD, "Lekarz trafił do drużyny o roli [medic_squad?.role] zamiast medycznej")
	var/datum/job/engineer_job = SSjob.GetJobType(/datum/job/station_engineer)
	var/datum/squad/engineer_squad = GLOB.squad_manager.aq_pick_squad(engineer_job, null)
	TEST_ASSERT(engineer_squad?.role == DC_SQUAD, "Inżynier trafił do drużyny o roli [engineer_squad?.role] zamiast kontroli uszkodzeń")
	var/datum/job/captain_job = SSjob.GetJobType(/datum/job/captain)
	TEST_ASSERT(!captain_job.aq_squad_auto, "Kapitan trafia do drużyny automatycznie")
	var/datum/job/assistant_job = SSjob.GetJobType(/datum/job/assistant)
	var/datum/squad/preferred = GLOB.squad_manager.aq_pick_squad(assistant_job, "Delta")
	TEST_ASSERT(preferred == aq_squad("Delta"), "Asystent z preferowaną drużyną Delta trafił do [preferred]")

	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	doctor.equip_to_slot_or_del(new /obj/item/storage/backpack(doctor), ITEM_SLOT_BACK)
	medic_job.register_squad(doctor)
	TEST_ASSERT(doctor.squad?.role == MEDICAL_SQUAD, "register_squad() nie dał lekarza do drużyny medycznej")
	TEST_ASSERT(doctor.squad_position == SQUAD_POSITION_MEDIC, "Lekarz w drużynie ma funkcję [doctor.squad_position] zamiast medyka")
	var/obj/item/squad_pager/pager = locate() in doctor.GetAllContents()
	TEST_ASSERT(!pager || pager.squad == doctor.squad, "Pager lekarza jest dostrojony do innej drużyny")

/// Automat wydaje zestaw funkcji w skrzyni, a zwrot skrzyni zamyka wypożyczenie
/datum/unit_test/aquila_squad_vendor_crate

/datum/unit_test/aquila_squad_vendor_crate/Run()
	var/datum/squad/squad = aq_squad("Bravo")
	var/old_clearance = squad.weapons_clearance
	squad.weapons_clearance = FALSE
	var/obj/machinery/squad_vendor/vendor = allocate(/obj/machinery/squad_vendor)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	medic.squad_position = SQUAD_POSITION_MEDIC
	squad.add_member(medic)
	if(squad.leader == medic)
		squad.unset_leader(medic)

	var/datum/squad_loadout/aquila/kit = vendor.aq_loadout_for(medic)
	TEST_ASSERT(kit?.position == SQUAD_POSITION_MEDIC, "Medyk dostał zestaw [kit?.name] zamiast medyka")
	TEST_ASSERT(vendor.aq_vend(medic), "Automat nie wydał zestawu")
	var/obj/item/storage/aq_squad_crate/crate = locate() in medic.held_items
	TEST_ASSERT(crate, "Zestaw nie trafił do ręki w skrzyni")
	TEST_ASSERT(locate(/obj/item/storage/firstaid/regular) in crate, "W skrzyni medyka nie ma apteczki")
	TEST_ASSERT(locate(/obj/item/clothing/suit/ship/squad/space) in crate, "W skrzyni nie ma skafandra obcisłego (trudne warunki miały być w każdym zestawie)")
	TEST_ASSERT(!(locate(/obj/item/gun) in crate), "Drużyna bez zezwolenia na broń dostała broń")
	var/datum/squad_loan/loan = get_squad_loan(medic)
	TEST_ASSERT(loan && length(loan.outstanding) == length(crate.contents), "Rejestr wydań nie zgadza się z zawartością skrzyni")
	TEST_ASSERT(!vendor.aq_vend(medic), "Automat wydał drugi zestaw przed zwrotem pierwszego")

	// Jedną rzecz wyjmujemy i oddajemy luzem, resztę w skrzyni
	var/obj/item/clothing/suit/ship/squad/armor = locate(/obj/item/clothing/suit/ship/squad) in crate
	armor.forceMove(get_turf(medic))
	vendor.return_item(medic, crate, quiet = TRUE)
	TEST_ASSERT(QDELETED(crate), "Pusta skrzynia nie została przyjęta")
	TEST_ASSERT(!QDELETED(loan) && length(loan.outstanding) == 1, "Po zwrocie skrzyni bez pancerza powinna brakować jedna rzecz, brakuje [QDELETED(loan) ? 0 : length(loan.outstanding)]")
	TEST_ASSERT(vendor.return_item(medic, armor, quiet = TRUE), "Automat nie przyjął pancerza luzem")
	TEST_ASSERT(QDELETED(loan) && !get_squad_loan(medic), "Wypożyczenie nie zamknęło się po oddaniu wszystkiego")
	squad.weapons_clearance = old_clearance

/// Śmierć dowódcy: dowodzenie przejmuje żywy członek drużyny
/datum/unit_test/aquila_squad_leader_succession

/datum/unit_test/aquila_squad_leader_succession/Run()
	var/datum/squad/squad = aq_squad("Charlie")
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	squad.add_member(first)
	squad.add_member(second)
	squad.set_leader(first)
	TEST_ASSERT(squad.leader == first, "Nie udało się ustawić dowódcy")
	first.death()
	TEST_ASSERT(squad.aq_leader_succession(first), "Po śmierci dowódcy nikt nie przejął dowodzenia")
	TEST_ASSERT(squad.leader == second, "Dowodzenie przejął [squad.leader] zamiast żywego członka drużyny")

/// Znaczniki rozkazów: jeden na typ, nowy zastępuje stary, można usunąć
/datum/unit_test/aquila_squad_markers

/datum/unit_test/aquila_squad_markers/Run()
	var/datum/squad/squad = aq_squad("Delta")
	var/mob/living/carbon/human/leader = allocate(/mob/living/carbon/human)
	squad.add_member(leader)
	squad.set_leader(leader)
	var/datum/aq_squad_marker/first = squad.aq_place_marker(leader, run_loc_floor_bottom_left, SQUAD_MARKER_ATTACK)
	TEST_ASSERT(first && squad.aq_markers[SQUAD_MARKER_ATTACK] == first, "Znacznik ataku nie został postawiony")
	TEST_ASSERT(!squad.aq_place_marker(leader, run_loc_floor_top_right, SQUAD_MARKER_ATTACK), "Drugi znacznik od razu po pierwszym ominął odstęp")
	leader.aq_next_squad_marker = 0
	var/datum/aq_squad_marker/second = squad.aq_place_marker(leader, run_loc_floor_top_right, SQUAD_MARKER_ATTACK)
	TEST_ASSERT(QDELETED(first) && squad.aq_markers[SQUAD_MARKER_ATTACK] == second, "Nowy znacznik ataku nie zastąpił starego")
	var/list/markers_data = squad.aq_markers_data()
	TEST_ASSERT(length(markers_data) == 1 && markers_data[1]["x"] == run_loc_floor_top_right.x, "Dane znaczników dla mapy są złe")
	TEST_ASSERT(squad.aq_clear_marker(SQUAD_MARKER_ATTACK) && !length(squad.aq_markers), "Znacznik nie dał się usunąć")
	leader.aq_next_squad_marker = 0
	TEST_ASSERT(!squad.aq_place_marker(leader, run_loc_floor_top_right, "nieistniejacy"), "Przyjęto nieznany typ znacznika")

#undef TEST_ASSERT
