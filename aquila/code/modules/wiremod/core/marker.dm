/obj/item/multitool/circuit
	name = "circuit multitool"
	desc = "A circuit multitool. Used to mark entities which can then be uploaded to components by pressing the upload button on a port. \
	Acts as a normal multitool otherwise. Use in hand to clear marked entity so that you can mark another entity."
	icon_state = "multitool_circuit"
	item_state = "multitool_circuit"
	custom_materials = list(/datum/material/iron = (MINERAL_MATERIAL_AMOUNT / 2), /datum/material/glass = (MINERAL_MATERIAL_AMOUNT / 2))

	/// The marked atom of this multitool
	var/atom/marked_atom

/obj/item/multitool/circuit/Destroy()
	marked_atom = null
	return ..()

/obj/item/multitool/circuit/examine(mob/user)
	. = ..()
	. += span_notice("It has [marked_atom? "a" : "no"] marked entity registered.")

/obj/item/multitool/circuit/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(!marked_atom)
		return

	say("Cleared marked targets.")
	clear_marked_atom()
	return TRUE

/obj/item/multitool/circuit/melee_attack_chain(mob/user, atom/target, params)
	var/list/modifiers = params2list(params)
	var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)

	if(marked_atom || !user.Adjacent(target) || is_right_clicking)
		return ..()

	if(isliving(target))
		INVOKE_ASYNC(src, PROC_REF(mark_mob_or_contents), user, target)
		return TRUE

	mark_target(target)

/obj/item/multitool/circuit/proc/mark_target(atom/target)
	say("Marked [target].")
	marked_atom = target
	RegisterSignal(marked_atom, COMSIG_QDELETING, PROC_REF(cleanup_marked_atom))
	update_icon()
	flick("multitool_circuit_flick", src)
	playsound(src.loc, 'sound/misc/compiler-stage2.ogg', 30, TRUE)
	return TRUE

/// Allow users to mark items equipped by the target that are visible.
/obj/item/multitool/circuit/proc/mark_mob_or_contents(mob/user, mob/living/target)
	var/list/visible_items = get_markable_items(target)
	if(!length(visible_items))
		mark_target(target)
		return

	// Klucz to nazwa (tak u nas działają podpowiedzi w menu radialnym), wartość to obiekt.
	var/list/selectable_targets = list()
	var/list/atoms_by_name = list()
	var/list/used_names = list()
	var/datum/radial_menu_choice/mob_choice = new
	mob_choice.image = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mob")
	var/mob_key = avoid_assoc_duplicate_keys(target.name, used_names)
	atoms_by_name[mob_key] = target
	selectable_targets[mob_key] = mob_choice
	for(var/obj/item/item as anything in visible_items)
		var/datum/radial_menu_choice/item_choice = new
		var/mutable_appearance/item_appearance = new(item)
		item_appearance.layer = FLOAT_LAYER
		item_appearance.plane = FLOAT_PLANE
		item_choice.image = item_appearance
		var/item_key = avoid_assoc_duplicate_keys(item.name, used_names)
		atoms_by_name[item_key] = item
		selectable_targets[item_key] = item_choice

	var/picked = show_radial_menu(user, src, selectable_targets, radius = 38, custom_check = CALLBACK(src, PROC_REF(check_menu), user, target), tooltips = TRUE)
	if(!picked)
		return

	var/atom/movable/chosen = atoms_by_name[picked]
	if(chosen == target || (chosen in get_markable_items(target)))
		mark_target(chosen)
	else
		balloon_alert(user, "cannot mark entity")

/// Przedmioty na celu, które widać i można oznaczyć.
/obj/item/multitool/circuit/proc/get_markable_items(mob/living/target)
	. = list()
	var/list/candidates = target.get_equipped_items() + target.held_items
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/list/obscured = carbon_target.check_obscured_slots()
		for(var/obj/item/item as anything in candidates)
			if(item && (item.slot_flags & obscured))
				candidates -= item
	for(var/obj/item/item in candidates)
		if(item == src || HAS_TRAIT(item, TRAIT_NO_STRIP) || HAS_TRAIT(item, TRAIT_EXAMINE_SKIP))
			continue
		. += item

/obj/item/multitool/circuit/proc/check_menu(mob/user, mob/living/target)
	return !marked_atom && user.is_holding(src) && user.Adjacent(target)

/obj/item/multitool/circuit/update_overlays()
	. = ..()
	cut_overlays()
	if(marked_atom)
		. += "marked_overlay"

/// Clears the current marked atom
/obj/item/multitool/circuit/proc/clear_marked_atom()
	if(!marked_atom)
		return
	UnregisterSignal(marked_atom, COMSIG_QDELETING)
	marked_atom = null
	update_icon()

/obj/item/multitool/circuit/proc/cleanup_marked_atom(datum/source)
	SIGNAL_HANDLER
	if(source == marked_atom)
		clear_marked_atom()
