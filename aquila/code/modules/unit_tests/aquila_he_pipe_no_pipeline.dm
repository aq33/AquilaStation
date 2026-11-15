// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - rura HE bez sieci rur (szablon w trakcie budowy sieci w setup_template_machinery) przechodzi cykl atmosfery
/// bez runtime'u „Cannot read null.air” (aquila/code/modules/atmospherics/machinery/pipes/he_pipe_no_pipeline.dm).
/// Objaw z gry i CI: aquila_engine_choice_swap padał losowo na runtime'ach rur HE w kosmosie po podmianie silnika.
/datum/unit_test/aquila_he_pipe_no_pipeline

/datum/unit_test/aquila_he_pipe_no_pipeline/Run()
	var/obj/machinery/atmospherics/pipe/heat_exchanging/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/heat_exchanging/simple, run_loc_floor_bottom_left)
	var/datum/pipeline/old_parent = pipe.parent
	var/datum/gas_mixture/old_temporary = pipe.air_temporary
	pipe.parent = null
	pipe.air_temporary = null
	// runtime w process_atmos() sam oblewa test (błędy w trakcie testu są zgłaszane jako porażka)
	pipe.process_atmos()
	pipe.parent = old_parent
	pipe.air_temporary = old_temporary
	TEST_ASSERT(!QDELETED(pipe), "Rura HE bez sieci zniknęła po cyklu atmosfery")

#undef TEST_ASSERT
