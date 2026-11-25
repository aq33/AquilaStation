/**
 * Z-Mimic: kopiuje wygląd piętra niżej na kafle otwartej przestrzeni.
 * Port BeeStation/BeeStation-Hornet#8813 z poprawkami z BeeStation/BeeStation-Hornet#14823
 * (pierwotnie DaedalusDock/daedalusdock#280, Baystation/Nebula).
 *
 * Różnice względem Bee:
 * - bez SS_HIBERNATE, addytywnego światła, kopii HUD-ów danych i analizatora openturfów (nie mamy tych systemów);
 * - plany nakładek zawsze poprawiane (u Bee tylko z flagą ustawianą przez SSoverlays), wynik i tak jest w cache wyglądów;
 * - kopia światła (shadower) leży na jednym planie cienia (ZMIMIC_SHADOW_PLANE), mnożonym przez jego plane master.
 *
 *! Here be dragons.
 */

#define READ_BASETURF(T) (islist(T.baseturfs) ? T.baseturfs[length(T.baseturfs)] : T.baseturfs)

SUBSYSTEM_DEF(zcopy)
	name = "Z-Copy"
	wait = 1
	init_order = INIT_ORDER_ZCOPY
	priority = FIRE_PRIORITY_ZCOPY
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/queued_turfs = list()
	var/qt_idex = 1
	var/list/queued_overlays = list()
	var/qo_idex = 1

	var/openspace_overlays = 0
	var/openspace_turfs = 0

	var/multiqueue_skips_turf = 0
	var/multiqueue_skips_object = 0

	// Caches for fixup.
	var/list/fixup_cache = list()
	var/list/fixup_known_good = list()

	// Fixup stats.
	var/fixup_miss = 0
	var/fixup_noop = 0
	var/fixup_hit = 0

/// Do wywołania przez admina (proc-call): przerysowuje wszystkie kafle Z-Mimic
/datum/controller/subsystem/zcopy/proc/update_all()
	can_fire = FALSE
	log_game("Z-Mimic: update_all() invoked.")

	var/turf/T
	var/num_upd = 0
	var/num_del = 0
	var/num_amupd = 0

	for (var/atom/A in world)
		if (isturf(A))
			T = A
			if (T.z_flags & Z_MIMIC_BELOW)
				T.update_mimic()
				num_upd += 1

		else if (istype(A, /atom/movable/openspace/mimic))
			var/turf/Tloc = A.loc
			if (TURF_IS_MIMICKING(Tloc))
				Tloc.update_mimic()
				num_amupd += 1
			else
				qdel(A)
				num_del += 1

		CHECK_TICK

	log_game("Z-Mimic: [num_upd + num_amupd] turf updates queued ([num_upd] direct, [num_amupd] indirect), [num_del] orphans destroyed.")

	if (!can_fire)
		next_fire = world.time + wait
		can_fire = TRUE

/datum/controller/subsystem/zcopy/stat_entry(msg)
	msg = "Q: { T: [queued_turfs.len - (qt_idex - 1)] O: [queued_overlays.len - (qo_idex - 1)] } T: { T: [openspace_turfs] O: [openspace_overlays] } Sk: { T: [multiqueue_skips_turf] O: [multiqueue_skips_object] } F: { H: [fixup_hit] M: [fixup_miss] N: [fixup_noop] }"
	return ..()

/datum/controller/subsystem/zcopy/Initialize(timeofday)
	// Flush the queue.
	fire(FALSE, TRUE)
	return ..()

/datum/controller/subsystem/zcopy/StartLoadingMap()
	can_fire = FALSE

/datum/controller/subsystem/zcopy/StopLoadingMap()
	next_fire = world.time + wait
	can_fire = TRUE

/datum/controller/subsystem/zcopy/fire(resumed = FALSE, no_mc_tick = FALSE)
	if (!resumed)
		qt_idex = 1
		qo_idex = 1

	MC_SPLIT_TICK_INIT(2)
	if (!no_mc_tick)
		MC_SPLIT_TICK

	var/list/curr_turfs = queued_turfs
	var/list/curr_ov = queued_overlays

	while (qt_idex <= curr_turfs.len)
		var/turf/T = curr_turfs[qt_idex]
		curr_turfs[qt_idex] = null
		qt_idex += 1

		if (!isturf(T) || !(T.z_flags & Z_MIMIC_BELOW) || !T.z_queued)
			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		// If we're not at our most recent queue position, don't bother -- we're updating again later anyways.
		if (T.z_queued > 1)
			T.z_queued -= 1
			multiqueue_skips_turf += 1

			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		// Z-Turf on the bottom-most level, just fake-copy space (or baseturf).
		// It's impossible for anything to be on the synthetic turf, so ignore the rest of the ZM machinery.
		if (!T.below)
			flush_z_state(T)
			if (T.z_flags & Z_MIMIC_BASETURF)
				simple_appearance_copy(T, READ_BASETURF(T), ZMIMIC_MAX_PLANE)
			else
				simple_appearance_copy(T, /turf/open/space, PLANE_SPACE)

			T.z_generation += 1
			T.z_queued -= 1

			if (T.above)
				T.above.update_mimic()

			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		if (!T.shadower)	// If we don't have a shadower yet, something has gone horribly wrong.
			T.z_queued -= 1
			WARNING("Turf [T] at [T.x],[T.y],[T.z] was queued, but had no shadower.")
			continue

		T.z_generation += 1

		// Get the bottom-most turf, the one we want to mimic.
		var/turf/Td = T
		while (Td.below)
			Td = Td.below

		// Depth must be the depth of the *visible* turf, not self.
		var/turf_depth = ZMIMIC_MAX_DEPTH - GET_TURF_DEPTH(Td)

		var/t_target = ZMIMIC_MAX_PLANE - turf_depth	// This is where the turf (but not the copied atoms) gets put.

		// Turf is set to mimic baseturf, handle that and bail.
		if (T.z_flags & Z_MIMIC_BASETURF)
			flush_z_state(T)
			simple_appearance_copy(T, READ_BASETURF(T), t_target)

			if (T.above)
				T.above.update_mimic()

			T.z_queued -= 1

			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		// If we previously were Z_MIMIC_BASETURF, there might be an orphaned proxy.
		else if (T.mimic_underlay)
			QDEL_NULL(T.mimic_underlay)

		// Handle space parallax & starlight.
		if (T.below.z_eventually_space)
			T.z_eventually_space = TRUE
			if ((T.below.z_flags & Z_MIMIC_OVERWRITE) || isspaceturf(T.below))
				t_target = PLANE_SPACE

		if (T.z_flags & Z_MIMIC_OVERWRITE)
			// This openturf doesn't care about its icon, so we can just overwrite it.
			if (T.below.mimic_proxy)
				QDEL_NULL(T.below.mimic_proxy)
			T.appearance = T.below
			T.name = initial(T.name)
			T.desc = initial(T.desc)
			T.gender = initial(T.gender)
			T.opacity = FALSE
			T.plane = t_target
		else
			// Some openturfs have icons, so we can't overwrite their appearance.
			if (!T.below.mimic_proxy)
				T.below.mimic_proxy = new(T)
			var/atom/movable/openspace/turf_proxy/TO = T.below.mimic_proxy
			TO.appearance = Td
			TO.name = T.name
			TO.gender = T.gender	// Need to grab this too so PLURAL works properly in examine.
			TO.opacity = FALSE
			TO.plane = t_target
			TO.mouse_opacity = initial(TO.mouse_opacity)

		// Explicitly copy turf delegates so they show up properly on below levels.
		//   I think it's possible to get this to work without discrete delegate copy objects, but I'd rather this just work.
		if ((T.below.z_flags & (Z_MIMIC_BELOW|Z_MIMIC_OVERWRITE)) == Z_MIMIC_BELOW)
			// Below is a delegate, gotta explicitly copy it for recursive copy.
			if (!T.below.mimic_above_copy)
				T.below.mimic_above_copy = new(T)
			var/atom/movable/openspace/turf_mimic/DC = T.below.mimic_above_copy
			DC.appearance = T.below
			DC.mouse_opacity = initial(DC.mouse_opacity)
			DC.plane = ZMIMIC_MAX_PLANE - turf_depth - 1

		else if (T.below.mimic_above_copy)
			QDEL_NULL(T.below.mimic_above_copy)

		T.shadower.copy_lighting(T.below.lighting_object)

		// Add everything below us to the update queue.
		for (var/thing in T.below)
			var/atom/movable/object = thing
			if (istype(object, /atom/movable/lighting_object))
				continue

			if (QDELETED(object) || (object.zmm_flags & ZMM_IGNORE) || object.loc != T.below || object.invisibility == INVISIBILITY_ABSTRACT)
				// Don't queue deleted stuff, stuff that's not visible, blacklisted stuff, or stuff that's centered on another tile but intersects ours.
				continue

			if (!object.bound_overlay)	// Generate a new overlay if the atom doesn't already have one.
				object.bound_overlay = new(T)
				object.bound_overlay.associated_atom = object

			var/override_depth
			var/original_type = object.type
			var/original_depth = GET_TURF_DEPTH(T.below)
			var/have_performed_fixup = FALSE

			switch (object.type)
				// Layering for recursive mimic needs to be inherited.
				if (/atom/movable/openspace/mimic)
					var/atom/movable/openspace/mimic/OOO = object
					original_type = OOO.mimiced_type
					override_depth = OOO.override_depth
					original_depth = OOO.original_depth
					have_performed_fixup = OOO.have_performed_fixup

				// If this is a turf proxy (the mimic for a non-OVERWRITE turf), it needs to respect space parallax if relevant.
				if (/atom/movable/openspace/turf_proxy)
					if (T.z_eventually_space)
						// Yes, this is an awful hack; I don't want to add yet another override_* var.
						override_depth = ZMIMIC_MAX_PLANE - PLANE_SPACE

				if (/atom/movable/openspace/turf_mimic)
					original_depth += 1

			var/atom/movable/openspace/mimic/OO = object.bound_overlay

			// If the OO was queued for destruction but was claimed by another OT, stop the destruction timer.
			if (OO.destruction_timer)
				deltimer(OO.destruction_timer)
				OO.destruction_timer = null

			OO.depth = override_depth || ZMIMIC_DEPTH(original_depth)

			// These types need to be pushed a layer down for bigturfs to function correctly.
			switch (original_type)
				if (/atom/movable/openspace/multiplier, /atom/movable/openspace/turf_proxy)
					if (OO.depth < ZMIMIC_MAX_DEPTH)
						OO.depth += 1

			OO.mimiced_type = original_type
			OO.override_depth = override_depth
			OO.original_depth = original_depth
			OO.have_performed_fixup ||= have_performed_fixup

			// Multi-queue to maintain ordering of updates to these
			//   queueing it multiple times will result in only the most recent
			//   actually processing.
			OO.queued += 1
			queued_overlays += OO

		T.z_queued -= 1
		if (T.above)
			T.above.update_mimic()

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break

	if (qt_idex > 1)
		curr_turfs.Cut(1, qt_idex)
		qt_idex = 1

	if (!no_mc_tick)
		MC_SPLIT_TICK

	while (qo_idex <= curr_ov.len)
		var/atom/movable/openspace/mimic/OO = curr_ov[qo_idex]
		curr_ov[qo_idex] = null
		qo_idex += 1

		if (QDELETED(OO) || !OO.queued)
			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		if (QDELETED(OO.associated_atom))	// This shouldn't happen, but just in-case.
			qdel(OO)

			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		// Don't update unless we're at the most recent queue occurrence.
		if (OO.queued > 1)
			OO.queued -= 1
			multiqueue_skips_object += 1

			if (no_mc_tick)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
			continue

		// Actually update the overlay.
		if (OO.dir != OO.associated_atom.dir)
			OO.dir = OO.associated_atom.dir

		if (OO.particles != OO.associated_atom.particles)
			OO.particles = OO.associated_atom.particles

		OO.appearance = OO.associated_atom
		// Render targets must stay unique
		if (OO.render_target)
			OO.render_target = null
		OO.zmm_flags = OO.associated_atom.zmm_flags
		OO.opacity = FALSE
		OO.queued = 0

		// Nakładki z jawnym planem (emisyjne, światło) trzeba przepiąć, inaczej rysują się na planach bieżącego piętra.
		// U Bee tylko z flagą ZMM_*MANGLE*; u nas zawsze, wynik jest w cache wyglądów.
		var/new_appearance = fixup_appearance_planes(OO.appearance, (OO.zmm_flags & ZMM_NO_CACHE_ROOT) ? 1 : 0)
		if (new_appearance)
			OO.appearance = new_appearance
			OO.have_performed_fixup = TRUE

		OO.plane = ZMIMIC_MAX_PLANE - OO.depth
		if (OO.mimiced_type == /atom/movable/openspace/multiplier)
			OO.plane = ZMIMIC_SHADOW_PLANE
		OO.mouse_opacity = OO.associated_atom.mouse_opacity

		if (OO.bound_overlay)	// If we have a bound overlay, queue it too.
			OO.update_above()

		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break

	if (qo_idex > 1)
		curr_ov.Cut(1, qo_idex)
		qo_idex = 1

/datum/controller/subsystem/zcopy/proc/flush_z_state(turf/T)
	if (T.below) // Z-Mimic turfs aren't necessarily above another turf.
		if (T.below.mimic_above_copy)
			QDEL_NULL(T.below.mimic_above_copy)
		if (T.below.mimic_proxy)
			QDEL_NULL(T.below.mimic_proxy)
	QDEL_NULL(T.mimic_underlay)
	for (var/atom/movable/openspace/mimic/OO in T)
		qdel(OO)

/datum/controller/subsystem/zcopy/proc/simple_appearance_copy(turf/T, new_appearance, target_plane)
	if (T.z_flags & Z_MIMIC_OVERWRITE)
		T.appearance = new_appearance
		T.name = initial(T.name)
		T.desc = initial(T.desc)
		T.gender = initial(T.gender)
		if (target_plane)
			T.plane = target_plane
	else
		// Some openturfs have icons, so we can't overwrite their appearance.
		if (!T.mimic_underlay)
			T.mimic_underlay = new(T)
		var/atom/movable/openspace/turf_proxy/TO = T.mimic_underlay
		TO.appearance = new_appearance
		TO.name = T.name
		TO.gender = T.gender // Need to grab this too so PLURAL works properly in examine.
		TO.mouse_opacity = initial(TO.mouse_opacity)
		if (target_plane)
			TO.plane = target_plane

// Recurse: for self, check if planes are invalid, if yes; return fixed appearance
// For each of overlay,underlay, call fixup_appearance_planes; if it returns a new appearance, replace self

/// Generate a new appearance from `appearance` with planes mangled to work with Z-Mimic. Do not pass a depth.
/datum/controller/subsystem/zcopy/proc/fixup_appearance_planes(appearance, cache_minimum_depth = 0, depth = 0)
	if (!appearance)
		return null

	if (fixup_known_good[appearance])
		fixup_hit += 1
		return null
	if (fixup_cache[appearance])
		fixup_hit += 1
		return fixup_cache[appearance]

	// If you have more than 4 layers of overlays within overlays, I dunno what to say.
	if (depth > 4)
		var/icon_name = "[appearance:icon]"
		WARNING("Fixup of appearance with icon [icon_name || "<unknown file>"] exceeded maximum recursion limit, bailing")
		return null

	var/plane_needs_fix = FALSE
	var/obliterate = FALSE

	// Don't fixup the root object's plane.
	if (depth > 0)
		switch (appearance:plane)
			if (GAME_PLANE, FLOOR_PLANE, FLOAT_PLANE)
				// fine
			if (EMISSIVE_PLANE, EMISSIVE_BLOCKER_PLANE, EMISSIVE_UNBLOCKABLE_PLANE, LIGHTING_PLANE, O_LIGHTING_VISUAL_PLANE)
				obliterate = TRUE
			else
				plane_needs_fix = TRUE

	// Scan & fix overlays
	var/list/fixed_overlays
	if (appearance:overlays:len)
		var/mutated = FALSE
		var/fixed_appearance
		for (var/i in 1 to appearance:overlays:len)
			if ((fixed_appearance = .(appearance:overlays[i], cache_minimum_depth, depth + 1)))
				mutated = TRUE
				if (!fixed_overlays)
					fixed_overlays = new(appearance:overlays.len)
				fixed_overlays[i] = fixed_appearance

		if (mutated)
			for (var/i in 1 to fixed_overlays.len)
				if (fixed_overlays[i] == null)
					fixed_overlays[i] = appearance:overlays[i]

	// Scan & fix underlays
	var/list/fixed_underlays
	if (appearance:underlays:len)
		var/mutated = FALSE
		var/fixed_appearance
		for (var/i in 1 to appearance:underlays:len)
			if ((fixed_appearance = .(appearance:underlays[i], cache_minimum_depth, depth + 1)))
				mutated = TRUE
				if (!fixed_underlays)
					fixed_underlays = new(appearance:underlays.len)
				fixed_underlays[i] = fixed_appearance

		if (mutated)
			for (var/i in 1 to fixed_underlays.len)
				if (fixed_underlays[i] == null)
					fixed_underlays[i] = appearance:underlays[i]

	// If we did nothing (no violations), don't bother creating a new appearance
	if (!plane_needs_fix && !obliterate && !fixed_overlays && !fixed_underlays)
		fixup_noop += 1
		if (depth >= cache_minimum_depth)
			fixup_known_good[appearance] = TRUE
		return null

	fixup_miss += 1

	// Nasz /mutable_appearance/New() wymusza FLOAT_PLANE, więc kopia wyglądu idzie przez przypisanie appearance
	var/mutable_appearance/MA = new
	MA.appearance = appearance
	if (plane_needs_fix)
		MA.plane = depth == 0 ? GAME_PLANE : FLOAT_PLANE
		MA.layer = FLY_LAYER	// probably fine
	if (obliterate)
		// Emissive or lighting, hide it.
		MA.invisibility = INVISIBILITY_ABSTRACT
		MA.alpha = 0

	if (fixed_overlays)
		MA.overlays = fixed_overlays

	if (fixed_underlays)
		MA.underlays = fixed_underlays

	if (depth >= cache_minimum_depth)
		fixup_cache[appearance] = MA.appearance

	return MA

/// Do wywołania przez admina (proc-call): pełny reset Z-Mimic
/datum/controller/subsystem/zcopy/proc/hard_reset()
	can_fire = FALSE
	log_game("Z-Mimic: hard_reset() invoked.")
	var/num_deleted = 0
	var/num_turfs = 0

	for (var/turf/T in world)
		if (T.z_queued)
			T.z_queued = 0
		CHECK_TICK

	queued_turfs.Cut()
	queued_overlays.Cut()

	var/turf/T
	for (var/atom/A in world)
		if (isturf(A))
			T = A
			if (T.z_flags & Z_MIMIC_BELOW)
				T.update_mimic()
				num_turfs += 1

		else if (istype(A, /atom/movable/openspace/mimic))
			qdel(A)
			num_deleted += 1

		CHECK_TICK

	log_game("Z-Mimic: deleted [num_deleted] overlays, and queued [num_turfs] turfs for update.")

	if (!can_fire)
		next_fire = world.time + wait
		can_fire = TRUE

#undef READ_BASETURF
