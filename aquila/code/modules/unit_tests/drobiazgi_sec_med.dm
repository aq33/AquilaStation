// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - kontrabanda: flaga uplinka, trait, blokery, paczki cargo i skaner N-spect
/datum/unit_test/aquila_contraband

/datum/unit_test/aquila_contraband/Run()
	var/obj/item/storage/box/box = allocate(/obj/item/storage/box)
	var/obj/item/pen/pen = new(box)
	TEST_ASSERT(!box.contains_contraband(), "An empty box with a pen is contraband")
	pen.item_flags |= ILLEGAL
	TEST_ASSERT(pen.is_contraband(), "An uplink item (ILLEGAL) is not contraband")
	TEST_ASSERT(box.contains_contraband(), "A box with an uplink item inside is clear")

	var/obj/item/storage/backpack/satchel/flat/smuggler = allocate(/obj/item/storage/backpack/satchel/flat/empty)
	box.forceMove(smuggler)
	TEST_ASSERT(!smuggler.contains_contraband(), "A smuggler's satchel does not hide its contents")

	var/obj/item/storage/box/marked = allocate(/obj/item/storage/box)
	var/obj/item/pen/inner = new(marked)
	marked.mark_contraband(TRUE)
	TEST_ASSERT(HAS_TRAIT(inner, TRAIT_CONTRABAND), "mark_contraband(TRUE) skipped the contents")

	var/obj/item/inspector/inspector = allocate(/obj/item/inspector)
	TEST_ASSERT(inspector.contraband_scan(marked), "N-spect missed contraband")
	TEST_ASSERT(!inspector.contraband_scan(smuggler), "N-spect sees through a smuggler's satchel")
	var/obj/item/inspector/faulty/faulty = allocate(/obj/item/inspector/faulty)
	TEST_ASSERT(faulty.contraband_scan(smuggler) && !faulty.contraband_scan(marked), "The faulty N-spect is not reversed")

	var/datum/supply_pack/contraband_pack
	for(var/pack_type in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/pack = pack_type
		if(initial(pack.contraband) && length(initial(pack.contains)))
			contraband_pack = new pack_type()
			break
	if(contraband_pack)
		var/obj/structure/closet/crate/crate = contraband_pack.generate(run_loc_floor_bottom_left)
		TEST_ASSERT(crate.contains_contraband(), "[contraband_pack.type] gave no contraband")
		TEST_ASSERT(!HAS_TRAIT(crate, TRAIT_CONTRABAND), "The crate itself is contraband")
		for(var/atom/movable/thing in crate.GetAllContents())
			qdel(thing)

/// AQUILA - Undercover I.D.: nie kopiuje dostępów, multitool blokuje przebranie, leży w szafce detektywa
/datum/unit_test/aquila_undercover_id

/datum/unit_test/aquila_undercover_id/Run()
	var/mob/living/carbon/human/detective = allocate(/mob/living/carbon/human)
	var/obj/item/card/id/syndicate/undercover/undercover = allocate(/obj/item/card/id/syndicate/undercover)
	var/obj/item/card/id/captains_spare/spare = allocate(/obj/item/card/id/captains_spare)
	var/access_before = length(undercover.access)
	undercover.afterattack(spare, detective, TRUE)
	TEST_ASSERT(length(undercover.access) == access_before, "The undercover ID copied access")
	TEST_ASSERT(!(ACCESS_SYNDICATE in undercover.access), "The undercover ID has Syndicate access")

	detective.mind_initialize()
	TEST_ASSERT(undercover.can_forge(detective), "Anyone should be able to forge the undercover ID")
	var/obj/item/multitool/multitool = allocate(/obj/item/multitool)
	undercover.attackby(multitool, detective)
	TEST_ASSERT(undercover.disguise_locked && !(undercover.chameleon_action in undercover.actions), "The multitool did not lock the disguise")
	TEST_ASSERT(!undercover.can_forge(detective), "A locked undercover ID can be forged")
	undercover.attackby(multitool, detective)
	TEST_ASSERT(!undercover.disguise_locked && (undercover.chameleon_action in undercover.actions), "The multitool did not unlock the disguise")

	var/obj/structure/closet/secure_closet/detective/locker = allocate(/obj/structure/closet/secure_closet/detective)
	TEST_ASSERT(locate(/obj/item/card/id/syndicate/undercover) in locker, "The detective locker has no undercover ID")

/// AQUILA - tagi triage: przyklejanie, examine, podmiana i zdejmowanie taggerem
/datum/unit_test/aquila_triage_tags

/datum/unit_test/aquila_triage_tags/Run()
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/sticker/sticky_note/triage/immediate/tag = allocate(/obj/item/sticker/sticky_note/triage/immediate)
	tag.tag_patient(patient, medic)
	TEST_ASSERT(tag.loc == patient && tag.sticker_state == STICKER_STATE_STUCK, "The tag did not stick to the patient")
	TEST_ASSERT(findtext(jointext(patient.examine(medic), ""), tag.category), "The patient examine does not show the tag")

	var/obj/item/triage_tagger/tagger = allocate(/obj/item/triage_tagger)
	tagger.selected = /obj/item/sticker/sticky_note/triage/minor
	tagger.pre_attack(patient, medic)
	TEST_ASSERT(tag.loc != patient, "The tagger did not replace the old tag")
	TEST_ASSERT(locate(/obj/item/sticker/sticky_note/triage/minor) in patient, "The tagger did not put a green tag on")
	tagger.selected = null
	tagger.pre_attack(patient, medic)
	TEST_ASSERT(!(locate(/obj/item/sticker/sticky_note/triage) in patient), "The tagger did not remove the tag")

	var/obj/item/storage/box/triage/box = allocate(/obj/item/storage/box/triage)
	TEST_ASSERT(length(box.contents) == 4, "The triage box should hold four pads")

/// AQUILA - opaska uciskowa: zatrzymuje krwawienie kończyny, rana się nie otwiera, za długo trzymana niszczy kończynę
/datum/unit_test/aquila_tourniquet

/datum/unit_test/aquila_tourniquet/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/datum/wound/slash/artery/artery = new()
	artery.apply_wound(arm, silent = TRUE)
	var/bleed_before = patient.aq_bleed_rate()
	TEST_ASSERT(bleed_before > 0, "A torn artery does not bleed")

	var/obj/item/tourniquet/tourniquet = allocate(/obj/item/tourniquet)
	tourniquet.attach(patient, BODY_ZONE_R_ARM)
	TEST_ASSERT(LAZYACCESS(patient.aq_tourniquets, BODY_ZONE_R_ARM) == tourniquet, "The tourniquet is not on the arm")
	TEST_ASSERT(patient.aq_bleed_rate() < bleed_before && tourniquet.held_bleed > 0, "The tourniquet did not stop the bleeding")
	var/bleed_held = patient.aq_bleed_rate()
	artery.reopen_progress = artery.reopen_interval
	artery.wound_effects(1)
	TEST_ASSERT(patient.aq_bleed_rate() == bleed_held, "The wound reopened under the tourniquet")
	patient.aq_add_limb_bleed(BODY_ZONE_R_ARM, 1)
	TEST_ASSERT(patient.aq_bleed_rate() == bleed_held, "New bleeding from the tied limb was not stopped")
	TEST_ASSERT(length(patient.get_wound_scan_lines()) == 2, "The analyzer does not see the tourniquet")
	TEST_ASSERT(findtext(jointext(patient.examine(patient), ""), "opaskę uciskową"), "Examine does not show the tourniquet")

	tourniquet.applied_at = world.time - 4 MINUTES
	var/brute_before = arm.brute_dam
	tourniquet.process(2)
	TEST_ASSERT(arm.brute_dam > brute_before, "Ischemia does not damage the limb")

	tourniquet.detach()
	TEST_ASSERT(!LAZYACCESS(patient.aq_tourniquets, BODY_ZONE_R_ARM), "The tourniquet is still listed after removal")
	TEST_ASSERT(patient.aq_bleed_rate() > bleed_held, "An open artery did not bleed again after removal")

	var/obj/item/tourniquet/leg_tourniquet = allocate(/obj/item/tourniquet)
	leg_tourniquet.attach(patient, BODY_ZONE_L_LEG)
	TEST_ASSERT(LAZYACCESS(patient.movespeed_modification, "aq_tourniquet"), "A tourniquet on a leg does not slow down")
	leg_tourniquet.detach()
	TEST_ASSERT(!LAZYACCESS(patient.movespeed_modification, "aq_tourniquet"), "The slowdown stayed after removal")

	var/mob/living/carbon/human/crewmember = allocate(/mob/living/carbon/human)
	crewmember.equipOutfit(/datum/outfit/job/assistant)
	TEST_ASSERT(locate(/obj/item/tourniquet) in crewmember.GetAllContents(), "A crew member did not get a tourniquet")

#undef TEST_ASSERT
