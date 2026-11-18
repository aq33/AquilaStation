// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Czy na danej warstwie jest nakładka o tym stanie (i opcjonalnie pliku) ikony
/proc/aquila_rasy_goon_has_overlay(mob/living/carbon/human/H, layer, state, icon_file)
	var/list/standing = H.overlays_standing[layer]
	if(!islist(standing))
		standing = list(standing)
	for(var/mutable_appearance/overlay in standing)
		if(overlay.icon_state == state && (!icon_file || overlay.icon == icon_file))
			return TRUE
	return FALSE

/// Mops z Goona: części ciała z umaszczeniem, ogon, oczy, głos, podwójne duszenie, czekolada, mowa, węszenie, padanie po sprincie
/datum/unit_test/aquila_rasy_goon_pug

/datum/unit_test/aquila_rasy_goon_pug/Run()
	var/mob/living/carbon/human/dog = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	dog.set_species(/datum/species/pug)
	TEST_ASSERT(ispug(dog), "set_species did not make a pug")
	var/datum/species/pug/pug = dog.dna.species
	TEST_ASSERT(istype(dog.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/pug), "A pug has no pug head")
	TEST_ASSERT(istype(dog.get_bodypart(BODY_ZONE_R_LEG), /obj/item/bodypart/r_leg/pug), "A pug has no pug legs")
	TEST_ASSERT(pug.goon_voice == "pug" || pug.goon_voice == "pugg", "A pug does not bark with a Goon pug voice")
	TEST_ASSERT_EQUAL(dog.get_species_goon_voice(), pug.goon_voice, "The pug voice is not used for speech")

	// Umaszczenie z okna postaci zmienia części ciała i ogon
	for(var/coat in GLOB.pug_coats)
		for(var/part in list("head", "chest", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "tail"))
			TEST_ASSERT(icon_exists(PUG_BODYPARTS_ICON, "pug_[coat]_[part]"), "Missing pug icon state pug_[coat]_[part]")
	dog.dna.features[FEATURE_PUG_COAT] = "black"
	dog.update_body_parts(TRUE)
	dog.update_body()
	var/obj/item/bodypart/chest/chest = dog.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(chest.limb_id, "pug_black", "The pug chest did not take the chosen coat")
	TEST_ASSERT(aquila_rasy_goon_has_overlay(dog, BODY_FRONT_LAYER, "pug_black_tail"), "A pug has no tail")
	TEST_ASSERT(aquila_rasy_goon_has_overlay(dog, BODY_LAYER, "eyes", PUG_BODYPARTS_ICON), "Pug eyes are drawn from the human face icon")
	dog.dna.features[FEATURE_PUG_COAT] = "nonsense"
	dog.update_body_parts(TRUE)
	TEST_ASSERT_EQUAL(chest.limb_id, "pug_fawn", "An unknown coat did not fall back to fawn")
	var/datum/preference/choiced/goon_variant/pug_coat/coat_pref = GLOB.preference_entries_by_key["feature_pug_coat"]
	TEST_ASSERT(istype(coat_pref), "There is no coat entry in the preferences window")
	TEST_ASSERT(isicon(coat_pref.icon_for("chocolate")), "The coat entry has no icon")

	// Duszenie boli podwójnie
	dog.setOxyLoss(0)
	dog.adjustOxyLoss(10)
	TEST_ASSERT_EQUAL(dog.getOxyLoss(), 20, "A pug did not take double suffocation damage")
	dog.setOxyLoss(0)

	// Czekolada truje
	var/datum/reagent/consumable/milk/chocolate_milk/milk = new
	pug.handle_chemicals(milk, dog)
	qdel(milk)
	TEST_ASSERT(pug.is_poisoned(), "Chocolate milk did not poison a pug")
	pug.poisoned_until = 0

	// Mowa i krzyk
	var/obj/item/organ/tongue/pug/tongue = dog.getorganslot(ORGAN_SLOT_TONGUE)
	TEST_ASSERT(istype(tongue), "A pug has no pug tongue")
	var/list/speech_args = list("that was rough", null, list(), TRUE, /datum/language/common)
	tongue.handle_speech(dog, speech_args)
	TEST_ASSERT_EQUAL(speech_args[SPEECH_MESSAGE], "that was ruff", "A pug does not say ruff")
	var/datum/emote/living/carbon/human/scream/scream = new
	TEST_ASSERT(findtext("[scream.get_sound(dog)]", "growl"), "A pug does not growl when screaming")
	TEST_ASSERT_EQUAL(scream.select_message_type(dog, TRUE), "warczy!", "A pug scream is not a growl")

	// Węszenie: zapach z odcisku palca
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/toucher = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	crayon.add_fingerprint(toucher, TRUE)
	var/print = rustg_hash_string(RUSTG_HASH_MD5, toucher.dna.uni_identity)
	TEST_ASSERT(findtext(pug_sleuth_text(crayon), pug_scent(print, 2)), "Sleuthing did not find the scent of whoever touched the crayon")
	TEST_ASSERT(findtext(pug_sleuth_text(dog), "pachnie głównie"), "A pug cannot smell itself")

	// Sprint do upadku
	var/datum/component/carbon_sprint/sprint = dog.GetComponent(/datum/component/carbon_sprint)
	TEST_ASSERT(sprint, "A pug cannot sprint")
	dog.set_resting(FALSE, TRUE)
	dog.stamina.adjust(-(dog.stamina.current - 1), TRUE)
	sprint.commit_step(NORTH, get_turf(dog))
	TEST_ASSERT(dog.resting, "A pug out of stamina did not flop over after sprinting")
	dog.set_resting(FALSE, TRUE)
	dog.stamina.refill()

	// Zmiana rasy tam i z powrotem
	dog.set_species(/datum/species/human)
	TEST_ASSERT(!ispug(dog), "A pug did not turn human")
	TEST_ASSERT(!istype(dog.get_bodypart(BODY_ZONE_CHEST), /obj/item/bodypart/chest/pug), "A former pug kept the pug chest")
	dog.setOxyLoss(0)
	dog.adjustOxyLoss(10)
	TEST_ASSERT_EQUAL(dog.getOxyLoss(), 10, "A human takes pug suffocation damage")
	dog.set_species(/datum/species/pug)
	TEST_ASSERT(ispug(dog), "A human did not turn back into a pug")

/// Żaba z Goona: odmiany skóry, odporności, woda, wchłanianie cieczy, mowa, rechot, lepki język
/datum/unit_test/aquila_rasy_goon_amphibian

/datum/unit_test/aquila_rasy_goon_amphibian/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/mob/living/carbon/human/frog = allocate(/mob/living/carbon/human, T)
	frog.set_species(/datum/species/amphibian)
	TEST_ASSERT(isamphibian(frog), "set_species did not make an amphibian")
	TEST_ASSERT(istype(frog.get_bodypart(BODY_ZONE_L_ARM), /obj/item/bodypart/l_arm/amphibian), "An amphibian has no amphibian arms")
	TEST_ASSERT_EQUAL(frog.get_species_goon_voice(), "amphibian", "An amphibian does not speak with the Goon amphibian voice")
	for(var/skin in GLOB.amphibian_skins)
		for(var/part in list("head", "chest", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg"))
			TEST_ASSERT(icon_exists(AMPHIBIAN_BODYPARTS_ICON, "amphibian_[skin]_[part]"), "Missing amphibian icon state amphibian_[skin]_[part]")
	frog.dna.features[FEATURE_AMPHIBIAN_SKIN] = "gills"
	frog.update_body_parts(TRUE)
	var/obj/item/bodypart/head/head = frog.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT_EQUAL(head.limb_id, "amphibian_gills", "The amphibian head did not take the chosen skin")
	frog.update_body()
	TEST_ASSERT(aquila_rasy_goon_has_overlay(frog, BODY_LAYER, "eyes", AMPHIBIAN_BODYPARTS_ICON), "Amphibian eyes are drawn from the human face icon")

	// Odporności z Goona
	frog.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(frog.getBruteLoss(), 7, "An amphibian does not take 70% brute damage")
	frog.apply_damage(10, TOX)
	TEST_ASSERT_EQUAL(frog.getToxLoss(), 20, "An amphibian does not take double toxin damage")
	frog.fully_heal(FALSE)
	TEST_ASSERT(HAS_TRAIT(frog, TRAIT_AQUATIC), "An amphibian is not aquatic")
	var/datum/component/swimming/amphibian/swim = frog.AddComponent(/datum/component/swimming/amphibian)
	TEST_ASSERT(istype(swim), "An amphibian cannot swim")
	TEST_ASSERT(!swim.is_drowning(frog), "An amphibian drowns in a pool")
	qdel(swim)
	TEST_ASSERT_EQUAL(frog.get_blood_color(), "#50b558", "Amphibian blood is not green")

	// Skóra wchłania ciecz z podłogi
	T.add_liquid(/datum/reagent/water, 100)
	var/datum/species/amphibian/amphibian = frog.dna.species
	for(var/i in 1 to 50)
		amphibian.dermal_absorption(frog)
		if(frog.reagents.has_reagent(/datum/reagent/water))
			break
	TEST_ASSERT(frog.reagents.has_reagent(/datum/reagent/water), "Amphibian skin did not absorb the puddle")
	aquila_liquids_cleanup(T)
	frog.reagents.clear_reagents()

	// Mowa i emotki
	var/said = amphibian_speech("Ser rzeka")
	TEST_ASSERT(findtext(said, "Serr rrzeka"), "An amphibian did not roll its r's: [said]")
	TEST_ASSERT(findtext(amphibian_speech("Rak"), "Rrak"), "A capital R before a lowercase letter is not Rr")
	var/datum/emote/living/carbon/human/scream/scream = new
	TEST_ASSERT(findtext("[scream.get_sound(frog)]", "amphibian/scream"), "An amphibian scream is not a frog scream")
	var/datum/emote/living/carbon/human/fart/fart = new
	TEST_ASSERT(!fart.can_run_emote(frog, TRUE, TRUE), "An amphibian can fart instead of croaking")
	var/datum/emote/living/carbon/human/amphibian_croak/croak = new
	TEST_ASSERT(croak.can_run_emote(frog, TRUE, TRUE), "An amphibian cannot croak")

	// Lepki język: przyciąga przedmiot, połyka owada
	var/datum/action/cooldown/mob_cooldown/sticky_tongue/sticky = locate() in frog.actions
	TEST_ASSERT(sticky, "An amphibian has no sticky tongue")
	var/turf/far = locate(T.x + 3, T.y, T.z)
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, far)
	TEST_ASSERT(sticky.Activate(crayon), "The sticky tongue could not be used")
	TEST_ASSERT(crayon.throwing, "The sticky tongue did not pull the crayon")
	crayon.throwing?.finalize(FALSE)
	var/mob/living/basic/cockroach/bug = allocate(/mob/living/basic/cockroach, far)
	var/nutrition_before = frog.nutrition
	sticky.next_use_time = 0
	sticky.Activate(bug)
	TEST_ASSERT(QDELETED(bug), "The sticky tongue did not swallow the cockroach")
	TEST_ASSERT(frog.nutrition > nutrition_before, "Swallowing a cockroach did not feed the amphibian")

	// Zmiana rasy tam i z powrotem
	frog.set_species(/datum/species/human)
	TEST_ASSERT(!isamphibian(frog), "An amphibian did not turn human")
	TEST_ASSERT(!(locate(/datum/action/cooldown/mob_cooldown/sticky_tongue) in frog.actions), "A former amphibian kept the sticky tongue")
	TEST_ASSERT(!HAS_TRAIT(frog, TRAIT_AQUATIC), "A former amphibian is still aquatic")
	frog.set_species(/datum/species/amphibian)
	TEST_ASSERT(isamphibian(frog), "A human did not turn back into an amphibian")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
