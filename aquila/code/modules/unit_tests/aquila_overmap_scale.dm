/// AQUILA - overmap scale (aquila/code/modules/overmap/overmap_scale.dm): ships are slower and guns reach half as far
/// on the overmap only, missiles keep their range, and an AI carrier holds its distance instead of closing in
/datum/unit_test/aquila_overmap_scale
	var/obj/structure/overmap/small_craft/ship
	var/obj/structure/overmap/small_craft/enemy

/datum/unit_test/aquila_overmap_scale/Run()
	var/was_enabled = GLOB.overmap_scale_enabled
	GLOB.overmap_scale_enabled = TRUE
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy.faction = "syndicate"
	var/fail = check_off_overmap() || check_on_overmap() || check_carrier_standoff()
	ship.ai_controlled = FALSE
	ship.ai_fighter_type = list()
	GLOB.overmap_scale_enabled = was_enabled
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_overmap_scale/proc/check_off_overmap()
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	if(ship.get_overmap_speed_mult() != 1)
		return "A ship outside the overmap was slowed down (multiplier [ship.get_overmap_speed_mult()])"

/datum/unit_test/aquila_overmap_scale/proc/check_on_overmap()
	var/list/overmap_levels = SSmapping.levels_by_trait(ZTRAIT_OVERMAP)
	if(!length(overmap_levels))
		return // No overmap loaded in this test run, the off-overmap check still ran
	var/overmap_z = overmap_levels[1]
	ship.forceMove(locate(100, 100, overmap_z))
	enemy.forceMove(locate(130, 100, overmap_z))
	if(ship.get_overmap_speed_mult() != 0.5)
		return "A ship on the overmap was not slowed down (multiplier [ship.get_overmap_speed_mult()])"

	// The speed cap is halved: a ship coasting faster than that is clamped to half its speed_limit
	ship.speed_limit = 4
	ship.user_thrust_dir = 0
	ship.brakes = FALSE
	ship.inertial_dampeners = FALSE
	ship.velocity._set(10, 10)
	ship.last_process = world.time - 1
	ship.process()
	if(abs(ship.velocity.a - 2) > 0.01 || abs(ship.velocity.e - 2) > 0.01)
		return "The overmap speed cap was not halved (speed_limit 4, velocity [ship.velocity.a], [ship.velocity.e])"
	ship.velocity._set(0, 0)

	var/obj/item/projectile/gun_round = ship.fire_projectile(/obj/item/projectile/bullet/light_cannon_round, enemy)
	var/obj/item/projectile/missile = ship.fire_projectile(/obj/item/projectile/guided_munition/missile, enemy)
	var/gun_range = gun_round?.range
	var/missile_range = missile?.range
	var/obj/item/projectile/guided_munition/missile/missile_type = /obj/item/projectile/guided_munition/missile
	var/missile_initial = initial(missile_type.range)
	QDEL_NULL(gun_round)
	QDEL_NULL(missile)
	if(gun_range != 25)
		return "An unguided round on the overmap did not get half range (got [gun_range], expected 25)"
	if(missile_range != missile_initial)
		return "A missile lost range on the overmap ([missile_range] instead of [missile_initial])"

/datum/unit_test/aquila_overmap_scale/proc/check_carrier_standoff()
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	enemy.forceMove(locate(20, 10, run_loc_floor_bottom_left.z))
	ship.ai_controlled = TRUE
	if(ship.get_ai_standoff_range(enemy))
		return "A ship without fighters or torpedoes wanted to keep its distance"
	ship.ai_fighter_type = list(/obj/structure/overmap/syndicate/ai/fighter)
	if(ship.get_ai_standoff_range(enemy) != 40)
		return "An AI carrier did not want to hold at 40 tiles (got [ship.get_ai_standoff_range(enemy)])"
	// Enemy 10 tiles east: a carrier backs off to the west instead of closing in
	ship.move_toward(enemy)
	var/heading = (ship.desired_angle + 360) % 360
	if(abs(heading - 270) > 1 || ship.move_mode != NORTH)
		return "An AI carrier 10 tiles from its target did not turn away (heading [heading], expected 270)"
	// Enemy at the standoff distance: orbit, so the heading is across the bearing, not toward or away from it
	enemy.forceMove(locate(50, 10, run_loc_floor_bottom_left.z))
	ship.move_toward(enemy)
	heading = (ship.desired_angle + 360) % 360
	if(abs(heading - 90) < 10 || abs(heading - 270) < 10)
		return "An AI carrier at standoff range did not orbit its target (heading [heading])"
	GLOB.overmap_scale_enabled = FALSE
	var/disabled_standoff = ship.get_ai_standoff_range(enemy)
	GLOB.overmap_scale_enabled = TRUE
	if(disabled_standoff)
		return "With the overmap scale switched off a carrier still kept its distance"
