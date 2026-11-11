// Pager drużyny schowany w PDA: wkłada się go kliknięciem pagerem w PDA, okno pagera otwiera przycisk akcji PDA,
// a wyjmuje Alt-klik (po karcie, przed długopisem; długopis wyjmuje Ctrl-klik) albo czynność „Wyjmij pager”. Schowany pager dalej odbiera łączność,
// komunikaty na ekranie i rozkazy, tak jak pager noszony przy sobie.

/obj/item/modular_computer/tablet
	var/obj/item/squad_pager/aq_squad_pager
	var/datum/action/item_action/aq_squad_pager/aq_squad_pager_action

/datum/action/item_action/aq_squad_pager
	name = "Pager drużyny"
	desc = "Otwiera pager drużyny schowany w PDA."
	icon_icon = 'nsv13/icons/obj/squad.dmi'
	button_icon_state = "squadpager"

/datum/action/item_action/aq_squad_pager/Trigger()
	if(!IsAvailable())
		return FALSE
	var/obj/item/modular_computer/tablet/pda = target
	if(!istype(pda) || !pda.aq_squad_pager)
		return FALSE
	pda.aq_squad_pager.attack_self(owner)
	return TRUE

/obj/item/modular_computer/tablet/attackby(obj/item/attacking_item, mob/user)
	if(!istype(attacking_item, /obj/item/squad_pager))
		return ..()
	if(aq_squad_pager)
		to_chat(user, "<span class='warning'>W [src] jest już pager drużyny.</span>")
		return TRUE
	if(!user.transferItemToLoc(attacking_item, src))
		return TRUE
	aq_insert_squad_pager(attacking_item, user)
	to_chat(user, "<span class='notice'>Wsuwasz [attacking_item] do [src]. Otworzysz go przyciskiem „Pager drużyny”, a wyjmiesz Alt-klikiem.</span>")
	playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)
	return TRUE

/obj/item/modular_computer/tablet/proc/aq_insert_squad_pager(obj/item/squad_pager/pager, mob/user)
	aq_squad_pager = pager
	aq_squad_pager_action = new(src)
	var/mob/holder = loc
	if(ismob(holder))
		aq_squad_pager_action.Grant(holder)
		pager.squad_channel?.on_equip(pager, holder, null)

/obj/item/modular_computer/tablet/proc/aq_eject_squad_pager(mob/user)
	if(!aq_squad_pager)
		return FALSE
	var/obj/item/squad_pager/pager = aq_squad_pager
	if(user)
		to_chat(user, "<span class='notice'>Wyjmujesz [pager] z [src].</span>")
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
		if(!user.put_in_hands(pager))
			pager.forceMove(drop_location())
	else
		pager.forceMove(drop_location())
	return TRUE

/// Pager opuścił PDA (wyjęty, wyrzucony przez zniszczenie PDA): sprzątamy akcję i kanał noszącego
/obj/item/modular_computer/tablet/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != aq_squad_pager)
		return
	var/mob/holder = loc
	if(ismob(holder))
		aq_squad_pager.squad_channel?.on_drop(aq_squad_pager, holder)
	aq_squad_pager = null
	QDEL_NULL(aq_squad_pager_action)

/obj/item/modular_computer/tablet/equipped(mob/user, slot, initial)
	. = ..()
	aq_squad_pager?.squad_channel?.on_equip(aq_squad_pager, user, slot)

/obj/item/modular_computer/tablet/dropped(mob/user, silent)
	. = ..()
	aq_squad_pager?.squad_channel?.on_drop(aq_squad_pager, user)

/// Najpierw karta (jak w oryginale), potem pager; długopis wyjmuje wtedy Ctrl-klik albo kolejny Alt-klik
/obj/item/modular_computer/tablet/AltClick(mob/user)
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	if(!aq_squad_pager || card_slot?.stored_card || card_slot2?.stored_card)
		return ..()
	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	aq_eject_squad_pager(user)

/obj/item/modular_computer/tablet/verb/aq_verb_eject_squad_pager()
	set name = "Wyjmij pager"
	set category = "Object"
	set src in usr
	if(issilicon(usr) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(!aq_eject_squad_pager(usr))
		to_chat(usr, "<span class='warning'>W [src] nie ma pagera drużyny.</span>")

/obj/item/modular_computer/tablet/examine(mob/user)
	. = ..()
	if(aq_squad_pager)
		. += "<span class='notice'>W bocznej kieszeni jest [aq_squad_pager]. Alt-klik go wyjmuje.</span>"

// Kanał pagera szuka noszącego bezpośrednio w loc pagera; w PDA trzeba sięgnąć poziom wyżej
/datum/component/simple_teamchat/radio_dependent/squad/get_user()
	var/atom/movable/holder = parent
	if(istype(holder) && istype(holder.loc, /obj/item/modular_computer/tablet))
		return holder.loc.loc
	return ..()
