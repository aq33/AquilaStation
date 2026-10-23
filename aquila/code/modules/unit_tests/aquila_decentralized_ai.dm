// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - zdecentralizowane AI: rdzenie danych, szafy, przydział zasobów, projekty, przenoszenie i pobieranie SI
/datum/unit_test/aquila_decentralized_ai

/datum/unit_test/aquila_decentralized_ai/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/turf/up = get_step(left, NORTH)
	var/turf/up_right = get_step(right, NORTH)

	// Działająca konsola komunikacyjna, żeby usunięcie SI nie wezwało promu (autoEvac)
	allocate(/obj/machinery/computer/communications, get_step(right, EAST))

	var/obj/machinery/ai/data_core/primary/core = allocate(/obj/machinery/ai/data_core/primary, left)
	core.integrated_battery = new /obj/item/stock_parts/cell/high(core)
	var/obj/machinery/ai/data_core/backup = allocate(/obj/machinery/ai/data_core, right)
	backup.integrated_battery = new /obj/item/stock_parts/cell/high(backup)
	TEST_ASSERT(core in GLOB.data_cores["[left.z]"], "Data core did not register itself")
	var/datum/ai_os/os = GLOB.ai_os["[left.z]"]
	TEST_ASSERT(os, "No resource system for the test z-level")
	TEST_ASSERT_EQUAL(core.linked_os, os, "Data core not linked to the resource system")

	var/cpu_before = os.total_cpu
	var/ram_before = os.total_ram
	allocate(/obj/machinery/ai/server_cabinet/prefilled, up)
	TEST_ASSERT_EQUAL(os.total_cpu, cpu_before + 1, "Prefilled server cabinet did not add CPU")
	TEST_ASSERT_EQUAL(os.total_ram, ram_before + 1, "Prefilled server cabinet did not add RAM")

	// Nowa SI na kafelku przenosi się do głównego rdzenia
	var/mob/living/carbon/human/brain_holder = allocate(/mob/living/carbon/human, up_right)
	var/mob/living/silicon/ai/ai = allocate(/mob/living/silicon/ai, up_right, null, brain_holder)
	TEST_ASSERT_EQUAL(ai.loc, core, "AI did not move into the primary data core")
	TEST_ASSERT(ai in os.ai_list, "AI was not added to the resource system")
	TEST_ASSERT(ai.dashboard, "AI has no dashboard")

	os.set_cpu(ai, os.total_cpu - os.total_cpu_assigned())
	os.set_ram(ai, os.total_ram - os.total_ram_assigned())
	TEST_ASSERT(os.cpu_assigned[ai] > 0, "AI got no CPU")

	// Wolne CPU daje punkty badań SI
	var/points_before = SSresearch.science_tech.research_points[TECHWEB_POINT_TYPE_AI] || 0
	ai.dashboard.tick(2)
	var/points_after = SSresearch.science_tech.research_points[TECHWEB_POINT_TYPE_AI] || 0
	TEST_ASSERT(points_after > points_before, "Spare CPU did not generate AI research points")

	// Ukończony projekt da się uruchomić i zatrzymać
	var/datum/ai_project/camera_speed/project = locate() in ai.dashboard.available_projects
	TEST_ASSERT(project, "Camera speed project missing")
	ai.dashboard.finish_project(project, FALSE)
	TEST_ASSERT(ai.dashboard.run_project(project), "Could not run a finished project")
	TEST_ASSERT(ai.acceleration, "Camera speed project did not apply")
	ai.dashboard.stop_project(project)
	TEST_ASSERT(!ai.acceleration, "Camera speed project did not stop")

	// Zniszczenie rdzenia przenosi SI do zapasowego
	qdel(core)
	TEST_ASSERT_EQUAL(ai.loc, backup, "AI did not relocate to the backup data core")

	// Pobranie na intellicard i ponowne wgranie
	var/obj/machinery/computer/ai_control_console/console = allocate(/obj/machinery/computer/ai_control_console, get_step(up_right, EAST))
	var/obj/item/aicard/card = allocate(/obj/item/aicard, console)
	console.intellicard = card
	TEST_ASSERT(console.download_to_card(ai, card), "Download to intellicard failed")
	TEST_ASSERT_EQUAL(ai.loc, card, "AI is not on the intellicard")
	TEST_ASSERT(!(ai in os.ai_list), "Carded AI still uses the resource system")
	TEST_ASSERT(console.upload_ai(), "Upload from intellicard failed")
	TEST_ASSERT_EQUAL(ai.loc, backup, "AI was not uploaded back into the data core")

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Decentralized AI test caused runtimes")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
