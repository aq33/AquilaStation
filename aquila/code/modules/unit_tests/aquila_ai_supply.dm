/// AQUILA - skończone zapasy na lotniskowcach AI (aquila/code/modules/overmap/ai_supply.dm): uzupełnianie daje
/// po kilka rakiet i torped z ograniczonego zapasu, a okręt bez torped nie wraca po nie, gdy flocie się skończyły.
/datum/unit_test/aquila_ai_supply
	var/obj/structure/overmap/small_craft/carrier
	var/obj/structure/overmap/small_craft/ship

/datum/unit_test/aquila_ai_supply/Run()
	var/was_enabled = GLOB.ai_finite_supply_enabled
	GLOB.ai_finite_supply_enabled = TRUE
	carrier = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/z = run_loc_floor_bottom_left.z
	carrier.forceMove(locate(100, 60, z))
	ship.forceMove(locate(105, 60, z))
	carrier.ai_controlled = TRUE
	carrier.can_resupply = TRUE
	ship.ai_controlled = TRUE
	ship.faction = carrier.faction
	ship.max_torpedoes = 10
	ship.max_missiles = 10
	var/fail = check_resupply() || check_rearm() || check_disabled()
	carrier.ai_controlled = FALSE
	ship.ai_controlled = FALSE
	GLOB.ai_finite_supply_enabled = was_enabled
	if(fail)
		return Fail(fail)

/// Jeden cykl uzupełniania, tak jak go woła ai_process() przez addtimer
/datum/unit_test/aquila_ai_supply/proc/cycle()
	carrier.resupply_target = ship
	carrier.resupplying = 1
	carrier.resupply()

/// Zgłoszony przypadek: przy lotniskowcu okręt dostawał co 5 s pełny magazyn, bez końca
/datum/unit_test/aquila_ai_supply/proc/check_resupply()
	carrier.ai_supply_torpedoes = -1
	carrier.ai_supply_missiles = -1
	ship.torpedoes = 0
	ship.missiles = 0
	cycle()
	if(ship.torpedoes != 2 || ship.missiles != 4)
		return "Jeden cykl dał [ship.torpedoes] torped i [ship.missiles] rakiet zamiast 2 i 4"
	if(carrier.ai_supply_torpedoes != 18 || carrier.ai_supply_missiles != 36)
		return "Zapas lotniskowca po cyklu to [carrier.ai_supply_torpedoes] torped i [carrier.ai_supply_missiles] rakiet zamiast 18 i 36"
	if(carrier.resupply_target)
		return "Lotniskowiec nie zwolnił okrętu po cyklu"
	// Okręt wystrzeliwuje wszystko i wraca, aż zapas się skończy
	for(var/i in 1 to 15)
		ship.torpedoes = 0
		ship.missiles = 0
		cycle()
	if(carrier.ai_supply_torpedoes != 0)
		return "Po wyczerpaniu zapasu lotniskowiec dalej miał [carrier.ai_supply_torpedoes] torped"
	ship.torpedoes = 0
	cycle()
	if(ship.torpedoes)
		return "Lotniskowiec z pustym zapasem dalej wydawał torpedy ([ship.torpedoes])"
	// Działa i kadłub dalej uzupełnia
	ship.shots_left = 0
	cycle()
	if(ship.shots_left != ship.max_shots_left)
		return "Pusty zapas torped zatrzymał też amunicję do dział"

/// Okręt bez torped wraca po nie tylko wtedy, gdy lotniskowiec floty jeszcze je ma
/datum/unit_test/aquila_ai_supply/proc/check_rearm()
	var/datum/fleet/test_fleet = new /datum/fleet()
	test_fleet.taskforces = list("fighters" = list(), "destroyers" = list(), "battleships" = list(), "supply" = list(carrier))
	ship.fleet = test_fleet
	ship.obj_integrity = ship.max_integrity
	ship.shots_left = ship.max_shots_left
	ship.torpedoes = 0
	var/datum/ai_goal/rearm/prey = new /datum/ai_goal/rearm()
	var/outcome
	carrier.ai_supply_torpedoes = 5
	if(prey.check_score(ship) != AI_SCORE_PRIORITY)
		outcome = "Okręt bez torped nie wracał po nie, choć lotniskowiec je miał"
	if(!outcome)
		carrier.ai_supply_torpedoes = 0
		if(prey.check_score(ship))
			outcome = "Okręt bez torped wracał do lotniskowca, który nie miał już czego wydać"
	if(!outcome)
		// Brak amunicji do dział to dalej powód do powrotu
		ship.shots_left = 0
		if(ship.max_shots_left && prey.check_score(ship) != AI_SCORE_PRIORITY)
			outcome = "Okręt bez amunicji do dział nie wracał, bo flocie skończyły się torpedy"
		ship.shots_left = ship.max_shots_left
	ship.fleet = null
	qdel(prey)
	return outcome

/// Z wyłączonym przełącznikiem: bazowy pełny magazyn
/datum/unit_test/aquila_ai_supply/proc/check_disabled()
	GLOB.ai_finite_supply_enabled = FALSE
	carrier.ai_supply_torpedoes = 0
	ship.torpedoes = 0
	ship.missiles = 0
	cycle()
	GLOB.ai_finite_supply_enabled = TRUE
	if(ship.torpedoes != ship.max_torpedoes || ship.missiles != ship.max_missiles)
		return "Z wyłączonym przełącznikiem okręt nie dostał pełnego magazynu ([ship.torpedoes]/[ship.max_torpedoes])"
