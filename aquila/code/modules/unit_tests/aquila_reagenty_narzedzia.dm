// AQUILA - testy reagentów z grupy narzedzia (raport/reagenty_02_plan_portu.md).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Splashes a reagent on a target from a fresh holder
/datum/unit_test/proc/aq_splash(atom/target, reagent_type, amount)
	var/datum/reagents/splash = new(amount)
	splash.add_reagent(reagent_type, amount)
	splash.reaction(target, TOUCH)
	qdel(splash)

/// AQUILA - every recipe of the group makes its reagent
/datum/unit_test/aquila_reagenty_narzedzia_recipes

/datum/unit_test/aquila_reagenty_narzedzia_recipes/Run()
	var/list/recipes = list(
		/datum/reagent/superglue = list(/datum/reagent/acetone = 1, /datum/reagent/phenol = 1, /datum/reagent/carbon = 1),
		/datum/reagent/silicate = list(/datum/reagent/aluminium = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1),
		/datum/reagent/concrete = list(/datum/reagent/silicon = 2, /datum/reagent/ash = 1, /datum/reagent/water = 1),
		/datum/reagent/matter_deconstructor = list(/datum/reagent/cellulose = 3, /datum/reagent/toxin/acid = 1, /datum/reagent/bluespace = 1),
		/datum/reagent/grassgro = list(/datum/reagent/plantnutriment/eznutriment = 1, /datum/reagent/plantnutriment/robustharvestnutriment = 1, /datum/reagent/water = 1),
		/datum/reagent/genesis = list(/datum/reagent/diethylamine = 10, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/stable_plasma = 1),
		/datum/reagent/silver_nitrate = list(/datum/reagent/silver = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 1),
		/datum/reagent/fingerprint_nanites = list(/datum/reagent/silver_nitrate = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/toxin/mutagen = 1),
		/datum/reagent/holy_salt = list(/datum/reagent/water/holywater = 5, /datum/reagent/consumable/sodiumchloride = 1),
	)
	for(var/result in recipes)
		var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)
		var/list/parts = recipes[result]
		for(var/part in parts)
			beaker.reagents.add_reagent(part, parts[part] * 2)
		TEST_ASSERT(beaker.reagents.has_reagent(result), "Mixing [jointext(parts, ", ")] did not make [result] ([beaker.reagents.log_list()])")

/// AQUILA - superglue sticks an item to the hand and to the floor until acetone or time, and seals a bleeding wound with pain and germs
/datum/unit_test/aquila_reagenty_narzedzia_superglue

/datum/unit_test/aquila_reagenty_narzedzia_superglue/Run()
	var/mob/living/carbon/human/holder = allocate(/mob/living/carbon/human)
	var/obj/item/wrench/held = allocate(/obj/item/wrench)
	holder.put_in_hands(held)
	aq_splash(held, /datum/reagent/superglue, 5)
	TEST_ASSERT(HAS_TRAIT(held, TRAIT_NODROP), "Superglue on a held item did not stick it to the hand")
	TEST_ASSERT(!holder.dropItemToGround(held), "A superglued item was dropped")
	aq_splash(held, /datum/reagent/acetone, 5)
	TEST_ASSERT(!HAS_TRAIT(held, TRAIT_NODROP), "Acetone did not dissolve the glue on a held item")

	var/obj/item/screwdriver/floor_item = allocate(/obj/item/screwdriver)
	aq_splash(floor_item, /datum/reagent/superglue, 5)
	TEST_ASSERT(floor_item.anchored, "Superglue did not stick an item to the floor")
	floor_item.aq_superglue_expire()
	TEST_ASSERT(floor_item.anchored, "The glue let go before its time")
	floor_item.aq_superglue_until = world.time - 1
	floor_item.aq_superglue_expire()
	TEST_ASSERT(!floor_item.anchored, "The glue on the floor never let go")

	// A bleeding arm: glue stops the bleeding, hurts a lot and lets germs in
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.add_bleeding(BLEED_CUT, BODY_ZONE_L_ARM)
	TEST_ASSERT(patient.is_bleeding(BODY_ZONE_L_ARM), "The test arm does not bleed")
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/pain_before = patient.aq_compute_pain()
	aq_splash(patient, /datum/reagent/superglue, 5)
	TEST_ASSERT(!patient.is_bleeding(BODY_ZONE_L_ARM), "Superglue did not stop the bleeding arm")
	TEST_ASSERT(patient.aq_compute_pain() >= pain_before + 40, "A glued wound does not hurt ([pain_before] -> [patient.aq_compute_pain()])")
	TEST_ASSERT(arm.aq_germs >= 20, "The glue let no germs in ([arm.aq_germs])")

/// AQUILA - silicate reinforces a window up to twice its integrity
/datum/unit_test/aquila_reagenty_narzedzia_silicate

/datum/unit_test/aquila_reagenty_narzedzia_silicate/Run()
	var/obj/structure/window/window = allocate(/obj/structure/window)
	var/base = window.max_integrity
	aq_splash(window, /datum/reagent/silicate, 5)
	TEST_ASSERT(window.max_integrity > base, "Silicate did not reinforce the window")
	aq_splash(window, /datum/reagent/silicate, 100)
	TEST_ASSERT(window.max_integrity == initial(window.max_integrity) * 2, "Silicate went past the limit ([window.max_integrity] / [base])")

/// AQUILA - concrete makes a tiled floor concrete and a girder a concrete wall after curing; grass-gro and genesis serum grow plants
/datum/unit_test/aquila_reagenty_narzedzia_terraform

/datum/unit_test/aquila_reagenty_narzedzia_terraform/Run()
	var/turf/floor_turf = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/turf/wall_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/original_floor = floor_turf.type
	var/original_wall_spot = wall_turf.type

	floor_turf = floor_turf.ChangeTurf(/turf/open/floor/plasteel)
	aq_splash(floor_turf, /datum/reagent/concrete, 5)
	floor_turf = locate(floor_turf.x, floor_turf.y, floor_turf.z)
	TEST_ASSERT(istype(floor_turf, /turf/open/floor/aq_concrete), "Concrete did not make a concrete floor ([floor_turf.type])")

	var/obj/structure/girder/girder = new(wall_turf)
	aq_splash(girder, /datum/reagent/concrete, 10)
	TEST_ASSERT(girder.aq_concrete_cure(), "Concrete on a girder did not cure")
	wall_turf = locate(wall_turf.x, wall_turf.y, wall_turf.z)
	TEST_ASSERT(istype(wall_turf, /turf/closed/wall/aq_concrete), "A cured girder is not a concrete wall ([wall_turf.type])")
	wall_turf.ChangeTurf(original_wall_spot)

	aq_splash(floor_turf, /datum/reagent/grassgro, 5)
	floor_turf = locate(floor_turf.x, floor_turf.y, floor_turf.z)
	TEST_ASSERT(istype(floor_turf, /turf/open/floor/grass), "Grass-gro did not grow grass ([floor_turf.type])")

	aq_splash(floor_turf, /datum/reagent/genesis, 5)
	var/obj/structure/flora/plant = locate() in floor_turf
	TEST_ASSERT(plant, "Genesis serum grew nothing on grass")
	qdel(plant)
	floor_turf.ChangeTurf(original_floor)

/// AQUILA - matter deconstructor turns an item into 75% of its sheets
/datum/unit_test/aquila_reagenty_narzedzia_deconstructor

/datum/unit_test/aquila_reagenty_narzedzia_deconstructor/Run()
	var/turf/spot = locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/obj/item/wrench/item = new(spot)
	item.set_custom_materials(list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 4))
	aq_splash(item, /datum/reagent/matter_deconstructor, 5)
	TEST_ASSERT(QDELETED(item), "The deconstructed item is still there")
	var/sheets = 0
	for(var/obj/item/stack/sheet/iron/stack in spot)
		sheets += stack.amount
		qdel(stack)
	TEST_ASSERT(sheets == 3, "4 sheets of iron gave back [sheets], not 3")

/// AQUILA - silver nitrate shows the prints on examine; fingerprint nanites change the prints left behind
/datum/unit_test/aquila_reagenty_narzedzia_fingerprints

/datum/unit_test/aquila_reagenty_narzedzia_fingerprints/Run()
	var/mob/living/carbon/human/toucher = allocate(/mob/living/carbon/human)
	var/obj/item/wrench/item = allocate(/obj/item/wrench)
	item.add_fingerprint(toucher)
	var/real_print = rustg_hash_string(RUSTG_HASH_MD5, toucher.dna.uni_identity)
	TEST_ASSERT(!item.aq_revealed_fingerprints(), "Prints show without silver nitrate")
	aq_splash(item, /datum/reagent/silver_nitrate, 2)
	var/list/shown = item.aq_revealed_fingerprints()
	TEST_ASSERT(shown && shown[real_print], "Silver nitrate did not reveal the print")
	TEST_ASSERT(findtext(jointext(item.examine(toucher), ""), real_print), "The revealed print is not on examine")

	// Random prints
	var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human)
	drinker.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10)
	for(var/i in 1 to 4)
		drinker.reagents.metabolize(drinker, can_overdose = TRUE)
	TEST_ASSERT(drinker.aq_fake_fingerprint, "Fingerprint nanites changed nothing")
	var/obj/item/screwdriver/touched = allocate(/obj/item/screwdriver)
	touched.add_fingerprint(drinker)
	var/list/prints = touched.return_fingerprints()
	TEST_ASSERT(prints[drinker.aq_fake_fingerprint], "The new print is not left on items")
	TEST_ASSERT(!prints[rustg_hash_string(RUSTG_HASH_MD5, drinker.dna.uni_identity)], "The old print is still left on items")
	TEST_ASSERT(drinker.aq_fingerprint() == drinker.aq_fake_fingerprint, "The scanner would read the old print")

	// Prints of the person whose blood is in the mix
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human)
	donor.dna.unique_enzymes = "aq_test_donor_enzymes"
	donor.dna.uni_identity = "aq_test_donor_identity"
	var/mob/living/carbon/human/copycat = allocate(/mob/living/carbon/human)
	copycat.reagents.add_reagent(/datum/reagent/blood, 20, donor.get_blood_data(donor.get_blood_id()))
	copycat.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10)
	for(var/i in 1 to 4)
		copycat.reagents.metabolize(copycat, can_overdose = TRUE)
	TEST_ASSERT(copycat.aq_fake_fingerprint == rustg_hash_string(RUSTG_HASH_MD5, "aq_test_donor_identity"), "Nanites with blood did not copy the donor's prints")

	// Drunk from a cup: the donor is remembered on the way in, before the body soaks up the blood
	var/mob/living/carbon/human/sipper = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/glass/beaker/cup = allocate(/obj/item/reagent_containers/glass/beaker)
	cup.reagents.add_reagent(/datum/reagent/blood, 10, donor.get_blood_data(donor.get_blood_id()))
	cup.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10)
	cup.reagents.trans_to(sipper, 20, method = INGEST)
	var/obj/item/organ/stomach/stomach = sipper.getorganslot(ORGAN_SLOT_STOMACH)
	var/datum/reagent/fingerprint_nanites/swallowed = sipper.reagents.has_reagent(/datum/reagent/fingerprint_nanites) || stomach?.reagents?.has_reagent(/datum/reagent/fingerprint_nanites)
	TEST_ASSERT(swallowed, "The drunk nanites are neither in the blood nor in the stomach")
	TEST_ASSERT(swallowed.donor_print == rustg_hash_string(RUSTG_HASH_MD5, "aq_test_donor_identity"), "Drunk nanites did not remember the donor of the blood in the cup")

/// AQUILA - a holy salt line stops a shadow demon in the dark and a vampire turned to mist
/datum/unit_test/aquila_reagenty_narzedzia_holy_salt

/datum/unit_test/aquila_reagenty_narzedzia_holy_salt/Run()
	var/turf/start = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/turf/salted = get_step(start, EAST)
	var/turf/beyond = get_step(salted, EAST)
	aq_splash(salted, /datum/reagent/holy_salt, 2)
	var/obj/effect/decal/cleanable/food/salt/holy/salt = aq_holy_salt_on(salted)
	TEST_ASSERT(salt, "Holy salt left no line on the floor")

	var/mob/living/carbon/human/crawler = allocate(/mob/living/carbon/human)
	var/obj/effect/dummy/phased_mob/shadow_crawl/shadow = new(start)
	crawler.forceMove(shadow)
	shadow.relaymove(crawler, EAST)
	TEST_ASSERT(shadow.loc == start, "A shadow demon crawled over holy salt")
	shadow.relaymove(crawler, NORTH)
	TEST_ASSERT(shadow.loc != start, "A shadow demon cannot crawl anywhere")
	crawler.forceMove(start)
	qdel(shadow)

	var/datum/action/vampire/targeted/trespass/mist = new
	mist.owner = crawler
	TEST_ASSERT(!mist.check_valid_target(beyond), "A vampire in mist passed over holy salt")
	qdel(salt)
	TEST_ASSERT(mist.check_valid_target(beyond), "A vampire in mist cannot pass a clean floor")
	mist.owner = null
	qdel(mist)

#undef TEST_ASSERT
