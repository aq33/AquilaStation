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
	/// Changed turfs -> their original type, put back in Destroy() even when an assertion stops Run() early
	var/list/original_turfs = list()
	/// Changed turfs -> their original baseturfs (PlaceOnTop() stacks the floor under the wall)
	var/list/original_baseturfs = list()

/datum/unit_test/aquila_reagenty_narzedzia_terraform/Destroy()
	for(var/turf/changed as anything in original_turfs)
		var/list/original_base = original_baseturfs[changed]
		changed.ChangeTurf(original_turfs[changed], islist(original_base) ? original_base.Copy() : original_base, CHANGETURF_FORCEOP) // FORCEOP: the same type would be a no-op that keeps the stacked baseturfs
	original_turfs = null
	original_baseturfs = null
	return ..()

/datum/unit_test/aquila_reagenty_narzedzia_terraform/proc/remember_turf(turf/T)
	original_turfs[T] = T.type
	original_baseturfs[T] = islist(T.baseturfs) ? T.baseturfs.Copy() : T.baseturfs

/datum/unit_test/aquila_reagenty_narzedzia_terraform/Run()
	var/turf/floor_turf = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/turf/wall_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	remember_turf(floor_turf)
	remember_turf(wall_turf)

	floor_turf = floor_turf.ChangeTurf(/turf/open/floor/plasteel)
	aq_splash(floor_turf, /datum/reagent/concrete, 5)
	floor_turf = locate(floor_turf.x, floor_turf.y, floor_turf.z)
	TEST_ASSERT(istype(floor_turf, /turf/open/floor/aq_concrete), "Concrete did not make a concrete floor ([floor_turf.type])")

	var/obj/structure/girder/girder = new(wall_turf)
	aq_splash(girder, /datum/reagent/concrete, 10)
	TEST_ASSERT(girder.aq_concrete_cure(), "Concrete on a girder did not cure")
	wall_turf = locate(wall_turf.x, wall_turf.y, wall_turf.z)
	TEST_ASSERT(istype(wall_turf, /turf/closed/wall/aq_concrete), "A cured girder is not a concrete wall ([wall_turf.type])")

	aq_splash(floor_turf, /datum/reagent/grassgro, 5)
	floor_turf = locate(floor_turf.x, floor_turf.y, floor_turf.z)
	TEST_ASSERT(istype(floor_turf, /turf/open/floor/grass), "Grass-gro did not grow grass ([floor_turf.type])")

	aq_splash(floor_turf, /datum/reagent/genesis, 5)
	var/obj/structure/flora/plant = locate() in floor_turf
	TEST_ASSERT(plant, "Genesis serum grew nothing on grass")
	qdel(plant)

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

	// Too little material for one sheet: the item stays whole
	var/obj/item/wrench/small = new(spot)
	small.set_custom_materials(list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT / 2))
	aq_splash(small, /datum/reagent/matter_deconstructor, 5)
	TEST_ASSERT(!QDELETED(small), "An item worth less than a sheet was destroyed for nothing")
	qdel(small)

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

	// An item touched before the nanites keeps the old trace and gets the new print on the next touch
	var/mob/living/carbon/human/regular = allocate(/mob/living/carbon/human)
	var/obj/item/crowbar/old_tool = allocate(/obj/item/crowbar)
	old_tool.add_fingerprint(regular)
	var/regular_real = rustg_hash_string(RUSTG_HASH_MD5, regular.dna.uni_identity)
	regular.aq_rewrite_fingerprints()
	old_tool.add_fingerprint(regular)
	var/list/old_tool_prints = old_tool.return_fingerprints()
	TEST_ASSERT(old_tool_prints[regular.aq_fake_fingerprint], "A second touch after the nanites left no new print")
	TEST_ASSERT(old_tool_prints[regular_real], "The trace from before the nanites was wiped")

	// Prints of the person whose blood is in the mix
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human)
	donor.dna.unique_enzymes = "aq_test_donor_enzymes"
	donor.dna.uni_identity = "aq_test_donor_identity"
	var/mob/living/carbon/human/copycat = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/glass/beaker/syringe_mix = allocate(/obj/item/reagent_containers/glass/beaker)
	syringe_mix.reagents.add_reagent(/datum/reagent/blood, 20, donor.get_blood_data(donor.get_blood_id()))
	syringe_mix.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10)
	syringe_mix.reagents.trans_to(copycat, 30)
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
	TEST_ASSERT(swallowed.aq_donor_print() == rustg_hash_string(RUSTG_HASH_MD5, "aq_test_donor_identity"), "Drunk nanites did not remember the donor of the blood in the cup")

	// Blood of someone else already in the stomach does not take over the donor of the drunk mix
	var/mob/living/carbon/human/other_donor = allocate(/mob/living/carbon/human)
	other_donor.dna.unique_enzymes = "aq_test_other_enzymes"
	other_donor.dna.uni_identity = "aq_test_other_identity"
	var/mob/living/carbon/human/second_sipper = allocate(/mob/living/carbon/human)
	var/obj/item/organ/stomach/second_stomach = second_sipper.getorganslot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT(second_stomach?.reagents, "The test human has no stomach")
	second_stomach.reagents.add_reagent(/datum/reagent/blood, 10, other_donor.get_blood_data(other_donor.get_blood_id()))
	var/obj/item/reagent_containers/glass/beaker/second_cup = allocate(/obj/item/reagent_containers/glass/beaker)
	second_cup.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10)
	second_cup.reagents.add_reagent(/datum/reagent/blood, 10, donor.get_blood_data(donor.get_blood_id()))
	second_cup.reagents.trans_to_ingested(second_sipper, 20)
	var/datum/reagent/fingerprint_nanites/second_swallowed = second_stomach.reagents.has_reagent(/datum/reagent/fingerprint_nanites)
	TEST_ASSERT(second_swallowed, "The drunk nanites are not in the stomach")
	TEST_ASSERT(second_swallowed.aq_donor_print() == rustg_hash_string(RUSTG_HASH_MD5, "aq_test_donor_identity"), "Old blood in the stomach took over the donor of the drunk mix")

	// A second dose with another donor changes the prints again, once
	var/datum/reagent/fingerprint_nanites/in_copycat = copycat.reagents.has_reagent(/datum/reagent/fingerprint_nanites)
	TEST_ASSERT(in_copycat, "The first dose is gone before the second one")
	copycat.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 5, list("donor_print" = "aq_test_second_donor_print"))
	for(var/i in 1 to 2)
		copycat.reagents.metabolize(copycat, can_overdose = TRUE)
	TEST_ASSERT(copycat.aq_fake_fingerprint == "aq_test_second_donor_print", "A second dose with another donor did not change the prints ([copycat.aq_fake_fingerprint])")

	// Nanites split between two cups do not share their donor
	var/obj/item/reagent_containers/glass/beaker/first_half = allocate(/obj/item/reagent_containers/glass/beaker)
	var/obj/item/reagent_containers/glass/beaker/second_half = allocate(/obj/item/reagent_containers/glass/beaker)
	first_half.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10, list("donor_print" = "aq_test_first_half"))
	first_half.reagents.trans_id_to(second_half, /datum/reagent/fingerprint_nanites, 5)
	var/datum/reagent/fingerprint_nanites/half_one = first_half.reagents.has_reagent(/datum/reagent/fingerprint_nanites)
	var/datum/reagent/fingerprint_nanites/half_two = second_half.reagents.has_reagent(/datum/reagent/fingerprint_nanites)
	half_two.aq_set_donor_print("aq_test_second_half")
	TEST_ASSERT(half_one.aq_donor_print() == "aq_test_first_half", "A new donor in one cup changed the nanites in the other ([half_one.aq_donor_print()])")

	// Blood A, then nanites, then blood B: the poured mix carries B, not the A kept by the merged blood
	var/obj/item/reagent_containers/glass/beaker/layered = allocate(/obj/item/reagent_containers/glass/beaker)
	var/obj/item/reagent_containers/glass/beaker/poured = allocate(/obj/item/reagent_containers/glass/beaker)
	layered.reagents.add_reagent(/datum/reagent/blood, 5, other_donor.get_blood_data(other_donor.get_blood_id()))
	layered.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10)
	layered.reagents.add_reagent(/datum/reagent/blood, 5, donor.get_blood_data(donor.get_blood_id()))
	layered.reagents.trans_to(poured, 20)
	var/datum/reagent/fingerprint_nanites/poured_nanites = poured.reagents.has_reagent(/datum/reagent/fingerprint_nanites)
	TEST_ASSERT(poured_nanites?.aq_donor_print() == rustg_hash_string(RUSTG_HASH_MD5, "aq_test_donor_identity"), "Pouring took the donor of the first blood, not the last one")

	// Nanites drunk without blood stay random even with someone else's blood already in the stomach
	var/mob/living/carbon/human/third_sipper = allocate(/mob/living/carbon/human)
	var/obj/item/organ/stomach/third_stomach = third_sipper.getorganslot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT(third_stomach?.reagents, "The third test human has no stomach")
	third_stomach.reagents.add_reagent(/datum/reagent/blood, 10, other_donor.get_blood_data(other_donor.get_blood_id()))
	var/obj/item/reagent_containers/glass/beaker/plain_cup = allocate(/obj/item/reagent_containers/glass/beaker)
	plain_cup.reagents.add_reagent(/datum/reagent/fingerprint_nanites, 10)
	plain_cup.reagents.trans_to_ingested(third_sipper, 10)
	var/datum/reagent/fingerprint_nanites/plain_swallowed = third_stomach.reagents.has_reagent(/datum/reagent/fingerprint_nanites)
	TEST_ASSERT(plain_swallowed, "The plain nanites are not in the stomach")
	TEST_ASSERT(!plain_swallowed.aq_donor_print(), "Nanites without blood took the donor of older blood in the stomach")
	// The swallowed portion is digested into the blood and works there: random prints, not the stomach's blood
	for(var/i in 1 to 10)
		third_stomach.digest()
		third_sipper.reagents.metabolize(third_sipper, can_overdose = TRUE)
		if(third_sipper.aq_fake_fingerprint)
			break
	TEST_ASSERT(third_sipper.aq_fake_fingerprint, "The digested nanites changed no prints")
	TEST_ASSERT(third_sipper.aq_fake_fingerprint && third_sipper.aq_fake_fingerprint != rustg_hash_string(RUSTG_HASH_MD5, "aq_test_other_identity"), "Nanites without blood copied the prints of blood they never met")

/// AQUILA - a holy salt line stops a shadow demon in the dark and a vampire turned to mist
/datum/unit_test/aquila_reagenty_narzedzia_holy_salt

/datum/unit_test/aquila_reagenty_narzedzia_holy_salt/Run()
	var/turf/start = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/turf/salted = get_step(start, EAST)
	var/turf/beyond = get_step(salted, EAST)
	aq_splash(salted, /datum/reagent/holy_salt, 2)
	var/obj/effect/decal/cleanable/food/salt/holy/salt = aq_holy_salt_on(salted)
	TEST_ASSERT(salt, "Holy salt left no line on the floor")
	allocated += salt // effects are not swept by the base Destroy(), so a failed assertion would leave it

	var/mob/living/carbon/human/crawler = allocate(/mob/living/carbon/human)
	var/obj/effect/dummy/phased_mob/shadow_crawl/shadow = new(start)
	allocated += shadow
	crawler.forceMove(shadow)
	shadow.relaymove(crawler, EAST)
	TEST_ASSERT(shadow.loc == start, "A shadow demon crawled over holy salt")
	shadow.relaymove(crawler, NORTH)
	TEST_ASSERT(shadow.loc != start, "A shadow demon cannot crawl anywhere")
	crawler.forceMove(start)
	qdel(shadow)

	var/datum/action/vampire/targeted/trespass/mist = new
	allocated += mist
	mist.owner = crawler
	TEST_ASSERT(!mist.check_valid_target(beyond), "A vampire in mist passed over holy salt")
	qdel(salt)
	TEST_ASSERT(mist.check_valid_target(beyond), "A vampire in mist cannot pass a clean floor")
	// Salt scattered after the target was picked, while the vampire is mist, still stops the move (FireTargetedPower).
	// No delay, so the power does not wait for game time.
	var/obj/effect/decal/cleanable/food/salt/holy/late_salt = new(salted)
	allocated += late_salt
	mist.aq_mist_delay = 0
	mist.FireTargetedPower(beyond)
	TEST_ASSERT(crawler.loc == start, "Salt scattered during the mist did not stop the vampire ([crawler.loc])")
	qdel(late_salt)
	// Pushed away while in mist: salt on the saved target still stops it, though the target is now three tiles away
	TEST_ASSERT(mist.check_valid_target(beyond), "A vampire in mist cannot pass a clean floor the second time")
	var/turf/pushed_to = get_step(start, WEST)
	crawler.forceMove(pushed_to)
	var/obj/effect/decal/cleanable/food/salt/holy/target_salt = new(beyond)
	allocated += target_salt
	mist.FireTargetedPower(beyond)
	TEST_ASSERT(crawler.loc == pushed_to, "Salt on the saved target did not stop a pushed vampire ([crawler.loc])")
	qdel(target_salt)
	crawler.forceMove(start)
	TEST_ASSERT(mist.check_valid_target(beyond), "A vampire in mist cannot pass a clean floor the third time")
	mist.FireTargetedPower(beyond)
	TEST_ASSERT(crawler.loc == beyond, "A vampire in mist did not move over a clean floor ([crawler.loc])")
	mist.owner = null

#undef TEST_ASSERT
