// AQUILA - basic gondolas (port of BeeStation/BeeStation-Hornet basic gondolas) and the garden gnome (new content from Bee)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// A dead gondola leaves its hide and meat and deletes itself; a dead gondola delivery pod takes its supply pod with it
/datum/unit_test/aquila_gondola_death_and_pod

/datum/unit_test/aquila_gondola_death_and_pod/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/basic/pet/gondola/gondola = allocate(/mob/living/basic/pet/gondola, floor)
	TEST_ASSERT(length(gondola.add_overlays) >= 3, "The gondola has no body, eyes and moustache overlays")
	var/list/on_floor_before = floor.contents.Copy()
	gondola.death()
	TEST_ASSERT(QDELETED(gondola), "A dead gondola was not deleted")
	// Only what the gondola dropped is cleaned up, the test room's own landmarks stay
	allocated += (floor.contents - on_floor_before)
	TEST_ASSERT(locate(/obj/item/stack/sheet/animalhide/gondola) in floor, "A dead gondola left no hide")

	var/turf/pod_floor = get_step(floor, EAST)
	var/obj/structure/closet/supplypod/centcompod/pod = allocate(/obj/structure/closet/supplypod/centcompod, pod_floor)
	var/mob/living/basic/pet/gondola/gondolapod/courier = allocate(/mob/living/basic/pet/gondola/gondolapod, pod_floor, pod)
	TEST_ASSERT(courier.linked_pod == pod, "The gondola pod is not linked to its supply pod")
	TEST_ASSERT(courier.icon_state == "gondola", "The gondola pod drew a random gondola body")
	courier.death()
	TEST_ASSERT(QDELETED(courier), "A dead gondola pod was not deleted")
	TEST_ASSERT(QDELETED(pod), "A dead gondola pod left its supply pod")

/// Hitting one garden gnome makes the gnomes around it fight back, and a gnome gets its colours from the greyscale config
/datum/unit_test/aquila_garden_gnome

/datum/unit_test/aquila_garden_gnome/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/carbon/human/vandal = allocate(/mob/living/carbon/human, floor)
	var/mob/living/basic/garden_gnome/victim = allocate(/mob/living/basic/garden_gnome, get_step(floor, EAST))
	var/mob/living/basic/garden_gnome/friend = allocate(/mob/living/basic/garden_gnome, get_step(floor, NORTH))
	TEST_ASSERT(victim.greyscale_colors, "The gnome got no colours")
	TEST_ASSERT(victim.GetComponent(/datum/component/caltrop), "The gnome does not hurt bare feet")
	TEST_ASSERT(victim.GetComponent(/datum/component/ground_sinking), "The gnome cannot sink into the ground")

	vandal.set_combat_mode(TRUE)
	victim.attack_hand(vandal, list())
	TEST_ASSERT(vandal in victim.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The hit gnome does not fight back")
	TEST_ASSERT(vandal in friend.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The gnome next to it does not fight back")

#undef TEST_ASSERT
