// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - w ruchu skrzydła i czułki ćmy (całe BODY_BEHIND/BODY_FRONT) są na fragmentach bez masek, a nie w buforze ciała,
/// który maski kończyn tną na kawałki
/datum/unit_test/walk_animation_wings

/datum/unit_test/walk_animation_wings/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/next = get_step(start, EAST)
	TEST_ASSERT(isopenturf(next), "No open turf east of the test room corner")

	var/mob/living/carbon/human/moth = allocate(/mob/living/carbon/human, start)
	moth.dna.features["moth_wings"] = "Plain"
	moth.set_species(/datum/species/moth)
	TEST_ASSERT(count_wings(moth), "A standing moth has no wing overlays")

	var/datum/component/walk_animation/animation = moth.GetComponent(/datum/component/walk_animation)
	TEST_ASSERT(animation, "Human without a client has no walk animation")

	var/area/test_area = get_area(start)
	var/old_gravity = test_area.has_gravity
	test_area.has_gravity = STANDARD_GRAVITY // w nieważkości animacja chodu się nie włącza
	moth.Move(next, EAST)
	test_area.has_gravity = old_gravity
	TEST_ASSERT(animation.active, "Walk animation did not activate on a step")
	TEST_ASSERT(!count_wings(moth), "Wings stayed in the masked body buffer while walking")
	TEST_ASSERT(!length(moth.overlays_standing[BODY_BEHIND_LAYER]) && !length(moth.overlays_standing[BODY_FRONT_LAYER]), "Mutant parts (antennae) stayed in the masked body buffer while walking")
	TEST_ASSERT(length(animation.part_em_blocks) == 2 && (animation.part_em_blocks[1] in moth.vis_contents), "Unmasked part fragments have no emissive blockers")
	var/obj/effect/overlay/walk_held/wings_behind = animation.limbs["parts_behind"]
	var/obj/effect/overlay/walk_held/wings_front = animation.limbs["parts_front"]
	TEST_ASSERT(length(wings_behind.add_overlays) + length(wings_front.add_overlays) > 4, "The unmasked part fragments hold only their anchors")
	TEST_ASSERT((wings_behind in moth.vis_contents) && (wings_front in moth.vis_contents), "Wing fragments are not shown on the walking moth")

	moth.dna.species.handle_mutant_bodyparts(moth)
	TEST_ASSERT(!count_wings(moth), "Rebuilding the mutant bodyparts while walking put the wings back into the body buffer")

	animation.idle_after = 0
	animation.check_idle()
	TEST_ASSERT(!animation.active, "Walk animation stayed active after the idle delay")
	TEST_ASSERT(count_wings(moth), "Wing overlays were not restored after walking")
	TEST_ASSERT(!length(wings_behind.add_overlays) && !length(wings_front.add_overlays), "Part fragments kept their overlays after walking")

/// Ile nakładek skrzydeł jest na warstwach części mutanckich moba.
/datum/unit_test/walk_animation_wings/proc/count_wings(mob/living/carbon/human/H)
	. = 0
	for(var/layer in list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER))
		for(var/mutable_appearance/part in H.overlays_standing[layer])
			if(findtext(part.icon_state, "wings"))
				.++

#undef TEST_ASSERT
