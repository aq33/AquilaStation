// AQUILA - drugie miejsce w mechu (Savannah-Ivanov z tg, Red Sunday). Na naszym /obj/mecha jest jeden occupant,
// więc drugi człowiek siedzi jako aq_copilot. Pierwszy, który wsiadł, jest strzelcem (occupant: wyposażenie, okno,
// akcje), drugi prowadzi (ruch i akcja skoku). Sam pilot robi oba, jak w tg przy jednym załogancie.

/obj/mecha
	/// Ile osób mieści kabina (2 = drugie miejsce dla kierowcy)
	var/aq_max_occupants = 1
	/// Drugi załogant (kierowca)
	var/mob/living/carbon/aq_copilot
	/// Akcje drugiego załoganta
	var/datum/action/innate/mecha/aq_copilot_eject/aq_copilot_eject_action

/obj/mecha/proc/aq_has_copilot_seat()
	return aq_max_occupants >= 2

/obj/mecha/MouseDrop_T(mob/M, mob/user)
	if(occupant && aq_has_copilot_seat() && !aq_copilot && user == M && ishuman(user) && Adjacent(user) && !user.incapacitated())
		aq_try_enter_copilot(user)
		return
	return ..()

/// Blokada DNA i kody operacyjne jak przy zwykłym wejściu (mecha.dm, MouseDrop_T): drugie miejsce, awans kierowcy, zdalne sterowanie
/obj/mecha/proc/aq_entry_allowed(mob/living/user)
	if(dna_lock)
		var/mob/living/carbon/C = user
		if(!istype(C) || !C.has_dna() || C.dna.unique_enzymes != dna_lock)
			to_chat(user, "<span class='warning'>Odmowa dostępu. [name] jest zabezpieczony blokadą DNA.</span>")
			log_message("Permission denied (DNA LOCK).", LOG_MECHA)
			return FALSE
	if(!operation_allowed(user))
		to_chat(user, "<span class='warning'>Odmowa dostępu. Niewystarczające kody operacyjne.</span>")
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return FALSE
	return TRUE

/// Kierowca może prowadzić i przejąć fotel pilota tylko przytomny i z graczem
/obj/mecha/proc/aq_copilot_capable()
	return aq_copilot && aq_copilot.loc == src && aq_copilot.stat == CONSCIOUS && GET_CLIENT(aq_copilot)

/// Kto prowadzi mecha: kierowca, jeśli może, inaczej pilot
/obj/mecha/proc/aq_driver()
	return aq_copilot_capable() ? aq_copilot : occupant

/// Alt przy strafe (obrót w miejscu) czytany z klawiatury tego, kto prowadzi (hook AQ EDIT w domove)
/obj/mecha/proc/aq_strafe_turn_held()
	var/mob/driver = aq_driver()
	if(!driver?.client)
		return FALSE
	return driver.client.keys_held["Alt"]

/obj/mecha/proc/aq_try_enter_copilot(mob/living/carbon/human/user)
	if(!aq_entry_allowed(user))
		return FALSE
	if(user.buckled || user.has_buckled_mobs())
		to_chat(user, "<span class='warning'>Nie możesz wejść do egzoszkieletu, będąc przypiętym.</span>")
		return FALSE
	visible_message("[user] zaczyna wchodzić na drugie miejsce [name].")
	if(!do_after(user, enter_delay, target = src))
		to_chat(user, "<span class='warning'>Przestajesz wchodzić do egzoszkieletu!</span>")
		return FALSE
	if(aq_copilot || obj_integrity <= 0 || !occupant)
		to_chat(user, "<span class='warning'>Nie możesz teraz zająć drugiego miejsca.</span>")
		return FALSE
	aq_copilot = user
	user.forceMove(src)
	if(!aq_copilot_eject_action)
		aq_copilot_eject_action = new
	aq_copilot_eject_action.Grant(user, src)
	aq_grant_copilot_actions(user)
	to_chat(user, "<span class='notice'>Siadasz za sterami jazdy. [occupant] obsługuje uzbrojenie.</span>")
	occupant_message("<span class='notice'>[user] zajmuje miejsce kierowcy. Ty obsługujesz uzbrojenie.</span>")
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	log_message("[user] moved in as copilot (driver).", LOG_MECHA)
	update_icon()
	return TRUE

/// Akcje kierowcy na danym podwoziu (Savannah: skok)
/obj/mecha/proc/aq_grant_copilot_actions(mob/living/user)
	return

/obj/mecha/proc/aq_remove_copilot_actions(mob/living/user)
	return

/obj/mecha/proc/aq_copilot_out(atom/newloc = drop_location())
	if(!aq_copilot)
		return
	var/mob/living/L = aq_copilot
	aq_copilot = null
	aq_copilot_eject_action?.Remove(L)
	aq_remove_copilot_actions(L)
	if(L.loc == src)
		L.forceMove(newloc)
	log_message("[L] moved out (copilot).", LOG_MECHA)
	update_icon()

/obj/mecha/Exited(atom/movable/M, atom/newloc)
	. = ..()
	if(M == aq_copilot)
		aq_copilot_out(newloc)

/obj/mecha/container_resist(mob/living/user)
	if(user == aq_copilot)
		to_chat(user, "<span class='notice'>Zaczynasz wychodzić z miejsca kierowcy.</span>")
		if(do_after(user, exit_delay, target = src))
			aq_copilot_out()
		return
	return ..()

/obj/mecha/go_out(forced, atom/newloc = loc)
	. = ..()
	aq_promote_copilot()

/// Strzelec wysiadł: kierowca przesiada się na fotel pilota (dostaje okno i wyposażenie). Nieprzytomny, martwy albo bez
/// gracza zostaje na miejscu kierowcy i przesiada się, gdy sam spróbuje ruszyć mechem.
/obj/mecha/proc/aq_promote_copilot()
	if(occupant || !aq_copilot || QDELETED(src))
		return FALSE
	var/mob/living/carbon/human/driver = aq_copilot
	if(!ishuman(driver) || !aq_copilot_capable() || !aq_entry_allowed(driver))
		return FALSE
	aq_copilot = null
	aq_copilot_eject_action?.Remove(driver)
	aq_remove_copilot_actions(driver)
	occupant = driver
	GrantActions(driver, human_occupant = 1)
	icon_state = initial(icon_state)
	update_icon()
	occupant_message("<span class='notice'>Przejmujesz pełne sterowanie.</span>")
	log_message("[driver] moved over from the copilot seat.", LOG_MECHA)
	return TRUE

/obj/mecha/Destroy()
	if(aq_copilot)
		aq_copilot.SetSleeping(destruction_sleep_duration)
		aq_copilot_out()
	. = ..()
	QDEL_NULL(aq_copilot_eject_action)

/obj/mecha/relaymove(mob/user, direction)
	if(aq_copilot && user == aq_copilot)
		if(!occupant && aq_promote_copilot())
			return ..()
		if(completely_disabled || !direction || construction_state || internal_tank?.connected_port)
			return FALSE
		return domove(direction)
	if(aq_copilot && user == occupant && aq_copilot_capable())
		if(world.time - last_message > 20)
			occupant_message("<span class='notice'>Mechem kieruje [aq_copilot]. Ty obsługujesz uzbrojenie.</span>")
			last_message = world.time
		return FALSE
	return ..()

/datum/action/innate/mecha/aq_copilot_eject
	name = "Wyjdź z miejsca kierowcy"
	button_icon_state = "mech_eject"

/datum/action/innate/mecha/aq_copilot_eject/Activate()
	if(!owner || !chassis || chassis.aq_copilot != owner)
		return
	chassis.container_resist(owner)
