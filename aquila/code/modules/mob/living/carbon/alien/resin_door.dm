// AQUILA: drzwi z żywicy z ParadiseSS13 (code/game/objects/structures/aliens.dm /obj/structure/alien/resin/door,
// code/datums/spells/alien_spells/build_resin_structure.dm; AGPL-3.0). Grafika aquila/icons/obj/smooth_structures/alien/resin_door.dmi
// i dźwięk aquila/sound/machines/alien_airlock.ogg z Paradise (CC-BY-SA 3.0).
// Różnice: u nas budowa idzie przez istniejącą moc „Wydziel żywicę” (lista wyboru, bez menu kołowego i bez 3 s formowania),
// a zburzenie drzwi przez obcego w trybie walki to zwykły atak obcego (60 obrażeń przy 60 wytrzymałości, czyli jak w Paradise jedno uderzenie).

/// Drzwi z żywicy: otwierają się przed każdym z węzłem ula (obcy), załoga musi je wyłamać
/obj/structure/alien/resin/door
	name = "drzwi z żywicy"
	desc = "Gęsta żywica uformowana w przejście. Rozsuwa się tylko przed tymi, którzy słyszą ul."
	icon = 'aquila/icons/obj/smooth_structures/alien/resin_door.dmi'
	icon_state = "resin"
	smooth = NONE
	canSmoothWith = null
	max_integrity = 60
	resintype = "door"
	/// Czy drzwi są teraz otwarte
	var/state_open = FALSE
	/// Czy trwa animacja otwierania albo zamykania
	var/is_operating = FALSE
	/// Po jakim czasie drzwi otwarte przez wejście w nie same się zamykają
	var/close_delay = 3 SECONDS

/obj/structure/alien/resin/door/Destroy()
	density = FALSE
	air_update_turf()
	return ..()

/obj/structure/alien/resin/door/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	try_to_operate(user)
	return TRUE

/obj/structure/alien/resin/door/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.combat_mode)
		return ..()
	try_to_operate(user)

/obj/structure/alien/resin/door/Bumped(atom/movable/AM)
	. = ..()
	if(!state_open && ismob(AM))
		try_to_operate(AM, TRUE)

/// Czy ten mob otwiera drzwi z żywicy: każdy węglowy z węzłem ula, bez kajdanek
/obj/structure/alien/resin/door/proc/can_operate(mob/user)
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/carbon_user = user
	if(!carbon_user.getorgan(/obj/item/organ/alien/hivenode))
		return FALSE
	return !carbon_user.handcuffed

/obj/structure/alien/resin/door/proc/try_to_operate(mob/user, bumped_open = FALSE)
	if(is_operating)
		return FALSE
	if(!can_operate(user))
		if(iscarbon(user) && !bumped_open)
			to_chat(user, span_warning("Żywica ani drgnie. Bez więzi z ulem te drzwi się nie otworzą."))
		return FALSE
	operate(bumped_open)
	return TRUE

/// Zamyka drzwi bez moba, gdy minie czas po wejściu w nie (w przejściu ktoś stoi: próbuje później)
/obj/structure/alien/resin/door/proc/mobless_try_to_operate()
	if(QDELETED(src) || !state_open)
		return
	if(is_operating)
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
		return
	operate()

/obj/structure/alien/resin/door/proc/operate(bumped_open = FALSE)
	if(state_open && (locate(/mob/living) in get_turf(src)))
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)
		return
	is_operating = TRUE
	playsound(loc, 'aquila/sound/machines/alien_airlock.ogg', 50, TRUE)
	flick(state_open ? "resinclosing" : "resinopening", src)
	state_open = !state_open
	density = !state_open
	set_opacity(!state_open)
	air_update_turf()
	addtimer(CALLBACK(src, PROC_REF(operate_update), bumped_open), 1 SECONDS)

/obj/structure/alien/resin/door/proc/operate_update(bumped_open)
	is_operating = FALSE
	update_icon()
	if(state_open && bumped_open)
		addtimer(CALLBACK(src, PROC_REF(mobless_try_to_operate)), close_delay)

/obj/structure/alien/resin/door/update_icon_state()
	icon_state = state_open ? "resinopen" : "resin"
	return ..()

/// Moc „Wydziel żywicę” dostaje drzwi obok ściany, błony i gniazda
/obj/effect/proc_holder/alien/resin/Initialize(mapload)
	. = ..()
	structures["drzwi z żywicy"] = /obj/structure/alien/resin/door
