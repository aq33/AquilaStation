// AQUILA - Dym i zapachy, port z Monkestation 2.0
PROCESSING_SUBSYSTEM_DEF(pollution_emitters)
	name = "Pollution Emitters"
	priority = FIRE_PRIORITY_OBJ
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 10 SECONDS

/// Atoms that keep polluting their tile, like vomit and green goo
/datum/element/pollution_emitter
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2

	/// List of all affected atoms
	var/list/affected
	/// Type of the spawned pollutions
	var/pollutant_type
	/// Amount of the pollutants spawned per process
	var/pollutant_amount

/datum/element/pollution_emitter/Attach(datum/target, pollutant_type, pollutant_amount)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.pollutant_type = pollutant_type
	src.pollutant_amount = pollutant_amount
	LAZYSET(affected, target, TRUE)
	START_PROCESSING(SSpollution_emitters, src)

/datum/element/pollution_emitter/Detach(datum/target)
	. = ..()
	LAZYREMOVE(affected, target)
	if(!LAZYLEN(affected))
		STOP_PROCESSING(SSpollution_emitters, src)

/datum/element/pollution_emitter/process(delta_time)
	if(!LAZYLEN(affected))
		return PROCESS_KILL
	for(var/atom/affected_atom as anything in affected)
		var/turf/my_turf = get_turf(affected_atom)
		// AQUILA - capped, so a dirty maintenance tile doesn't pile up smell forever
		my_turf?.pollute_turf(pollutant_type, pollutant_amount, POLLUTION_PASSIVE_EMITTER_CAP)
