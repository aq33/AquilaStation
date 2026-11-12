// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - tg bleeding overlays on the body, joined blood trails, drops in vis_contents, tg human sprites and damage overlays
/datum/unit_test/aquila_blood_trails

/datum/unit_test/aquila_blood_trails/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	// Bleeding attributed to the right arm shows on the right arm only
	patient.add_bleeding(BLEED_DEEP_WOUND, BODY_ZONE_R_ARM)
	TEST_ASSERT(patient.overlays_standing[WOUND_LAYER], "Bleeding made no wound overlay")
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "r_arm_2"), "A deep wound on the right arm shows [patient.aq_wound_overlay_key] instead of r_arm_2")
	TEST_ASSERT(!findtext(patient.aq_wound_overlay_key, "chest"), "Bleeding from the arm shows on the chest too ([patient.aq_wound_overlay_key])")

	// Bandaging takes the blood off and puts a bandage on (medical_overlays.dm)
	patient.suppress_bloodloss(BLEED_CRITICAL * 2)
	TEST_ASSERT(!findtext(patient.aq_wound_overlay_key, "r_arm_"), "Bandaged bleeding still shows a wound overlay ([patient.aq_wound_overlay_key])")
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "bandage_r_arm"), "The bandaged arm shows no bandage ([patient.aq_wound_overlay_key])")

	// Bleeding with no known zone shows on the chest
	patient.cauterise_wounds()
	patient.add_bleeding(BLEED_SURFACE)
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "chest_1"), "Unattributed bleeding shows [patient.aq_wound_overlay_key] instead of chest_1")
	patient.cauterise_wounds()
	TEST_ASSERT(!patient.overlays_standing[WOUND_LAYER], "Cauterised bleeding still shows a wound overlay")

	// An old head wound does not keep bleeding from the head once the bleeding stopped
	patient.add_bleeding(BLEED_CUT, BODY_ZONE_HEAD)
	patient.remove_status_effect(STATUS_EFFECT_BLEED)
	TEST_ASSERT(!length(patient.aq_get_limb_bleeds()), "Stopped bleeding kept the limb bleeding")
	patient.add_bleeding(BLEED_DEEP_WOUND, BODY_ZONE_CHEST)
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "chest_2") && !findtext(patient.aq_wound_overlay_key, "head"), "A new chest bleed shows [patient.aq_wound_overlay_key]")

	// A wound bleeds from its own limb
	patient.cauterise_wounds()
	var/datum/wound/pierce/open/hole = new()
	hole.apply_wound(patient.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
	TEST_ASSERT(findtext(patient.aq_wound_overlay_key, "l_leg"), "A pierce wound on the left leg shows [patient.aq_wound_overlay_key]")
	qdel(hole)
	patient.cauterise_wounds()

	// Dragged while bleeding: two steps east leave a full piece on the middle turf and a half piece ahead
	var/turf/start = run_loc_floor_bottom_left
	var/turf/middle = get_step(start, EAST)
	var/turf/ahead = get_step(middle, EAST)
	var/area/test_area = get_area(start)
	var/old_gravity = test_area.has_gravity
	test_area.has_gravity = STANDARD_GRAVITY // no trails in zero gravity, and the test room has no generator
	patient.add_bleeding(BLEED_DEEP_WOUND)
	patient.make_blood_trail(middle, start, EAST, EAST)
	patient.make_blood_trail(ahead, middle, EAST, EAST)
	test_area.has_gravity = old_gravity
	var/obj/effect/decal/cleanable/blood/trail_holder/middle_trail = locate() in middle
	TEST_ASSERT(middle_trail, "Dragging a bleeding body left no trail")
	TEST_ASSERT(LAZYLEN(middle_trail.trail_components) == 1, "The middle trail has [LAZYLEN(middle_trail.trail_components)] pieces instead of one joined piece")
	var/obj/effect/decal/cleanable/blood/trail/middle_piece = middle_trail.trail_components[middle_trail.trail_components[1]]
	TEST_ASSERT(!middle_piece.half_piece, "The two half pieces on the middle turf did not join")
	TEST_ASSERT(middle_piece in middle_trail.vis_contents, "The trail piece is not shown")
	var/obj/effect/decal/cleanable/blood/trail_holder/ahead_trail = locate() in ahead
	TEST_ASSERT(ahead_trail, "The trail does not reach the turf ahead")
	var/obj/effect/decal/cleanable/blood/trail/ahead_piece = ahead_trail.get_trail_component(EAST)
	TEST_ASSERT(ahead_piece?.half_piece, "The trail ahead is not a half piece")
	TEST_ASSERT(findtext(ahead_piece.icon_state, "_start"), "The half piece uses [ahead_piece.icon_state]")
	patient.cauterise_wounds()

	// Drops: each further drop is its own decal in the first one's vis_contents
	var/turf/drop_turf = get_step(start, NORTH)
	patient.add_splatter_floor(drop_turf, TRUE)
	patient.add_splatter_floor(drop_turf, TRUE)
	var/obj/effect/decal/cleanable/blood/drip/drop = locate() in drop_turf
	TEST_ASSERT(drop, "No blood drop")
	TEST_ASSERT(LAZYLEN(drop.drip_parts) == 1 && (drop.drip_parts[1] in drop.vis_contents), "The second drop is not in vis_contents")
	var/obj/effect/decal/cleanable/blood/drip/part/second = drop.drip_parts[1]
	TEST_ASSERT(second.icon_state != drop.icon_state, "The second drop has the same sprite as the first")

	// tg human body sprites, other species keep the shared icon
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/found_tg_sprite = FALSE
	for(var/image/part in chest.get_limb_icon())
		if(part.icon == 'aquila/icons/mob/human/human_bodyparts_greyscale.dmi')
			found_tg_sprite = TRUE
	TEST_ASSERT(found_tg_sprite, "The human chest does not use the tg body sprite")

	// tg damage overlays: blood-tinted brute and the untinted bruises over it
	chest.receive_damage(brute = chest.max_damage * 0.25) // brute state 1, tg has bruises for it
	patient.update_body_parts(TRUE) // limbs take the species damage overlay type here
	patient.update_damage_overlays()
	var/mutable_appearance/damage_overlay = patient.overlays_standing[DAMAGE_LAYER]
	TEST_ASSERT(damage_overlay?.icon == AQ_DAMAGE_OVERLAY_ICON, "The damage overlay does not use the tg icon")
	TEST_ASSERT(length(damage_overlay.overlays) >= 2, "Brute damage shows [length(damage_overlay?.overlays)] overlays instead of the blood and bruise layers")
	TEST_ASSERT(icon_exists(AQ_DAMAGE_OVERLAY_ICON, "human_chest_[chest.brutestate]0_overlay"), "No bruise state for brute state [chest.brutestate]")

	for(var/turf/used as anything in list(start, middle, ahead, drop_turf))
		for(var/obj/effect/decal/cleanable/blood/stain in used)
			qdel(stain)
		for(var/obj/effect/blood_trace/trace in used)
			qdel(trace)

#undef TEST_ASSERT
