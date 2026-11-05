/// AQUILA - AI morale (aquila/code/modules/overmap/ai_morale.dm): heavy damage in a short time scares a ship into the retreat zone,
/// temperament scales the fear, a scared ship keeps its distance, a fleeing one beats every other goal, and a calm one rallies
/datum/unit_test/aquila_ai_morale
	var/obj/structure/overmap/ship
	var/obj/structure/overmap/small_craft/enemy

/// Unarmed, so nothing it does in the test can hurt the run
/obj/structure/overmap/syndicate/ai/gunboat/morale_test
	missiles = 0
	shots_left = 0
	torpedoes = 0

/obj/structure/overmap/syndicate/ai/gunboat/morale_test/apply_weapons()
	return

/datum/unit_test/aquila_ai_morale/Run()
	var/was_enabled = GLOB.ai_morale_enabled
	GLOB.ai_morale_enabled = TRUE
	ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy.faction = "nanotrasen"
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	enemy.forceMove(locate(30, 10, run_loc_floor_bottom_left.z))
	var/fail = check_burst() || check_temperament() || check_flee_goal() || check_standoff() || check_hesitation()
	GLOB.ai_morale_enabled = was_enabled
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_ai_morale/proc/reset(temperament = "zwykły")
	ship.ai_temperament = temperament
	ship.ai_odds_error = 0
	ship.ai_odds_ratio = 1
	ship.ai_shock = 0
	ship.ai_fear = 0
	ship.ai_recent_damage = 0
	ship.ai_fleeing = FALSE
	ship.ai_flags &= ~AI_FLAG_ELITE
	ship.obj_integrity = ship.max_integrity
	ship.ai_last_integrity = ship.max_integrity

/datum/unit_test/aquila_ai_morale/proc/check_burst()
	reset()
	if(!ship.can_ai_flee())
		return "The test gunboat is not allowed to flee, the test cannot check retreats"
	ship.update_ai_morale()
	if(ship.ai_fear > 1)
		return "An undamaged ship with even odds was scared ([ship.ai_fear])"
	// 30% of the hull in one hit: two ticks later the ship is in the retreat zone
	ship.obj_integrity -= ship.max_integrity * 0.3
	ship.update_ai_morale()
	ship.update_ai_morale()
	if(ship.ai_fear < 60)
		return "Losing 30% of the hull at once left the ship below the retreat threshold (fear [ship.ai_fear])"
	// Nobody shooting any more: the fear goes down again
	var/peak = ship.ai_fear
	for(var/i in 1 to 30)
		ship.update_ai_morale()
	if(ship.ai_fear >= peak)
		return "Fear did not fade once the damage stopped ([peak] -> [ship.ai_fear])"

/datum/unit_test/aquila_ai_morale/proc/check_temperament()
	var/list/fear = list()
	for(var/temperament in list("ostrożny", "zwykły", "brawurowy"))
		reset(temperament)
		ship.ai_recent_damage = ship.max_integrity * 0.2
		fear[temperament] = ship.get_ai_fear_target()
	reset()
	ship.ai_flags |= AI_FLAG_ELITE
	ship.ai_recent_damage = ship.max_integrity * 0.2
	var/elite = ship.get_ai_fear_target()
	ship.ai_flags &= ~AI_FLAG_ELITE
	if(!(fear["ostrożny"] > fear["zwykły"] && fear["zwykły"] > fear["brawurowy"] && fear["zwykły"] > elite))
		return "Temperament did not scale fear (cautious [fear["ostrożny"]], normal [fear["zwykły"]], reckless [fear["brawurowy"]], elite [elite])"
	// A commander who overestimates the enemy is more scared at the same real odds
	reset()
	ship.ai_odds_ratio = 2
	var/fair = ship.get_ai_fear_target()
	ship.ai_odds_ratio = 2 * 1.3
	if(ship.get_ai_fear_target() <= fair)
		return "Overestimating the enemy did not raise fear"

/datum/unit_test/aquila_ai_morale/proc/check_flee_goal()
	reset()
	var/datum/ai_goal/ai_flee/goal = new
	ship.ai_fleeing = TRUE
	var/fleeing_score = goal.check_score(ship)
	var/old_mass = ship.mass
	ship.mass = MASS_TINY
	var/fighter_score = goal.check_score(ship)
	ship.mass = old_mass
	ship.ai_fleeing = FALSE
	var/calm_score = goal.check_score(ship)
	qdel(goal)
	if(fleeing_score <= AI_SCORE_MAXIMUM + 1)
		return "A fleeing ship's escape goal does not beat seek and stationary goals (score [fleeing_score])"
	if(fighter_score || calm_score)
		return "The escape goal was picked by a fighter ([fighter_score]) or a ship that is not fleeing ([calm_score])"
	// Calm again: the ship rallies and stops running
	reset()
	ship.ai_fleeing = TRUE
	ship.update_ai_morale()
	if(ship.ai_fleeing)
		return "A ship with no fear left kept running"

/datum/unit_test/aquila_ai_morale/proc/check_standoff()
	reset()
	ship.ai_fear = 40
	var/scared = ship.get_ai_standoff_range(enemy)
	reset("brawurowy")
	ship.ai_fear = 40
	var/reckless = ship.get_ai_standoff_range(enemy)
	if(scared < 35)
		return "A scared ship did not keep out of gun range (standoff [scared])"
	if(reckless)
		return "A reckless commander kept its distance (standoff [reckless])"

/datum/unit_test/aquila_ai_morale/proc/check_hesitation()
	reset()
	ship.last_target = null
	ship.ai_hold_fire_until = 0
	ship.add_enemy(enemy)
	if(ship.last_target != enemy || ship.ai_hold_fire_until <= world.time)
		return "A normal commander opened fire on a new target without hesitating"
	reset("brawurowy")
	ship.last_target = null
	ship.ai_hold_fire_until = 0
	ship.add_enemy(enemy)
	if(ship.ai_hold_fire_until > world.time)
		return "A reckless commander hesitated before opening fire"
	ship.last_target = null
