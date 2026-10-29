// AQUILA - A big fire used to cost seconds per SSair run: every hotspot burned everything on its tile and smoked every tick.
// Now it burns its tile's contents every HOTSPOT_CONTENTS_INTERVAL ticks and smokes every HOTSPOT_SMOKE_INTERVAL ticks, like SSmiasma.
// The gas reaction itself still runs every tick. Core hook: perform_exposure() in code/modules/atmospherics/environmental/LINDA_fire.dm

/obj/effect/hotspot
	/// Exposures done so far, the first one burns and smokes right away
	var/exposure_count = 0

/// Called by perform_exposure() each tick. Smokes now and then, returns TRUE when the tile's contents should get fire_act().
/obj/effect/hotspot/proc/throttled_exposure(turf/open/location)
	var/count = exposure_count++
	if(!(count % HOTSPOT_SMOKE_INTERVAL) && !location.planetary_atmos)
		location.pollute_turf_list(list(/datum/pollutant/smoke = 30, /datum/pollutant/carbon_air_pollution = 10), POLLUTION_ACTIVE_EMITTER_CAP)
	return !(count % HOTSPOT_CONTENTS_INTERVAL)

/obj/effect/hotspot/perform_exposure()
	. = ..()
	// fire_act() on the tile can delete us (ChangeTurf, explosions), Initialize() and process() then clean up
	if(QDELETED(src))
		return FALSE

/// AQUILA - Puddles and ash on a burning tile react without a sound or a message.
/// Every burned item leaves ash that bakes into ash rims in the fire, and each reaction looked up everyone in view (dview), which was most of a fire's cost.
/// The reaction and its products stay. Core hook: instant_react() in code/modules/reagents/chemistry/holder.dm
/proc/fire_mutes_reaction(atom/holder_atom)
	if(!istype(holder_atom, /obj/effect/decal/cleanable))
		return FALSE
	var/turf/open/location = holder_atom.loc
	return istype(location) && !isnull(location.active_hotspot)

/// AQUILA - Burning gas heats the contents of a tile with a hotspot only every HOTSPOT_CONTENTS_INTERVAL ticks, like the hotspot's own fire_act().
/// Tiles without a hotspot are heated every time. Core hook: fire_expose() in code/modules/atmospherics/gasmixtures/reactions.dm
/proc/fire_exposes_contents(turf/open/location)
	var/obj/effect/hotspot/hotspot = location.active_hotspot
	return isnull(hotspot) || !(hotspot.exposure_count % HOTSPOT_CONTENTS_INTERVAL)
