// Licznik Geigera z BeeStation/BeeStation-Hornet#13442 (port tg): cztery stopnie zagrożenia zamiast liczby radów.
// Zastępuje stary code/game/objects/items/devices/geiger_counter.dm (bez trybu emag, jak w Bee).
/obj/item/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "\improper licznik Geigera"
	desc = "Ręczne urządzenie do wykrywania i mierzenia impulsów promieniowania."
	icon = 'aquila/icons/obj/device.dmi'
	icon_state = "geiger_off"
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron = 150, /datum/material/glass = 150)

	var/last_perceived_radiation_danger = null
	var/scanning = FALSE

/obj/item/geiger_counter/Initialize(mapload)
	. = ..()
	// Licznik zawsze słucha impulsów, więc SSradiation liczy dla niego linię także przy słabych impulsach
	ADD_TRAIT(src, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))

/obj/item/geiger_counter/examine(mob/user)
	. = ..()
	if(!scanning)
		return
	. += span_info("Alt-kliknij, by wyczyścić zapisane poziomy promieniowania.")
	switch(last_perceived_radiation_danger)
		if(null)
			. += span_notice("Poziom promieniowania tła w normie.")
		if(PERCEIVED_RADIATION_DANGER_LOW)
			. += span_alert("Poziom promieniowania tła lekko powyżej średniej.")
		if(PERCEIVED_RADIATION_DANGER_MEDIUM)
			. += span_warning("Poziom promieniowania tła powyżej średniej.")
		if(PERCEIVED_RADIATION_DANGER_HIGH)
			. += span_danger("Poziom promieniowania tła znacznie powyżej średniej.")
		if(PERCEIVED_RADIATION_DANGER_EXTREME)
			. += span_suicide("Poziom promieniowania tła osiąga poziom krytyczny!")

/obj/item/geiger_counter/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return ..()

	switch(last_perceived_radiation_danger)
		if(null)
			icon_state = "geiger_on_1"
		if(PERCEIVED_RADIATION_DANGER_LOW)
			icon_state = "geiger_on_2"
		if(PERCEIVED_RADIATION_DANGER_MEDIUM)
			icon_state = "geiger_on_3"
		if(PERCEIVED_RADIATION_DANGER_HIGH)
			icon_state = "geiger_on_4"
		if(PERCEIVED_RADIATION_DANGER_EXTREME)
			icon_state = "geiger_on_5"
	return ..()

/obj/item/geiger_counter/attack_self(mob/user)
	scanning = !scanning

	if(scanning)
		AddComponent(/datum/component/geiger_sound)
	else
		qdel(GetComponent(/datum/component/geiger_sound))

	update_icon()
	to_chat(user, span_notice("[icon2html(src, user)] [scanning ? "Włączasz" : "Wyłączasz"] [src]."))

/obj/item/geiger_counter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(user.combat_mode)
		return

	if(!CAN_IRRADIATE(target))
		return

	user.visible_message(span_notice("[user] skanuje [target] za pomocą [src]."), span_notice("Skanujesz poziom promieniowania [target] za pomocą [src]..."))
	addtimer(CALLBACK(src, PROC_REF(scan), target, user), 2 SECONDS, TIMER_UNIQUE) // Bez spamowania
	return TRUE

/obj/item/geiger_counter/equipped(mob/user, slot, initial)
	. = ..()
	RegisterSignal(user, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation), override = TRUE)

/obj/item/geiger_counter/dropped(mob/user, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_IN_RANGE_OF_IRRADIATION)

/obj/item/geiger_counter/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	last_perceived_radiation_danger = get_perceived_radiation_danger(pulse_information, insulation_to_target)
	addtimer(CALLBACK(src, PROC_REF(reset_perceived_danger)), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)

	if(scanning)
		update_icon()

/obj/item/geiger_counter/proc/reset_perceived_danger()
	last_perceived_radiation_danger = null
	if(scanning)
		update_icon()

/obj/item/geiger_counter/proc/scan(atom/target, mob/user)
	if(QDELETED(target) || QDELETED(user))
		return
	if(SEND_SIGNAL(target, COMSIG_GEIGER_COUNTER_SCAN, user, src) & COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL)
		return

	to_chat(user, span_notice("[icon2html(src, user)] [isliving(target) ? "Obiekt" : "Przedmiot"] jest wolny od skażenia radioaktywnego."))

/obj/item/geiger_counter/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return ..()
	if(!scanning)
		to_chat(user, span_warning("[src] musi być włączony, by zresetować poziom promieniowania!"))
		return
	to_chat(user, span_notice("Czyścisz liczniki promieniowania [src], przywracając normę."))
	last_perceived_radiation_danger = null
	update_icon()
