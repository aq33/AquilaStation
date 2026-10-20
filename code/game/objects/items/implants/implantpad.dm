/obj/item/implantpad
	name = "implant pad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/implantcase/case = null

/obj/item/implantpad/update_icon()
	icon_state = "implantpad-[!QDELETED(case)]"

/obj/item/implantpad/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "[case ? "Zawiera [case]" : "Jest obecnie pusty"]."
		if(case)
			. += "<span class='info'>Alt-kliknij, by wyjąć [case].</span>"
	else
		if(case)
			. += "<span class='warning'>Coś chyba jest w środku, ale stąd nie da się stwierdzić co...</span>"

/obj/item/implantpad/handle_atom_del(atom/A)
	if(A == case)
		case = null
	update_icon()
	SStgui.update_uis(src)
	. = ..()

/obj/item/implantpad/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	remove_implant(user)

/obj/item/implantpad/attackby(obj/item/implantcase/C, mob/user, params)
	if(istype(C, /obj/item/implantcase) && !case)
		if(!user.transferItemToLoc(C, src))
			return
		case = C
		SStgui.update_uis(src)
		update_icon()
	else
		return ..()

/// AQUILA: wyjmuje obudowę implantu z minikomputera (Alt-klik i przycisk w oknie TGUI)
/obj/item/implantpad/proc/remove_implant(mob/user)
	if(!case)
		to_chat(user, "<span class='warning'>W [src] nie ma implantu do wyjęcia.</span>")
		return FALSE
	user.put_in_hands(case)
	add_fingerprint(user)
	case.add_fingerprint(user)
	case = null
	SStgui.update_uis(src)
	update_icon()
	return TRUE

/obj/item/implantpad/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ImplantPad", name)
		ui.open()

/obj/item/implantpad/ui_data(mob/user)
	var/list/data = list()
	data["has_case"] = !!case
	data["has_implant"] = !!case?.imp
	data["case_information"] = case?.imp ? case.imp.get_data() : null
	return data

/obj/item/implantpad/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "eject_implant")
		if(!usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
			return
		remove_implant(usr)
		return TRUE
