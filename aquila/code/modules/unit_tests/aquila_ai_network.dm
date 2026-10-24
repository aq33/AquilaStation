// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - sieć kabli ethernet zdecentralizowanego AI: łączenie i dzielenie zasobów kablem i nadajnikami
/datum/unit_test/aquila_ai_network

/datum/unit_test/aquila_ai_network/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/origin = run_loc_floor_bottom_left
	var/list/row0 = list()
	var/list/row1 = list()
	for(var/i in 0 to 4)
		row0 += locate(origin.x + i, origin.y, origin.z)
		row1 += locate(origin.x + i, origin.y + 1, origin.z)

	// Działająca konsola komunikacyjna, żeby usunięcie SI nie wezwało promu (autoEvac)
	allocate(/obj/machinery/computer/communications, locate(origin.x + 4, origin.y + 2, origin.z))

	// Sieć A: rdzeń, szafa i nadajnik. Sieć B: szafa i nadajnik. Między nimi przerwa w kablu (row0[3]).
	for(var/turf/cable_turf in list(row0[1], row0[2], row1[1], row0[4], row1[4]))
		allocate(/obj/structure/ethernet_cable, cable_turf)
	var/obj/machinery/ai/data_core/primary/core = allocate(/obj/machinery/ai/data_core/primary, row0[1])
	core.integrated_battery = new /obj/item/stock_parts/cell/high(core)
	var/obj/machinery/ai/server_cabinet/cabinet_a = allocate(/obj/machinery/ai/server_cabinet/prefilled, row0[2])
	var/obj/machinery/ai/server_cabinet/cabinet_b = allocate(/obj/machinery/ai/server_cabinet/prefilled, row0[4])
	var/obj/machinery/ai/networking/dish_a = allocate(/obj/machinery/ai/networking, row1[1])
	var/obj/machinery/ai/networking/dish_b = allocate(/obj/machinery/ai/networking, row1[4])
	rebuild_ai_networks()

	var/datum/ai_os/os_a = core.get_os()
	var/datum/ai_os/os_b = cabinet_b.get_os()
	TEST_ASSERT(os_a, "Data core on a cable has no resource system")
	TEST_ASSERT(os_b, "Server cabinet on a cable has no resource system")
	TEST_ASSERT(os_a != os_b, "Separate cable networks share resources")
	TEST_ASSERT_EQUAL(cabinet_a.get_os(), os_a, "Cabinet next to the core is not in its network")
	TEST_ASSERT_EQUAL(os_a.total_cpu, 1, "Network A should only count its own cabinet")
	TEST_ASSERT_EQUAL(os_b.total_cpu, 1, "Network B should only count its own cabinet")

	// Maszyna bez kabla nie należy do żadnej sieci
	var/obj/machinery/ai/server_cabinet/loose = allocate(/obj/machinery/ai/server_cabinet/prefilled, row0[5])
	TEST_ASSERT(!loose.get_os(), "Cabinet without a cable joined a network")

	// SI w rdzeniu dostaje całe CPU sieci
	var/mob/living/carbon/human/brain_holder = allocate(/mob/living/carbon/human, row1[2])
	var/mob/living/silicon/ai/ai = allocate(/mob/living/silicon/ai, row1[2], null, brain_holder)
	TEST_ASSERT_EQUAL(ai.loc, core, "AI did not move into the networked data core")
	TEST_ASSERT_EQUAL(ai.get_ai_os(), os_a, "AI does not use its core's resource system")

	// Domknięcie kabla łączy sieci
	var/obj/structure/ethernet_cable/bridge = allocate(/obj/structure/ethernet_cable, row0[3])
	rebuild_ai_networks()
	TEST_ASSERT_EQUAL(cabinet_b.get_os(), core.get_os(), "Bridging cable did not merge the networks")
	TEST_ASSERT_EQUAL(core.get_os(), os_a, "Network with the AI lost its resource system")
	TEST_ASSERT_EQUAL(os_a.total_cpu, 2, "Merged network did not sum CPU")
	os_a.set_cpu(ai, 2)
	TEST_ASSERT_EQUAL(os_a.cpu_assigned[ai], 2, "AI did not get the merged CPU")

	// Przecięcie kabla dzieli zasoby, a przydział SI jest przycinany
	qdel(bridge)
	rebuild_ai_networks()
	TEST_ASSERT_EQUAL(core.get_os(), os_a, "AI's network lost its resource system after the split")
	TEST_ASSERT(cabinet_b.get_os() != os_a, "Cut cable did not split the networks")
	TEST_ASSERT_EQUAL(os_a.total_cpu, 1, "Split network still counts the far cabinet")
	TEST_ASSERT_EQUAL(os_a.cpu_assigned[ai], 1, "AI kept CPU from the disconnected cabinet")

	// Nadajniki łączą sieci bez kabla
	TEST_ASSERT(dish_a.connect_to_partner(dish_b), "Networking machines did not connect")
	rebuild_ai_networks()
	TEST_ASSERT_EQUAL(cabinet_b.get_os(), os_a, "Networking machines did not share resources")
	TEST_ASSERT_EQUAL(os_a.total_cpu, 2, "Linked networks did not sum CPU")
	TEST_ASSERT_EQUAL(length(os_a.networks), 2, "Linked resource system should span two cable networks")

	dish_a.disconnect()
	rebuild_ai_networks()
	TEST_ASSERT(cabinet_b.get_os() != os_a, "Disconnecting the dishes did not split the networks")
	TEST_ASSERT_EQUAL(ai.loc, core, "AI left its core after the split")

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "AI network test caused runtimes")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
