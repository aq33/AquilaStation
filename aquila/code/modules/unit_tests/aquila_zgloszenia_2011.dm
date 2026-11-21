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

/// AQUILA - kompaktowy HUD (widok myśliwca) tylko w małych jednostkach, za sterem okrętu klasyczny panel
/datum/unit_test/aquila_ship_hud_choice

/datum/unit_test/aquila_ship_hud_choice/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	TEST_ASSERT(main, "No main ship")
	var/obj/structure/overmap/small_craft/combat/light/fighter = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/old_gunner = main.gunner
	main.gunner = H
	var/gunner_compact = H.aq_wants_compact_ship_hud(main)
	main.gunner = old_gunner
	TEST_ASSERT(gunner_compact, "A ship's gunner lost the compact HUD with the DRADIS radar")
	var/old_pilot = main.pilot
	main.pilot = H
	var/pilot_compact = H.aq_wants_compact_ship_hud(main)
	main.pilot = old_pilot
	TEST_ASSERT(!pilot_compact, "The ship's helm gave the compact fighter HUD")
	TEST_ASSERT(H.aq_wants_compact_ship_hud(fighter), "A fighter didn't give the compact HUD by default")

#undef TEST_ASSERT
