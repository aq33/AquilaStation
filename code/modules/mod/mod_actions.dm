// AQUILA: akcje modułów hardsuitu (dawniej MODsuitu). Bez rozkładania i aktywacji (hełm ma swoją akcję) i bez SI w kombinezonie.
/datum/action/item_action/mod
	background_icon_state = "bg_mod"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	button_icon = 'icons/mob/actions/backgrounds.dmi'
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/mod/New(Target)
	..()
	if(!istype(Target, /obj/item/clothing/suit/space/hardsuit))
		qdel(src)
		return

/datum/action/item_action/mod/Trigger(trigger_flags)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	on_activate(owner, target, trigger_flags)
	return TRUE

/// What the action does when pressed. Called by Trigger() after the availability checks.
/datum/action/item_action/mod/proc/on_activate(mob/user, obj/item/clothing/suit/space/hardsuit/mod, trigger_flags)
	return

/datum/action/item_action/mod/module
	name = "Przełącz moduł"
	desc = "Wybiera moduł kombinezonu do użycia."
	button_icon_state = "module"

/datum/action/item_action/mod/module/on_activate(mob/user, obj/item/clothing/suit/space/hardsuit/mod, trigger_flags)
	if(!mod.try_activate(user)) // kombinezon założony przez kogoś innego uruchamia się dopiero tu (blokada DNA)
		return
	mod.quick_module(user)

/datum/action/item_action/mod/panel
	name = "Panel kombinezonu"
	desc = "Otwiera panel modułów i zasilania kombinezonu."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/on_activate(mob/user, obj/item/clothing/suit/space/hardsuit/mod, trigger_flags)
	if(!mod.try_activate(user))
		return
	mod.ui_interact(user)

/datum/action/item_action/mod/pinned_module
	desc = "Aktywuje moduł."
	/// Overrides the icon applications.
	var/override = FALSE
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// A reference to the mob we are pinned to.
	var/mob/pinner
	/// Timer until we remove our cooldown overlay
	var/cooldown_timer

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	. = ..()
	module = linked_module
	pinner = user
	module.pinned_to[REF(user)] = src
	if(linked_module.allow_flags & MODULE_ALLOW_INCAPACITATED)
		// clears check hands and check conscious
		check_flags = NONE
	name = "Aktywuj: [linked_module.name]"
	desc = "Szybko aktywuje moduł: [linked_module]."
	button.name = name
	button.desc = desc
	icon_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	RegisterSignal(linked_module, list(
		COMSIG_MODULE_ACTIVATED,
		COMSIG_MODULE_DEACTIVATED,
		COMSIG_MODULE_USED,
	), PROC_REF(module_interacted_with))
	RegisterSignal(linked_module, COMSIG_MODULE_COOLDOWN_STARTED, PROC_REF(cooldown_started))
	// PREQDELETED, since Grant() registers QDELETING on the owner
	RegisterSignal(user, COMSIG_PARENT_PREQDELETED, PROC_REF(pinner_deleted))

/datum/action/item_action/mod/pinned_module/Destroy()
	deltimer(cooldown_timer)
	UnregisterSignal(module, list(
		COMSIG_MODULE_ACTIVATED,
		COMSIG_MODULE_DEACTIVATED,
		COMSIG_MODULE_COOLDOWN_STARTED,
		COMSIG_MODULE_USED,
	))
	module.pinned_to -= REF(pinner)
	module = null
	pinner = null
	return ..()

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	if(pinner != user)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/on_activate(mob/user, obj/item/clothing/suit/space/hardsuit/mod, trigger_flags)
	module.on_select()

/datum/action/item_action/mod/pinned_module/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	current_button.cut_overlays(TRUE)
	current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
	current_button.button_icon_state = button_icon_state
	if(override)
		return
	var/obj/item/clothing/suit/space/hardsuit/mod = target
	if(module == mod.selected_module)
		current_button.add_overlay(image(icon = 'icons/mob/radial.dmi', icon_state = "module_selected", layer = FLOAT_LAYER-0.1))
	else if(module.active)
		current_button.add_overlay(image(icon = 'icons/mob/radial.dmi', icon_state = "module_active", layer = FLOAT_LAYER-0.1))
	if(!COOLDOWN_FINISHED(module, cooldown_timer))
		current_button.add_overlay(image(icon = 'icons/mob/radial.dmi', icon_state = "module_cooldown"))

/// If the guy whose UI we are pinned to got deleted
/datum/action/item_action/mod/pinned_module/proc/pinner_deleted()
	SIGNAL_HANDLER

	pinner = null
	qdel(src)

/datum/action/item_action/mod/pinned_module/proc/module_interacted_with(datum/source)
	SIGNAL_HANDLER

	UpdateButtonIcon(force = TRUE)

/datum/action/item_action/mod/pinned_module/proc/cooldown_started(datum/source, cooldown_time)
	SIGNAL_HANDLER

	deltimer(cooldown_timer)
	UpdateButtonIcon(force = TRUE)
	if (cooldown_time == 0)
		return
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(UpdateButtonIcon), FALSE, TRUE), cooldown_time + 1, TIMER_STOPPABLE)
