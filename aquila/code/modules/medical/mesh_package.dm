// AQUILA - sterile packaging of the regenerative mesh from tgstation (code/game/objects/items/stacks/medical.dm).
// A full pack comes sealed: use it in hand (Z) to open it, only then it treats burns and pieces can be taken out.

/obj/item/stack/medical/mesh
	/// The sterile packaging has been opened
	var/is_open = TRUE

/obj/item/stack/medical/mesh/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(amount == max_amount) // only full packs are sealed
		is_open = FALSE
		update_icon()

/obj/item/stack/medical/mesh/update_icon_state()
	. = ..()
	if(!is_open)
		icon_state = "[initial(icon_state)]_closed"

/obj/item/stack/medical/mesh/examine(mob/user)
	. = ..()
	if(!is_open)
		. += "<span class='notice'>Jest w zamkniętym, sterylnym opakowaniu. Otwórz je (Z).</span>"

/obj/item/stack/medical/mesh/attack_self(mob/user)
	if(is_open)
		return ..()
	is_open = TRUE
	balloon_alert(user, "otwarte")
	update_icon()
	playsound(src, 'sound/items/poster_ripped.ogg', 20, TRUE)

/obj/item/stack/medical/mesh/pre_attack(atom/A, mob/living/user, params)
	if(!is_open && isliving(A))
		balloon_alert(user, "najpierw otwórz (Z)")
		return FALSE
	return ..()

/obj/item/stack/medical/mesh/attack_hand(mob/user)
	if(!is_open && user.get_inactive_held_item() == src)
		balloon_alert(user, "najpierw otwórz (Z)")
		return
	return ..()

/obj/item/stack/medical/mesh/AltClick(mob/living/user)
	if(!is_open)
		balloon_alert(user, "najpierw otwórz (Z)")
		return
	return ..()

/obj/item/stack/medical/mesh/attack_hand_secondary(mob/user, modifiers)
	if(!is_open)
		balloon_alert(user, "najpierw otwórz (Z)")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()
