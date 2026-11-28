// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wiązka emitera odbita reflektorem rysuje ślad z załamaniem, a nie jedną skośną linię od emitera do końca drogi
/datum/unit_test/aquila_hitscan_reflect_tracer

/datum/unit_test/aquila_hitscan_reflect_tracer/Run()
	var/turf/emitter_turf = run_loc_floor_bottom_left
	var/turf/reflector_turf = locate(emitter_turf.x, emitter_turf.y + 2, emitter_turf.z)
	TEST_ASSERT(isopenturf(reflector_turf), "No open turf 2 tiles north of the test room corner")

	var/obj/structure/reflector/box/mapping/reflector = allocate(/obj/structure/reflector/box/mapping, reflector_turf)
	reflector.setAngle(90, TRUE) // na wschód
	var/obj/machinery/power/emitter/emitter = allocate(/obj/machinery/power/emitter, emitter_turf)
	emitter.setDir(NORTH)
	emitter.fire_beam()

	// Przy zajętym ticku hitscan kończy lot w process(), więc ślad może pojawić się tick później
	var/list/tracers = list()
	for(var/i in 1 to 10)
		for(var/obj/effect/projectile/tracer/tracer in range(6, emitter_turf))
			tracers += tracer
		if(length(tracers))
			break
		sleep(world.tick_lag)

	var/vertical = 0
	var/horizontal = 0
	var/diagonal = 0
	for(var/obj/effect/projectile/tracer/tracer as anything in tracers)
		var/matrix/M = tracer.transform
		if(abs(M.b) < 0.01 && abs(M.d) < 0.01)
			vertical++
		else if(abs(M.a) < 0.01 && abs(M.e) < 0.01)
			horizontal++
		else
			diagonal++
	TEST_ASSERT(!diagonal, "Reflected emitter beam drew [diagonal] diagonal tracer segment(s)")
	TEST_ASSERT(vertical == 1 && horizontal == 1, "Reflected emitter beam drew [vertical] vertical and [horizontal] horizontal segments instead of 1 and 1")

#undef TEST_ASSERT
