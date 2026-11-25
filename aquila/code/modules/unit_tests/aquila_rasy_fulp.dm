// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Mięsoczłowiek z Fulpstation: wygląd, zmiana rasy w obie strony, uraz Fobetora, krwawienie sokiem per kończyna,
/// odrywanie i przyczepianie kończyn z mięsa, chłodne ciało, szarfa zamiast kombinezonu
/datum/unit_test/aquila_rasy_fulp_beefman

/datum/unit_test/aquila_rasy_fulp_beefman/Run()
	var/mob/living/carbon/human/beef = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	beef.dna.features[FEATURE_BEEF_COLOR] = "Dobrze wysmażony"
	beef.dna.features[FEATURE_BEEF_EYES] = "Kapary"
	beef.dna.features[FEATURE_BEEF_MOUTH] = "Grymas"
	beef.set_species(/datum/species/beefman)
	TEST_ASSERT(isbeefman(beef), "set_species did not make a beefman")
	var/datum/species/beefman/species = beef.dna.species
	TEST_ASSERT_EQUAL(species.fixed_mut_color, GLOB.beefman_colors["Dobrze wysmażony"], "The meat colour does not follow the chosen doneness")

	// Wygląd: kończyny z naszego pliku i twarz z przypraw
	var/obj/item/bodypart/head/head = beef.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT(istype(head, /obj/item/bodypart/head/beef), "The head is not a beefman head")
	TEST_ASSERT(icon_exists(BEEFMAN_BODYPARTS_ICON, "[head.limb_id]_[head.body_zone]"), "There is no icon for the beefman head")
	TEST_ASSERT(icon_exists(BEEFMAN_BODYPARTS_ICON, "beefman_l_hand"), "There is no icon for the beefman hand")
	beef.update_body()
	var/list/face_states = list()
	for(var/mutable_appearance/overlay as anything in beef.overlays_standing[BODY_LAYER])
		face_states += overlay.icon_state
	TEST_ASSERT("capers_head" in face_states, "The caper eyes are not drawn ([json_encode(face_states)])")
	TEST_ASSERT("frown_head" in face_states, "The frown is not drawn ([json_encode(face_states)])")

	// Uraz mózgu i język
	TEST_ASSERT(beef.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor), "A beefman has no Phobetor trauma")
	TEST_ASSERT(beef.has_language(/datum/language/space_russian), "A beefman does not know Space Russian")
	TEST_ASSERT(istype(beef.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/beefman), "A beefman has no meaty tongue")

	// Zmiana rasy tam i z powrotem
	beef.set_species(/datum/species/human)
	TEST_ASSERT(!beef.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor), "The Phobetor trauma stayed after becoming a human")
	TEST_ASSERT(!istype(beef.get_bodypart(BODY_ZONE_L_ARM), /obj/item/bodypart/l_arm/beef), "A human kept a beefman arm")
	beef.set_species(/datum/species/beefman)
	species = beef.dna.species
	TEST_ASSERT(istype(beef.get_bodypart(BODY_ZONE_L_ARM), /obj/item/bodypart/l_arm/beef), "The beefman arm did not come back")
	TEST_ASSERT(beef.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor), "The Phobetor trauma did not come back")

	// Ciało wraca do 20°C
	beef.bodytemperature = T20C - 30
	TEST_ASSERT(species.natural_bodytemperature_stabilization(beef) > 0, "A cold beefman does not warm up")
	beef.bodytemperature = BODYTEMP_NORMAL
	TEST_ASSERT(species.natural_bodytemperature_stabilization(beef) < 0, "A beefman at 37°C does not cool down to 20°C")

	// Sok cieknie w cieple z każdej kończyny i staje w chłodzie
	beef.bodytemperature = BEEFMAN_BLEEDOUT_LEVEL + 60
	species.handle_juices(beef)
	TEST_ASSERT(beef.aq_get_limb_bleed(BODY_ZONE_L_ARM) > 0, "A hot beefman does not leak juice from the arm ([json_encode(beef.aq_get_limb_bleeds())])")
	TEST_ASSERT(beef.aq_get_limb_bleed(BODY_ZONE_R_LEG) > 0, "A hot beefman does not leak juice from the leg")
	var/arm_juice = beef.aq_get_limb_bleed(BODY_ZONE_L_ARM)
	species.handle_juices(beef)
	TEST_ASSERT(abs(beef.aq_get_limb_bleed(BODY_ZONE_L_ARM) - arm_juice) < 0.01, "The juice keeps stacking up every tick")
	// Rana na ręce zostaje, gdy sok staje
	beef.add_bleeding(BLEED_SURFACE, BODY_ZONE_R_ARM)
	var/wounded_arm = beef.aq_get_limb_bleed(BODY_ZONE_R_ARM)
	beef.bodytemperature = T20C
	species.handle_juices(beef)
	TEST_ASSERT(!beef.aq_get_limb_bleed(BODY_ZONE_L_ARM), "The juice did not stop in the cold")
	TEST_ASSERT(abs(beef.aq_get_limb_bleed(BODY_ZONE_R_ARM) - (wounded_arm - arm_juice)) < 0.01, "Stopping the juice took more than the juice from a real wound ([beef.aq_get_limb_bleed(BODY_ZONE_R_ARM)] of [wounded_arm])")
	TEST_ASSERT(beef.aq_get_limb_bleed(BODY_ZONE_R_ARM) > 0, "Stopping the juice closed a real wound")
	beef.cauterise_wounds()

	// Opatrzona kończyna soku nie puszcza
	beef.bodytemperature = BEEFMAN_BLEEDOUT_LEVEL + 60
	species.handle_juices(beef)
	beef.suppress_bloodloss(INFINITY, BODY_ZONE_L_LEG)
	species.handle_juices(beef)
	TEST_ASSERT(!beef.aq_get_limb_bleed(BODY_ZONE_L_LEG), "A bandaged leg leaks juice again")
	beef.bodytemperature = T20C
	species.handle_juices(beef)
	beef.cauterise_wounds()
	beef.remove_status_effect(STATUS_EFFECT_BLEED)

	// Oderwanie kończyny daje płat mięsa, mięso w kikucie wyrasta w nową kończynę
	var/obj/item/food/meat/slab/meat = species.tear_off_now(beef, BODY_ZONE_L_ARM)
	TEST_ASSERT(istype(meat), "Tearing off the arm did not give a slab of meat")
	TEST_ASSERT(isnull(beef.get_bodypart(BODY_ZONE_L_ARM)), "The arm is still attached after tearing it off")
	TEST_ASSERT(!beef.is_bleeding(BODY_ZONE_L_ARM), "Tearing off your own arm opened a bleeding stump")
	var/obj/item/bodypart/new_arm = species.attach_meat(beef, meat, BODY_ZONE_L_ARM)
	TEST_ASSERT(istype(new_arm, /obj/item/bodypart/l_arm/beef), "The meat did not grow into a beefman arm")
	TEST_ASSERT(beef.get_bodypart(BODY_ZONE_L_ARM) == new_arm, "The new arm is not attached")
	TEST_ASSERT(QDELETED(meat), "The meat stayed after growing into the arm")
	TEST_ASSERT(!new_arm.brute_dam, "An untouched slab gave a damaged arm")

	// Nadgryzione mięso daje uszkodzoną kończynę
	var/obj/item/food/meat/slab/eaten = species.tear_off_now(beef, BODY_ZONE_R_LEG)
	eaten.reagents.remove_all(eaten.reagents.total_volume / 2)
	var/obj/item/bodypart/new_leg = species.attach_meat(beef, eaten, BODY_ZONE_R_LEG)
	TEST_ASSERT(new_leg?.brute_dam > 0, "Half-eaten meat gave an undamaged leg")

	// Język: oderwany i odrośnięty
	var/obj/item/food/meat/slab/tongue_meat = species.tear_off_now(beef, BODY_ZONE_PRECISE_MOUTH)
	TEST_ASSERT(istype(tongue_meat) && !beef.getorganslot(ORGAN_SLOT_TONGUE), "Tearing off the tongue failed")
	TEST_ASSERT(istype(species.attach_meat(beef, tongue_meat, BODY_ZONE_PRECISE_MOUTH), /obj/item/organ/tongue/beefman), "The meat did not grow into a tongue")

	// Odcięta noga spada jako mięso, a kikut krwawi jak u każdego (medycyna 4)
	var/obj/item/bodypart/leg = beef.get_bodypart(BODY_ZONE_L_LEG)
	leg.dismember()
	TEST_ASSERT(QDELETED(leg), "A cut off beefman leg stayed a leg")
	TEST_ASSERT(locate(/obj/item/food/meat/slab) in range(5, beef), "A cut off beefman leg left no meat")
	TEST_ASSERT(beef.is_bleeding(BODY_ZONE_L_LEG), "The stump of a cut off leg does not bleed")
	beef.cauterise_wounds()
	beef.regenerate_limbs()

	// Rozerwane ciało: ręce i nogi rozlatują się jako mięso, nie jako kończyny
	var/mob/living/carbon/human/gibbed = allocate(/mob/living/carbon/human/species/beefman, run_loc_floor_top_right)
	var/meat_before = 0 // mięso z odciętej wcześniej nogi leży w tym samym pokoju
	for(var/obj/item/food/meat/slab/slab in range(5, run_loc_floor_top_right))
		meat_before++
	gibbed.spread_bodyparts()
	var/meat_after = 0
	for(var/obj/item/food/meat/slab/slab in range(5, run_loc_floor_top_right))
		meat_after++
	TEST_ASSERT(!(locate(/obj/item/bodypart/l_arm/beef) in range(5, run_loc_floor_top_right)), "A gibbed beefman dropped an arm instead of meat")
	TEST_ASSERT(meat_after > meat_before, "A gibbed beefman dropped no meat")

	// Szarfa zamiast kombinezonu, z pancerzem kombinezonu
	var/obj/item/clothing/under/rank/security/officer/uniform = new(beef)
	beef.equip_to_slot_or_del(uniform, ITEM_SLOT_ICLOTHING)
	var/datum/armor/uniform_armor = uniform.armor
	var/datum/job/officer = SSjob.GetJob(JOB_NAME_SECURITYOFFICER)
	species.after_equip_job(officer, beef)
	TEST_ASSERT(istype(beef.w_uniform, beefman_sash_for_job(officer?.title)), "A beefman did not get the department sash ([beef.w_uniform?.type])")
	TEST_ASSERT(beef.w_uniform.armor == uniform_armor, "The sash did not keep the uniform armour")
	TEST_ASSERT_EQUAL(beefman_sash_for_job(JOB_NAME_SECURITYOFFICER), /obj/item/clothing/under/bodysash/security, "A military police officer does not get the security sash")

	// Okno postaci: trzy cechy dla mięsoczłowieka, żadnej dla człowieka
	var/datum/preferences/prefs = new(null)
	prefs.active_character.pref_species = new /datum/species/beefman
	for(var/preference_type in list(/datum/preference/choiced/beefman_color, /datum/preference/choiced/beefman_eyes, /datum/preference/choiced/beefman_mouth))
		var/datum/preference/choiced/entry = GLOB.preference_entries[preference_type]
		TEST_ASSERT(entry.is_accessible(prefs), "[preference_type] is hidden for a beefman")
		TEST_ASSERT(isicon(entry.icon_for(entry.get_choices()[1])), "[preference_type] has no icon")
	prefs.active_character.pref_species = new /datum/species/human
	TEST_ASSERT(!GLOB.preference_entries[/datum/preference/choiced/beefman_eyes].is_accessible(prefs), "A human can pick beefman eyes")

/// Rozdarcia Fobetora: para rozdarć powstaje przy mięsoczłowieku i znika razem z urazem
/datum/unit_test/aquila_rasy_fulp_phobetor

/datum/unit_test/aquila_rasy_fulp_phobetor/Run()
	var/mob/living/carbon/human/beef = allocate(/mob/living/carbon/human/species/beefman, run_loc_floor_bottom_left)
	var/datum/brain_trauma/special/bluespace_prophet/phobetor/trauma = beef.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor)
	TEST_ASSERT(istype(trauma), "A spawned beefman has no Phobetor trauma")
	var/obj/effect/hallucination/simple/phobetor/first = new(run_loc_floor_bottom_left, beef)
	var/obj/effect/hallucination/simple/phobetor/second = new(run_loc_floor_top_right, beef)
	first.link_with(second, beef)
	second.link_with(first, beef)
	trauma.created_firsts += first
	trauma.burn_out(0)
	TEST_ASSERT(!first.tear_active && !second.tear_active, "A burnt out trauma left its tears active")
	trauma.restore()
	TEST_ASSERT(first.tear_active && second.tear_active, "Restoring did not light the tears again")
	// Przejście: nikt nie patrzy (brak umysłów), więc mięsoczłowiek ląduje po drugiej stronie
	first.attack_hand(beef)
	TEST_ASSERT_EQUAL(get_turf(beef), get_turf(second), "Walking into the tear did not move the beefman")
	beef.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	TEST_ASSERT(QDELETED(first) && QDELETED(second), "The tears stayed after the trauma was cured")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
