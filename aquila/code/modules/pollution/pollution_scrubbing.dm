// AQUILA - Dym i zapachy: scrubbery wciągają też pollution
/obj/machinery/atmospherics/components/unary/vent_scrubber/scrub(turf/open/tile)
	. = ..()
	if(.)
		tile.pollution?.scrub_amount(POLLUTION_HEIGHT_DIVISOR * 2)

/obj/machinery/portable_atmospherics/scrubber/process_atmos()
	. = ..()
	if(!on || holding)
		return
	var/turf/open/open_turf = get_turf(src)
	if(istype(open_turf))
		open_turf.pollution?.scrub_amount(POLLUTION_HEIGHT_DIVISOR * 2)
