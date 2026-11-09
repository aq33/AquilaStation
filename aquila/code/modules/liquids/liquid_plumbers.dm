// AQUILA - Ciecze: pompy podłogowe plumbingu, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_plumbers.dm)
// Różnice: nasz plumbing z tg (Initialize(mapload, layer), komponenty z warstwą), bez chowania pod płytką (COMSIG_OBJ_HIDE),
// regulator przez tgui_input_number, maszyny dopisane do zwykłego konstruktora instalacji zamiast osobnego inżynieryjnego.

/**
 * Base class for underfloor plumbing machines that mess with floor liquids.
 */
/obj/machinery/plumbing/floor_pump
	icon = 'aquila/icons/obj/structures/drains.dmi'
	base_icon_state = "active_input"
	icon_state = "active_input"
	anchored = FALSE
	density = FALSE
	plane = FLOOR_PLANE
	layer = GAS_SCRUBBER_LAYER
	idle_power_usage = 5
	active_power_usage = 100
	buffer = 300
	reagent_flags = NO_REACT

	/// Pump is turned on by engineer, etc.
	var/turned_on = FALSE
	/// Only pump to this liquid level height. 0 means pump the most possible.
	var/height_regulator = 0

	/// The default duct layer for mapping
	var/duct_layer = 0

	/// Base amount to drain
	var/drain_flat = 20
	/// Additional ratio of liquid volume to drain
	var/drain_percent = 1

	/// Currently pumping.
	var/is_pumping = FALSE

	var/processes = 0
	var/processes_required = 25

/obj/machinery/plumbing/floor_pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Jest [turned_on ? "WŁĄCZONA" : "WYŁĄCZONA"].</span>"
	. += "<span class='notice'>Regulator poziomu [height_regulator ? "wskazuje [height_regulator]" : "jest wyłączony"]. Kliknij odkręconą pompę, żeby go zmienić.</span>"

/obj/machinery/plumbing/floor_pump/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]-open"
	else if(is_pumping)
		icon_state = "[base_icon_state]-pumping"
	else if(is_operational && turned_on)
		icon_state = "[base_icon_state]-idle"
	else
		icon_state = base_icon_state
	return ..()

/obj/machinery/plumbing/floor_pump/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		turned_on = FALSE
		update_icon()

/obj/machinery/plumbing/floor_pump/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!anchored)
		set_regulator(user)
		return TRUE
	balloon_alert(user, turned_on ? "wyłączona" : "włączona")
	turned_on = !turned_on
	if(turned_on)
		begin_processing()
	update_icon()
	return TRUE

/**
 * Change regulator level -- ie. what liquid depth we are OK with, like a thermostat.
 */
/obj/machinery/plumbing/floor_pump/proc/set_regulator(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	var/new_height = tgui_input_number(user,
		"Do jakiego poziomu cieczy (0-[LIQUID_HEIGHT_CONSIDER_FULL_TILE]) pompa ma działać? 0 wyłącza regulator.",
		"[src]",
		height_regulator,
		LIQUID_HEIGHT_CONSIDER_FULL_TILE,
		0)
	if(QDELETED(src) || isnull(new_height))
		return
	height_regulator = new_height

/**
 * Can the pump actually run at all?
 */
/obj/machinery/plumbing/floor_pump/proc/can_run()
	return is_operational \
		&& turned_on \
		&& anchored \
		&& !panel_open \
		&& isturf(loc) \
		&& are_reagents_ready()

/**
 * Is the internal reagents container able to give or take liquid as appropriate?
 */
/obj/machinery/plumbing/floor_pump/proc/are_reagents_ready()
	CRASH("are_reagents_ready() must be overriden.")

/**
 * Should we actually be pumping this tile right now?
 */
/obj/machinery/plumbing/floor_pump/proc/should_pump(turf/affected_turf)
	return isturf(affected_turf) \
		&& should_regulator_permit(affected_turf)

/**
 * Should the liquid height regulator allow water to be pumped here?
 */
/obj/machinery/plumbing/floor_pump/proc/should_regulator_permit(turf/affected_turf)
	CRASH("should_regulator_permit() must be overriden.")

/obj/machinery/plumbing/floor_pump/process(delta_time)
	var/was_pumping = is_pumping

	if(!can_run())
		is_pumping = FALSE
		if(was_pumping)
			update_icon()
		return

	// Determine what tiles should be pumped. We grab from a 3x3 area,
	// but overall try to pump the same volume regardless of number of affected tiles
	var/turf/local_turf = get_turf(src)
	var/list/turf/candidate_turfs = local_turf.GetAtmosAdjacentTurfs(alldir = TRUE)
	candidate_turfs += local_turf

	var/list/turf/affected_turfs = list()

	for(var/turf/candidate as anything in candidate_turfs)
		if(should_pump(candidate))
			affected_turfs += candidate

	// Update state
	is_pumping = length(affected_turfs) > 0
	if(is_pumping != was_pumping)
		update_icon()
	if(!is_pumping)
		return

	var/multiplier = 1 / length(affected_turfs)

	// We're good, actually pump.
	for(var/turf/affected_turf as anything in affected_turfs)
		pump_turf(affected_turf, delta_time, multiplier)

/**
 * Pump out the liquids on a turf.
 */
/obj/machinery/plumbing/floor_pump/proc/pump_turf(turf/affected_turf, delta_time, multiplier)
	CRASH("pump_turf() must be overriden.")

/obj/machinery/plumbing/floor_pump/input
	name = "podłogowa pompa ssąca"
	desc = "Pompa, która wysysa ciecz z podłogi do instalacji rurowej."
	icon_state = "active_input"
	base_icon_state = "active_input"

/obj/machinery/plumbing/floor_pump/input/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, layer || duct_layer || DUCT_LAYER_DEFAULT)

/obj/machinery/plumbing/floor_pump/input/are_reagents_ready()
	return reagents.total_volume < reagents.maximum_volume

/obj/machinery/plumbing/floor_pump/input/should_regulator_permit(turf/affected_turf)
	return affected_turf.liquids && affected_turf.liquids.liquid_group && !affected_turf.liquids.liquid_group.frozen && affected_turf.liquids.liquid_group.expected_turf_height > height_regulator

/obj/machinery/plumbing/floor_pump/input/pump_turf(turf/affected_turf, delta_time, multiplier)
	if(processes < processes_required)
		processes++
		return
	processes = 0
	if(!affected_turf.liquids || !affected_turf.liquids.liquid_group || reagents.total_volume)
		return
	var/target_value = delta_time * (drain_flat + (affected_turf.liquids.liquid_group.total_reagent_volume * drain_percent)) * multiplier
	//Free space handling
	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(target_value > free_space)
		target_value = free_space

	var/datum/liquid_group/targeted_group = affected_turf.liquids.liquid_group
	if(!targeted_group.reagents_per_turf)
		return
	var/turfs_to_pull = round(target_value / targeted_group.reagents_per_turf,1)

	var/list/removed_turfs = targeted_group.return_connected_liquids_in_range(affected_turf.liquids, turfs_to_pull)
	targeted_group.trans_to_seperate_group(reagents, target_value, merge = TRUE)
	for(var/turf/listed_turf in removed_turfs)
		if(QDELETED(listed_turf.liquids))
			continue
		var/datum/liquid_group/listed_group = listed_turf.liquids.liquid_group
		targeted_group.remove_from_group(listed_turf)
		qdel(listed_turf.liquids)
		if(QDELETED(targeted_group))
			return
		for(var/dir in GLOB.cardinals)
			var/turf/open/direction_turf = get_step(listed_turf, dir)
			if(!isopenturf(direction_turf) || !direction_turf.liquids)
				continue
			if(!listed_group)
				continue
			listed_group.check_edges(direction_turf)

	if(QDELETED(targeted_group) || !length(targeted_group.members))
		return
	///recalculate the values here because processing
	targeted_group.total_reagent_volume = targeted_group.reagents.total_volume
	targeted_group.reagents_per_turf = targeted_group.total_reagent_volume / length(targeted_group.members)

	while(length(removed_turfs) && !QDELETED(targeted_group))
		var/turf/picked_turf = pick_n_take(removed_turfs)
		var/list/output = targeted_group.try_split(picked_turf, TRUE)
		for(var/turf/outputted_turf in output)
			if(outputted_turf in removed_turfs)
				removed_turfs -= outputted_turf

/obj/machinery/plumbing/floor_pump/input/on
	icon_state = "active_input-mapping"
	anchored = TRUE
	turned_on = TRUE

/obj/machinery/plumbing/floor_pump/input/on/waste
	icon_state = "active_input-mapping2"
	duct_layer = SECOND_DUCT_LAYER

/obj/machinery/plumbing/floor_pump/output
	name = "podłogowa pompa wylewająca"
	desc = "Pompa, która wylewa ciecz z instalacji rurowej na podłogę."
	icon_state = "active_output"
	base_icon_state = "active_output"

	/// Is the turf too full to pump more?
	var/over_volume = FALSE
	/// Max liquid volume on the turf before we stop pumping.
	var/max_ext_volume = LIQUID_HEIGHT_CONSIDER_FULL_TILE

	/// Is the turf too high-pressured to pump more?
	var/over_pressure = FALSE
	/// Max pressure on the turf before we stop pumping.
	var/max_ext_kpa = WARNING_HIGH_PRESSURE

/obj/machinery/plumbing/floor_pump/output/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, layer || duct_layer || DUCT_LAYER_DEFAULT)

/obj/machinery/plumbing/floor_pump/output/examine(mob/user)
	. = ..()
	if(over_pressure)
		. += "<span class='warning'>Miga lampka regulatora ciśnienia gazu.</span>"
	if(over_volume)
		. += "<span class='warning'>Miga lampka regulatora poziomu cieczy.</span>"

/obj/machinery/plumbing/floor_pump/output/are_reagents_ready()
	return reagents.total_volume > 0

/obj/machinery/plumbing/floor_pump/output/should_regulator_permit(turf/affected_turf)
	// 0 means keep pumping forever.
	return !height_regulator || (affected_turf?.liquids?.liquid_group && (affected_turf.liquids.liquid_group.expected_turf_height < height_regulator))

/obj/machinery/plumbing/floor_pump/output/process(delta_time)
	over_pressure = FALSE
	return ..()

/obj/machinery/plumbing/floor_pump/output/should_pump(turf/affected_turf)
	. = ..()
	if(!.)
		return FALSE

	if(affected_turf.liquids?.liquid_group?.expected_turf_height >= max_ext_volume)
		over_volume = TRUE
		return FALSE
	over_volume = FALSE
	var/turf/open/open_turf = affected_turf
	var/datum/gas_mixture/gas_mix = open_turf?.return_air()
	if(gas_mix?.return_pressure() > max_ext_kpa)
		over_pressure = TRUE
		return FALSE
	return TRUE

/obj/machinery/plumbing/floor_pump/output/pump_turf(turf/affected_turf, delta_time, multiplier)
	var/target_value = delta_time * (drain_flat + (reagents.total_volume * drain_percent)) * multiplier
	if(target_value > reagents.total_volume)
		target_value = reagents.total_volume

	var/datum/reagents/tempr = new(10000, NO_REACT)
	reagents.trans_to(tempr, target_value, no_react = TRUE)
	affected_turf.add_liquid_from_reagents(tempr)
	qdel(tempr)

/obj/machinery/plumbing/floor_pump/output/on
	icon_state = "active_output-mapping"
	anchored = TRUE
	turned_on = TRUE

/obj/machinery/plumbing/floor_pump/output/on/supply
	icon_state = "active_output-mapping2"
	duct_layer = FOURTH_DUCT_LAYER
