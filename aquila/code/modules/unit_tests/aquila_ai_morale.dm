/// AQUILA - AI morale (aquila/code/modules/overmap/ai_morale.dm, ai_targeting.dm): heavy damage in a short time scares a ship into the retreat zone,
/// temperament scales the fear, a scared ship keeps its distance, a fleeing one beats every other goal, a calm one rallies,
/// and a commander switches to a crippled ship or to whoever is shooting at it
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
	var/fail = check_burst() || check_temperament() || check_flee_goal() || check_standoff() || check_hesitation() || check_retarget() || check_flanking() || check_escape()
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

/datum/unit_test/aquila_ai_morale/proc/check_retarget()
	reset()
	var/obj/structure/overmap/small_craft/second = allocate(/obj/structure/overmap/small_craft/combat/light)
	second.faction = "nanotrasen"
	// The gunboat does not take forceMove to the corner of the test level, so the targets are placed around it
	ship.velocity._set(0, 0)
	enemy.forceMove(locate(ship.x + 10, ship.y, ship.z)) // 10 tiles, intact
	second.forceMove(locate(ship.x, ship.y + 14, ship.z)) // 14 tiles, crippled
	enemy.obj_integrity = enemy.max_integrity
	second.obj_integrity = second.max_integrity * 0.3
	enemy.update_sensor_signature()
	second.update_sensor_signature()
	var/list/candidates = list(enemy, second)
	LAZYNULL(ship.ai_attackers)
	ship.last_target = enemy
	var/obj/structure/overmap/picked = ship.choose_ai_tactical_target(candidates)
	if(picked != second)
		return "The commander did not switch to a crippled ship nearby (picked [picked || "nothing"])"
	// Whoever is shooting at us comes first
	LAZYSET(ship.ai_attackers, enemy, world.time)
	ship.last_target = second
	picked = ship.choose_ai_tactical_target(candidates)
	if(picked != enemy)
		return "The commander did not turn on the ship shooting at it (picked [picked || "nothing"])"
	// Already on the best target: no switch
	ship.last_target = enemy
	picked = ship.choose_ai_tactical_target(candidates)
	if(picked)
		return "The commander switched away from its best target to [picked]"
	LAZYNULL(ship.ai_attackers)
	ship.last_target = null
	if(ship.get_ai_retarget_chance() != 100)
		return "A normal commander does not reconsider its target every check"
	reset("brawurowy")
	if(ship.get_ai_retarget_chance() >= 100)
		return "A reckless commander has no target fixation"

/datum/unit_test/aquila_ai_morale/proc/check_flanking()
	reset()
	var/obj/structure/overmap/wing = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	wing.ai_temperament = "zwykły"
	enemy.forceMove(locate(ship.x + 30, ship.y, ship.z))
	enemy.angle = 180 // Heading south; the slot must not depend on it
	var/list/ships = list(ship, wing)
	ship.last_target = enemy
	wing.last_target = enemy
	if(ship.get_ai_flank_point(enemy, ships))
		return "The first attacker (the anchor) was sent to a flank slot instead of attacking head on"
	var/turf/slot = wing.get_ai_flank_point(enemy, ships)
	if(!slot)
		return "The second attacker did not get a flank slot"
	// The anchor attacks from the west (bearing 270 from the target); the second ship takes the slot 90 degrees round on the side
	// it is already on: 18 tiles north or south
	if(abs(slot.x - enemy.x) > 1 || abs(abs(slot.y - enemy.y) - 18) > 1)
		return "The flank slot is not beside the anchor's line of attack ([slot.x], [slot.y], target at [enemy.x], [enemy.y], anchor at [ship.x], [ship.y])"
	wing.ai_temperament = "brawurowy"
	if(wing.get_ai_flank_point(enemy, ships))
		return "A reckless commander took a flank slot instead of charging"
	wing.ai_temperament = "zwykły"
	ship.last_target = null
	if(wing.get_ai_flank_point(enemy, ships))
		return "A lone attacker was sent to a flank slot"
	wing.last_target = null

/// Regression: the escape used to qdel the ship inside ai_process() (which then kept running on the deleted ship),
/// with the explosion, the wreck and the "reactor critical" warning of a real kill
/datum/unit_test/aquila_ai_morale/proc/check_escape()
	reset()
	ship.enemies = list(enemy)
	ship.ai_escape()
	if(QDELETED(ship))
		return "An escaping ship was deleted on the spot instead of after the current AI tick"
	if(ship.destruction_effects || length(ship.enemies))
		return "An escaping ship would explode and warn its enemies like a destroyed one"
	var/datum/ai_goal/ai_flee/goal = new
	ship.ai_fleeing = TRUE
	var/score = goal.check_score(ship)
	qdel(goal)
	if(score)
		return "A ship that already jumped out still picks the escape goal"
