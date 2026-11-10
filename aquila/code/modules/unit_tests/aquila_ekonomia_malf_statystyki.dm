// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - premia działu: 20% zarobku działu trafia przy wypłacie do żywych członków działu, licznik się zeruje,
/// a premia działu bez członków przepada
/datum/unit_test/aquila_department_commission

/datum/unit_test/aquila_department_commission/Run()
	var/mob/living/carbon/human/scientist = allocate(/mob/living/carbon/human)
	scientist.mind_initialize()
	scientist.mind.key = "aquila_commission_test"
	scientist.mind.assigned_role = JOB_NAME_SCIENTIST
	var/datum/bank_account/personal = new("Test Scientist", SSjob.GetJob(JOB_NAME_SCIENTIST))
	scientist.account_id = personal.account_id
	var/start_balance = personal.account_balance

	GLOB.department_commission_pending.Cut()
	add_department_commission(ACCOUNT_SCI, 1000)
	add_department_commission(ACCOUNT_SCI, -500) // wydatki się nie liczą
	add_department_commission(ACCOUNT_MUN, 1000)
	var/members = length(department_commission_accounts(ACCOUNT_SCI))
	TEST_ASSERT(personal in department_commission_accounts(ACCOUNT_SCI), "A living scientist is not a member of the science department")
	TEST_ASSERT(!(personal in department_commission_accounts(ACCOUNT_MED)), "A scientist counts as medical staff")
	pay_department_commissions()
	TEST_ASSERT_EQUAL(personal.account_balance - start_balance, round(200 / members), "Wrong department commission")
	TEST_ASSERT(!length(GLOB.department_commission_pending), "The commission was not reset after the payday")

	scientist.death()
	add_department_commission(ACCOUNT_SCI, 1000)
	var/dead_balance = personal.account_balance
	pay_department_commissions()
	TEST_ASSERT_EQUAL(personal.account_balance, dead_balance, "A dead scientist got the commission")

	scientist.mind.key = null
	scientist.account_id = null
	qdel(personal)

/// AQUILA - automat górniczy daje najwyżej 400 kr gotówki za 2400 punktów
/datum/unit_test/aquila_mining_cash_rate

/datum/unit_test/aquila_mining_cash_rate/Run()
	var/obj/machinery/vendor/mining/vendor = allocate(/obj/machinery/vendor/mining)
	var/cash_items = 0
	for(var/datum/data/vendor_equipment/prize as anything in vendor.prize_list)
		if(!ispath(prize.equipment_path, /obj/item/stack/spacecash))
			continue
		cash_items++
		var/obj/item/stack/spacecash/cash = prize.equipment_path
		var/credits = initial(cash.value) * initial(cash.amount)
		TEST_ASSERT(credits * 2400 <= 400 * prize.cost, "[prize.equipment_name] gives [credits] cr for [prize.cost] points, more than 400 cr per 2400 points")
	TEST_ASSERT(cash_items, "The mining vendor sells no cash")

/// AQUILA - tryb wadliwej SI bez chętnych na SI nie startuje i nie sypie runtime'ami
/datum/unit_test/aquila_malf_mode_without_candidates

/datum/unit_test/aquila_malf_mode_without_candidates/Run()
	var/datum/game_mode/malf/mode = new
	var/runtimes_before = GLOB.total_runtimes
	TEST_ASSERT(!length(mode.malf_candidates()), "Malf candidates found without any players")
	TEST_ASSERT(!mode.pre_setup(), "The malf mode started without candidates")
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "The malf mode caused runtimes")
	// Slot SI zajęty przez wadliwą SI: przydział prac nie obsadza go drugi raz
	var/datum/job/ai_job = SSjob.GetJob(JOB_NAME_AI)
	var/old_positions = ai_job.current_positions
	ai_job.current_positions = ai_job.total_positions
	TEST_ASSERT(SSjob.FillAIPosition(), "A taken AI slot was not reported as filled")
	TEST_ASSERT_EQUAL(ai_job.current_positions, ai_job.total_positions, "The AI slot was filled twice")
	// Częściowa obsada: 2 sloty, 1 zajęty → jeden wolny; FillAIPosition() przywraca liczbę slotów
	// (bez graczy w kolejce, bo FindOccupationCandidates() wymaga klienta z preferencjami)
	var/old_total = ai_job.total_positions
	ai_job.total_positions = 2
	ai_job.current_positions = 1
	TEST_ASSERT_EQUAL(SSjob.free_ai_positions(), 1, "Wrong amount of free AI slots")
	var/list/old_unassigned = SSjob.unassigned
	SSjob.unassigned = list()
	SSjob.FillAIPosition()
	SSjob.unassigned = old_unassigned
	TEST_ASSERT_EQUAL(ai_job.total_positions, 2, "The AI slot count was not restored")
	TEST_ASSERT_EQUAL(ai_job.current_positions, 1, "An AI slot was filled without players")
	ai_job.total_positions = old_total
	ai_job.current_positions = old_positions
	var/datum/weighted_ghost_midround/midround = new
	TEST_ASSERT(!length(midround.malf_ai_candidates()), "A midround malf AI was found without any AI players")
	qdel(midround)
	qdel(mode)

/// AQUILA - statystyki postaci: liczniki zdarzeń trafiają do wierszy rundy razem z rundą i przeżyciem,
/// plik zapasowy sumuje statystyki, a najlepszy zarobek trzyma maksimum
/datum/unit_test/aquila_character_stats

/datum/unit_test/aquila_character_stats/Run()
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	medic.mind_initialize()
	medic.mind.key = "Aquila Stats Test"
	medic.mind.assigned_role = JOB_NAME_MEDICALDOCTOR
	medic.mind.name = "Test Medyk"
	record_character_stat(medic, "surgeries", 2)
	record_character_stat(medic, "surgeries")
	record_character_stat(null, "surgeries") // bez moba nic się nie dzieje

	var/list/by_stat = list()
	for(var/list/row as anything in character_stats_round_rows(list(medic.mind)))
		TEST_ASSERT_EQUAL(row["ckey"], "aquilastatstest", "The stats row has a wrong ckey")
		TEST_ASSERT_EQUAL(row["character_name"], "Test Medyk", "The stats row has a wrong character")
		by_stat[row["stat"]] = row["value"]
	TEST_ASSERT_EQUAL(by_stat["surgeries"], 3, "Surgeries were not counted")
	TEST_ASSERT_EQUAL(by_stat["rounds"], 1, "The round was not counted")
	TEST_ASSERT_EQUAL(by_stat["survived"], 1, "A living character did not survive")
	TEST_ASSERT(!by_stat["deaths"], "A living character died")

	var/test_file = "data/unit_test_character_stats.json"
	fdel(test_file)
	character_stats_merge_file(list(
		list("ckey" = "aquilastatstest", "character_name" = "Test Medyk", "stat" = "surgeries", "value" = 3),
		list("ckey" = "aquilastatstest", "character_name" = "Test Medyk", "stat" = "earnings_best", "value" = 900),
	), test_file)
	character_stats_merge_file(list(
		list("ckey" = "aquilastatstest", "character_name" = "Test Medyk", "stat" = "surgeries", "value" = 2),
		list("ckey" = "aquilastatstest", "character_name" = "Test Medyk", "stat" = "earnings_best", "value" = 500),
	), test_file)
	var/list/saved = character_stats_load_file(test_file)
	var/list/medic_stats = saved["aquilastatstest"]?["Test Medyk"]
	fdel(test_file)
	TEST_ASSERT(islist(medic_stats), "The character was not saved to the file")
	TEST_ASSERT_EQUAL(medic_stats["surgeries"], 5, "Stats were not added up")
	TEST_ASSERT_EQUAL(medic_stats["earnings_best"], 900, "The best earnings were not kept")

	// Uszkodzony plik: wpisy w innym kształcie są pomijane, poprawne zostają
	rustg_file_write(json_encode(list("aquilastatstest" = list("Test Medyk" = list("surgeries" = 4, "zle" = "x"), "Zly" = 5), "liczba" = 7)), test_file)
	var/list/broken = character_stats_load_file(test_file)
	fdel(test_file)
	TEST_ASSERT_EQUAL(broken["aquilastatstest"]?["Test Medyk"]?["surgeries"], 4, "A valid stat was lost from a damaged file")
	TEST_ASSERT(!("liczba" in broken) && !("Zly" in broken["aquilastatstest"]), "Entries of a wrong shape were kept")
	TEST_ASSERT(!("zle" in broken["aquilastatstest"]["Test Medyk"]), "A non-number stat was kept")

	var/list/window_data = GLOB.character_stats_ui.ui_static_data(medic)
	TEST_ASSERT(islist(window_data["characters"]), "The stats window has no character list")

	medic.mind.key = null

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
