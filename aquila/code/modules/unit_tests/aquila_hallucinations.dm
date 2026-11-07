// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - port BeeStation/BeeStation-Hornet#13095 (hallucination_icons.dm): obrazy halucynacji wskazują istniejące stany ikon
/datum/unit_test/aquila_hallucination_icons

/datum/unit_test/aquila_hallucination_icons/Run()
	for(var/datum/hallucination/nearby_fake_item/hallucination as anything in subtypesof(/datum/hallucination/nearby_fake_item))
		check_icon(hallucination, initial(hallucination.left_hand_file), initial(hallucination.image_icon_state))
		check_icon(hallucination, initial(hallucination.right_hand_file), initial(hallucination.image_icon_state))

	for(var/datum/hallucination/delusion/preset/hallucination as anything in subtypesof(/datum/hallucination/delusion/preset))
		check_icon(hallucination, initial(hallucination.delusion_icon_file), initial(hallucination.delusion_icon_state))

	for(var/datum/hallucination/body/hallucination as anything in subtypesof(/datum/hallucination/body))
		if(initial(hallucination.abstract_hallucination_parent) == hallucination)
			continue
		check_icon(hallucination, initial(hallucination.body_image_file), initial(hallucination.body_image_state))

	var/datum/hallucination/shock/shock_hallucination = /datum/hallucination/shock
	check_icon(shock_hallucination, initial(shock_hallucination.electrocution_icon), initial(shock_hallucination.electrocution_icon_state))

	var/datum/hallucination/fake_flood/flood_hallucination = /datum/hallucination/fake_flood
	check_icon(flood_hallucination, initial(flood_hallucination.image_icon), initial(flood_hallucination.image_state))

	for(var/obj/effect/client_image_holder/hallucination/image_holder as anything in subtypesof(/obj/effect/client_image_holder/hallucination))
		var/icon = initial(image_holder.image_icon)
		var/icon_state = initial(image_holder.image_state)
		if(!icon || !icon_state)
			continue
		if(!icon_exists(icon, icon_state))
			Fail("Hallucination image holder [image_holder] had an invalid / missing icon state ([icon_state]) for the icon [icon].")

/datum/unit_test/aquila_hallucination_icons/proc/check_icon(hallucination, icon, icon_state)
	if(!icon || !icon_state)
		Fail("Hallucination [hallucination] forgot to set its icon file or icon state.")
		return
	if(!icon_exists(icon, icon_state))
		Fail("Hallucination [hallucination] has an invalid icon_state ([icon_state]) for its icon ([icon]).")

/// AQUILA - tgstation/tgstation#89865: losowanie z poziomu nie wychodzi ponad poziom, tryb ścisły tylko z tego poziomu
/datum/unit_test/aquila_hallucination_tiers

/datum/unit_test/aquila_hallucination_tiers/Run()
	for(var/i in 1 to 50)
		var/datum/hallucination/picked = get_random_hallucination(HALLUCINATION_TIER_COMMON)
		TEST_ASSERT_EQUAL(initial(picked.hallucination_tier), HALLUCINATION_TIER_COMMON, "A common-tier roll picked [picked]")
		picked = get_random_hallucination(HALLUCINATION_TIER_RARE)
		TEST_ASSERT(initial(picked.hallucination_tier) <= HALLUCINATION_TIER_RARE, "A rare-tier roll picked [picked] from a higher tier")
		picked = get_random_hallucination(HALLUCINATION_TIER_UNCOMMON, strict = TRUE)
		TEST_ASSERT_EQUAL(initial(picked.hallucination_tier), HALLUCINATION_TIER_UNCOMMON, "A strict uncommon roll picked [picked]")

/// AQUILA - halucynacje jako czasowy efekt statusu: dodawanie, limit, nie skracanie, zdejmowanie
/datum/unit_test/aquila_hallucination_duration

/datum/unit_test/aquila_hallucination_duration/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!dummy.hallucinating(), "A new human is hallucinating")

	dummy.adjust_hallucinations(30 SECONDS)
	TEST_ASSERT(dummy.hallucinating(), "adjust_hallucinations did not apply the status effect")
	TEST_ASSERT_EQUAL(dummy.get_hallucination_duration(), 30 SECONDS, "adjust_hallucinations set the wrong duration")

	dummy.adjust_hallucinations_up_to(60 SECONDS, 40 SECONDS)
	TEST_ASSERT_EQUAL(dummy.get_hallucination_duration(), 40 SECONDS, "adjust_hallucinations_up_to went over its cap")

	dummy.set_hallucinations_if_lower(10 SECONDS)
	TEST_ASSERT_EQUAL(dummy.get_hallucination_duration(), 40 SECONDS, "set_hallucinations_if_lower shortened the effect")

	dummy.adjust_hallucinations(-50 SECONDS)
	TEST_ASSERT(!dummy.hallucinating(), "A negative adjustment below zero did not remove the effect")

	// Mindbreaker przy Zaburzeniach Dysocjacyjnych i inne leki zdejmują efekt w całości
	dummy.set_hallucinations(20 SECONDS)
	dummy.remove_status_effect(/datum/status_effect/hallucination)
	TEST_ASSERT(!dummy.hallucinating(), "remove_status_effect left the hallucination")

/// AQUILA - test dymny: każda halucynacja z losowej puli startuje i sprząta się bez błędów na manekinie
/datum/unit_test/aquila_hallucination_smoke

/datum/unit_test/aquila_hallucination_smoke/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	for(var/tier in GLOB.random_hallucination_weighted_list)
		for(var/hallucination_type in GLOB.random_hallucination_weighted_list[tier])
			var/datum/hallucination/started = dummy.cause_hallucination(hallucination_type, "unit test")
			if(!QDELETED(started))
				qdel(started)
	for(var/datum/hallucination/leftover as anything in GLOB.all_ongoing_hallucinations)
		if(leftover.hallucinator == dummy)
			qdel(leftover)
	TEST_ASSERT(!QDELETED(dummy), "A hallucination deleted its hallucinator")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
