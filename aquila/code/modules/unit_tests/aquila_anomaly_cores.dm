// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - każda anomalia zostawia rdzeń swojego typu, a każdy rdzeń jest wart punkty badań
/datum/unit_test/aquila_anomaly_cores

/datum/unit_test/aquila_anomaly_cores/Run()
	var/list/expected = list(
		/obj/effect/anomaly/pyro = /obj/item/assembly/signaler/anomaly/pyro,
		/obj/effect/anomaly/grav = /obj/item/assembly/signaler/anomaly/grav,
		/obj/effect/anomaly/flux = /obj/item/assembly/signaler/anomaly/flux,
		/obj/effect/anomaly/bluespace = /obj/item/assembly/signaler/anomaly/bluespace,
		/obj/effect/anomaly/bhole = /obj/item/assembly/signaler/anomaly/vortex,
		/obj/effect/anomaly/hallucination = /obj/item/assembly/signaler/anomaly/hallucination,
		/obj/effect/anomaly/plasmasoul = /obj/item/assembly/signaler/anomaly/plasmasoul,
	)
	for(var/anomaly_type in expected)
		var/obj/effect/anomaly/anomaly = new anomaly_type(run_loc_floor_bottom_left)
		TEST_ASSERT(istype(anomaly.aSignal, expected[anomaly_type]), "[anomaly_type] made a [anomaly.aSignal?.type] core instead of [expected[anomaly_type]]")
		TEST_ASSERT(icon_exists(anomaly.aSignal.icon, anomaly.aSignal.icon_state), "[anomaly.aSignal.type] has no sprite [anomaly.aSignal.icon_state]")
		qdel(anomaly)
	for(var/core_type in typesof(/obj/item/assembly/signaler/anomaly))
		TEST_ASSERT(length(SSresearch.techweb_point_items[core_type]), "[core_type] isn't worth any research points")

#undef TEST_ASSERT
