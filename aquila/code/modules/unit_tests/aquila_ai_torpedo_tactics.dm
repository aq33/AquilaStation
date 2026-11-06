/// AQUILA - AI torpedo tactics (aquila/code/modules/overmap/ai_torpedo_tactics.dm): a fleet holds its torpedoes until every
/// launcher on the target has reloaded (or the wait runs out), fires them together, then holds again; a failed salvo roll
/// lets every ship fire on its own until the next roll; a reckless commander
/// fires on its own; an AI ship dodges a torpedo homing on it to the side away from the torpedo's path.
/datum/unit_test/aquila_ai_torpedo_tactics
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo/first
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo/second
	var/obj/structure/overmap/small_craft/enemy
	var/datum/fleet/fleet

/// The unarmed morale test gunboat with one torpedo launcher, so it counts as a torpedo ship
/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo
	torpedoes = 4
	max_torpedoes = 4

/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo/apply_weapons()
	new /datum/overmap_ship_weapon/torpedo_launcher(src)

/datum/unit_test/aquila_ai_torpedo_tactics/Run()
	var/was_enabled = GLOB.ai_morale_enabled
	GLOB.ai_morale_enabled = TRUE
	var/z = run_loc_floor_bottom_left.z
	first = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo)
	second = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo)
	enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy.faction = "nanotrasen"
	// The AI gunboat stays where it spawned even after forceMove() in tests, so everything else is placed around it
	first.forceMove(locate(10, 10, z))
	second.forceMove(locate(10, 14, z))
	enemy.forceMove(locate(first.x + 10, first.y, first.z))
	fleet = new /datum/fleet
	fleet.all_ships = list(first, second)
	for(var/obj/structure/overmap/ship as anything in fleet.all_ships)
		ship.fleet = fleet
		ship.last_target = enemy
		ship.ai_temperament = "zwykły"
		ship.ai_fleeing = FALSE
	var/fail = check_salvo() || check_dodge()
	for(var/obj/structure/overmap/ship as anything in fleet.all_ships)
		ship.fleet = null
		ship.last_target = null
	fleet.all_ships = list()
	GLOB.ai_morale_enabled = was_enabled
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_ai_torpedo_tactics/proc/launcher_of(obj/structure/overmap/ship)
	var/list/launchers = ship.get_ai_torpedo_launchers()
	return length(launchers) ? launchers[1] : null

/datum/unit_test/aquila_ai_torpedo_tactics/proc/check_salvo()
	if(length(fleet.get_ai_salvo_ships(enemy)) != 2)
		return "Both torpedo ships on the target were not counted for the salvo ([length(fleet.get_ai_salvo_ships(enemy))])"
	var/datum/overmap_ship_weapon/second_launcher = launcher_of(second)
	if(!second_launcher)
		return "The test ship has no AI torpedo launcher"
	// A failed salvo roll: nobody waits, the ships fire on their own until the next roll
	fleet.ai_salvo_chance = 0
	second_launcher.next_firetime = world.time + 10 SECONDS
	if(!fleet.ai_salvo_allows(first, enemy))
		return "A ship waited for a salvo the fleet did not roll"
	LAZYREMOVE(fleet.ai_salvos, enemy)
	fleet.ai_salvo_chance = 100
	// The second ship is still reloading: the first one waits for it
	second_launcher.next_firetime = world.time + 10 SECONDS
	if(fleet.ai_salvo_allows(first, enemy))
		return "A ship fired its torpedo before the rest of the fleet had reloaded"
	// The wait runs out: the salvo opens anyway, and the second ship may fire inside the window
	var/list/salvo = fleet.ai_salvos[enemy]
	salvo[3] -= 7 SECONDS
	if(!fleet.ai_salvo_allows(first, enemy))
		return "The salvo did not open after the maximum wait"
	second_launcher.next_firetime = world.time
	if(!fleet.ai_salvo_allows(second, enemy))
		return "The second ship could not fire inside the salvo window"
	// After the window, torpedoes are held until the next salvo
	salvo[1] = world.time - 1
	if(fleet.ai_salvo_allows(first, enemy))
		return "A ship fired between salvos"
	// Everyone loaded at the next salvo: it opens at once
	salvo[2] = world.time - 1
	if(!fleet.ai_salvo_allows(first, enemy))
		return "A salvo with every launcher loaded did not open"
	// A reckless commander is not part of the salvo and fires on its own
	salvo[1] = world.time - 1
	salvo[2] = world.time + 10 SECONDS
	second.ai_temperament = "brawurowy"
	if(second in fleet.get_ai_salvo_ships(enemy))
		return "A reckless commander was made to wait for the salvo"
	second.ai_temperament = "zwykły"
	// Regression: a destroyed target leaves no salvo entry behind (hard delete)
	var/obj/structure/overmap/small_craft/victim = allocate(/obj/structure/overmap/small_craft/combat/light)
	LAZYSET(fleet.ai_salvos, victim, list(0, 0, 0))
	qdel(victim)
	if(LAZYACCESS(fleet.ai_salvos, victim))
		return "A destroyed target stayed in the fleet's salvo list"

/datum/unit_test/aquila_ai_torpedo_tactics/proc/check_dodge()
	// A torpedo flying north, passing just west of the ship
	var/obj/item/projectile/guided_munition/torpedo/torpedo = allocate(/obj/item/projectile/guided_munition/torpedo, locate(first.x - 1, first.y - 8, first.z))
	torpedo.Angle = 0
	torpedo.homing_target = first
	first.torpedoes_to_target += torpedo
	first.ai_dodge_side = 0
	var/turf/dodge = first.get_ai_dodge_point()
	if(!dodge)
		return "A ship did not dodge a torpedo 8 tiles away"
	if(dodge.x <= first.x || abs(dodge.y - first.y) > 1)
		return "The ship dodged towards the torpedo's path or along it (to [dodge.x],[dodge.y] from [first.x],[first.y])"
	first.ai_temperament = "brawurowy"
	if(first.get_ai_dodge_point())
		return "A reckless commander dodged"
	first.ai_temperament = "zwykły"
	torpedo.forceMove(locate(first.x - 1, first.y - 19, first.z))
	if(first.get_ai_dodge_point())
		return "The ship dodged a torpedo 19 tiles away"
	first.torpedoes_to_target -= torpedo
