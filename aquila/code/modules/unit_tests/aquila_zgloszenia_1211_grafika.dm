// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Depth overlays (stageN_top/stageN_bottom) on an atom, both compiled and still queued in SSoverlays
/proc/aquila_test_depth_overlay_count(atom/target)
	var/list/all_overlays = list()
	for(var/overlay in target.overlays)
		all_overlays += overlay
	if(target.add_overlays)
		all_overlays += target.add_overlays
	. = 0
	for(var/mutable_appearance/overlay as anything in all_overlays)
		if(findtext("[overlay.icon_state]", "stage") == 1)
			.++

/// AQUILA - a pool of blood (80-100 u on one tile, ankle deep) drew the full-tile depth overlays tinted red: a red square.
/// Viscous liquid gets no depth overlays, water still does
/datum/unit_test/aquila_blood_pool_no_depth_overlays

/datum/unit_test/aquila_blood_pool_no_depth_overlays/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	T.pool_liquid(/datum/reagent/blood, 90, T20C, list("blood_DNA" = "AQUILATEST", "blood_type" = "O-"))
	TEST_ASSERT(!QDELETED(T.liquids), "90 u of blood made no puddle")
	TEST_ASSERT(T.liquids.liquid_state == LIQUID_STATE_ANKLES, "Setup: 90 u of blood on one tile is not ankle deep (state [T.liquids.liquid_state])")
	TEST_ASSERT(T.liquids.liquid_group.is_viscous(), "Setup: a pool of blood is not viscous")
	var/blood_overlays = aquila_test_depth_overlay_count(T.liquids)
	TEST_ASSERT(!blood_overlays, "A pool of blood got [blood_overlays] depth overlays (the red square)")
	aquila_liquids_cleanup(T)

	T.add_liquid(/datum/reagent/water, 90)
	TEST_ASSERT(!QDELETED(T.liquids), "90 u of water made no puddle")
	TEST_ASSERT(T.liquids.liquid_state == LIQUID_STATE_ANKLES, "Setup: 90 u of water on one tile is not ankle deep (state [T.liquids.liquid_state])")
	TEST_ASSERT(aquila_test_depth_overlay_count(T.liquids), "Ankle deep water lost its depth overlays")
	aquila_liquids_cleanup(T)

/// AQUILA - every brute/burn hit sets damageoverlaytemp = 20, which alone pulsed the red pain vignette after a 1 point scratch
/datum/unit_test/aquila_pain_vignette_small_hit

/datum/unit_test/aquila_pain_vignette_small_hit/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.aq_adrenal_reserve = 0
	patient.apply_damage(1, BRUTE, BODY_ZONE_CHEST)
	TEST_ASSERT(patient.damageoverlaytemp >= 20, "Setup: a brute hit did not set damageoverlaytemp ([patient.damageoverlaytemp])")
	patient.aq_handle_pain()
	TEST_ASSERT(patient.aq_pain < 10, "Setup: 1 brute is felt as [patient.aq_pain] pain")
	TEST_ASSERT(patient.aq_pain_vignette_level() < 10, "1 brute without pain gives a vignette of [patient.aq_pain_vignette_level()]")

	// The fresh hit still adds to a pain that is already felt
	patient.aq_pain = 30
	TEST_ASSERT(patient.aq_pain_vignette_level() >= 50, "A hit on top of felt pain gives only [patient.aq_pain_vignette_level()]")

/// AQUILA - the gun cursor follows the mouse with hysteresis: a size one step off is kept, two steps change it
/datum/unit_test/aquila_gun_cursor_hysteresis

/datum/unit_test/aquila_gun_cursor_hysteresis/Run()
	TEST_ASSERT(aq_gun_cursor_hysteresis(null, 12) == 12, "No shown cursor, but the size was not taken")
	TEST_ASSERT(aq_gun_cursor_hysteresis(8, 12) == 8, "A one step change flipped the cursor size")
	TEST_ASSERT(aq_gun_cursor_hysteresis(8, 4) == 8, "A one step change down flipped the cursor size")
	TEST_ASSERT(aq_gun_cursor_hysteresis(8, 16) == 16, "A two step change kept the old cursor size")
	TEST_ASSERT(aq_gun_cursor_hysteresis(8, 0) == 0, "A two step change down kept the old cursor size")
	var/list/sizes = aq_gun_cursor_sizes()
	TEST_ASSERT(length(sizes) == 11 && sizes[1] == 0 && sizes[length(sizes)] == 40, "Preloaded cursor sizes are [jointext(sizes, ", ")]")

#undef TEST_ASSERT
