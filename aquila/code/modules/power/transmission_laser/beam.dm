/obj/effect/transmission_beam
	name = "migocząca wiązka"
	desc = "Oślepiająca wiązka energii. Lepiej w nią nie wchodzić."
	icon = 'aquila/icons/obj/power/ptl_beam.dmi'
	icon_state = "ptl_beam"
	anchored = TRUE
	/// Laser, który nas postawił
	var/obj/machinery/power/transmission_laser/host

/obj/effect/transmission_beam/Initialize(mapload, obj/machinery/power/transmission_laser/host)
	. = ..()
	if(!istype(host))
		stack_trace("PTL beam initialized without PTL!")
		return INITIALIZE_HINT_QDEL
	src.host = host
	setDir(host.dir)
	host.laser_effects += src
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/transmission_beam/Destroy(force)
	host?.laser_effects -= src
	host = null
	return ..()

/obj/effect/transmission_beam/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "ptl_beam_e")

/obj/effect/transmission_beam/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	host?.atom_entered_beam(src, arrived)
