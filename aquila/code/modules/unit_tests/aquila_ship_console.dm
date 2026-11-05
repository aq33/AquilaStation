// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - panel konsoli: pilot myśliwca dostaje panel, panel pokazuje stan statku, znika po zejściu ze sterów
/datum/unit_test/aquila_ship_console
	var/obj/structure/overmap/small_craft/combat/light/fighter
	var/mob/living/carbon/human/dummy

/datum/unit_test/aquila_ship_console/Run()
	var/turf/center = SSmapping.get_station_center()
	TEST_ASSERT(center, "No station center")
	fighter = new(center)
	dummy = new(center)
	fighter.enter(dummy)
	fighter.start_piloting(dummy, OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)

	TEST_ASSERT_EQUAL(LAZYLEN(dummy.aquila_consoles), 1, "Fighter pilot should get exactly one console panel")
	var/atom/movable/screen/movable/aquila_ship_console/panel = dummy.aquila_consoles[1]
	TEST_ASSERT_EQUAL(panel.kind, "fighter", "Fighter pilot got the wrong panel")

	// hamulec i sterowanie trafiają na panel
	fighter.brakes = TRUE
	fighter.move_by_mouse = FALSE
	var/list/layers = splittext(panel.build_state(), ";")
	TEST_ASSERT("brake_on" in layers, "Brakes on should light brake_on, got [panel.build_state()]")
	TEST_ASSERT("rotation_keyboard" in layers, "Keyboard rotation should light rotation_keyboard, got [panel.build_state()]")
	fighter.brakes = FALSE
	fighter.move_by_mouse = TRUE
	layers = splittext(panel.build_state(), ";")
	TEST_ASSERT("brake_off" in layers, "Brakes off should light brake_off, got [panel.build_state()]")
	TEST_ASSERT("rotation_mouse" in layers, "Mouse rotation should light rotation_mouse, got [panel.build_state()]")

	// progi kadłuba
	var/list/expected_hull = list(list(100, 100), list(80, 75), list(50, 50), list(20, 25), list(5, 0))
	for(var/list/pair in expected_hull)
		fighter.obj_integrity = fighter.max_integrity * pair[1] / 100
		TEST_ASSERT_EQUAL(aquila_console_hull_level(fighter), pair[2], "Hull at [pair[1]]% shows the wrong level")
	fighter.obj_integrity = fighter.max_integrity

	// broń myśliwca: działko i torpedy
	for(var/datum/overmap_ship_weapon/weapon as anything in fighter.overmap_weapon_datums)
		if(istype(weapon, /datum/overmap_ship_weapon/fighter/secondary))
			TEST_ASSERT_EQUAL(aquila_console_weapon_category(weapon), "torpedo", "Fighter secondary should show the torpedo")
		else if(istype(weapon, /datum/overmap_ship_weapon/fighter/primary))
			TEST_ASSERT_EQUAL(aquila_console_weapon_category(weapon), "pdc", "Fighter primary should show the cannon")

	// klik na przełącznik bez drugiego nie katapultuje
	panel.use_button("switch_left")
	TEST_ASSERT(panel.left_armed_until > world.time, "Left eject switch did not arm")
	TEST_ASSERT_EQUAL(dummy.loc, fighter, "One eject switch alone must not eject the pilot")

	// przeciągnięty panel nie wyjeżdża za ekran (widok 21x15 kafelków, panel myśliwca 195x155 po skali 0.75)
	TEST_ASSERT_EQUAL(aquila_console_clamp_screen_loc("40:10,30:5", 21, 15, 195, 155), "15:29,11:5", "Panel dropped past the top-right corner was not pulled back on screen")
	TEST_ASSERT_EQUAL(aquila_console_clamp_screen_loc("1:-50,1:-50", 21, 15, 195, 155), "1:0,1:0", "Panel dropped past the bottom-left corner was not pulled back on screen")
	TEST_ASSERT_EQUAL(aquila_console_clamp_screen_loc("5:3,4:7", 21, 15, 195, 155), "5:3,4:7", "Panel fully on screen should stay where it was dropped")
	TEST_ASSERT(isnull(aquila_console_clamp_screen_loc("CENTER:-100,SOUTH+1", 21, 15, 195, 155)), "Default centered position should not be rewritten")

	// panel usunięty sam (np. statek zniknął) nie zostaje na liście
	var/atom/movable/screen/movable/aquila_ship_console/extra = new(null, fighter, dummy, "fighter")
	LAZYADD(dummy.aquila_consoles, extra)
	qdel(extra)
	TEST_ASSERT(!(extra in dummy.aquila_consoles), "Deleted panel stayed in aquila_consoles")

	// zejście ze sterów usuwa panel
	fighter.stop_piloting(dummy, eject_mob = FALSE)
	TEST_ASSERT(!LAZYLEN(dummy.aquila_consoles), "Panel stayed after the pilot left the controls")
	TEST_ASSERT(QDELETED(panel), "Panel was not deleted after the pilot left the controls")

/datum/unit_test/aquila_ship_console/Destroy()
	// najpierw wyjmij człowieka z myśliwca, inaczej Destroy() myśliwca wystrzeli z nim kapsułę
	if(fighter && dummy)
		fighter.mobs_in_ship -= dummy
		dummy.moveToNullspace()
	QDEL_NULL(fighter)
	QDEL_NULL(dummy)
	return ..()

/// AQUILA - ręczna katapulta: pilot trafia do kapsuły ratunkowej, myśliwiec zostaje pusty z hamulcem
/datum/unit_test/aquila_manual_eject
	var/obj/structure/overmap/small_craft/combat/light/fighter
	var/mob/living/carbon/human/dummy
	var/obj/structure/overmap/small_craft/escapepod/pod

/datum/unit_test/aquila_manual_eject/Run()
	var/turf/center = SSmapping.get_station_center()
	TEST_ASSERT(center, "No station center")
	fighter = new(center)
	dummy = new(center)
	fighter.enter(dummy)
	fighter.start_piloting(dummy, OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)
	fighter.brakes = FALSE

	// na pokładzie statku (stacja jest poziomem do abordażu) katapulta odmawia
	if(SSmapping.level_trait(fighter.z, ZTRAIT_BOARDABLE))
		TEST_ASSERT(!fighter.aquila_can_manual_eject(dummy), "Manual eject should be refused on a boardable level")

	TEST_ASSERT(fighter.aquila_manual_eject(dummy), "Manual eject failed")
	pod = dummy.loc
	TEST_ASSERT(istype(pod, /obj/structure/overmap/small_craft/escapepod), "Pilot ended up in [dummy.loc] instead of an escape pod")
	TEST_ASSERT_EQUAL(pod.pilot, dummy, "Ejected pilot should fly the escape pod")
	TEST_ASSERT(!QDELETED(fighter), "Fighter should stay after the pilot ejects")
	TEST_ASSERT(isnull(fighter.pilot), "Fighter still has a pilot after the eject")
	TEST_ASSERT(fighter.brakes, "Abandoned fighter should have its brakes on")
	TEST_ASSERT(!(dummy in fighter.mobs_in_ship), "Pilot is still counted as inside the fighter")
	TEST_ASSERT(!pod.aquila_can_manual_eject(dummy), "An escape pod must not eject again")

/datum/unit_test/aquila_manual_eject/Destroy()
	// najpierw wyjmij człowieka z kapsuły, inaczej Destroy() kapsuły zada „załodze bez kapsuły” 200 obrażeń
	if(pod && !QDELETED(pod) && dummy)
		pod.stop_piloting(dummy, eject_mob = FALSE)
		pod.mobs_in_ship -= dummy
		dummy.moveToNullspace()
	QDEL_NULL(pod)
	QDEL_NULL(fighter)
	QDEL_NULL(dummy)
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL


