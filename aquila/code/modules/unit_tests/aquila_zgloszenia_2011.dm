// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wbudowana butla hardsuitu podaje tlen pod ciśnieniem zwykłej butli: oddychanie z niej nie dusi
/datum/unit_test/aquila_hardsuit_tank_breathing

/datum/unit_test/aquila_hardsuit_tank_breathing/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/suit/space/hardsuit/engine/suit = allocate(/obj/item/clothing/suit/space/hardsuit/engine)
	H.equip_to_slot_or_del(suit, ITEM_SLOT_OCLOTHING)
	suit.ToggleHelmet()
	suit.toggle_integrated_tank(H)
	TEST_ASSERT(H.internal == suit.integrated_tank, "The integrated tank didn't open ([H.internal])")
	var/start_pressure = suit.integrated_tank.air_contents.return_pressure()
	for(var/i in 1 to 10)
		H.breathe()
	TEST_ASSERT(suit.integrated_tank.air_contents.return_pressure() < start_pressure, "Breathing didn't take air from the integrated tank")
	TEST_ASSERT(H.getOxyLoss() == 0, "Breathing from the integrated tank caused [H.getOxyLoss()] oxygen damage")

/// AQUILA - martwy VIP nie oblewa misji od razu: można go ożywić, a misja przepada dopiero bez ciała
/datum/unit_test/aquila_vip_revive

/datum/unit_test/aquila_vip_revive/Run()
	var/datum/orbital_objective/vip_recovery/objective = new
	var/mob/living/carbon/human/vip = allocate(/mob/living/carbon/human)
	objective.mob_to_recover = vip
	objective.generated = TRUE
	vip.death()
	TEST_ASSERT(!objective.check_failed(), "A dead VIP without a player failed the mission right away")
	qdel(vip)
	TEST_ASSERT(objective.check_failed(), "A deleted VIP didn't fail the mission")
	objective.mob_to_recover = null
	qdel(objective)

#undef TEST_ASSERT
