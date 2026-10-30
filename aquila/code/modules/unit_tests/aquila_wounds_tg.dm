// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - pierce wounds, cranial fissure, eye puncture, scars, wound bonuses, bullets staying in the body
/datum/unit_test/aquila_wounds_tg

/datum/unit_test/aquila_wounds_tg/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)

	TEST_ASSERT(!patient.check_wounding(arm, 100, WOUND_PIERCE, CANT_WOUND), "CANT_WOUND still wounded")

	// A huge wound bonus always rolls the worst wound of the kind
	var/datum/wound/cavity = patient.check_wounding(arm, 25, WOUND_PIERCE, 500)
	TEST_ASSERT(istype(cavity, /datum/wound/pierce/cavity), "A huge wound bonus did not roll a ruptured cavity")
	TEST_ASSERT(patient.is_bleeding(), "A pierce wound does not bleed")
	var/obj/item/cautery/cautery = allocate(/obj/item/cautery)
	TEST_ASSERT(cavity.can_treat_with(cautery), "A cautery cannot close a pierce wound")
	var/datum/wound/open = cavity.replace_with(/datum/wound/pierce/open)
	TEST_ASSERT(!LAZYLEN(arm.scars), "A wound replaced by a milder one left a scar")

	// A healed wound leaves a scar
	qdel(open)
	TEST_ASSERT(LAZYLEN(arm.scars) == 1, "A healed open puncture left no scar")

	// Cranial fissure only on someone in hard crit
	TEST_ASSERT(!istype(patient.check_wounding(head, 25, WOUND_BLUNT, 500), /datum/wound/cranial_fissure), "A conscious person got a cranial fissure")
	patient.fully_heal(admin_revive = TRUE)
	TEST_ASSERT(!LAZYLEN(arm.scars), "An admin heal kept the scars")
	patient.stat = UNCONSCIOUS
	var/datum/wound/fissure = patient.check_wounding(head, 25, WOUND_BLUNT, 500)
	TEST_ASSERT(istype(fissure, /datum/wound/cranial_fissure), "Someone in hard crit got no cranial fissure from a huge hit on the head")
	patient.stat = CONSCIOUS
	patient.fully_heal(admin_revive = TRUE)

	// Eye puncture scars the eye
	var/datum/wound/pierce/eye/eye_wound = patient.puncture_eye()
	TEST_ASSERT(istype(eye_wound), "No eye puncture")
	TEST_ASSERT(HAS_TRAIT_FROM(patient, TRAIT_NEARSIGHT, EYE_SCAR_TRAIT), "A punctured eye does not blur the sight")
	patient.fully_heal(admin_revive = TRUE)

	// Bullets pierce, beams can't wound by default, rubber bruises
	var/obj/item/projectile/bullet/bullet = allocate(/obj/item/projectile/bullet)
	TEST_ASSERT(bullet.wound_kind == WOUND_PIERCE, "Bullets don't pierce")
	var/obj/item/projectile/bullet/shotgun_beanbag/beanbag = allocate(/obj/item/projectile/bullet/shotgun_beanbag)
	TEST_ASSERT(beanbag.wound_kind == WOUND_BLUNT, "A beanbag pierces")

	// A bullet can stay in the body as an embedded fragment
	bullet.lodge_chance = 1000
	bullet.starting = get_turf(patient)
	bullet.def_zone = BODY_ZONE_CHEST
	var/obj/item/bullet_fragment/fragment = bullet.try_lodge(patient, 0)
	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(fragment && (fragment in chest.embedded_objects), "A bullet did not stay in the chest")
	patient.remove_embedded_object(fragment)

#undef TEST_ASSERT
