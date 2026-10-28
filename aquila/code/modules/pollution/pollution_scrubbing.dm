// AQUILA - Dym i zapachy: scrubbery wciągają też pollution
/obj/machinery/atmospherics/components/unary/vent_scrubber/scrub(turf/open/tile)
	. = ..()
	if(.)
		tile.pollution?.scrub_amount(POLLUTION_HEIGHT_DIVISOR * 2)

/// Same check as /obj/machinery/portable_atmospherics/scrubber/proc/scrub(): a full tank takes no air, so no pollution either
/obj/machinery/portable_atmospherics/scrubber/proc/can_scrub_pollution()
	return on && !holding && air_contents.return_pressure() < overpressure_m * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/scrubber/process_atmos()
	var/scrub_pollution = can_scrub_pollution()
	. = ..()
	if(!scrub_pollution || !on)
		return
	var/turf/open/open_turf = get_turf(src)
	if(istype(open_turf))
		open_turf.pollution?.scrub_amount(POLLUTION_HEIGHT_DIVISOR * 2)

// The huge scrubber also pulls air from the tiles around it
/obj/machinery/portable_atmospherics/scrubber/huge/process_atmos()
	var/scrub_pollution = can_scrub_pollution()
	. = ..()
	if(!scrub_pollution || !on)
		return
	var/turf/my_turf = get_turf(src)
	for(var/turf/open/adjacent_turf in my_turf?.GetAtmosAdjacentTurfs(alldir = TRUE))
		adjacent_turf.pollution?.scrub_amount(POLLUTION_HEIGHT_DIVISOR * 2)
