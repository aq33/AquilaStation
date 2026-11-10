// AQUILA - Ciecze, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_controller.dm, master 6a4365b)
// Różnice: bez oceanu; bez SS_HIBERNATE (u nas go nie ma) - pusty świat wychodzi od razu, jak SSpollution;
// w fazie kafli dochodzi wymiana ciepła z powietrzem i zamarzanie, a po niej faza bloków lodu (nowe).

SUBSYSTEM_DEF(liquids)
	name = "Liquid Turfs"
	wait = 0.5 SECONDS
	flags = SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_LIQUID_TURFS
	var/list/active_groups = list()

	var/list/evaporation_queue = list()
	var/evaporation_counter = 0 //Only process evaporation on intervals
	///groups left to disperse in the current evaporation run
	var/list/currentrun_disperse_groups = list()
	///turfs left to evaporate in the current evaporation run
	var/list/currentrun_evaporation = list()

	var/run_type = SSLIQUIDS_RUN_TYPE_GROUPS

	///debug variable to toggle evaporation from running
	var/debug_evaporation = FALSE

	var/list/burning_turfs = list()
	var/fire_counter = 0
	///burning turfs left to spread fire from in the current fire run
	var/list/currentrun_fire_spread = list()
	///groups left to burn in the current fire run
	var/list/currentrun_fire_groups = list()

	var/member_counter = 0

	var/list/arrayed_groups = list()

	///list of groups to work on for cached edges
	var/list/cached_edge_work_queue = list()
	///list of groups we are going to work on in group process
	var/list/group_process_work_queue = list()
	///list of all work queue for turf processing
	var/list/active_turf_group_queue = list()
	///list of cached exposures we are working with
	var/list/cached_exposures = list()

	/// AQUILA - zamarznięte grupy do sprawdzenia, czy robią bloki lodu
	var/list/ice_block_candidates = list()

/datum/controller/subsystem/liquids/stat_entry(msg)
	msg += "AG:[length(active_groups)]|BT:[length(burning_turfs)]|EQ:[length(evaporation_queue)]|IB:[length(ice_block_candidates)]"
	return ..()

/datum/controller/subsystem/liquids/Recover()
	active_groups = SSliquids.active_groups
	evaporation_queue = SSliquids.evaporation_queue
	burning_turfs = SSliquids.burning_turfs
	arrayed_groups = SSliquids.arrayed_groups
	ice_block_candidates = SSliquids.ice_block_candidates

/datum/controller/subsystem/liquids/fire(resumed)
	// Bez SS_HIBERNATE: pusty świat kończy od razu
	if(!length(active_groups) && !length(evaporation_queue) && !length(burning_turfs) && !length(arrayed_groups))
		return

	list_clear_nulls(active_groups)

	if(length(arrayed_groups))
		list_clear_nulls(arrayed_groups)
		for(var/datum/liquid_group/liquid_group as anything in arrayed_groups)
			if(QDELETED(liquid_group))
				arrayed_groups -= liquid_group
				continue
			while(length(liquid_group.splitting_array)) // three at a time until we either finish or over-run, this should be done before anything else
				liquid_group.work_on_split_queue()
				if(!QDELETED(liquid_group))
					liquid_group.cleanse_members()
				if(MC_TICK_CHECK)
					return
				if(QDELETED(liquid_group))
					break

	if(run_type == SSLIQUIDS_RUN_TYPE_GROUPS)
		if(!length(group_process_work_queue))
			group_process_work_queue |= active_groups
		list_clear_nulls(group_process_work_queue)
		if(length(group_process_work_queue))
			var/populate_evaporation = FALSE
			if(!length(evaporation_queue))
				populate_evaporation = TRUE
			for(var/datum/liquid_group/liquid_group as anything in group_process_work_queue)
				if(MC_TICK_CHECK)
					return
				if(QDELETED(liquid_group))
					group_process_work_queue -= liquid_group
					continue
				liquid_group.process_group(TRUE)
				if(QDELETED(liquid_group))
					group_process_work_queue -= liquid_group
					continue
				if(populate_evaporation && !liquid_group.frozen && (liquid_group.always_evaporates || liquid_group.expected_turf_height <= LIQUID_ANKLES_LEVEL_HEIGHT) && liquid_group.evaporates)
					for(var/turf/listed_turf as anything in liquid_group.members)
						if(!listed_turf)
							continue
						evaporation_queue |= listed_turf
				group_process_work_queue -= liquid_group

		run_type = SSLIQUIDS_RUN_TYPE_EVAPORATION

	// these phases only set up a new run when the last one finished, so a pause picks up where it left off
	if(run_type == SSLIQUIDS_RUN_TYPE_EVAPORATION)
		if(!debug_evaporation && !length(currentrun_disperse_groups) && !length(currentrun_evaporation))
			evaporation_counter++
			if(evaporation_counter >= REQUIRED_EVAPORATION_PROCESSES)
				evaporation_counter = 0
				currentrun_disperse_groups = active_groups.Copy()
				currentrun_evaporation = evaporation_queue.Copy()
		while(length(currentrun_disperse_groups))
			var/datum/liquid_group/liquid_group = currentrun_disperse_groups[length(currentrun_disperse_groups)]
			currentrun_disperse_groups.len--
			if(QDELETED(liquid_group))
				continue
			liquid_group.check_dead()
			if(!QDELETED(liquid_group) && !length(liquid_group.splitting_array))
				liquid_group.process_turf_disperse()
			if(MC_TICK_CHECK)
				return
		while(length(currentrun_evaporation))
			var/turf/liquid_turf = currentrun_evaporation[length(currentrun_evaporation)]
			currentrun_evaporation.len--
			if(!prob(EVAPORATION_CHANCE) || !liquid_turf)
				evaporation_queue -= liquid_turf
			else if(!QDELETED(liquid_turf.liquids) && !QDELETED(liquid_turf.liquids.liquid_group))
				liquid_turf.liquids.process_evaporation()
			else
				evaporation_queue -= liquid_turf
			if(MC_TICK_CHECK)
				return
		run_type = SSLIQUIDS_RUN_TYPE_FIRE

	if(run_type == SSLIQUIDS_RUN_TYPE_FIRE)
		if(!length(currentrun_fire_spread) && !length(currentrun_fire_groups))
			fire_counter++
			for(var/datum/liquid_group/liquid_group as anything in active_groups)
				if(length(liquid_group?.burning_members))
					currentrun_fire_spread += liquid_group.burning_members
			if(fire_counter > REQUIRED_FIRE_PROCESSES)
				fire_counter = 0
				currentrun_fire_groups = active_groups.Copy()
		while(length(currentrun_fire_spread))
			var/turf/burning_turf = currentrun_fire_spread[length(currentrun_fire_spread)]
			currentrun_fire_spread.len--
			var/datum/liquid_group/liquid_group = burning_turf?.liquids?.liquid_group
			if(!QDELETED(liquid_group))
				liquid_group.process_spread(burning_turf)
			if(MC_TICK_CHECK)
				return
		while(length(currentrun_fire_groups))
			var/datum/liquid_group/liquid_group = currentrun_fire_groups[length(currentrun_fire_groups)]
			currentrun_fire_groups.len--
			if(QDELETED(liquid_group) || !length(liquid_group.burning_members))
				continue
			liquid_group.process_fire()
			if(MC_TICK_CHECK)
				return
		run_type = SSLIQUIDS_RUN_TYPE_TURFS

	if(run_type == SSLIQUIDS_RUN_TYPE_TURFS)
		member_counter++
		if(!length(active_turf_group_queue))
			active_turf_group_queue += active_groups
		list_clear_nulls(active_turf_group_queue)

		if(member_counter > REQUIRED_MEMBER_PROCESSES)
			list_clear_nulls(cached_exposures)
			if(!length(cached_exposures))
				for(var/datum/liquid_group/liquid_group as anything in active_turf_group_queue)
					if(MC_TICK_CHECK)
						return
					if(QDELETED(liquid_group))
						active_turf_group_queue -= liquid_group
						continue
					liquid_group.build_turf_reagent()
					// AQUILA - ciepło z powietrza i zamarzanie, raz na przebieg kafli
					liquid_group.share_air_temperature()
					active_turf_group_queue -= liquid_group
					if(QDELETED(liquid_group) || !liquid_group.exposure)
						continue
					cached_exposures |= liquid_group.members

			var/process_count = 0
			var/list/groups_we_rebuilt = list()
			while((process_count <= 500) && length(cached_exposures))
				process_count++
				var/turf/member = pick_n_take(cached_exposures)
				if(!member || QDELETED(member.liquids) || QDELETED(member.liquids.liquid_group))
					continue
				var/datum/liquid_group/liquid_group = member.liquids.liquid_group
				if(!(liquid_group in groups_we_rebuilt))
					groups_we_rebuilt |= liquid_group
					liquid_group.build_turf_reagent()

				if(!istype(member))
					liquid_group.members -= member
					continue
				liquid_group.process_member(member)
				if(MC_TICK_CHECK)
					return
			member_counter = 0
		run_type = SSLIQUIDS_RUN_TYPE_CACHED_EDGES

	if(run_type == SSLIQUIDS_RUN_TYPE_CACHED_EDGES)
		if(!length(cached_edge_work_queue))
			cached_edge_work_queue |= active_groups
		list_clear_nulls(cached_edge_work_queue)

		if(length(cached_edge_work_queue))
			for(var/datum/liquid_group/liquid_group as anything in cached_edge_work_queue)
				if(MC_TICK_CHECK)
					return
				if(QDELETED(liquid_group))
					cached_edge_work_queue -= liquid_group
					continue

				liquid_group.build_turf_reagent()
				// a big flood can have more edges than one tick can spread, so it stays queued and carries on next fire
				if(liquid_group.reagents_per_turf > LIQUID_HEIGHT_DIVISOR && liquid_group.process_cached_edges())
					pause()
					return
				cached_edge_work_queue -= liquid_group

		// AQUILA - bloki lodu z głębokiej zamarzniętej cieczy, z limitem na przebieg (każdy blok przelicza atmos)
		process_ice_blocks()

		run_type = SSLIQUIDS_RUN_TYPE_GROUPS

/datum/controller/subsystem/liquids/proc/process_ice_blocks()
	var/blocks_left = LIQUID_ICE_BLOCKS_PER_RUN
	while(length(ice_block_candidates) && blocks_left > 0)
		var/datum/liquid_group/liquid_group = ice_block_candidates[length(ice_block_candidates)]
		if(QDELETED(liquid_group) || !liquid_group.frozen || liquid_group.reagents_per_turf < LIQUID_ICE_BLOCK_VOLUME)
			ice_block_candidates.len--
			continue
		var/turf/open/member = pick(liquid_group.members)
		if(!liquid_group.freeze_into_block(member))
			// Kafel się nie nadaje (np. stoi na nim coś gęstego): grupa wraca przy następnym update_freezing() (dolanie, wymiana ciepła)
			ice_block_candidates.len--
			continue
		blocks_left--
		if(MC_TICK_CHECK)
			return

/client/proc/toggle_liquid_debug()
	set category = "Debug"
	set name = "Liquid Groups Color Debug"
	set desc = "Koloruje grupy cieczy losowymi kolorami, żeby było widać ich granice."
	if(!check_rights(R_DEBUG))
		return
	GLOB.liquid_debug_colors = !GLOB.liquid_debug_colors
	message_admins("[key_name_admin(usr)] [GLOB.liquid_debug_colors ? "włącza" : "wyłącza"] kolory debugowania grup cieczy.")
