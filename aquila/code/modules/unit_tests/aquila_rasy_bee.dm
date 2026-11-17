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

/// Sprite'y cech i części ciała psyfozy i diony istnieją, a podglądy w oknie postaci da się wygenerować
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
	for(var/species_id in list(SPECIES_PSYPHOZA, SPECIES_DIONA))
		var/icon_file = species_id == SPECIES_PSYPHOZA ? 'aquila/icons/mob/species/psyphoza/bodyparts.dmi' : 'aquila/icons/mob/species/diona/bodyparts.dmi'
		for(var/zone in list("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "l_hand", "r_hand"))
			TEST_ASSERT(icon_exists(icon_file, "[species_id]_[zone]"), "Missing limb sprite [species_id]_[zone]")
	for(var/db_key in list("feature_psyphoza_cap", "feature_diona_leaves", "feature_diona_eyes", "feature_diona_pbody"))
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

/// Diona: wyrostki się rysują, fotosynteza i promieniowanie leczą, kończyna i śmierć zamieniają się w nimfy, nimfa dorasta w dionę
/datum/unit_test/aquila_rasy_bee_diona

/datum/unit_test/aquila_rasy_bee_diona/Run()
	var/turf/T = run_loc_floor_bottom_left
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, T)
	H.set_species(/datum/species/diona)
	TEST_ASSERT(isdiona(H), "set_species did not make a diona")
	TEST_ASSERT_EQUAL(H.dna.features[FEATURE_DIONA_LEAVES], "Brak", "A diona without saved growths did not get the defaults")
	H.dna.features[FEATURE_DIONA_LEAVES] = "Liście"
	H.dna.features[FEATURE_DIONA_EYES] = "Oczy owada"
	H.update_body()
	TEST_ASSERT(aquila_rasy_bee_has_adj_overlay(H, "m_diona_leaves_chest_ADJ"), "Diona leaves are not drawn")
	TEST_ASSERT(aquila_rasy_bee_has_adj_overlay(H, "m_diona_eyes_bugeyes_head_ADJ"), "Diona eye growths are not drawn")
	var/datum/species/diona/diona = H.dna.species
	TEST_ASSERT(diona.split_ability in H.actions, "A diona has no split action")
	TEST_ASSERT(diona.partition_ability in H.actions, "A diona has no partition action")

	// Fotosynteza: kafelek bez obiektu oświetlenia liczy się jako w pełni oświetlony
	var/old_lighting = T.lighting_object
	T.lighting_object = null
	H.set_nutrition(NUTRITION_LEVEL_HUNGRY)
	for(var/i in 1 to 7)
		diona.spec_life(H)
	T.lighting_object = old_lighting
	TEST_ASSERT(H.nutrition > NUTRITION_LEVEL_HUNGRY, "A diona in the light did not get fed")
	var/datum/status_effect/diona_planthealing/photosynthesis = H.has_status_effect(/datum/status_effect/diona_planthealing)
	TEST_ASSERT(photosynthesis, "A diona in the light did not start photosynthesis")
	H.adjustBruteLoss(10)
	var/brute_before = H.getBruteLoss()
	photosynthesis.tick()
	TEST_ASSERT(H.getBruteLoss() < brute_before, "Photosynthesis did not heal")

	// Promieniowanie karmi i leczy, bez wymiotów i powalenia
	brute_before = H.getBruteLoss()
	var/nutrition_before = H.nutrition
	diona.handle_radiation(H, 100, 1)
	TEST_ASSERT(H.getBruteLoss() < brute_before, "Radiation did not heal a diona")
	TEST_ASSERT(H.nutrition > nutrition_before, "Radiation did not feed a diona")
	TEST_ASSERT(!H.IsParalyzed(), "Radiation knocked a diona down")

	var/datum/emote/living/carbon/human/scream/scream = new
	TEST_ASSERT_EQUAL(scream.get_sound(H), 'aquila/sound/emotes/diona/scream.ogg', "A diona does not scream like a diona")
	qdel(scream)

	// Odcięta kończyna odchodzi jako nimfa
	var/obj/item/bodypart/arm = H.get_bodypart(BODY_ZONE_L_ARM)
	arm.drop_limb()
	var/list/nymphs = list()
	for(var/mob/living/simple_animal/hostile/retaliate/nymph/nymph in T)
		nymphs += nymph
	TEST_ASSERT_EQUAL(length(nymphs), 1, "A cut off diona arm did not become a nymph")
	QDEL_LIST(nymphs)

	// Zmiana rasy w obie strony
	H.set_species(/datum/species/human)
	TEST_ASSERT(!(locate(/datum/action/diona_split) in H.actions), "The split action stayed after becoming human")
	TEST_ASSERT(!aquila_rasy_bee_has_adj_overlay(H, "m_diona_leaves_chest_ADJ"), "Diona leaves are still drawn on a human")
	H.set_species(/datum/species/diona)
	diona = H.dna.species
	H.regenerate_limbs()

	// Rozpad: nimfa z głowy, tułowia i każdej kończyny, gestalt znika
	var/mob/living/simple_animal/hostile/retaliate/nymph/player_nymph = diona.diona_split(H)
	TEST_ASSERT(isnymph(player_nymph), "The split did not return the player nymph")
	TEST_ASSERT(QDELETED(H), "The diona body stayed after splitting")
	for(var/mob/living/simple_animal/hostile/retaliate/nymph/nymph in T)
		nymphs += nymph
	TEST_ASSERT_EQUAL(length(nymphs), 6, "A split diona did not become six nymphs (head, chest and four limbs)")
	nymphs -= player_nymph
	QDEL_LIST(nymphs)

	// Dorosła nimfa wyrasta w dionę z samą głową i tułowiem
	player_nymph.amount_grown = player_nymph.max_grown
	var/mob/living/carbon/human/adult = player_nymph.evolve()
	TEST_ASSERT(isdiona(adult), "An evolved nymph did not become a diona")
	TEST_ASSERT_EQUAL(length(adult.bodyparts), 2, "A freshly evolved diona should only have a head and a chest")
	TEST_ASSERT(QDELETED(player_nymph), "The nymph stayed after evolving")
	qdel(adult)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
