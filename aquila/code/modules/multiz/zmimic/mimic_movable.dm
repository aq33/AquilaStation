// Z-Mimic (port BeeStation/BeeStation-Hornet#8813, poprawki z BeeStation/BeeStation-Hornet#14823): obiekty

/// The mimic (if any) that's *directly* copying us.
/atom/movable/var/tmp/atom/movable/openspace/mimic/bound_overlay
/// Movable-level Z-Mimic flags. This uses ZMM_* flags, not ZM_* flags.
/atom/movable/var/zmm_flags = NONE

/atom/movable/setDir(newdir)
	var/old_dir = dir
	. = ..()
	if (bound_overlay && old_dir != dir)
		bound_overlay.setDir(dir)

/atom/movable/update_above()
	if (!bound_overlay || !isturf(loc))
		return

	if (MOVABLE_IS_BELOW_ZTURF(src))
		if (bound_overlay.queued)
			return
		SSzcopy.queued_overlays += bound_overlay
		bound_overlay.queued += 1
	else if (bound_overlay && !bound_overlay.destruction_timer)
		bound_overlay.destruction_timer = QDEL_IN(bound_overlay, 10 SECONDS)

// Grabs a list of every openspace mimic that's directly or indirectly copying this object. Returns an empty list if none found.
/atom/movable/proc/get_associated_mimics()
	. = list()
	var/atom/movable/curr = src
	while (curr.bound_overlay)
		. += curr.bound_overlay
		curr = curr.bound_overlay

// Hooki ruchu i wyglądu (w Bee wpisane w core)

/atom/movable/Initialize(mapload)
	. = ..()
	if(isturf(loc))
		var/turf/T = loc
		T.update_above()

/atom/movable/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if (bound_overlay)
		// The overlay will handle cleaning itself up on non-openspace turfs.
		if (isturf(loc))
			bound_overlay.forceMove(get_step(src, UP))
			if (bound_overlay && dir != bound_overlay.dir)
				bound_overlay.setDir(dir)
		else	// Not a turf, so we need to destroy immediately instead of waiting for the destruction timer to proc.
			qdel(bound_overlay)

/atom/movable/Destroy(force)
	if (bound_overlay)
		QDEL_NULL(bound_overlay)
	return ..()

/atom/movable/update_appearance(updates = ALL)
	. = ..()
	UPDATE_OO_IF_PRESENT

/atom/movable/update_icon(updates = ALL)
	. = ..()
	// update_appearance() nie zawsze jest wołane
	UPDATE_OO_IF_PRESENT

// Zmiany nakładek poza update_icon() (ubrania, stany maszyn). SSoverlays kompiluje je przed SSzcopy w tym samym ticku.
/atom/movable/add_overlay(list/overlays, priority = FALSE)
	. = ..()
	if (bound_overlay)
		update_above()

/atom/movable/cut_overlay(list/overlays, priority)
	. = ..()
	if (bound_overlay)
		update_above()

/atom/movable/cut_overlays(priority = FALSE)
	. = ..()
	if (bound_overlay)
		update_above()

// -- Openspace movables --

/atom/movable/openspace
	name = ""
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/openspace/ex_act(severity, target)
	return

/atom/movable/openspace/singularity_act()
	return

/atom/movable/openspace/singularity_pull(obj/anomaly/singularity/S, current_size)
	return

/atom/movable/openspace/attackby(obj/item/W, mob/user, params)
	return

/atom/movable/openspace/fire_act(exposed_temperature, exposed_volume)
	return

/atom/movable/openspace/acid_act(acidpwr, acid_volume)
	return

/atom/movable/openspace/mech_melee_attack(obj/mecha/M)
	return 0

/atom/movable/openspace/blob_act(obj/structure/blob/B)
	return

/atom/movable/openspace/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	return 0

/atom/movable/openspace/experience_pressure_difference()
	return

/atom/movable/openspace/has_gravity(turf/T)
	return FALSE

// -- MULTIPLIER / SHADOWER --

/// Kopia światła kafla z piętra niżej. Leży na wspólnym planie cienia, którego plane master mnoży się
/// na wszystkie plany kopii (u nas bez przekaźników planów, więc mnożenie robi plane master, nie obiekt).
/atom/movable/openspace/multiplier
	name = "openspace multiplier"
	desc = "You shouldn't see this."
	icon = LIGHTING_ICON
	icon_state = "transparent"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ZMIMIC_SHADOW_PLANE
	layer = MIMICKED_LIGHTING_LAYER
	blend_mode = BLEND_OVERLAY

/atom/movable/openspace/multiplier/Destroy(force)
	var/turf/myturf = loc
	if(!force)
		// Prom albo szablon mapy czyści cały kafel: kopia światła zostaje, dopóki kafel pokazuje piętro niżej.
		// Usuwa ją cleanup_zmimic() z force, gdy kafel przestaje być otwartą przestrzenią.
		if(istype(myturf) && myturf.shadower == src && (myturf.z_flags & Z_MIMIC_BELOW))
			return QDEL_HINT_LETMELIVE
	if (istype(myturf))
		myturf.shadower = null
	return ..()

/atom/movable/openspace/multiplier/proc/copy_lighting(atom/movable/lighting_object/lighting_object)
	if (!lighting_object)
		// Piętro niżej bez dynamicznego światła (kosmos, pełne oświetlenie): nic nie przyciemnia
		icon = LIGHTING_ICON
		icon_state = "transparent"
		color = null
	else
		appearance = lighting_object
	layer = MIMICKED_LIGHTING_LAYER
	plane = ZMIMIC_SHADOW_PLANE
	blend_mode = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = 0
	UPDATE_OO_IF_PRESENT

//! -- OPENSPACE MIMIC --
/// Object used to hold a mimiced atom's appearance.
/atom/movable/openspace/mimic
	plane = ZMIMIC_MAX_PLANE
	var/atom/movable/associated_atom
	var/depth
	var/queued = 0
	var/destruction_timer
	var/mimiced_type
	var/original_depth
	var/override_depth
	var/have_performed_fixup = FALSE

/atom/movable/openspace/mimic/New()
	flags_1 |= INITIALIZED_1
	SSzcopy.openspace_overlays += 1

/atom/movable/openspace/mimic/Destroy()
	SSzcopy.openspace_overlays -= 1
	queued = 0
	if (associated_atom)
		associated_atom.bound_overlay = null
		associated_atom = null
	if (destruction_timer)
		deltimer(destruction_timer)
		destruction_timer = null
	return ..()

/atom/movable/openspace/mimic/attackby(obj/item/W, mob/user, params)
	to_chat(user, span_notice("[capitalize("[src]")] jest za daleko."))
	return TRUE

/atom/movable/openspace/mimic/attack_hand(mob/user, list/modifiers)
	to_chat(user, span_notice("Nie sięgasz stąd do: [src]."))
	return TRUE

/atom/movable/openspace/mimic/examine(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	. = associated_atom?.examine(user)

/atom/movable/openspace/mimic/forceMove(atom/destination)
	. = ..()
	if (associated_atom && MOVABLE_IS_BELOW_ZTURF(associated_atom))
		if (destruction_timer)
			deltimer(destruction_timer)
			destruction_timer = null
	else if (!destruction_timer)
		destruction_timer = QDEL_IN(src, 10 SECONDS)

/atom/movable/openspace/mimic/newtonian_move(direction, instant = FALSE, start_delay = 0)
	return TRUE

// Called when the turf we're on is deleted/changed.
/atom/movable/openspace/mimic/proc/owning_turf_changed()
	if (!destruction_timer)
		destruction_timer = QDEL_IN(src, 10 SECONDS)

// -- TURF PROXY --
// This thing holds the mimic appearance for non-OVERWRITE turfs.
/atom/movable/openspace/turf_proxy
	plane = ZMIMIC_MAX_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	zmm_flags = ZMM_IGNORE  // Only one of these should ever be visible at a time, the mimic logic will handle that.

/atom/movable/openspace/turf_proxy/attackby(obj/item/W, mob/user, params)
	return loc.attackby(W, user, params)

/atom/movable/openspace/turf_proxy/attack_hand(mob/user, list/modifiers)
	return loc.attack_hand(user, modifiers)

/atom/movable/openspace/turf_proxy/examine(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	. = loc.examine(user)

// -- TURF MIMIC --
// A type for copying non-overwrite turfs' self-appearance.
/atom/movable/openspace/turf_mimic
	plane = ZMIMIC_MAX_PLANE	// These *should* only ever be at the top?
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/turf/delegate

/atom/movable/openspace/turf_mimic/Initialize(mapload, ...)
	. = ..()
	ASSERT(isturf(loc))
	delegate = loc:below

/atom/movable/openspace/turf_mimic/attackby(obj/item/W, mob/user, params)
	loc.attackby(W, user, params)

/atom/movable/openspace/turf_mimic/attack_hand(mob/user, list/modifiers)
	to_chat(user, span_notice("Nie sięgasz stąd do: [src]."))
	return TRUE

/atom/movable/openspace/turf_mimic/examine(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	. = delegate.examine(user)
