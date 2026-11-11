// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/components/fertile_egg.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Replaces our old /obj/item/food/egg/process() hatching. The chicken cap (config max_chickens) is checked again when the egg
// hatches, so a pile of eggs laid under the cap cannot push the flock past it.
/**
 * ### A fertile egg component!
 *
 * This component tracks over time if the atom is in ideal conditions,
 * and eventually hatches into the embryonic type.
 *
 * The initial design of this component was to make more generic the code for
 * chickens laying eggs.
 */
/datum/component/fertile_egg
	/// What will come out of the egg when it's done.
	var/embryo_type

	/// Minimum growth rate per tick
	var/minimum_growth_rate

	/// Maximum growth rate per tick
	var/maximum_growth_rate

	/// Total growth required before hatching.
	var/total_growth_required

	/// The current amount of growth.
	var/current_growth

	/// List of locations which, if set, the egg will only develop if in those locations.
	var/list/location_allowlist

	/// If true, being in an unsuitable location spoils the egg (ie. kills the component). If false, it just pauses the egg's development.
	var/spoilable

	///callback after the egg hatches
	var/datum/callback/post_hatch

	/// AQUILA: optional check before hatching (the chicken cap); FALSE spoils the egg
	var/datum/callback/can_hatch

/datum/component/fertile_egg/Initialize(embryo_type, minimum_growth_rate, maximum_growth_rate, total_growth_required, current_growth, location_allowlist, spoilable, examine_message, post_hatch, can_hatch)
	// Quite how an _area_ can be a fertile egg is an open question, but it still has a location. Technically.
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.embryo_type = embryo_type
	src.minimum_growth_rate = minimum_growth_rate
	src.maximum_growth_rate = maximum_growth_rate
	src.total_growth_required = total_growth_required
	src.current_growth = current_growth
	src.location_allowlist = location_allowlist
	src.spoilable = spoilable
	src.post_hatch = post_hatch
	src.can_hatch = can_hatch

	START_PROCESSING(SSobj, src)

/datum/component/fertile_egg/Destroy()
	STOP_PROCESSING(SSobj, src)
	post_hatch = null
	can_hatch = null
	return ..()

/datum/component/fertile_egg/process(delta_time)
	var/atom/parent_atom = parent

	if(location_allowlist && !is_type_in_typecache(parent_atom.loc, location_allowlist))
		// In a zone that is not allowed, do nothing, and possibly self destruct
		if(spoilable)
			qdel(src)
		return

	current_growth += rand(minimum_growth_rate, maximum_growth_rate) * delta_time
	if(current_growth < total_growth_required)
		return
	hatch()

/// The egg hatches now (if it still may)
/datum/component/fertile_egg/proc/hatch()
	var/atom/parent_atom = parent
	if(can_hatch && !can_hatch.Invoke())
		qdel(src)
		return
	parent_atom.visible_message(span_notice("[parent] wykluwa się z cichym trzaskiem."))
	var/atom/hatchling = new embryo_type(get_turf(parent_atom))
	post_hatch?.Invoke(hatchling)
	// We destroy the parent on hatch, which will destroy the component as well, which will stop us processing.
	qdel(parent_atom)
	return hatchling
