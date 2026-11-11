// AQUILA: synced with BeeStation/BeeStation-Hornet code/controllers/subsystem/ai_controllers.dm (our MC style: flags, init_order)
/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.5 SECONDS //Plan every half second if required, not great not terrible.
	var/list/currentrun = list()
	///type of status we are interested in running
	var/planning_status = AI_STATUS_ON
	/// The average tick cost of all active AI, calculated on fire.
	var/our_cost
	/// The tick cost of all currently processed AI, being summed together
	var/summing_cost
	/// AQUILA: how often a controller of ours re-checks its status (idle without clients nearby, see should_idle())
	var/idle_check_interval = AI_IDLE_CHECK_INTERVAL
	/// AQUILA: plan a controller at most this often (0: every fire); lets the idle subsystem check for clients often
	/// while planning rarely
	var/planning_interval = 0

/datum/controller/subsystem/ai_controllers/Initialize(timeofday)
	setup_subtrees()
	on_max_z_changed()
	return ..()

/datum/controller/subsystem/ai_controllers/stat_entry()
	var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
	. = ..("Planning AIs:[length(planning_list)]/[round(our_cost, 0.01)]ms")

/datum/controller/subsystem/ai_controllers/fire(resumed)
	if(!resumed)
		var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
		currentrun = planning_list.Copy()
		summing_cost = 0

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.currentrun
	var/timer = TICK_USAGE_REAL
	while(length(current_run))
		var/datum/ai_controller/ai_controller = current_run[length(current_run)]
		current_run.len--
		// AQUILA: no spatial grid to idle and wake controllers (decision D4), so they check themselves now and then
		if(ai_controller.next_idle_check <= world.time)
			ai_controller.next_idle_check = world.time + idle_check_interval
			var/expected_status = ai_controller.get_expected_ai_status()
			if(expected_status != planning_status)
				ai_controller.set_ai_status(expected_status)
				continue
		if(!ai_controller.able_to_plan)
			continue
		if(planning_interval)
			if(ai_controller.next_planning > world.time)
				continue
			ai_controller.next_planning = world.time + planning_interval
		ai_controller.SelectBehaviors(max(wait, planning_interval) * 0.1)

		if(!length(ai_controller.current_behaviors)) //Still no plan
			ai_controller.planning_failed()

		if(MC_TICK_CHECK)
			break

	summing_cost += TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer)
	if(MC_TICK_CHECK)
		return

	our_cost = MC_AVERAGE(our_cost, summing_cost)

///Creates all instances of ai_subtrees and assigns them to the ai_subtrees list.
/datum/controller/subsystem/ai_controllers/proc/setup_subtrees()
	if(length(GLOB.ai_subtrees))
		return
	for(var/subtree_type in subtypesof(/datum/ai_planning_subtree))
		var/datum/ai_planning_subtree/subtree = new subtree_type
		GLOB.ai_subtrees[subtree_type] = subtree

///Called when the max Z level was changed, updating our coverage.
/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	if(!length(GLOB.ai_controllers_by_zlevel))
		GLOB.ai_controllers_by_zlevel = new /list(world.maxz,0)
		for(var/z_index in 1 to world.maxz)
			GLOB.ai_controllers_by_zlevel[z_index] = list()
	while (GLOB.ai_controllers_by_zlevel.len < world.maxz)
		GLOB.ai_controllers_by_zlevel.len++
		GLOB.ai_controllers_by_zlevel[GLOB.ai_controllers_by_zlevel.len] = list()
