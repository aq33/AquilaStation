// AQUILA - port of BeeStation/BeeStation-Hornet code/controllers/subsystem/ai_idle_controllers.dm,
// unplanned_controllers.dm and unplanned_ai_idle_controllers.dm (our MC style: flags, init_order).
// Without SSspatial_grid nothing goes AI_STATUS_IDLE yet (see /datum/ai_controller/proc/should_idle()), so the idle
// subsystems only run when that is added; the unplanned ON subsystem runs idle behaviours (random walks etc.).

/// Plans AI controllers in AI_STATUS_IDLE, rarely
AI_CONTROLLER_SUBSYSTEM_DEF(ai_idle_controllers)
	name = "AI Idle Controllers"
	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND
	priority = FIRE_PRIORITY_IDLE_NPC
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 5 SECONDS
	runlevels = RUNLEVEL_GAME
	planning_status = AI_STATUS_IDLE

GLOBAL_LIST_EMPTY(unplanned_controller_subsystems)

/// Handles making mobs perform lightweight "idle" behaviors such as wandering around when they have nothing planned
SUBSYSTEM_DEF(unplanned_controllers)
	name = "Unplanned AI Controllers"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_UNPLANNED_NPC
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.25 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	///what ai status are we interested in
	var/target_status = AI_STATUS_ON
	var/list/current_run = list()

/datum/controller/subsystem/unplanned_controllers/Initialize(timeofday)
	GLOB.unplanned_controller_subsystems += src
	return ..()

/datum/controller/subsystem/unplanned_controllers/Destroy()
	GLOB.unplanned_controller_subsystems -= src
	return ..()

/datum/controller/subsystem/unplanned_controllers/stat_entry()
	. = ..("Idle AIs:[length(GLOB.unplanned_controllers[target_status])]")

/datum/controller/subsystem/unplanned_controllers/fire(resumed)
	if(!resumed)
		src.current_run = GLOB.unplanned_controllers[target_status].Copy()
	var/list/current_run = src.current_run // cache for sonic speed
	while(length(current_run))
		var/datum/ai_controller/unplanned = current_run[current_run.len]
		current_run.len--
		if(!QDELETED(unplanned))
			unplanned.idle_behavior.perform_idle_behavior(wait * 0.1, unplanned)
		if (MC_TICK_CHECK)
			return

/// Idle behaviours of AI controllers in AI_STATUS_IDLE
UNPLANNED_CONTROLLER_SUBSYSTEM_DEF(idle_unplanned_controllers)
	name = "Unplanned AI Idle Controllers"
	wait = 2.5 SECONDS
	target_status = AI_STATUS_IDLE
