// Z-Mimic (port BeeStation/BeeStation-Hornet#8813, poprawki z BeeStation/BeeStation-Hornet#14823): kafle

/turf
	var/tmp/turf/above	//! If present, a turf above that is copying this turf. Implies a Z-connection and that the turf above is a z-mimic enabled turf.
	var/tmp/turf/below	//! If present, the turf below that we are copying. Implies a Z-connection and that this is a z-mimic enabled turf.
	// Various Z-Mimic abstract objects.
	var/tmp/atom/movable/openspace/turf_proxy/mimic_proxy      //! If we're a non-overwrite z-turf, this holds the appearance of the bottom-most Z-turf in the z-stack.
	var/tmp/atom/movable/openspace/multiplier/shadower         //! Object used to multiply color of all OO overlays at once.
	var/tmp/atom/movable/openspace/turf_mimic/mimic_above_copy //! If this is a delegate (non-overwrite) Z-turf with a z-turf above, this is the delegate copy that's copying us.
	var/tmp/atom/movable/openspace/turf_proxy/mimic_underlay   //! If we're at the bottom of the stack, a proxy used to fake a below space turf.
	/// How many times this turf is currently queued - multiple queue occurrences are allowed to ensure update consistency.
	var/tmp/z_queued = 0
	/// If this Z-turf leads to space, uninterrupted.
	var/tmp/z_eventually_space = FALSE
	/// The computed depth, this should never be directly accessed.
	/// This is assumed to always be correct, so if below is changed it must be invalidated by setting it to null.
	var/tmp/z_depth = null
	var/tmp/z_generation = 0	//! Update count, used in analyzer.
	/// Z-Mimic flags (Z_MIMIC_*)
	var/z_flags = NONE

/turf/open/space
	z_eventually_space = TRUE

/turf/update_above()
	if (TURF_IS_MIMICKING(above))
		above.update_mimic()

/turf/proc/update_mimic()
	if(!(z_flags & Z_MIMIC_BELOW))
		return
	if (!shadower)
		return
	z_queued += 1
	// This adds duplicates for a reason. Do not change this unless you understand how ZM queues work.
	SSzcopy.queued_turfs += src

/// Enables Z-mimic for a turf that didn't already have it enabled.
/turf/proc/enable_zmimic(additional_flags = 0)
	if (z_flags & Z_MIMIC_BELOW)
		return FALSE
	z_flags |= Z_MIMIC_BELOW | additional_flags
	setup_zmimic(FALSE)
	return TRUE

/// Disables Z-mimic for a turf.
/turf/proc/disable_zmimic()
	if (!(z_flags & Z_MIMIC_BELOW))
		return FALSE
	z_flags &= ~Z_MIMIC_BELOW
	cleanup_zmimic()
	return TRUE

/// Sets up Z-mimic for this turf. You shouldn't call this directly 99% of the time.
/turf/proc/setup_zmimic(mapload)
	if (shadower)
		CRASH("Attempt to enable Z-mimic on already-enabled turf!")
	shadower = new(src)
	SSzcopy.openspace_turfs += 1
	var/turf/under = GET_TURF_BELOW(src)
	if (under)
		below = under
		below.above = src
	z_depth = null
	if (!(z_flags & (Z_MIMIC_OVERWRITE|Z_MIMIC_NO_OCCLUDE)) && mouse_opacity)
		mouse_opacity = MOUSE_OPACITY_OPAQUE
	update_mimic()

/// Cleans up Z-mimic objects for this turf. You shouldn't call this directly 99% of the time.
/turf/proc/cleanup_zmimic()
	SSzcopy.openspace_turfs -= 1
	// Don't remove ourselves from the queue, the subsystem will explode. We'll naturally fall out of the queue.
	z_queued = 0
	// can't use QDEL_NULL as we need to supply force to qdel
	if(shadower)
		qdel(shadower, TRUE)
		shadower = null
	QDEL_NULL(mimic_above_copy)
	QDEL_NULL(mimic_underlay)
	if (below?.mimic_proxy)
		QDEL_NULL(below.mimic_proxy)
	for (var/atom/movable/openspace/mimic/OO in src)
		OO.owning_turf_changed()

	if (above)
		above.update_mimic()

	if (below)
		below.above = null
		below = null

/// Calculate the z-depth of this provided turf.
/turf/proc/calculate_zdepth()
	z_depth = null
	// Traverse to the bottom of the stack
	var/turf/b = src.below || GET_TURF_BELOW(src)
	// We are the bottom
	if (!b)
		z_depth = 0
		return z_depth
	var/turf/nextb = b.below || GET_TURF_BELOW(b)
	// Keep going down until we reach the bottom or something that has a valid z_depth
	while (nextb && !nextb.z_depth)
		b = nextb
		nextb = b.below || GET_TURF_BELOW(b)
	if (nextb)
		b = nextb
	// Set the base zdepth if b has nothing below it (Reset the stack)
	if (!b.below && !GET_TURF_BELOW(b))
		b.z_depth = 0
	// Begin building up, we know there is at least 1 turf above
	var/turf/a = b.above || GET_TURF_ABOVE(b)
	var/turf/nexta = a.above || GET_TURF_ABOVE(a)
	a.z_depth = b.z_depth + 1
	// Continue up until we build all the way to the top
	while (nexta)
		nexta.z_depth = a.z_depth + 1
		a = nexta
		nexta = a.above || GET_TURF_ABOVE(a)
	// Return whatever we were assigned during this process
	return z_depth

/turf/Initialize(mapload)
	. = ..()
	if (z_flags & Z_MIMIC_BELOW)
		setup_zmimic(mapload)

/turf/Destroy(force)
	if (z_flags & Z_MIMIC_BELOW)
		cleanup_zmimic()
	return ..()

/// Po ChangeTurf nowy kafel nie pamięta kafla nad sobą (zmienne tmp wracają do domyślnych), więc otwarta przestrzeń
/// wyżej musi się z nim połączyć na nowo i przerysować
/turf/AfterChange(flags)
	. = ..()
	var/turf/up = GET_TURF_ABOVE(src)
	if (TURF_IS_MIMICKING(up))
		above = up
		up.below = src
		up.z_depth = null
		up.update_mimic()

/turf/Entered(atom/movable/arrived, direction)
	. = ..()
	if (!TURF_IS_MIMICKING(above) || (arrived.bound_overlay && !arrived.bound_overlay.destruction_timer) || (arrived.zmm_flags & ZMM_IGNORE) || arrived.invisibility == INVISIBILITY_ABSTRACT)
		return
	above.update_mimic()

/turf/open/space/Destroy(force)
	// Cleanup cached z_eventually_space values above us.
	if (above)
		var/turf/T = src
		while ((T = GET_TURF_ABOVE(T)))
			T.z_eventually_space = FALSE
	return ..()
