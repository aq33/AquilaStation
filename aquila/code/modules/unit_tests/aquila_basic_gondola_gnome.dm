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

/// The gondola drops one hide, the gondola pod two, whichever of them spawned first (they shared one loot list before)
/datum/unit_test/aquila_gondola_loot_per_type

/datum/unit_test/aquila_gondola_loot_per_type/Run()
	var/turf/pod_floor = run_loc_floor_bottom_left
	var/turf/floor = get_step(pod_floor, EAST)
	// The pod first: before the fix the gondola then dropped the pod's two hides
	var/obj/structure/closet/supplypod/centcompod/pod = allocate(/obj/structure/closet/supplypod/centcompod, pod_floor)
	var/mob/living/basic/pet/gondola/gondolapod/courier = allocate(/mob/living/basic/pet/gondola/gondolapod, pod_floor, pod)
	var/mob/living/basic/pet/gondola/gondola = allocate(/mob/living/basic/pet/gondola, floor)
	var/list/before = pod_floor.contents.Copy() + floor.contents.Copy()
	courier.death()
	gondola.death()
	allocated += (pod_floor.contents + floor.contents) - before
	TEST_ASSERT(count_hides(pod_floor) == 2, "The gondola pod dropped [count_hides(pod_floor)] hides instead of 2")
	TEST_ASSERT(count_hides(floor) == 1, "The gondola dropped [count_hides(floor)] hides instead of 1")

/datum/unit_test/aquila_gondola_loot_per_type/proc/count_hides(turf/floor)
	. = 0
	for(var/obj/item/stack/sheet/animalhide/gondola/hide in floor)
		. += hide.amount

/// A gnome sinks only once at a time, and an interrupted or deleted sink does not end up sunk or runtime
/datum/unit_test/aquila_gnome_sinking_interrupted

/datum/unit_test/aquila_gnome_sinking_interrupted/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/basic/garden_gnome/gnome = allocate(/mob/living/basic/garden_gnome, floor)
	var/datum/component/ground_sinking/sinking = gnome.GetComponent(/datum/component/ground_sinking)
	TEST_ASSERT(sinking, "The gnome cannot sink into the ground")
	sinking.sink_speed = 0.5 SECONDS

	sinking.sinked = TRUE
	sinking.start_sinking(gnome)
	TEST_ASSERT(!sinking.is_sinking, "A sunk gnome started sinking again")
	sinking.unsink()

	sinking.start_sinking(gnome)
	TEST_ASSERT(sinking.is_sinking, "The gnome did not start sinking")
	sleep(0.2 SECONDS)
	gnome.forceMove(get_step(floor, EAST))
	sleep(2 SECONDS)
	TEST_ASSERT(!sinking.sinked, "A gnome that moved while sinking ended up sunk")
	TEST_ASSERT(!sinking.is_sinking, "A gnome that moved while sinking is still sinking")
	TEST_ASSERT(gnome.density, "A gnome that moved while sinking is not dense")

	sinking.start_sinking(gnome)
	sleep(0.2 SECONDS)
	qdel(gnome)
	sleep(2 SECONDS)
	TEST_ASSERT(QDELETED(sinking), "The sinking component outlived its gnome")

#undef TEST_ASSERT
