// Kopie makr z code/modules/unit_tests/_unit_tests.dm (tam są #undef na końcu)
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - strzał z broni palnej zostawia dym (zanieczyszczenie) na kafelku strzelca, broń na piankę nie
/datum/unit_test/aquila_gun_smoke_pollution

/datum/unit_test/aquila_gun_smoke_pollution/Run()
	var/turf/open/shooter_turf = run_loc_floor_bottom_left
	var/turf/open/toy_turf = locate(shooter_turf.x + 2, shooter_turf.y, shooter_turf.z)
	TEST_ASSERT(isopenturf(toy_turf), "No open turf 2 tiles east of the test room corner")
	QDEL_NULL(shooter_turf.pollution)
	QDEL_NULL(toy_turf.pollution)

	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, shooter_turf)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	shooter.put_in_hands(gun)
	var/turf/target = locate(shooter_turf.x, shooter_turf.y + 2, shooter_turf.z)
	gun.process_fire(target, shooter, FALSE)
	TEST_ASSERT(shooter_turf.pollution?.pollutants[/datum/pollutant/smoke] >= gun.gun_smoke_pollution, "Pistol shot left no gun smoke on the shooter's tile")

	var/mob/living/carbon/human/toy_shooter = allocate(/mob/living/carbon/human, toy_turf)
	var/obj/item/gun/ballistic/automatic/toy/pistol/toy = allocate(/obj/item/gun/ballistic/automatic/toy/pistol)
	toy_shooter.put_in_hands(toy)
	toy.process_fire(target, toy_shooter, FALSE)
	TEST_ASSERT(!toy_turf.pollution?.pollutants[/datum/pollutant/smoke], "Foam pistol left gun smoke")

	QDEL_NULL(shooter_turf.pollution)

/// AQUILA - karta ID w slocie ID rysuje się na postaci, a każda karta ze zwykłym sprite'em ma swój stan na postaci
/datum/unit_test/aquila_id_worn_overlay

/datum/unit_test/aquila_id_worn_overlay/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/card/id/captains_spare/card = allocate(/obj/item/card/id/captains_spare)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(card, ITEM_SLOT_ID), "Could not put the ID card in the ID slot")
	var/mutable_appearance/id_overlay = wearer.overlays_standing[ID_LAYER]
	TEST_ASSERT(id_overlay, "No ID overlay on a human wearing an ID card")
	TEST_ASSERT(id_overlay.icon_state in icon_states(id_overlay.icon), "ID overlay state '[id_overlay.icon_state]' missing in [id_overlay.icon]")

	var/list/worn_states = icon_states('aquila/icons/mob/clothing/id.dmi')
	var/list/missing = list()
	for(var/obj/item/card/id/card_type as anything in typesof(/obj/item/card/id))
		if(initial(card_type.icon) != 'nsv13/icons/obj/card.dmi' || initial(card_type.worn_icon))
			continue
		var/state = initial(card_type.worn_icon_state) || initial(card_type.icon_state)
		if(!(state in worn_states))
			missing |= state
	TEST_ASSERT(!length(missing), "ID card states without a worn sprite in aquila/icons/mob/clothing/id.dmi: [jointext(missing, ", ")]")

#undef TEST_ASSERT
