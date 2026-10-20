// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - drony eksploracyjne z tg: przygody się wczytują, miejsca się generują, a dron leci i wraca na wyrzutnię
/datum/unit_test/exodrone

/datum/unit_test/exodrone/Run()
	// Każda przygoda z strings/exoadventures przechodzi walidację
	var/list/entries = get_adventure_db_entries()
	TEST_ASSERT(length(entries), "No exploration drone adventures were loaded")
	for(var/datum/adventure_db_entry/entry as anything in entries)
		var/datum/adventure/adventure = entry.create_adventure()
		TEST_ASSERT(adventure, "Adventure [entry.filename] failed to load")
		adventure.start_adventure()
		TEST_ASSERT(adventure.current_node, "Adventure [entry.filename] did not reach its starting node")
		qdel(adventure)

	// Każdy typ miejsca da się utworzyć, a czarna lista cech działa
	for(var/site_type in subtypesof(/datum/exploration_site))
		var/datum/exploration_site/site = new site_type(3)
		TEST_ASSERT(site.name, "[site_type] has no name")
		for(var/datum/exploration_event/event in site.events)
			if(event.blacklisted_site_traits)
				TEST_ASSERT(!length(site.site_traits & event.blacklisted_site_traits), "[event.type] spawned on [site_type] despite a blacklisted trait")
		qdel(site)

	// Pellet trafia do wyrzutni w combat mode i bez niego (stare intencje też go przełączają)
	var/turf/pad_turf = run_loc_floor_bottom_left
	var/obj/machinery/exodrone_launcher/launcher = allocate(/obj/machinery/exodrone_launcher, pad_turf)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, get_step(pad_turf, EAST))
	for(var/combat in list(TRUE, FALSE))
		user.set_combat_mode(combat)
		var/obj/item/fuel_pellet/pellet = allocate(/obj/item/fuel_pellet)
		user.put_in_active_hand(pellet)
		pellet.melee_attack_chain(user, launcher)
		TEST_ASSERT_EQUAL(launcher.fuel_canister, pellet, "Pellet was not loaded with combat mode [combat ? "on" : "off"]")
		launcher.fuel_canister.forceMove(pad_turf)
		TEST_ASSERT(!launcher.fuel_canister, "Removing the pellet did not clear the launcher")
		qdel(pellet)

	// Lot na miejsce i z powrotem na tę samą wyrzutnię
	var/obj/item/fuel_pellet/fuel = allocate(/obj/item/fuel_pellet)
	user.put_in_active_hand(fuel)
	fuel.melee_attack_chain(user, launcher)
	var/obj/item/exodrone/drone = allocate(/obj/item/exodrone, pad_turf)
	drone.add_tool(EXODRONE_TOOL_LASER)
	TEST_ASSERT(drone.has_tool(EXODRONE_TOOL_LASER), "Drone did not get its laser")
	TEST_ASSERT(!drone.travel_error(), "Drone on a fuelled launcher can't travel: [drone.travel_error()]")
	var/datum/exploration_site/target = new /datum/exploration_site/junkyard(1)
	GLOB.exploration_sites += target
	drone.launch_for(target)
	TEST_ASSERT_EQUAL(drone.drone_status, EXODRONE_TRAVEL, "Drone did not start travelling")
	TEST_ASSERT_EQUAL(fuel.uses, 4, "Launch did not use up one pellet charge")
	deltimer(drone.travel_timer_id)
	drone.finish_travel()
	TEST_ASSERT_EQUAL(drone.drone_status, EXODRONE_EXPLORATION, "Drone did not arrive at the site")
	TEST_ASSERT(target.revealed, "Arriving did not reveal the site")

	// Niebezpieczeństwo z odpowiednim narzędziem nie rani drona
	var/datum/exploration_event/simple/danger/carp/carp = new
	carp.encounter(drone)
	TEST_ASSERT(drone.current_event_ui_data, "Danger event did not open its screen")
	var/integrity_before = drone.obj_integrity
	carp.fire(drone)
	TEST_ASSERT_EQUAL(drone.obj_integrity, integrity_before, "Laser did not protect the drone from the carp")
	TEST_ASSERT(!drone.current_event_ui_data, "Danger event did not close")

	drone.launch_for(null)
	deltimer(drone.travel_timer_id)
	drone.finish_travel()
	TEST_ASSERT_EQUAL(drone.drone_status, EXODRONE_IDLE, "Drone did not come back")
	TEST_ASSERT_EQUAL(drone.loc, pad_turf, "Drone did not land on its launcher")

	GLOB.exploration_sites -= target
	qdel(target)
	qdel(carp)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
