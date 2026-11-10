// AQUILA - basic vermin (port of BeeStation/BeeStation-Hornet basic mice and cockroaches): mouse AI eats cables and cheese,
// the royal cheese still crowns a regal rat (decision D8), cockroaches get squashed.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// The mouse AI finds a cable it can reach and bites through it; it hunts cheese and eats it
/datum/unit_test/aquila_mouse_eats_cable_and_cheese

/datum/unit_test/aquila_mouse_eats_cable_and_cheese/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/old_turf_type = left.type
	var/turf/open/floor/plating/bare = left.ChangeTurf(/turf/open/floor/plating)
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse, bare)
	var/datum/ai_controller/controller = mouse.ai_controller
	TEST_ASSERT(istype(controller, /datum/ai_controller/basic_controller/mouse), "Mouse has no mouse AI")

	var/obj/structure/cable/cable = allocate(/obj/structure/cable, bare)
	var/datum/ai_behavior/find_hunt_target/mouse_cable/cable_finder = GET_AI_BEHAVIOR(/datum/ai_behavior/find_hunt_target/mouse_cable)
	TEST_ASSERT(cable_finder.valid_dinner(mouse, cable, 0, controller, 1), "Mouse does not want a cable on bare plating")
	var/obj/structure/lattice/catwalk/catwalk = allocate(/obj/structure/lattice/catwalk, bare)
	TEST_ASSERT(!cable_finder.valid_dinner(mouse, cable, 0, controller, 1), "Mouse wants to chew a cable through a catwalk")
	qdel(catwalk)

	// An unpowered cable is just eaten
	mouse.UnarmedAttack(cable, TRUE)
	TEST_ASSERT(QDELETED(cable), "Mouse AI did not bite through the cable")
	TEST_ASSERT_EQUAL(mouse.stat, CONSCIOUS, "Mouse died on an unpowered cable")

	var/obj/item/food/cheese/wedge/cheese = allocate(/obj/item/food/cheese/wedge, right)
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/find_hunt_target/cheese_finder = GET_AI_BEHAVIOR(/datum/ai_behavior/find_hunt_target)
	TEST_ASSERT(controller.current_behaviors[cheese_finder], "Mouse did not look for the cheese next to it")
	controller.ProcessBehavior(1, cheese_finder)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_CURRENT_HUNTING_TARGET], cheese, "Mouse did not pick the cheese as its hunt")
	mouse.UnarmedAttack(cheese, TRUE)
	TEST_ASSERT(QDELETED(cheese), "Mouse AI did not eat the cheese")
	TEST_ASSERT(mouse.full, "Mouse is not full after the cheese")

	// Decision D8: the royal cheese still turns a mouse into a regal rat, now through its own signals
	var/obj/item/food/royalcheese/crown = allocate(/obj/item/food/royalcheese, right)
	crown.forceMove(bare)
	TEST_ASSERT(QDELETED(mouse), "Mouse did not change after getting the royal cheese")
	var/mob/living/simple_animal/hostile/regalrat/king = locate() in bare
	TEST_ASSERT(king, "Royal cheese did not make a regal rat")
	qdel(king)
	bare.ChangeTurf(old_turf_type)

/// Walking over a cockroach can squash it; the strong one from xenoarchaeology cannot be squashed
/datum/unit_test/aquila_cockroach_squash

/datum/unit_test/aquila_cockroach_squash/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/mob/living/basic/cockroach/roach = allocate(/mob/living/basic/cockroach, right)
	TEST_ASSERT(roach.GetComponent(/datum/component/squashable), "Cockroach cannot be squashed")
	var/mob/living/basic/cockroach/strong/strong_roach = allocate(/mob/living/basic/cockroach/strong, right)
	TEST_ASSERT(!strong_roach.GetComponent(/datum/component/squashable), "Strong cockroach can be squashed")
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, left)
	for(var/i in 1 to 30)
		walker.forceMove(left)
		walker.Move(right, EAST)
		if(QDELETED(roach))
			break
	TEST_ASSERT(QDELETED(roach), "Thirty steps on a cockroach never squashed it")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/insectguts) in right, "Squashed cockroach left no guts")
	TEST_ASSERT(!QDELETED(strong_roach), "Strong cockroach got squashed")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
