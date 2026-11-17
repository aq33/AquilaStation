// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Czy któraś nakładka na danej warstwie ma ten stan ikony (i opcjonalnie ten plik)
/proc/monke_test_has_overlay(mob/living/carbon/human/H, layer, state, icon_file)
	for(var/mutable_appearance/overlay in H.overlays_standing[layer])
		if(overlay.icon_state == state && (!icon_file || overlay.icon == icon_file))
			return TRUE
	return FALSE

/// Małpolud z Monkestation: części ciała, ogon, skrócona sylwetka, mniej zdrowia, tłumacz, przeskakiwanie i przyjaźń małp
/datum/unit_test/aquila_rasy_monke_simian

/datum/unit_test/aquila_rasy_monke_simian/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/human/simian = allocate(/mob/living/carbon/human, left)
	simian.set_species(/datum/species/simian)
	TEST_ASSERT(issimian(simian), "set_species did not make a simian")
	TEST_ASSERT(istype(simian.get_bodypart(BODY_ZONE_CHEST), /obj/item/bodypart/chest/simian), "A simian has no simian chest")
	TEST_ASSERT(istype(simian.get_bodypart(BODY_ZONE_L_LEG), /obj/item/bodypart/l_leg/simian), "A simian has no simian legs")
	TEST_ASSERT_EQUAL(simian.maxHealth, 85, "A simian does not have 85% health")
	TEST_ASSERT(simian.filter_data && simian.filter_data["Monkey_Torso"] && simian.filter_data["Monkey_Legs"], "A simian is not shortened like a monkey")
	TEST_ASSERT(HAS_TRAIT(simian, TRAIT_VAULTING), "A simian cannot vault")
	TEST_ASSERT(istype(simian.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/simian), "A simian has no simian tongue")
	TEST_ASSERT(length(GLOB.simian_names_male) > 10 && length(GLOB.simian_names_female) > 10 && length(GLOB.simian_last_names) > 10, "Simian names were not loaded")
	var/simian_random_name = simian.dna.species.random_name(MALE, TRUE)
	TEST_ASSERT(length(splittext(simian_random_name, " ")) == 2, "A random simian name [simian_random_name] is not a first and last name")

	simian.update_body()
	TEST_ASSERT(monke_test_has_overlay(simian, BODY_BEHIND_LAYER, "m_tail_monkey_default_BEHIND"), "A simian has no tail behind the body")
	TEST_ASSERT(monke_test_has_overlay(simian, BODY_FRONT_LAYER, "m_tail_monkey_default_FRONT"), "A simian has no tail in front of the body")
	TEST_ASSERT(monke_test_has_overlay(simian, BODY_LAYER, "eyes", 'aquila/icons/mob/species/simian/simian.dmi'), "Simian eyes are drawn from the human face icon")
	simian.dna.features["tail_monkey"] = "None"
	simian.update_body()
	TEST_ASSERT(!monke_test_has_overlay(simian, BODY_BEHIND_LAYER, "m_tail_monkey_default_BEHIND"), "A simian without a tail still draws one")

	// Tłumacz przekłada małpią mowę na Wspólny
	var/obj/item/clothing/mask/translator/translator = allocate(/obj/item/clothing/mask/translator)
	var/list/speech_args = list("uuk uuk", null, list(), TRUE, /datum/language/monkey)
	translator.handle_speech(simian, speech_args)
	TEST_ASSERT_EQUAL(speech_args[5], /datum/language/common, "The translator does not translate to Common")

	// Krzyk i śmiech małpy
	var/datum/emote/living/carbon/human/scream/scream = new
	var/scream_sound = "[scream.get_sound(simian)]"
	TEST_ASSERT(findtext(scream_sound, "monkey"), "A simian scream [scream_sound] is not a monkey screech")
	var/datum/emote/living/laugh/laugh = new
	TEST_ASSERT_EQUAL(laugh.get_sound(simian), 'aquila/sound/voice/simian/monkey_laugh_1.ogg', "A simian does not laugh like a monkey")

	// W biegu przeskakuje przez stół
	var/obj/structure/table/table = allocate(/obj/structure/table, get_step(left, EAST))
	simian.m_intent = MOVE_INTENT_RUN
	table.simian_vault(simian)
	TEST_ASSERT(simian.throwing, "A running simian did not vault over the table")
	simian.throwing?.finalize(FALSE)
	simian.forceMove(left)

	// Agresywna małpa nie wybiera małpoluda na cel, a zwykłego człowieka tak
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, get_step(left, NORTH))
	var/datum/ai_controller/monkey/controller = monkey.ai_controller
	controller.set_blackboard_key(BB_MONKEY_AGGRESSIVE, TRUE)
	var/datum/ai_behavior/monkey_set_combat_target/set_target = GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_set_combat_target)
	set_target.perform(1, controller, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_ENEMIES)
	TEST_ASSERT(isnull(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]), "An aggressive monkey picked a simian as its target")

	// Zmiana rasy z powrotem
	simian.set_species(/datum/species/human)
	TEST_ASSERT(!issimian(simian), "The simian did not turn back into a human")
	TEST_ASSERT_EQUAL(simian.maxHealth, 100, "A former simian did not get full health back")
	TEST_ASSERT(!simian.filter_data || !simian.filter_data["Monkey_Torso"], "A former simian is still shortened")
	TEST_ASSERT(!HAS_TRAIT(simian, TRAIT_VAULTING), "A former simian can still vault")
	set_target.perform(1, controller, BB_MONKEY_CURRENT_ATTACK_TARGET, BB_MONKEY_ENEMIES)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET], simian, "An aggressive monkey does not target a human")

	var/datum/preference/choiced/species_feature/simian_tail/tail_entry = GLOB.preference_entries_by_key["feature_monkey_tail"]
	TEST_ASSERT(istype(tail_entry), "There is no simian tail entry in the preferences window")
	TEST_ASSERT(isicon(tail_entry.icon_for("Monkey")), "The simian tail preview icon is broken")

/// Floranin w świetle zawsze w pełni (fotosynteza w teście nie zależy od oświetlenia mapy)
/datum/species/floran/aquila_test_lit
	id = "aquila_test_floran_lit" // własne id, bo species_list jest po id i nadpisałby florana

/datum/species/floran/aquila_test_lit/get_light_amount(mob/living/carbon/human/H)
	return 0.5

/datum/species/floran/aquila_test_dark
	id = "aquila_test_floran_dark"

/datum/species/floran/aquila_test_dark/get_light_amount(mob/living/carbon/human/H)
	return -0.5

/// Floranin z Monkestation: fotosynteza, syk, liście, kwiaty na głowie, wrażliwość na Plant-B-Gone
/datum/unit_test/aquila_rasy_monke_floran

/datum/unit_test/aquila_rasy_monke_floran/Run()
	var/mob/living/carbon/human/floran = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	floran.set_species(/datum/species/floran)
	TEST_ASSERT(isfloran(floran), "set_species did not make a floran")
	TEST_ASSERT(istype(floran.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/floran), "A floran has no floran head")
	TEST_ASSERT(istype(floran.getorganslot(ORGAN_SLOT_EYES), /obj/item/organ/eyes/floran), "A floran has no floran eyes")
	TEST_ASSERT_EQUAL(floran.dna.features["floran_leaves"], "Furnivour", "A floran did not get the default leaves")

	floran.update_body()
	TEST_ASSERT(monke_test_has_overlay(floran, BODY_ADJ_LAYER, "m_floran_leaves_furnivour_ADJ"), "A floran has no leaves")
	TEST_ASSERT(monke_test_has_overlay(floran, BODY_LAYER, "floraneyes", 'aquila/icons/mob/species/floran/floran.dmi'), "Floran eyes are not drawn")
	floran.dna.features["floran_hair"] = "Rose"
	floran.update_hair()
	TEST_ASSERT(monke_test_has_overlay(floran, HAIR_LAYER, "m_floran_hair_rose_ADJ"), "A floran has no leaves on the head")
	TEST_ASSERT(monke_test_has_overlay(floran, HAIR_LAYER, "m_floran_hair_rose_FRONT"), "A floran has no flowers on the head")

	// Syk o długości z preferencji
	var/obj/item/organ/tongue/floran/tongue = floran.getorganslot(ORGAN_SLOT_TONGUE)
	TEST_ASSERT(istype(tongue), "A floran has no floran tongue")
	floran.dna.features["floran_hiss"] = 4
	var/list/speech_args = list("sos", null, list(), TRUE, /datum/language/common)
	tongue.handle_speech(floran, speech_args)
	TEST_ASSERT_EQUAL(speech_args[SPEECH_MESSAGE], "ssssossss", "The floran hiss does not use the length from the preferences")

	// Fotosynteza leczy tylko w świetle
	floran.set_species(/datum/species/floran/aquila_test_dark)
	floran.adjustBruteLoss(10)
	floran.dna.species.spec_life(floran)
	TEST_ASSERT_EQUAL(floran.getBruteLoss(), 10, "A floran heals in the dark")
	floran.set_species(/datum/species/floran/aquila_test_lit)
	floran.dna.species.spec_life(floran)
	TEST_ASSERT(floran.getBruteLoss() < 10, "A floran does not heal in bright light")

	// Oprysk Plant-B-Gone (5 jednostek) zadaje 40 obrażeń od toksyn
	var/datum/reagent/toxin/plantbgone/plantbgone = new
	plantbgone.reaction_mob(floran, TOUCH, 5)
	TEST_ASSERT_EQUAL(floran.getToxLoss(), 40, "Plant-B-Gone spray does not hurt a floran")
	qdel(plantbgone)

	var/datum/emote/living/carbon/human/scream/scream = new
	var/scream_sound = "[scream.get_sound(floran)]"
	TEST_ASSERT(findtext(scream_sound, "lizard"), "A floran scream [scream_sound] is not a lizard scream")

	floran.set_species(/datum/species/human)
	TEST_ASSERT(!isfloran(floran), "The floran did not turn back into a human")
	floran.update_body()
	TEST_ASSERT(!monke_test_has_overlay(floran, BODY_ADJ_LAYER, "m_floran_leaves_furnivour_ADJ"), "A former floran still has leaves")

	for(var/key in list("feature_floran_leaves", "feature_floran_hair"))
		var/datum/preference/choiced/entry = GLOB.preference_entries_by_key[key]
		TEST_ASSERT(istype(entry), "There is no [key] entry in the preferences window")
		for(var/choice in entry.get_choices())
			TEST_ASSERT(isicon(entry.icon_for(choice)), "The [key] preview icon for [choice] is broken")
	TEST_ASSERT(GLOB.preference_entries_by_key["feature_floran_leaves_color"], "There is no leaves colour entry in the preferences window")
	TEST_ASSERT(GLOB.preference_entries_by_key["feature_floran_hiss"], "There is no hiss length entry in the preferences window")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
