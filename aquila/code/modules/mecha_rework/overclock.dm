// AQUILA - overclock mecha z czasem odnowienia (overclock_mode z tg na tym samym /obj/mecha, bez systemu ciepła).
// Overclock przyspiesza krok i przeładowanie wyposażenia, za każdą sekundę pobiera prąd i działa najwyżej
// AQ_MECHA_OVERCLOCK_DURATION. Po wyłączeniu (ręcznym, samoczynnym albo z braku prądu) da się go włączyć
// dopiero po AQ_MECHA_OVERCLOCK_COOLDOWN.

/obj/mecha
	/// Czy overclock jest włączony
	var/aq_overclock = FALSE
	/// O ile overclock przyspiesza krok (dzielnik step_in, jak overclock_coeff w tg)
	var/aq_overclock_coeff = 1.5
	/// Stały dodatek do opóźnienia kroku (płyta pancerza). Ani to, ani overclock nie zmieniają step_in: rdzeń
	/// (przeciążenie siłowników) i Ripley (update_pressure przy każdym kroku) ustawiają go sami, więc modyfikatory
	/// liczą się względem bieżącego step_in dopiero przy ruchu (aq_step_delay)
	var/aq_step_in_bonus = 0
	/// Kiedy włączony overclock sam się wyłączy
	var/aq_overclock_end = 0
	/// Odnowienie overclocku po wyłączeniu
	COOLDOWN_DECLARE(aq_overclock_cooldown)
	/// Przycisk akcji overclocku
	var/datum/action/innate/mecha/aq_overclock/aq_overclock_action = new

/obj/mecha/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	aq_overclock_action.Grant(user, src)

/obj/mecha/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	aq_overclock_action.Remove(user)

/obj/mecha/Destroy()
	. = ..()
	QDEL_NULL(aq_overclock_action)

/obj/mecha/process(delta_time)
	. = ..()
	if(QDELETED(src))
		return
	aq_process_overclock(delta_time || 2)

/// Prąd za działający overclock; po czasie albo bez prądu overclock gaśnie
/obj/mecha/proc/aq_process_overclock(delta_time)
	if(!aq_overclock)
		return
	if(!has_charge(step_energy_drain * delta_time))
		occupant_message("<span class='warning'>Za mało energii na overclock.</span>")
		aq_set_overclock(FALSE)
		return
	use_power(step_energy_drain * delta_time)
	if(world.time >= aq_overclock_end)
		aq_set_overclock(FALSE)

/// Opóźnienie kroku z płytą pancerza i overclockiem, liczone od bieżącego step_in
/obj/mecha/proc/aq_step_delay()
	. = step_in + aq_step_in_bonus
	if(aq_overclock)
		. = min(., max(1, round(. / aq_overclock_coeff, 0.5)))

/obj/mecha/domove(direction)
	. = ..()
	if(.)
		can_move = world.time + aq_step_delay()

/obj/mecha/proc/aq_set_overclock(state)
	if(state == aq_overclock)
		return
	if(state && !COOLDOWN_FINISHED(src, aq_overclock_cooldown))
		occupant_message("<span class='warning'>Overclock się odnawia, będzie gotowy za [DisplayTimeText(COOLDOWN_TIMELEFT(src, aq_overclock_cooldown))].</span>")
		return
	aq_overclock = state
	if(state)
		aq_overclock_end = world.time + AQ_MECHA_OVERCLOCK_DURATION
		occupant_message("<span class='danger'>Overclock włączony na [DisplayTimeText(AQ_MECHA_OVERCLOCK_DURATION)]: szybszy krok i przeładowanie.</span>")
	else
		COOLDOWN_START(src, aq_overclock_cooldown, AQ_MECHA_OVERCLOCK_COOLDOWN)
		occupant_message("<span class='notice'>Overclock wyłączony, odnowienie: [DisplayTimeText(AQ_MECHA_OVERCLOCK_COOLDOWN)].</span>")
	aq_overclock_action.button_icon_state = "mech_overload_[state ? "on" : "off"]"
	aq_overclock_action.UpdateButtonIcon()
	log_message("Toggled overclock: [state].", LOG_MECHA)

/// Po każdym użyciu modułu (maskowanie zdejmuje się przy strzale, equipment/utility.dm)
/obj/item/mecha_parts/mecha_equipment/proc/aq_on_used()
	return

/obj/item/mecha_parts/mecha_equipment/start_cooldown()
	. = ..()
	aq_on_used()

// rdzeniowe start_cooldown() broni energetycznej nie woła ..()
/obj/item/mecha_parts/mecha_equipment/weapon/energy/start_cooldown()
	. = ..()
	aq_on_used()

/obj/item/mecha_parts/mecha_equipment/set_ready_state(state)
	if(!state && chassis?.aq_overclock && equip_cooldown)
		// gotowość wraca szybciej: osobny krótszy timer, właściwy po starcie i tak zastanie gotowy moduł
		addtimer(CALLBACK(src, PROC_REF(aq_overclock_ready)), max(1, equip_cooldown / chassis.aq_overclock_coeff))
	return ..()

/obj/item/mecha_parts/mecha_equipment/proc/aq_overclock_ready()
	if(chassis?.aq_overclock && !equip_ready)
		set_ready_state(TRUE)

/datum/action/innate/mecha/aq_overclock
	name = "Overclock"
	desc = "Na chwilę przyspiesza mecha kosztem energii, potem trzeba odczekać."
	button_icon_state = "mech_overload_off"

/datum/action/innate/mecha/aq_overclock/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.aq_set_overclock(!chassis.aq_overclock)
