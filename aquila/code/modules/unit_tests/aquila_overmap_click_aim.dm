/// AQUILA - celowanie kliknięciem na mapie kosmosu (aquila/code/modules/overmap/overmap_click_aim.dm).
/// Klik w prawy górny róg gwiazdy (160x160 px) celował w jej lewy dolny róg, 4 kafle obok kursora.
/datum/unit_test/aquila_overmap_click_aim

/datum/unit_test/aquila_overmap_click_aim/Run()
	var/list/overmap_levels = SSmapping.levels_by_trait(ZTRAIT_OVERMAP)
	if(!length(overmap_levels))
		return // Bez mapy kosmosu w tym przebiegu nie ma czego sprawdzać
	var/overmap_z = overmap_levels[1]
	var/obj/structure/overmap/small_craft/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/structure/overmap/small_craft/enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.forceMove(locate(100, 100, overmap_z))
	enemy.forceMove(locate(120, 120, overmap_z))
	var/obj/effect/overmap_anomaly/safe/sun/sun = allocate(/obj/effect/overmap_anomaly/safe/sun, locate(110, 110, overmap_z))
	var/obj/effect/temp_visual/shifted = allocate(/obj/effect/temp_visual, locate(90, 90, overmap_z))
	shifted.pixel_x = -32
	shifted.pixel_y = -32

	// Piksel (150, 140) ikony gwiazdy leży w kaflu o 4 w prawo i 4 w górę od jej loc
	var/atom/aimed = ship.get_click_aim_target(sun, "icon-x=150;icon-y=140;left=1")
	if(aimed != locate(114, 114, overmap_z))
		return Fail("Clicking the sun aims at ([aimed?.x], [aimed?.y]) instead of the turf under the cursor (114, 114)")
	// Lewy dolny piksel gwiazdy to jej własny kafel
	aimed = ship.get_click_aim_target(sun, "icon-x=1;icon-y=1")
	if(aimed != locate(110, 110, overmap_z))
		return Fail("Clicking the bottom left corner of the sun aims at ([aimed?.x], [aimed?.y]) instead of (110, 110)")
	// Efekt przesunięty o kafel w lewo i w dół: jego piksel (10, 10) leży na kaflu obok loc
	aimed = ship.get_click_aim_target(shifted, "icon-x=10;icon-y=10")
	if(aimed != locate(89, 89, overmap_z))
		return Fail("Clicking a shifted effect aims at ([aimed?.x], [aimed?.y]) instead of (89, 89)")
	// Okręt zostaje celem (środek okrętu, namierzanie ctrl-klikiem), kafel też
	if(ship.get_click_aim_target(enemy, "icon-x=60;icon-y=60") != enemy)
		return Fail("Clicking a ship no longer targets the ship")
	var/turf/space = locate(105, 100, overmap_z)
	if(ship.get_click_aim_target(space, "icon-x=5;icon-y=5") != space)
		return Fail("Clicking a turf changed the target")
	// Bez współrzędnych kursora cel się nie zmienia
	if(ship.get_click_aim_target(sun, "left=1") != sun)
		return Fail("A click without icon-x/icon-y changed the target")
	// Poza mapą kosmosu (np. przyciski na mostku) nic się nie zmienia
	var/obj/item/thing = allocate(/obj/item, run_loc_floor_bottom_left)
	if(ship.get_click_aim_target(thing, "icon-x=150;icon-y=140") != thing)
		return Fail("A click off the overmap changed the target")
