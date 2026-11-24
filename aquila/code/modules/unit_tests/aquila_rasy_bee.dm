// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Czy na warstwie BODY_ADJ_LAYER jest nakładka o tym stanie ikony
/proc/aquila_rasy_bee_has_adj_overlay(mob/living/carbon/human/H, state)
	var/list/standing = H.overlays_standing[BODY_ADJ_LAYER]
	if(!islist(standing))
		standing = list(standing)
	for(var/mutable_appearance/overlay in standing)
		if(overlay.icon_state == state)
			return TRUE
	return FALSE

/// Sprite'y cech i części ciała psyfozy istnieją, a podglądy w oknie postaci da się wygenerować
/datum/unit_test/aquila_rasy_bee_sprites

/datum/unit_test/aquila_rasy_bee_sprites/Run()
	for(var/key in GLOB.bee_species_feature_lists)
		var/list/accessories = GLOB.vars[GLOB.bee_species_feature_lists[key]]
		TEST_ASSERT(length(accessories) >= 2, "Feature [key] has no choices")
		for(var/name in accessories)
			var/datum/sprite_accessory/accessory = accessories[name]
			if(accessory.icon_state == "none")
				continue
			TEST_ASSERT(icon_exists(accessory.icon, "m_[key]_[accessory.icon_state]_ADJ"), "Missing sprite m_[key]_[accessory.icon_state]_ADJ for [name]")
	for(var/zone in list("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "l_hand", "r_hand"))
		TEST_ASSERT(icon_exists('aquila/icons/mob/species/psyphoza/bodyparts.dmi', "[SPECIES_PSYPHOZA]_[zone]"), "Missing limb sprite [SPECIES_PSYPHOZA]_[zone]")
	for(var/db_key in list("feature_psyphoza_cap"))
		var/datum/preference/choiced/entry = GLOB.preference_entries_by_key[db_key]
		TEST_ASSERT(istype(entry), "No preference entry [db_key]")
		for(var/value in entry.get_choices())
			TEST_ASSERT(isicon(entry.icon_for(value)), "No preview icon for [db_key] = [value]")

/// Psyfoza: kapelusz się rysuje, oczy dają ślepotę z nakładką psychiczną i zmysł psychiczny, zmiana rasy w obie strony sprząta
/datum/unit_test/aquila_rasy_bee_psyphoza

/datum/unit_test/aquila_rasy_bee_psyphoza/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/psyphoza)
	TEST_ASSERT(ispsyphoza(H), "set_species did not make a psyphoza")
	TEST_ASSERT_EQUAL(H.dna.features[FEATURE_PSYPHOZA_CAP], "Portobello", "A psyphoza without a saved cap did not get the default one")
	H.dna.features[FEATURE_PSYPHOZA_CAP] = "Smardz"
	H.update_body()
	TEST_ASSERT(aquila_rasy_bee_has_adj_overlay(H, "m_psyphoza_cap_crown_ADJ"), "The psyphoza cap is not drawn")

	var/obj/item/organ/eyes/psyphoza/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	TEST_ASSERT(istype(eyes), "A psyphoza has no psyphoza eyes")
	TEST_ASSERT(HAS_TRAIT_FROM(H, TRAIT_BLIND, PSYPHOZA_BLINDNESS_SOURCE), "Psyphoza eyes did not blind their owner")
	TEST_ASSERT(istype(H.screens["blind"], /atom/movable/screen/fullscreen/blind/psychic), "The blindness overlay is not the psychic one")
	TEST_ASSERT(istype(H.screens["psychic_highlight"], /atom/movable/screen/fullscreen/psychic_highlight), "There is no psychic highlight overlay")
	var/datum/action/cooldown/psyphoza_sense/sense = locate() in H.actions
	TEST_ASSERT(sense, "A psyphoza has no psychic sense action")
	TEST_ASSERT(eyes.psychic_pulse(), "The psychic pulse failed without a helmet")

	// Pełne leczenie zdejmuje ślepotę, a oczy zakładają ją z powrotem
	H.fully_heal()
	eyes.on_life()
	TEST_ASSERT(HAS_TRAIT_FROM(H, TRAIT_BLIND, PSYPHOZA_BLINDNESS_SOURCE), "Psyphoza eyes did not restore the blindness after a full heal")

	// Narkotyki uzupełniają krew
	H.blood_volume = 300
	H.reagents.add_reagent(/datum/reagent/drug/space_drugs, 5)
	var/datum/reagent/drug = H.reagents.get_reagent(/datum/reagent/drug/space_drugs)
	H.dna.species.handle_chemicals(drug, H)
	TEST_ASSERT(H.blood_volume > 300, "A drug did not refill psyphoza blood")

	var/datum/emote/living/carbon/human/scream/scream = new
	var/scream_sound = scream.get_sound(H)
	TEST_ASSERT(scream_sound == 'aquila/sound/voice/psyphoza/psyphoza_scream_1.ogg' || scream_sound == 'aquila/sound/voice/psyphoza/psyphoza_scream_2.ogg', "A psyphoza scream [scream_sound] is not the psyphoza one")
	qdel(scream)

	H.set_species(/datum/species/human)
	TEST_ASSERT(!HAS_TRAIT_FROM(H, TRAIT_BLIND, PSYPHOZA_BLINDNESS_SOURCE), "The psyphoza blindness stayed after becoming human")
	TEST_ASSERT(!istype(H.screens["blind"], /atom/movable/screen/fullscreen/blind/psychic), "The psychic overlay stayed after becoming human")
	TEST_ASSERT(!H.screens["psychic_highlight"], "The psychic highlight stayed after becoming human")
	TEST_ASSERT(!(locate(/datum/action/cooldown/psyphoza_sense) in H.actions), "The psychic sense action stayed after becoming human")
	TEST_ASSERT(!aquila_rasy_bee_has_adj_overlay(H, "m_psyphoza_cap_crown_ADJ"), "The cap is still drawn on a human")
	H.set_species(/datum/species/psyphoza)
	TEST_ASSERT(HAS_TRAIT_FROM(H, TRAIT_BLIND, PSYPHOZA_BLINDNESS_SOURCE), "A psyphoza is not blind after changing species back")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
