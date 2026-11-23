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
	var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/relay = allocate(/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay)
	TEST_ASSERT(!relay.can_attach(locker), "locker mech accepted a power module")

	// Every existing module has a valid slot
	for(var/path in subtypesof(/obj/item/mecha_parts/mecha_equipment))
		var/obj/item/mecha_parts/mecha_equipment/E = path
		var/slot = initial(E.aq_slot) || (initial(E.selectable) ? AQ_MECHA_SLOT_ARM : AQ_MECHA_UTILITY)
		TEST_ASSERT(slot in list(AQ_MECHA_SLOT_ARM, AQ_MECHA_UTILITY, AQ_MECHA_POWER, AQ_MECHA_ARMOR, AQ_MECHA_SLOT_NONE), "[path] has an unknown slot [slot]")

/// Overclock przyspiesza krok, sam gaśnie po czasie i nie da się go włączyć w czasie odnowienia
/datum/unit_test/aquila_mecha_overclock

/datum/unit_test/aquila_mecha_overclock/Run()
	var/obj/mecha/combat/gygax/mech = allocate(/obj/mecha/combat/gygax)
	var/base_step = mech.step_in
	mech.aq_set_overclock(TRUE)
	TEST_ASSERT(mech.aq_overclock, "overclock did not turn on")
	TEST_ASSERT(mech.aq_step_delay() < base_step, "overclock did not speed up the step")
	mech.aq_process_overclock(2)
	TEST_ASSERT(mech.aq_overclock, "overclock turned off before its time ran out")
	// Czas działania minął: overclock gaśnie i zaczyna się odnowienie
	mech.aq_overclock_end = world.time
	mech.aq_process_overclock(2)
	TEST_ASSERT(!mech.aq_overclock, "overclock did not turn off after its duration")
	TEST_ASSERT_EQUAL(mech.aq_step_delay(), base_step, "step not restored after overclock")
	mech.aq_set_overclock(TRUE)
	TEST_ASSERT(!mech.aq_overclock, "overclock turned on during its cooldown")
	// Po odnowieniu znowu działa
	COOLDOWN_RESET(mech, aq_overclock_cooldown)
	mech.aq_set_overclock(TRUE)
	TEST_ASSERT(mech.aq_overclock, "overclock did not turn on after the cooldown")
	mech.aq_set_overclock(FALSE)

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
	set_test_controls(driver, FALSE) // kierowca z graczem: tylko taki odbiera strzelcowi ruch
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

/// Każda broń balistyczna mecha (także stara) przeładowuje się tylko z zapasu: nie z ogniwa, tylko ze skrzynek,
/// nabojów albo z tego, co wyrzutnia wystrzeliwuje
/datum/unit_test/aquila_mecha_ammo

/datum/unit_test/aquila_mecha_ammo/Run()
	var/obj/mecha/combat/gygax/mech = allocate(/obj/mecha/combat/gygax)
	var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/lmg = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg)
	lmg.attach(mech)
	lmg.projectiles = 0
	lmg.aq_ammo_cache = 0 // bez zapasu startowego
	var/charge = mech.get_charge()
	TEST_ASSERT(!lmg.rearm(), "LMG rearmed without ammo in storage")
	TEST_ASSERT_EQUAL(lmg.projectiles, 0, "LMG refilled from the power cell")
	TEST_ASSERT_EQUAL(mech.get_charge(), charge, "rearm used the power cell")
	var/obj/item/mecha_ammo/lmg/box = allocate(/obj/item/mecha_ammo/lmg)
	TEST_ASSERT(mech.aq_load_ammo(box), "LMG ammo box did not load")
	TEST_ASSERT(lmg.rearm(), "LMG did not rearm from storage")
	TEST_ASSERT_EQUAL(lmg.projectiles, initial(lmg.projectiles), "LMG not full after rearm")
	// Granatnik ładuje się granatami hukowymi
	var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/launcher = allocate(/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang)
	launcher.attach(mech)
	launcher.projectiles = 0
	launcher.aq_ammo_cache = 0 // bez zapasu startowego
	var/obj/item/grenade/flashbang/bang = allocate(/obj/item/grenade/flashbang)
	TEST_ASSERT(mech.aq_load_ammo(bang), "flashbang did not load into the grenade launcher")
	TEST_ASSERT(QDELETED(bang), "loaded flashbang still exists")
	TEST_ASSERT_EQUAL(launcher.aq_ammo_cache, 1, "launcher storage after loading one flashbang")
	TEST_ASSERT(launcher.rearm(), "launcher did not rearm from storage")
	TEST_ASSERT_EQUAL(launcher.projectiles, 1, "launcher rounds after rearm")
	// Każda broń balistyczna ma czym się ładować
	for(var/path in subtypesof(/obj/item/mecha_parts/mecha_equipment/weapon/ballistic))
		var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = path
		if(!initial(gun.projectiles))
			continue
		TEST_ASSERT(initial(gun.aq_ammo_cache_max), "[path] has no ammo storage")
		var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/G = allocate(path)
		TEST_ASSERT(G.aq_ammo_type || length(G.aq_calibers) || G.aq_item_ammo_type() || istype(G, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_forge_cannon), "[path] has no way to load ammo")

/// Każde nowe podwozie i każda pozycja wyposażenia z planu tworzy się i montuje w pasującym mechu
/datum/unit_test/aquila_mecha_content

/datum/unit_test/aquila_mecha_content/Run()
	TEST_ASSERT_EQUAL(length(GLOB.aq_mecha_plan_equipment), 56, "plan equipment count")
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

/// Pilot zdalny siedzi w kokpicie: pocisk broni mecha startuje z mecha, a wybuch, pocisk w otwartą kabinę i ogień
/// nie ranią pilota (regresja: rdzeń traktował occupanta jak siedzącego w kabinie)
/datum/unit_test/aquila_mecha_remote_pilot

/datum/unit_test/aquila_mecha_remote_pilot/Run()
	var/obj/mecha/combat/gygax/mech = allocate(/obj/mecha/combat/gygax)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	mech.aq_remote_pilot = pilot
	mech.occupant = pilot
	pilot.remote_control = mech
	var/turf/mech_turf = get_turf(mech)
	var/turf/target = locate(mech_turf.x, mech_turf.y + 1, mech_turf.z)
	var/obj/item/projectile/shot = allocate(/obj/item/projectile, run_loc_floor_top_right)
	shot.preparePixelProjectile(target, pilot)
	TEST_ASSERT_EQUAL(get_turf(shot), mech_turf, "remote mech shot did not start from the mech")
	TEST_ASSERT_EQUAL(shot.starting, mech_turf, "remote mech shot starting turf")
	TEST_ASSERT_EQUAL(shot.Angle, 0, "remote mech shot does not aim from the mech at a target to the north")
	// Otwarta kabina i wybuch: pilot w kokpicie zostaje cały
	mech.enclosed = FALSE
	mech.contents_explosion(EXPLODE_DEVASTATE, mech)
	TEST_ASSERT_EQUAL(pilot.getBruteLoss(), 0, "explosion inside the mech hurt the remote pilot")
	var/obj/item/projectile/bullet = allocate(/obj/item/projectile)
	bullet.def_zone = BODY_ZONE_CHEST
	bullet.damage = 10
	mech.bullet_act(bullet)
	TEST_ASSERT_EQUAL(pilot.getBruteLoss(), 0, "a bullet into the open cockpit hit the remote pilot")
	mech.fire_act(1000, 100)
	TEST_ASSERT_EQUAL(pilot.fire_stacks, 0, "fire on the mech set the remote pilot on fire")
	mech.aq_end_remote()
	TEST_ASSERT(isnull(mech.occupant), "remote pilot still the occupant after the session ended")

/// Overclock i płyta pancerza liczą się względem bieżącego step_in: przeciążenie Gygaxa nie zostawia trwałego kroku 1,
/// Ripley i Paddy po update_pressure dalej przyspieszają z overclockiem, cykle płyty nie zmieniają kroku
/datum/unit_test/aquila_mecha_step_modifiers

/datum/unit_test/aquila_mecha_step_modifiers/Run()
	var/obj/mecha/combat/gygax/gygax = allocate(/obj/mecha/combat/gygax)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human)
	gygax.occupant = pilot
	pilot.forceMove(gygax)
	gygax.GrantActions(pilot, TRUE)
	var/base_step = initial(gygax.step_in)
	gygax.overload_action.Activate() // przeciążenie siłowników włączone
	gygax.aq_set_overclock(TRUE)
	gygax.overload_action.Activate() // wyłączone: rdzeń wraca do initial(step_in)
	gygax.aq_set_overclock(FALSE)
	TEST_ASSERT_EQUAL(gygax.step_in, base_step, "Gygax step after overload and overclock")
	TEST_ASSERT_EQUAL(gygax.aq_step_delay(), base_step, "Gygax step delay after overload and overclock")

	// Ripley: update_pressure ustawia step_in przy każdym kroku, overclock działa mimo to
	var/obj/mecha/working/ripley/ripley = allocate(/obj/mecha/working/ripley)
	ripley.update_pressure()
	var/ripley_step = ripley.step_in
	ripley.aq_set_overclock(TRUE)
	ripley.update_pressure()
	TEST_ASSERT(ripley.aq_step_delay() < ripley.step_in, "overclock does not speed up a Ripley")
	ripley.can_move = 0
	TEST_ASSERT(ripley.domove(NORTH), "Ripley did not move or turn")
	TEST_ASSERT_EQUAL(ripley.can_move - world.time, ripley.aq_step_delay(), "Ripley step after domove ignores overclock")
	ripley.aq_set_overclock(FALSE)
	ripley.update_pressure()
	TEST_ASSERT_EQUAL(ripley.aq_step_delay(), ripley_step, "Ripley step after overclock")
	// Paddy ma własny, wolniejszy krok także po update_pressure
	var/obj/mecha/working/ripley/aq_paddy/paddy = allocate(/obj/mecha/working/ripley/aq_paddy)
	paddy.update_pressure()
	TEST_ASSERT(paddy.step_in > ripley.step_in, "Paddy step ([paddy.step_in]) not slower than a Ripley MK-I ([ripley.step_in])")

	// Płyta pancerza spowalnia tylko póki jest przykręcona, cykle nie zmieniają kroku
	var/obj/mecha/combat/durand/durand = allocate(/obj/mecha/combat/durand)
	durand.construction_state = MECHA_OPEN_HATCH
	var/obj/item/mecha_parts/aq_armor_plating/reinforced/plate = allocate(/obj/item/mecha_parts/aq_armor_plating/reinforced)
	for(var/i in 1 to 3)
		TEST_ASSERT(durand.aq_install_plating(plate), "plating did not install")
		TEST_ASSERT_EQUAL(durand.aq_step_delay(), durand.step_in + plate.plate_slowdown, "plating slowdown")
		durand.aq_remove_plating()
	TEST_ASSERT_EQUAL(durand.step_in, initial(durand.step_in), "Durand step after plating cycles")
	TEST_ASSERT_EQUAL(durand.aq_step_delay(), initial(durand.step_in), "Durand step delay after plating cycles")

/// Drugie miejsce sprawdza blokadę DNA; martwy kierowca nie blokuje strzelca i nie przejmuje fotela; po zdalnym
/// pilocie fotel przejmuje żywy kierowca; strafe bez klienta pilota nie daje runtime'u
/datum/unit_test/aquila_mecha_copilot_access

/datum/unit_test/aquila_mecha_copilot_access/Run()
	var/obj/mecha/combat/aq_savannah/mech = allocate(/obj/mecha/combat/aq_savannah)
	var/mob/living/carbon/human/gunner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human)
	mech.occupant = gunner
	gunner.forceMove(mech)
	mech.GrantActions(gunner, TRUE)
	mech.dna_lock = gunner.dna.unique_enzymes
	TEST_ASSERT(!mech.aq_try_enter_copilot(stranger), "a stranger got into the second seat of a DNA-locked mech")
	TEST_ASSERT(isnull(mech.aq_copilot), "DNA-locked mech has a copilot")
	mech.dna_lock = null

	var/mob/living/carbon/human/driver = allocate(/mob/living/carbon/human)
	mech.aq_copilot = driver
	driver.forceMove(mech)
	mech.aq_grant_copilot_actions(driver)
	driver.death()
	TEST_ASSERT(mech.relaymove(gunner, NORTH), "a dead driver blocks the gunner")
	mech.strafe = TRUE
	mech.can_move = 0
	mech.domove(turn(mech.dir, 180)) // strafe czyta Alt kierowcy: nikt tu nie ma klienta
	mech.strafe = FALSE
	mech.go_out()
	TEST_ASSERT(isnull(mech.occupant), "a dead driver took over the pilot seat")
	TEST_ASSERT_EQUAL(mech.aq_copilot, driver, "dead driver left the driver seat")
	mech.aq_copilot_out()

	// Pilot zdalny kończy sesję: żywy kierowca z graczem przejmuje fotel
	var/mob/living/carbon/human/remote = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/mob/living/carbon/human/live_driver = allocate(/mob/living/carbon/human)
	mech.aq_remote_pilot = remote
	mech.occupant = remote
	remote.remote_control = mech
	mech.aq_copilot = live_driver
	live_driver.forceMove(mech)
	set_test_controls(live_driver, FALSE)
	mech.go_out()
	TEST_ASSERT(isnull(mech.aq_remote_pilot), "remote session did not end")
	TEST_ASSERT_EQUAL(mech.occupant, live_driver, "driver did not take over after the remote pilot left")
	TEST_ASSERT(isnull(mech.aq_copilot), "driver still in the copilot seat after taking over")

/// Odłączenie albo zniszczenie systemu zrzutu w locie przywraca mecha (regresja: zostawał niewidzialny i wyłączony)
/datum/unit_test/aquila_mecha_drop_abort

/datum/unit_test/aquila_mecha_drop_abort/Run()
	var/obj/mecha/combat/gygax/mech = allocate(/obj/mecha/combat/gygax)
	for(var/destroy in list(FALSE, TRUE))
		var/obj/item/mecha_parts/mecha_equipment/aq_drop_system/drop = allocate(/obj/item/mecha_parts/mecha_equipment/aq_drop_system)
		drop.attach(mech)
		// stan po starcie zrzutu (start_drop)
		drop.in_flight = TRUE
		mech.completely_disabled = TRUE
		mech.density = FALSE
		mech.alpha = 0
		mech.pixel_z = 300
		if(destroy)
			qdel(drop)
		else
			drop.detach(run_loc_floor_top_right)
		var/how = destroy ? "destroyed" : "detached"
		TEST_ASSERT(!mech.completely_disabled, "mech still disabled after the drop system was [how] in flight")
		TEST_ASSERT(mech.density, "mech not dense after the drop system was [how] in flight")
		TEST_ASSERT_EQUAL(mech.alpha, 255, "mech alpha after the drop system was [how] in flight")
		TEST_ASSERT_EQUAL(mech.pixel_z, 0, "mech pixel_z after the drop system was [how] in flight")
		if(!destroy)
			TEST_ASSERT(!drop.in_flight, "detached drop system still in flight")
			drop.land(get_turf(mech)) // spóźniony timer lądowania nic nie robi
			TEST_ASSERT_EQUAL(get_turf(mech), run_loc_floor_bottom_left, "late landing timer moved the mech")

/// Stare bronie balistyczne mają zapas startowy: gotowe mechy z uplinka strzelają i przeładowują (też pilot NPC)
/datum/unit_test/aquila_mecha_starting_ammo

/datum/unit_test/aquila_mecha_starting_ammo/Run()
	var/list/old_guns = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove,
	)
	for(var/path in old_guns)
		var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = path
		TEST_ASSERT(initial(gun.aq_ammo_cache) > 0, "[path] has no starting ammo reserve")
		TEST_ASSERT(initial(gun.aq_ammo_cache) <= initial(gun.aq_ammo_cache_max), "[path] starting reserve above its capacity")
	for(var/mech_type in list(/obj/mecha/combat/gygax/dark/loaded, /obj/mecha/combat/marauder/mauler/loaded))
		var/obj/mecha/M = allocate(mech_type)
		var/guns = 0
		for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/G in M.equipment)
			guns++
			G.projectiles = 0
			// jak mecha_reload() pilota NPC
			TEST_ASSERT(G.needs_rearm(), "[G] in [mech_type] does not ask for a reload")
			G.rearm()
			TEST_ASSERT(G.projectiles > 0, "[G] in [mech_type] could not reload from its reserve")
		TEST_ASSERT(guns, "[mech_type] has no ballistic weapons")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
