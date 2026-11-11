/// AQUILA - działa jako ostateczność (aquila/code/modules/overmap/ai_weapon_doctrine.dm): okręt AI z amunicją
/// kierowaną pasującą do celu nie strzela do niego z dział dalej niż z bliska.

/// Podtyp testowy: amunicja kierowana podstawiana wprost, bo zależy od uzbrojenia typu
/obj/structure/overmap/small_craft/combat/light/doctrine_test
	var/test_guided = FALSE

/obj/structure/overmap/small_craft/combat/light/doctrine_test/has_ai_guided_option(obj/structure/overmap/target)
	return test_guided

/datum/unit_test/aquila_ai_weapon_doctrine

/datum/unit_test/aquila_ai_weapon_doctrine/Run()
	var/was_enabled = GLOB.ai_guns_last_resort_enabled
	GLOB.ai_guns_last_resort_enabled = TRUE
	var/z = run_loc_floor_bottom_left.z
	var/obj/structure/overmap/small_craft/combat/light/doctrine_test/ship = allocate(/obj/structure/overmap/small_craft/combat/light/doctrine_test)
	var/obj/structure/overmap/small_craft/combat/light/target = allocate(/obj/structure/overmap/small_craft/combat/light)
	target.faction = "syndicate"
	ship.ai_controlled = TRUE
	ship.forceMove(locate(100, 60, z))
	target.forceMove(locate(100, 90, z)) // 30 pól
	var/fail = check(ship, target)
	ship.ai_controlled = FALSE
	GLOB.ai_guns_last_resort_enabled = was_enabled
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_ai_weapon_doctrine/proc/check(obj/structure/overmap/small_craft/combat/light/doctrine_test/ship, obj/structure/overmap/target)
	var/z = run_loc_floor_bottom_left.z
	ship.test_guided = TRUE
	if(!ship.ai_holds_guns_for(target))
		return "Okręt z amunicją kierowaną nie trzymał dział na cel 30 pól dalej"
	// Zgłoszony przypadek: działa strzelały z dystansu, choć okręt miał torpedy
	var/datum/overmap_ship_weapon/dzialo
	for(var/datum/overmap_ship_weapon/weapon as anything in ship.overmap_weapon_datums)
		if(!weapon.is_guided_weapon())
			dzialo = weapon
			break
	if(dzialo && dzialo.can_fire(target))
		return "Broń niekierowana dostała zgodę na strzał z dystansu, choć okręt miał amunicję kierowaną"
	target.forceMove(locate(100, 70, z)) // 10 pól
	if(ship.ai_holds_guns_for(target))
		return "Okręt trzymał działa na cel tuż obok"
	target.forceMove(locate(100, 90, z))
	ship.test_guided = FALSE
	if(ship.ai_holds_guns_for(target))
		return "Okręt bez amunicji kierowanej trzymał działa"
	ship.test_guided = TRUE
	ship.ai_controlled = FALSE
	var/gracz = ship.ai_holds_guns_for(target)
	ship.ai_controlled = TRUE
	if(gracz)
		return "Zasada działała na okręcie gracza"
	GLOB.ai_guns_last_resort_enabled = FALSE
	var/wylaczone = ship.ai_holds_guns_for(target)
	GLOB.ai_guns_last_resort_enabled = TRUE
	if(wylaczone)
		return "Zasada działała z wyłączonym przełącznikiem"

/// Daleki ostrzał: cel dalej niż 50 pól tylko wtedy, gdy nasze sensory go widzą, i nie dalej niż 120 pól
/datum/unit_test/aquila_ai_long_range_fire

/datum/unit_test/aquila_ai_long_range_fire/Run()
	var/z = run_loc_floor_bottom_left.z
	var/obj/structure/overmap/small_craft/combat/light/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/structure/overmap/small_craft/combat/light/target = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.ai_controlled = TRUE
	ship.mass = MASS_MEDIUM // radar (lidar) mają okręty większe od myśliwca
	target.mass = MASS_MEDIUM
	target.faction = "syndicate"
	ship.forceMove(locate(60, 60, z))
	var/list/okrety = list(ship, target)
	var/fail
	// Radar w czasie impulsu: widzimy do max_tracking_range
	ship.max_tracking_range = 100
	ship.last_radar_pulse = world.time
	target.forceMove(locate(60, 130, z)) // 70 pól
	if(ship.get_ai_long_range_target(okrety) != target)
		fail = "Okręt nie wybrał celu 70 pól dalej, choć jego radar go widział"
	if(!fail)
		target.forceMove(locate(60, 100, z)) // 40 pól: to robota zwykłego ai_fire()
		if(ship.get_ai_long_range_target(okrety))
			fail = "Daleki ostrzał wybrał cel w zwykłym zasięgu ognia"
	if(!fail)
		target.forceMove(locate(60, 195, z)) // 135 pól
		if(ship.get_ai_long_range_target(okrety))
			fail = "Daleki ostrzał wybrał cel dalej niż 120 pól"
	if(!fail)
		// Bez impulsu zimny cel 70 pól dalej jest niewidoczny
		ship.last_radar_pulse = -INFINITY
		target.thrust_heat = 0
		target.inertial_dampeners = FALSE
		target.last_weapon_fire = -INFINITY
		target.forceMove(locate(60, 130, z))
		if(ship.get_ai_long_range_target(okrety))
			fail = "Okręt wybrał na daleki ostrzał cel, którego jego sensory nie widziały"
	ship.ai_controlled = FALSE
	if(fail)
		return Fail(fail)
