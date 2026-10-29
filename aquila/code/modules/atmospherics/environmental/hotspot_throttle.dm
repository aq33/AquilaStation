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
