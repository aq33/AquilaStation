// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - regresja: rura wymiany ciepła przed zbudowaniem sieci (szablon wczytany w trakcie rundy) nie sypie runtime'ami w process_atmos
/datum/unit_test/aquila_he_pipe_no_network

/datum/unit_test/aquila_he_pipe_no_network/Run()
	var/obj/machinery/atmospherics/pipe/heat_exchanging/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/heat_exchanging/simple, run_loc_floor_bottom_left)
	var/datum/pipeline/old_parent = pipe.parent
	var/datum/gas_mixture/old_temporary = pipe.air_temporary
	pipe.parent = null
	pipe.air_temporary = null
	pipe.process_atmos()
	pipe.parent = old_parent
	pipe.air_temporary = old_temporary
	TEST_ASSERT(!QDELETED(pipe), "The pipe got deleted while processing without a network")

#undef TEST_ASSERT
