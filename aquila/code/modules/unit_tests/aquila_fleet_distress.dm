/// AQUILA - fleet distress calls and retreat (aquila/code/modules/overmap/fleet_distress.dm): an allied fleet next door answers a call,
/// one busy with its own fight does not, a retreating fleet picks a neighbouring system, and losses are counted from the fleet's peak
/datum/unit_test/aquila_fleet_distress
	var/datum/fleet/caller_fleet
	var/datum/fleet/helper
	var/datum/star_system/home
	var/datum/star_system/next_door

/datum/unit_test/aquila_fleet_distress/Run()
	for(var/datum/star_system/system as anything in SSstar_system.systems)
		if(length(system.adjacency_list) && !system.hidden)
			var/datum/star_system/adjacent = SSstar_system.system_by_id(system.adjacency_list[1])
			if(adjacent && !adjacent.hidden && !length(adjacent.fleets)) // An empty system, so no fight there keeps our helper busy
				home = system
				next_door = adjacent
				break
	if(!home)
		return // No connected star systems loaded in this run
	caller_fleet = new /datum/fleet
	helper = new /datum/fleet
	caller_fleet.current_system = home
	helper.current_system = next_door
	next_door.fleets += helper
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	helper.all_ships += ship
	caller_fleet.all_ships += ship
	var/fail = check_responders() || check_retreat_system() || check_state(ship)
	next_door.fleets -= helper
	helper.all_ships = list()
	caller_fleet.all_ships = list()
	helper.current_system = null
	caller_fleet.current_system = null
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_fleet_distress/proc/check_responders()
	helper.last_encounter_time = -INFINITY
	var/list/responders = caller_fleet.find_ai_distress_responders()
	if(responders[helper] != 1)
		return "An allied fleet one jump away did not answer the distress call (got [json_encode(responders)])"
	helper.last_encounter_time = world.time
	responders = caller_fleet.find_ai_distress_responders()
	helper.last_encounter_time = -INFINITY
	if(responders[helper])
		return "A fleet busy with its own fight answered a distress call"
	helper.alignment = "nanotrasen"
	responders = caller_fleet.find_ai_distress_responders()
	helper.alignment = caller_fleet.alignment
	if(responders[helper])
		return "A fleet of another faction answered a distress call"

/datum/unit_test/aquila_fleet_distress/proc/check_retreat_system()
	var/datum/star_system/target = caller_fleet.pick_ai_retreat_system()
	var/datum/star_system/player_system = SSstar_system.find_main_overmap()?.current_system
	if(target && !(target.name in home.adjacency_list))
		return "A retreating fleet picked a system that is not next door ([target])"
	if(target && target == player_system)
		return "A retreating fleet ran into the players' system"

/datum/unit_test/aquila_fleet_distress/proc/check_state(obj/structure/overmap/ship)
	caller_fleet.ai_peak_ships = 3
	ship.ai_fear = 40
	var/list/state = caller_fleet.get_ai_fleet_state()
	if(state[1] != 1 || abs(state[2] - 40) > 0.01 || abs(state[3] - 2 / 3) > 0.01)
		return "Fleet state is wrong: [state[1]] ships, fear [state[2]], losses [state[3]] (expected 1, 40, 0.67)"
