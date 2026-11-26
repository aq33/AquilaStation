// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/**
 * AQUILA - HFR jako silnik do wyboru (E18): szablon każdego statku ma rozmiar slotu, nie wypada w losowaniu,
 * a po wczytaniu reaktor jest złożony, a jego wloty, wylot i port chłodziwa są podłączone do rur.
 */
/datum/unit_test/aquila_hfr_engine_templates
	/// Pola wczytanych szablonów, sprzątane w Destroy
	var/list/area_turfs = list()

/datum/unit_test/aquila_hfr_engine_templates/Run()
	var/list/slots = list(
		/datum/map_template/random_room/aq_engine_atl_hfr = /datum/map_template/random_room/sk_rdm_eng_atl_02,
		/datum/map_template/random_room/aq_engine_ser_hfr = /datum/map_template/random_room/aq_engine_ser_03,
		/datum/map_template/random_room/aq_engine_snk_hfr = /datum/map_template/random_room/aq_engine_snk_03,
	)
	for(var/hfr_type in slots)
		var/datum/map_template/random_room/hfr = new hfr_type()
		var/supermatter_type = slots[hfr_type]
		var/datum/map_template/random_room/supermatter = new supermatter_type()
		TEST_ASSERT(hfr.engine_type == ENGINE_CHOICE_HFR, "[hfr.name] is not an HFR engine choice")
		TEST_ASSERT(hfr.spawned, "[hfr.name] can be rolled at random on map load")
		TEST_ASSERT(hfr.width == supermatter.width && hfr.height == supermatter.height, "[hfr.name] is [hfr.width]x[hfr.height], the slot is [supermatter.width]x[supermatter.height]")
		TEST_ASSERT(hfr.template_width == supermatter.template_width && hfr.template_height == supermatter.template_height, "[hfr.name] has a different slot size than [supermatter.name]")

		// Bez Release(): zwolnione pola od razu bierze komora testowa (wzór: aquila_engine_choice_swap)
		var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(hfr.width + 1, hfr.height + 1)
		TEST_ASSERT(reservation, "No space to reserve for [hfr.name]")
		var/turf/origin = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
		area_turfs += hfr.get_affected_turfs(origin)
		TEST_ASSERT(hfr.load(origin, centered = FALSE), "[hfr.name] did not load")
		var/obj/machinery/atmospherics/components/unary/hypertorus/core/core
		for(var/turf/T as anything in hfr.get_affected_turfs(origin))
			core = locate() in T
			if(core)
				break
		TEST_ASSERT(core, "[hfr.name] has no HFR core")
		TEST_ASSERT(core.check_part_connectivity(), "[hfr.name]: the HFR parts around the core are misplaced or misrotated")
		TEST_ASSERT(core.nodes[1], "[hfr.name]: the HFR cooling port is not connected to a pipe")
		TEST_ASSERT(core.linked_input.nodes[1], "[hfr.name]: the HFR fuel input is not connected to a pipe")
		TEST_ASSERT(core.linked_moderator.nodes[1], "[hfr.name]: the HFR moderator input is not connected to a pipe")
		TEST_ASSERT(core.linked_output.nodes[1], "[hfr.name]: the HFR waste output is not connected to a pipe")
		TEST_ASSERT(core.parents[1] != core.linked_input.parents[1], "[hfr.name]: fuel flows straight into the cooling loop")
		TEST_ASSERT(core.linked_input.parents[1] != core.linked_moderator.parents[1], "[hfr.name]: fuel and moderator share one pipe network")
		TEST_ASSERT(core.parents[1] != core.linked_output.parents[1], "[hfr.name]: hot waste flows into the cooling loop")
		// Gorące chłodziwo przy rdzeniu: rury tej sieci są wzmocnione (zwykłe pękają od 10 000 K)
		var/datum/pipeline/coolant = core.parents[1]
		for(var/obj/machinery/atmospherics/pipe/pipe in coolant.members)
			TEST_ASSERT(pipe.aq_reinforced, "[hfr.name]: the HFR cooling loop pipe at [pipe.x - origin.x + 1],[pipe.y - origin.y + 1] is not reinforced")

/datum/unit_test/aquila_hfr_engine_templates/Destroy()
	for(var/turf/T as anything in area_turfs)
		for(var/atom/movable/AM as anything in T)
			if(isobj(AM) || isliving(AM))
				qdel(AM)
	area_turfs = null
	return ..()


#undef TEST_ASSERT
