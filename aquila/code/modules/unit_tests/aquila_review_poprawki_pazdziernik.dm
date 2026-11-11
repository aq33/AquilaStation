// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - schowanie jednego ostrza modliszki wyłącza tryb podważania w drugim (podważanie wymaga pary)
/datum/unit_test/aquila_mantis_pry_needs_pair

/datum/unit_test/aquila_mantis_pry_needs_pair/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/mantis_blade/first = allocate(/obj/item/mantis_blade)
	var/obj/item/mantis_blade/second = allocate(/obj/item/mantis_blade)
	user.put_in_active_hand(first)
	user.put_in_inactive_hand(second)
	first.attack_self(user)
	TEST_ASSERT_EQUAL(first.tool_behaviour, TOOL_CROWBAR, "Two blades did not switch to the pry mode")
	user.dropItemToGround(second)
	TEST_ASSERT_EQUAL(first.tool_behaviour, TOOL_KNIFE, "The blade left alone stayed in the pry mode")
	TEST_ASSERT(!HAS_TRAIT(first, TRAIT_DOOR_PRYER), "The blade left alone can still pry doors")

/// AQUILA - obrót po rzucie nie podmienia ani nie wyrejestrowuje własnego handlera COMSIG_MOVABLE_MOVED przedmiotu
/datum/unit_test/aquila_scatter_keeps_moved_handler

/datum/unit_test/aquila_scatter_keeps_moved_handler/Run()
	var/obj/item/usb_cable/cable = allocate(/obj/item/usb_cable, run_loc_floor_bottom_left)
	var/list/own_signals = cable.signal_procs?[cable]
	var/handler = own_signals?[COMSIG_MOVABLE_MOVED]
	TEST_ASSERT(handler, "The USB cable has no moved handler of its own")
	cable.throw_scatter_rotate(90)
	TEST_ASSERT_EQUAL(cable.scatter_angle, 90, "The cable was not rotated")
	own_signals = cable.signal_procs?[cable]
	TEST_ASSERT_EQUAL(own_signals?[COMSIG_MOVABLE_MOVED], handler, "Rotating the cable replaced its own moved handler")
	var/obj/structure/closet/closet = allocate(/obj/structure/closet, run_loc_floor_bottom_left)
	cable.forceMove(closet)
	TEST_ASSERT(!cable.scatter_angle, "The rotation stayed after the cable left the floor")
	own_signals = cable.signal_procs?[cable]
	TEST_ASSERT_EQUAL(own_signals?[COMSIG_MOVABLE_MOVED], handler, "Leaving the floor unregistered the cable's own moved handler")

/// AQUILA - puste wpisy łupu z technicznych ("") nie kończą się runtime'em w łupie drona eksploracyjnego
/datum/unit_test/aquila_exodrone_maint_loot_empty

/datum/unit_test/aquila_exodrone_maint_loot_empty/Run()
	var/list/old_loot = GLOB.maintenance_loot
	GLOB.maintenance_loot = list("" = 1, /obj/item/paper = 3)
	var/datum/adventure_loot_generator/maintenance/generator = new
	generator.amount = 10
	var/list/loot = generator.generate()
	GLOB.maintenance_loot = old_loot
	qdel(generator)
	for(var/atom/movable/thing as anything in loot)
		allocated += thing
	TEST_ASSERT_EQUAL(length(loot), 10, "Empty maintenance loot entries were not rerolled")
	for(var/thing in loot)
		TEST_ASSERT(istype(thing, /obj/item/paper), "Maintenance loot made [thing]")

/// AQUILA - log dostępu nie zapisuje otwarcia, gdy zaryglowane drzwi się nie otworzyły
/datum/unit_test/aquila_access_log_bolted_door

/datum/unit_test/aquila_access_log_bolted_door/Run()
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, run_loc_floor_bottom_left)
	door.req_access = list(ACCESS_CAPTAIN)
	door.locked = TRUE
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/card/id/captains_spare/card = allocate(/obj/item/card/id/captains_spare)
	user.put_in_active_hand(card)
	TEST_ASSERT(door.allowed(user), "The captain's spare ID does not open the test door")
	door.activate_door_base(user, FALSE)
	TEST_ASSERT(door.density, "A bolted door opened")
	TEST_ASSERT(!length(door.aq_access_records), "A bolted door that stayed closed logged an opening")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
