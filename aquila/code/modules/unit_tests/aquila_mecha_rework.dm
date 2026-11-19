// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Sloty: dwie bronie zajmują oba ramiona, trzecia się nie mieści; limity zależą od podwozia
/datum/unit_test/aquila_mecha_slots

/datum/unit_test/aquila_mecha_slots/Run()
	var/obj/mecha/combat/gygax/gygax = allocate(/obj/mecha/combat/gygax)
	var/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/first = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser)
	var/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/second = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser)
	var/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/third = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser)
	TEST_ASSERT(first.can_attach(gygax), "first weapon does not fit a Gygax")
	first.attach(gygax)
	TEST_ASSERT_EQUAL(first.aq_mounted_slot, AQ_MECHA_L_ARM, "first weapon slot")
	TEST_ASSERT(second.can_attach(gygax), "second weapon does not fit the right arm")
	second.attach(gygax)
	TEST_ASSERT_EQUAL(second.aq_mounted_slot, AQ_MECHA_R_ARM, "second weapon slot")
	TEST_ASSERT(!third.can_attach(gygax), "a third weapon fit into an occupied arm")
	TEST_ASSERT_EQUAL(gygax.aq_slot_used(AQ_MECHA_L_ARM), 1, "left arm holds more than one module")
	// Detach frees the arm
	first.detach(get_turf(gygax))
	TEST_ASSERT_EQUAL(gygax.aq_slot_used(AQ_MECHA_L_ARM), 0, "left arm not freed after detach")
	TEST_ASSERT(third.can_attach(gygax), "freed arm does not accept a weapon")

	// Armor slot limits: Gygax 1, Phazon 2, lockermech 0
	var/obj/item/mecha_parts/mecha_equipment/aq_armor/ablative/plate1 = allocate(/obj/item/mecha_parts/mecha_equipment/aq_armor/ablative)
	var/obj/item/mecha_parts/mecha_equipment/aq_armor/shocker/plate2 = allocate(/obj/item/mecha_parts/mecha_equipment/aq_armor/shocker)
	plate1.attach(gygax)
	TEST_ASSERT(!plate2.can_attach(gygax), "Gygax took a second armor module")
	var/obj/mecha/combat/phazon/phazon = allocate(/obj/mecha/combat/phazon)
	var/obj/item/mecha_parts/mecha_equipment/aq_armor/ablative/plate3 = allocate(/obj/item/mecha_parts/mecha_equipment/aq_armor/ablative)
	var/obj/item/mecha_parts/mecha_equipment/aq_armor/shocker/plate4 = allocate(/obj/item/mecha_parts/mecha_equipment/aq_armor/shocker)
	plate3.attach(phazon)
	TEST_ASSERT(plate4.can_attach(phazon), "Phazon has no second armor slot")
	var/obj/mecha/working/lockermech/locker = allocate(/obj/mecha/working/lockermech)
	var/obj/item/mecha_parts/mecha_equipment/aq_cooling/active/cooler = allocate(/obj/item/mecha_parts/mecha_equipment/aq_cooling/active)
	TEST_ASSERT(!cooler.can_attach(locker), "locker mech accepted a power module")

	// Every existing module has a valid slot
	for(var/path in subtypesof(/obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = path
		var/slot = initial(E.aq_slot) || (initial(E.selectable) ? AQ_MECHA_SLOT_ARM : AQ_MECHA_UTILITY)
		TEST_ASSERT(slot in list(AQ_MECHA_SLOT_ARM, AQ_MECHA_UTILITY, AQ_MECHA_POWER, AQ_MECHA_ARMOR, AQ_MECHA_SLOT_NONE), "[path] has an unknown slot [slot]")

/// Overclock grzeje mecha, bezpiecznik przepala się przy maksimum, chłodzenie zbija ciepło
/datum/unit_test/aquila_mecha_overclock

/datum/unit_test/aquila_mecha_overclock/Run()
	var/obj/mecha/combat/gygax/mech = allocate(/obj/mecha/combat/gygax)
	var/base_step = mech.step_in
	mech.aq_set_overclock(TRUE)
	TEST_ASSERT(mech.aq_overclock, "overclock did not turn on")
	TEST_ASSERT(mech.step_in < base_step, "overclock did not speed up the step")
	mech.aq_process_heat(2)
	TEST_ASSERT(mech.aq_heat > 0, "overclock did not heat the mech")
	var/fuses = mech.aq_fuses
	mech.aq_adjust_heat(AQ_MECHA_HEAT_MAX)
	TEST_ASSERT_EQUAL(mech.aq_fuses, fuses - 1, "fuse did not blow at max heat")
	TEST_ASSERT(!mech.aq_overclock, "blown fuse did not turn overclock off")
	TEST_ASSERT_EQUAL(mech.step_in, base_step, "step not restored after overclock")
	var/heat = mech.aq_heat
	var/obj/item/mecha_parts/mecha_equipment/aq_cooling/passive/radiator = allocate(/obj/item/mecha_parts/mecha_equipment/aq_cooling/passive)
	radiator.attach(mech)
	mech.aq_process_heat(2)
	TEST_ASSERT(mech.aq_heat < heat, "mech did not cool down")
	mech.equipment_disabled = FALSE

/// Kierunkowy pancerz: trafienie od przodu zadaje mniej obrażeń niż od tyłu
/datum/unit_test/aquila_mecha_facing

/datum/unit_test/aquila_mecha_facing/Run()
	var/obj/mecha/combat/durand/mech = allocate(/obj/mecha/combat/durand)
	mech.deflect_chance = 0
	mech.setDir(SOUTH)
	var/front = mech.run_obj_armor(100, BRUTE, "melee", SOUTH)
	var/back = mech.run_obj_armor(100, BRUTE, "melee", NORTH)
	var/side = mech.run_obj_armor(100, BRUTE, "melee", EAST)
	TEST_ASSERT(front < side, "front hit ([front]) not weaker than side hit ([side])")
	TEST_ASSERT(side < back, "side hit ([side]) not weaker than back hit ([back])")
	// Tarcza balistyczna wzmacnia tylko przód
	var/obj/item/mecha_parts/mecha_equipment/aq_ballistic_shield/shield = allocate(/obj/item/mecha_parts/mecha_equipment/aq_ballistic_shield)
	shield.deflect_bonus = 0
	shield.attach(mech)
	var/front_shield = mech.run_obj_armor(100, BRUTE, "melee", SOUTH)
	var/back_shield = mech.run_obj_armor(100, BRUTE, "melee", NORTH)
	TEST_ASSERT(front_shield < front, "ballistic shield did not reduce frontal damage")
	TEST_ASSERT_EQUAL(back_shield, back, "ballistic shield changed rear damage")

/// Savannah-Ivanov przyjmuje dwóch załogantów: pierwszy strzela, drugi prowadzi
/datum/unit_test/aquila_mecha_two_seats

/datum/unit_test/aquila_mecha_two_seats/Run()
	var/obj/mecha/combat/aq_savannah/mech = allocate(/obj/mecha/combat/aq_savannah)
	var/mob/living/carbon/human/gunner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/driver = allocate(/mob/living/carbon/human)
	mech.occupant = gunner
	gunner.forceMove(mech)
	mech.GrantActions(gunner, TRUE)
	TEST_ASSERT(mech.aq_has_copilot_seat(), "Savannah has no second seat")
	mech.aq_copilot = driver
	driver.forceMove(mech)
	mech.aq_grant_copilot_actions(driver)
	TEST_ASSERT_EQUAL(mech.aq_copilot, driver, "driver not seated")
	TEST_ASSERT_EQUAL(mech.occupant, gunner, "gunner lost the pilot seat")
	// Strzelec nie prowadzi, gdy jest kierowca; kierowca ma akcję skoku
	TEST_ASSERT(!mech.relaymove(gunner, NORTH), "gunner moved the mech while a driver is aboard")
	TEST_ASSERT(mech.skyfall_action.owner == driver, "driver has no Skyfall action")
	mech.update_icon()
	TEST_ASSERT_EQUAL(mech.icon_state, "savannah_ivanov_1_1", "two-crew icon state")
	// Kierowca wysiada
	mech.aq_copilot_out()
	TEST_ASSERT(isnull(mech.aq_copilot), "driver still seated after leaving")
	TEST_ASSERT(driver.loc != mech, "driver still inside")
	// Jednoosobowy mech nie ma drugiego miejsca
	var/obj/mecha/combat/gygax/gygax = allocate(/obj/mecha/combat/gygax)
	TEST_ASSERT(!gygax.aq_has_copilot_seat(), "Gygax has a second seat")

/// Każde nowe podwozie i każda pozycja wyposażenia z planu tworzy się i montuje w pasującym mechu
/datum/unit_test/aquila_mecha_content

/datum/unit_test/aquila_mecha_content/Run()
	TEST_ASSERT_EQUAL(length(GLOB.aq_mecha_plan_equipment), 71, "plan equipment count")
	for(var/path in GLOB.aq_mecha_new_chassis)
		var/obj/mecha/M = allocate(path)
		TEST_ASSERT(!QDELETED(M), "[path] failed to initialize")
		TEST_ASSERT(icon_exists(M.icon, M.icon_state), "[path] has no icon state [M.icon_state] in [M.icon]")
		TEST_ASSERT(icon_exists(M.icon, "[initial(M.icon_state)]-open"), "[path] has no open icon state")
		var/obj/structure/mecha_wreckage/W = M.wreckage
		TEST_ASSERT(ispath(W, /obj/structure/mecha_wreckage), "[path] has no wreckage")
		TEST_ASSERT(icon_exists(initial(W.icon), initial(W.icon_state)), "[W] has no icon state")
	var/list/candidates = list(/obj/mecha/combat/gygax, /obj/mecha/working/ripley, /obj/mecha/working/ripley/aq_paddy, /obj/mecha/combat/aq_sentinel, /obj/mecha/medical/odysseus)
	for(var/name in GLOB.aq_mecha_plan_equipment)
		var/path = GLOB.aq_mecha_plan_equipment[name]
		var/obj/item/mecha_parts/mecha_equipment/E = allocate(path)
		TEST_ASSERT(icon_exists(E.icon, E.icon_state), "[name] ([path]) has no icon state [E.icon_state]")
		var/mounted = FALSE
		for(var/mech_type in candidates)
			var/obj/mecha/M = allocate(mech_type)
			if(E.can_attach(M))
				E.attach(M)
				TEST_ASSERT(E in M.equipment, "[name] did not end up in [mech_type] equipment")
				TEST_ASSERT(E.aq_mounted_slot, "[name] has no slot after mounting")
				E.detach(run_loc_floor_top_right)
				TEST_ASSERT(!(E in M.equipment), "[name] did not detach")
				mounted = TRUE
				break
		TEST_ASSERT(mounted, "[name] ([path]) fits none of the test mechs")

/// Zestaw konwersji tworzy nowe podwozie z częściami starego; skiny pasują do podwozi
/datum/unit_test/aquila_mecha_conversion_skins

/datum/unit_test/aquila_mecha_conversion_skins/Run()
	var/obj/mecha/working/ripley/ripley = allocate(/obj/mecha/working/ripley)
	ripley.maint_access = TRUE
	var/obj/item/stock_parts/cell/old_cell = ripley.cell
	var/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paddy/kit = allocate(/obj/item/mecha_parts/mecha_equipment/aq_conversion_kit/paddy)
	TEST_ASSERT(kit.can_attach(ripley), "Paddy kit does not fit a Ripley MK-I")
	var/turf/T = get_turf(ripley)
	kit.attach(ripley)
	var/obj/mecha/working/ripley/aq_paddy/paddy = locate() in T
	TEST_ASSERT(paddy, "Paddy kit did not produce a Paddy")
	TEST_ASSERT_EQUAL(paddy.cell, old_cell, "Paddy did not take over the cell")
	TEST_ASSERT(locate(/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/jail_cell) in paddy.equipment, "Paddy has no jail cell")
	allocated += paddy

	TEST_ASSERT_EQUAL(length(GLOB.aq_mecha_skins), 17, "skin count (16 from the plan + dark Odysseus)")
	for(var/datum/aq_mecha_skin/S as anything in GLOB.aq_mecha_skins)
		for(var/suffix in list("", "-open", "-broken"))
			TEST_ASSERT(icon_exists(S.icon, "[S.base_state][suffix]"), "skin [S.name] has no state [S.base_state][suffix]")
	var/obj/mecha/combat/durand/durand = allocate(/obj/mecha/combat/durand)
	var/list/durand_skins = durand.aq_available_skins()
	TEST_ASSERT_EQUAL(length(durand_skins), 3, "Durand skin count")
	durand.aq_apply_skin(durand_skins[1])
	TEST_ASSERT(durand.icon != initial(durand.icon), "skin did not change the icon")
	var/obj/mecha/combat/gygax/dark/dark = allocate(/obj/mecha/combat/gygax/dark)
	TEST_ASSERT(!length(dark.aq_available_skins()), "an antag chassis got crew skins")

/// Obecne podwozia działają po zmianie: gotowe mechy mają wyposażenie w slotach, nasze dodatki (piana kadłubowa, inteligentna
/// piana, chaingun na kulki, szafkowy mech) dalej się montują, a szafkowy mech bierze najwyżej dwa narzędzia
/datum/unit_test/aquila_mecha_existing

/datum/unit_test/aquila_mecha_existing/Run()
	for(var/path in subtypesof(/obj/mecha) - GLOB.aq_mecha_new_chassis)
		var/obj/mecha/M = allocate(path)
		TEST_ASSERT(M.aq_equip_by_category, "[path] has no slot lists")
		var/counted = 0
		for(var/key in M.aq_equip_by_category)
			counted += length(M.aq_equip_by_category[key])
		TEST_ASSERT_EQUAL(counted, length(M.equipment), "[path] modules missing from slot lists")
		TEST_ASSERT(M.max_equip >= length(M.equipment), "[path] max_equip below mounted modules")
	var/obj/mecha/working/ripley/ripley = allocate(/obj/mecha/working/ripley)
	var/obj/item/mecha_parts/mecha_equipment/extinguisher/hull_repair_juice/foam = allocate(/obj/item/mecha_parts/mecha_equipment/extinguisher/hull_repair_juice)
	TEST_ASSERT(foam.can_attach(ripley), "hull foam does not fit a Ripley")
	foam.attach(ripley)
	var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/smart_foam/smart = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/smart_foam)
	TEST_ASSERT(smart.can_attach(ripley), "smart foam launcher does not fit a Ripley")
	smart.attach(ripley)
	var/obj/item/mecha_parts/mecha_equipment/drill/drill = allocate(/obj/item/mecha_parts/mecha_equipment/drill)
	TEST_ASSERT(!drill.can_attach(ripley), "Ripley took a third arm module")
	var/obj/mecha/combat/gygax/gygax = allocate(/obj/mecha/combat/gygax)
	var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/BBchaingun/toy = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/BBchaingun)
	TEST_ASSERT(toy.can_attach(gygax), "toy chaingun does not fit a Gygax")
	var/obj/mecha/working/lockermech/locker = allocate(/obj/mecha/working/lockermech)
	var/obj/item/mecha_parts/mecha_equipment/drill/makeshift/tool1 = allocate(/obj/item/mecha_parts/mecha_equipment/drill/makeshift)
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift/tool2 = allocate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift)
	var/obj/item/mecha_parts/mecha_equipment/weapon/energy/makeshift/tool3 = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/energy/makeshift)
	TEST_ASSERT(tool1.can_attach(locker), "makeshift drill does not fit the locker mech")
	tool1.attach(locker)
	TEST_ASSERT(tool2.can_attach(locker), "makeshift clamp does not fit the locker mech")
	tool2.attach(locker)
	TEST_ASSERT(!tool3.can_attach(locker), "locker mech took a third tool")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
