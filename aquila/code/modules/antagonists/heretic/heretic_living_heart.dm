/**
 * # Living Heart Component
 *
 * Applied to a heart to turn it into a heretic's 'living heart'.
 * The living heart is what they use to track people they need to sacrifice.
 *
 * This component handles the action associated with it -
 * if the organ is removed, the action should be deleted
 */
/datum/component/living_heart
	/// The action we create and give to our heart.
	var/datum/action/cooldown/track_target/action

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	action = new(src)
	action.Grant(organ_parent.owner)

/datum/component/living_heart/Destroy(force)
	QDEL_NULL(action)
	return ..()

/datum/component/living_heart/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	RegisterSignal(parent, COMSIG_ORGAN_BEING_REPLACED, PROC_REF(on_organ_replaced))

/datum/component/living_heart/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	UnregisterSignal(parent, list(COMSIG_ORGAN_REMOVED, COMSIG_ORGAN_BEING_REPLACED))

/datum/component/living_heart/PostTransfer(datum/new_parent)
	if(!isorgan(new_parent))
		return COMPONENT_INCOMPATIBLE

/**
 * Signal proc for [COMSIG_ORGAN_REMOVED].
 *
 * If the organ is removed, the component will remove itself.
 */
/datum/component/living_heart/proc/on_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	if(old_owner)
		to_chat(old_owner, span_userdanger("Gdy żywy organ ([source.name]) opuszcza twoje ciało, czujesz słabszą więź z Mansusem!"))
	qdel(src)

/**
 * Signal proc for [COMSIG_ORGAN_BEING_REPLACED].
 *
 * If the organ is replaced, before it's done transfer the component over
 */
/datum/component/living_heart/proc/on_organ_replaced(obj/item/organ/source, obj/item/organ/replacement)
	SIGNAL_HANDLER

	// AQUILA - u nas sztuczne organy mają flagę ORGAN_SYNTHETIC (tg: IS_ROBOTIC_ORGAN)
	if(replacement.organ_flags & ORGAN_SYNTHETIC)
		qdel(src)
		return

	replacement.TakeComponent(src)

/**
 * The action associated with the living heart.
 * Allows a heretic to track sacrifice targets.
 */
/datum/action/cooldown/track_target
	name = "Living Heartbeat"
	desc = "LPM: wybierz cel ofiarny do namierzenia. PPM (w intencjach: na rozbrajaniu): namierz ponownie ostatni wybrany cel."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_ecult"
	icon_icon = 'aquila/icons/obj/antags/eldritch.dmi'
	button_icon_state = "living_heart"
	cooldown_time = 4 SECONDS

	/// Tracks whether we were right clicked or left clicked in our last trigger
	var/right_clicked = FALSE
	/// The real name of the last thing we tracked
	var/last_tracked_name
	/// Whether the target radial is currently opened.
	var/radial_open = FALSE

/datum/action/cooldown/track_target/Grant(mob/granted)
	if(!IS_HERETIC(granted))
		return

	return ..()

/datum/action/cooldown/track_target/IsAvailable(feedback = FALSE)
	// AQUILA - nasze /datum/action/cooldown nie sprawdza check_flags
	if(!owner || owner.stat != CONSCIOUS)
		return FALSE
	. = ..()
	if(!.)
		return

	if(!IS_HERETIC(owner))
		return FALSE
	if(radial_open)
		return FALSE

	return TRUE

/datum/action/cooldown/track_target/Trigger(trigger_flags, atom/target)
	right_clicked = !!(trigger_flags & TRIGGER_SECONDARY_ACTION)
	if(!..())
		return FALSE
	// AQUILA - u nas akcje nie mają łańcucha PreActivate/Activate, a menu kołowe usypia
	INVOKE_ASYNC(src, PROC_REF(Activate), target)
	return TRUE

/// AQUILA - tg: StartCooldown(czas); u nas bazowe StartCooldown() nie bierze czasu
/datum/action/cooldown/track_target/StartCooldown(override_cooldown_time)
	if(!isnum(override_cooldown_time))
		return ..()
	var/old_cooldown_time = cooldown_time
	cooldown_time = override_cooldown_time
	. = ..()
	cooldown_time = old_cooldown_time

/datum/action/cooldown/track_target/proc/Activate(atom/target)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(owner)
	if(!heretic_datum)
		return FALSE
	var/datum/heretic_knowledge/sac_knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)

	if(!LAZYLEN(heretic_datum.sac_targets) && !LAZYLEN(heretic_datum.tracked_items))
		owner.balloon_alert(owner, "brak celów, odwiedź runę!")
		StartCooldown(1 SECONDS)
		return TRUE

	// Holds a list of `name = image` used to display the radial menu when you left click the living heart
	var/list/choosable_targets = list()
	// Holds a list of 'name = atom/thing` used to check if our thing still exists after we've made our selection
	var/list/possible_tracked_atoms = list()
	// Tracks names to how many times they show up, so we can append a number to them if multiple of the same name exist
	var/list/existing_name_counts = list()

	// Checks if our heretic has a blade research, and then checks if they have made blades
	// adds them to our list of target when pulsing the living heart so that you can locate them
	for(var/datum/weakref/item_ref as anything in heretic_datum.tracked_items)
		var/obj/item/item = item_ref?.resolve()
		if(QDELETED(item))
			LAZYREMOVE(heretic_datum.tracked_items, item_ref)
			continue
		if(get(item, /mob/living) == owner)
			continue
		// Means our blade is somewhere, but not on our person, so let's make it trackable
		var/item_name = item.name
		if(existing_name_counts[item_name])
			existing_name_counts[item_name] += 1
			item_name += " ([existing_name_counts[item_name]])"

		choosable_targets[item_name] = image(item.icon, icon_state = item.icon_state)
		possible_tracked_atoms[item_name] = item
		existing_name_counts[item_name] = 1

	for(var/mob/living/carbon/human/sac_target as anything in heretic_datum.sac_targets)
		var/target_name = sac_target.real_name
		if(existing_name_counts[target_name])
			existing_name_counts[target_name] += 1
			target_name += " ([existing_name_counts[target_name]])"

		choosable_targets[target_name] = heretic_datum.sac_targets[sac_target]
		possible_tracked_atoms[target_name] = sac_target
		existing_name_counts[target_name] = 1

	if(!length(choosable_targets))
		owner.balloon_alert(owner, "brak celów, odwiedź runę!")
		StartCooldown(1 SECONDS)
		return TRUE

	// If we don't have a last tracked name, open a radial to set one.
	// If we DO have a last tracked name, we skip the radial if they right click the action.
	if(isnull(last_tracked_name) || !right_clicked)
		radial_open = TRUE
		last_tracked_name = show_radial_menu(
			owner,
			owner,
			choosable_targets,
			custom_check = CALLBACK(src, PROC_REF(check_menu)),
			radius = 40,
			require_near = TRUE,
			tooltips = TRUE,
		)
		radial_open = FALSE

	// If our last tracked name is still null, skip the trigger
	if(isnull(last_tracked_name))
		return FALSE

	var/atom/tracked_thing = possible_tracked_atoms[last_tracked_name]
	if(QDELETED(tracked_thing))
		last_tracked_name = null
		return FALSE

	playsound(owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	owner.balloon_alert(owner, get_balloon_message(tracked_thing))

	// Let them know how to sacrifice people if they're able to be sac'd
	if(ismob(tracked_thing))
		var/mob/tracked_mob = tracked_thing
		if(tracked_mob.stat == DEAD && sac_knowledge)
			to_chat(owner, span_mansus("[tracked_mob] nie żyje. Zanieś ciało na runę transmutacji \
				i odpraw \"[sac_knowledge.name]\", by złożyć tę osobę w ofierze!"))

	StartCooldown()
	return TRUE

/// Callback for the radial to ensure it's closed when not allowed.
/datum/action/cooldown/track_target/proc/check_menu()
	if(QDELETED(src))
		return FALSE
	if(!IS_HERETIC(owner))
		return FALSE
	return TRUE

/// Gets the balloon message for who we're tracking.
/datum/action/cooldown/track_target/proc/get_balloon_message(atom/tracked_thing)
	var/balloon_message = "błąd!"
	var/turf/their_turf = get_turf(tracked_thing)
	var/turf/our_turf = get_turf(owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	// One of us is in somewhere we shouldn't be
	if(!our_z || !their_z)
		// "Hell if I know"
		balloon_message = "na innym planie!"

	// They're not on the same z-level as us
	else if(our_z != their_z)
		// They're on the station
		if(is_station_level(their_z))
			// We're on a multi-z station
			if(is_station_level(our_z))
				if(our_z > their_z)
					balloon_message = "pod tobą!"
				else
					balloon_message = "nad tobą!"
			// We're off station, they're not
			else
				balloon_message = "na statku!"

		// Mining
		else if(is_mining_level(their_z))
			balloon_message = "na planecie górniczej!"

		// In the gateway
		else if(is_away_level(their_z) || is_reserved_level(their_z))
			balloon_message = "za bramą!"

		// They're somewhere we probably can't get too - sacrifice z-level, centcom, etc
		else
			balloon_message = "na innym planie!"

	// They're on the same z-level as us!
	else
		var/dist = get_dist(our_turf, their_turf)
		// AQUILA - kierunki po polsku
		var/static/list/polish_dirs = list(
			"[NORTH]" = "na północ",
			"[SOUTH]" = "na południe",
			"[EAST]" = "na wschód",
			"[WEST]" = "na zachód",
			"[NORTHEAST]" = "na północny wschód",
			"[NORTHWEST]" = "na północny zachód",
			"[SOUTHEAST]" = "na południowy wschód",
			"[SOUTHWEST]" = "na południowy zachód",
		)
		var/dir = polish_dirs["[get_dir(our_turf, their_turf)]"] || "tutaj"

		var/arrow_color

		switch(dist)
			if(0 to 15)
				balloon_message = "bardzo blisko, [dir]!"
				arrow_color = COLOR_GREEN
			if(16 to 31)
				balloon_message = "blisko, [dir]!"
				arrow_color = COLOR_YELLOW
			if(32 to 127)
				balloon_message = "daleko, [dir]!"
				arrow_color = COLOR_ORANGE
			else
				balloon_message = "bardzo daleko!"
				arrow_color = COLOR_RED

		// AQUILA - u nas HUD nie ma add_screen_object, strzałkę dokładamy prosto do ekranu klienta
		if(owner.client)
			var/atom/movable/screen/navigate_arrow/arrow = new()
			arrow.viewer = owner.client
			owner.client.screen += arrow
			arrow.start_effect(owner, their_turf, arrow_color)

	if(ismob(tracked_thing))
		var/mob/tracked_mob = tracked_thing
		if(tracked_mob.stat == DEAD)
			balloon_message = "nie żyje, " + balloon_message

	return balloon_message

/atom/movable/screen/navigate_arrow
	icon = 'aquila/icons/effects/heretic_96x96.dmi'
	name = "farsight arrow"
	icon_state = "navigate_arrow_appear"
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-1,CENTER-1"
	/// AQUILA - klient, któremu pokazujemy strzałkę
	var/client/viewer

/atom/movable/screen/navigate_arrow/proc/start_effect(mob/owner, turf/tracked_turf, arrow_color)
	if (owner)
		animate(src, transform = matrix(get_angle(owner, tracked_turf), MATRIX_ROTATE), 0.2 SECONDS)
	color = arrow_color
	addtimer(CALLBACK(src, PROC_REF(end_effect)), 1.6 SECONDS)

/atom/movable/screen/navigate_arrow/Destroy()
	viewer?.screen -= src
	viewer = null
	return ..()

/atom/movable/screen/navigate_arrow/proc/end_effect()
	icon_state = "navigate_arrow_disappear"
	QDEL_IN(src, 0.4 SECONDS)
