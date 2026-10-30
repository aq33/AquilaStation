// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - bone gel and surgical tape make a compound fracture knit by itself
/datum/unit_test/aquila_bone_gel_tape

/datum/unit_test/aquila_bone_gel_tape/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	var/datum/wound/blunt/compound = new /datum/wound/blunt/compound()
	compound.apply_wound(leg, silent = TRUE)
	var/obj/item/stack/medical/bone_gel/gel = allocate(/obj/item/stack/medical/bone_gel)
	var/obj/item/stack/sticky_tape/surgical/tape = allocate(/obj/item/stack/sticky_tape/surgical)

	TEST_ASSERT(patient.get_treatable_wound(leg, gel) == compound, "Bone gel cannot treat a compound fracture")
	TEST_ASSERT(!compound.apply_tape(tape, patient), "Surgical tape went on without bone gel")
	TEST_ASSERT(tape.get_amount() == initial(tape.amount), "Tape was used up without bone gel")

	compound.set_gelled()
	TEST_ASSERT(compound.gelled && leg.brute_dam >= 25, "Bone gel did not coat and burn the limb")
	compound.start_knitting()
	TEST_ASSERT(compound.taped && compound.regen_time == 8 MINUTES, "Tape did not start an 8 minute knitting")
	TEST_ASSERT(!patient.get_treatable_wound(leg, tape), "A taped fracture can be taped again")
	TEST_ASSERT(findtext(compound.treat_text, "zrasta"), "The analyzer does not show the knitting")

	compound.regen_progress = compound.regen_time
	compound.process(1)
	TEST_ASSERT(QDELETED(compound) && !leg.get_wound(WOUND_BLUNT), "The knitted bone did not heal")

	var/datum/wound/blunt/fracture = new /datum/wound/blunt/fracture()
	fracture.apply_wound(leg, silent = TRUE)
	fracture.start_knitting(TRUE)
	TEST_ASSERT(fracture.regen_time == 6 MINUTES, "Taping your own fracture is not slower")

/// AQUILA - a new patch keeps its film until it is peeled off in hand
/datum/unit_test/aquila_patch_film

/datum/unit_test/aquila_patch_film/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/pill/patch/styptic/patch = allocate(/obj/item/reagent_containers/pill/patch/styptic)
	patch.self_delay = 0
	TEST_ASSERT(patch.has_film, "A new patch has no film")
	patch.attack(user, user)
	TEST_ASSERT(!QDELETED(patch) && patch.reagents.total_volume, "A patch with its film on was applied")
	patch.attack_self(user)
	TEST_ASSERT(!patch.has_film, "Using the patch in hand did not peel the film")
	patch.attack(user, user)
	TEST_ASSERT(QDELETED(patch), "A peeled patch was not applied")
	TEST_ASSERT(user.reagents.has_reagent(/datum/reagent/medicine/styptic_powder), "The patch did not deliver its reagents")

/// AQUILA - the stasis body bag puts its occupant in stasis and lets go when they leave
/datum/unit_test/aquila_stasis_bodybag

/datum/unit_test/aquila_stasis_bodybag/Run()
	var/obj/structure/closet/body_bag/stasis/bag = allocate(/obj/structure/closet/body_bag/stasis)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.forceMove(bag)
	TEST_ASSERT(!patient.IsInStasis(), "Stasis came before 5 seconds")
	bag.process(6)
	TEST_ASSERT(patient.IsInStasis(), "The stasis bag did not put the patient in stasis")
	var/datum/gas_mixture/air = bag.loc.return_air()
	if(air?.return_temperature() > T0C)
		TEST_ASSERT(bag.obj_integrity < bag.max_integrity, "The bag does not wear out in a warm room")
	patient.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!patient.IsInStasis(), "The patient is still in stasis outside of the bag")

/// AQUILA - the ported medical gear has sprites
/datum/unit_test/aquila_medical_tg_gear_icons

/datum/unit_test/aquila_medical_tg_gear_icons/Run()
	var/list/types = list(
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/bonesetter,
		/obj/item/blood_scanner,
		/obj/item/bodybag/stasis,
		/obj/structure/closet/body_bag/stasis,
		/obj/item/stack/medical/bandage,
		/obj/item/stack/medical/bandage/makeshift,
		/obj/machinery/medipen_refiller,
	)
	for(var/atom/path as anything in types)
		var/state = initial(path.icon_state)
		var/icon_file = initial(path.icon)
		TEST_ASSERT(state in icon_states(icon_file), "[path] has no sprite '[state]' in [icon_file]")
	TEST_ASSERT("holobag_med_open" in icon_states('aquila/icons/obj/medical/bodybag_stasis.dmi'), "The open stasis bag has no sprite")
	TEST_ASSERT("medipen_refiller_open" in icon_states('aquila/icons/obj/machines/medipen_refiller.dmi'), "The open refiller has no sprite")

#undef TEST_ASSERT
