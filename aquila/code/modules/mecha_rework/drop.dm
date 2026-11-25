// AQUILA - zrzut mecha z orbity (Drop System z Tau Ceti Classic, latarnia zrzutu). Pasuje do planet z AQ#639:
// drużyna desantowa rozkłada latarnię na planecie (albo gdziekolwiek), pilot w mechu z systemem zrzutu wybiera ją
// z listy, mech odpala silniki, znika w górze i po chwili spada przy latarni, przewracając i raniąc stojących obok.

GLOBAL_LIST_EMPTY(aq_mech_drop_beacons)

/obj/item/aq_mech_drop_beacon
	name = "latarnia zrzutu egzoszkieletów"
	desc = "Nadajnik naprowadzający dla mechów z systemem zrzutu orbitalnego. Użyj w ręce, żeby go włączyć i postawić na ziemi, a potem odsuń się od miejsca lądowania."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon-off"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/beacon_name

/obj/item/aq_mech_drop_beacon/Initialize(mapload)
	. = ..()
	beacon_name = "Latarnia [rand(100, 999)]"
	GLOB.aq_mech_drop_beacons += src

/obj/item/aq_mech_drop_beacon/Destroy()
	GLOB.aq_mech_drop_beacons -= src
	return ..()

/obj/item/aq_mech_drop_beacon/attack_self(mob/user)
	active = !active
	if(active)
		user.dropItemToGround(src)
		anchored = TRUE
		icon_state = "beacon"
		to_chat(user, "<span class='notice'>Włączasz [src] ([beacon_name]) i stawiasz ją na ziemi. Odsuń się od miejsca lądowania.</span>")
	else
		anchored = FALSE
		icon_state = "beacon-off"
		to_chat(user, "<span class='notice'>Wyłączasz [src].</span>")

/obj/item/aq_mech_drop_beacon/attack_hand(mob/user)
	if(active)
		active = FALSE
		anchored = FALSE
		icon_state = "beacon-off"
		to_chat(user, "<span class='notice'>Wyłączasz [src].</span>")
	return ..()

/obj/item/aq_mech_drop_beacon/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[beacon_name]: [active ? "nadaje" : "wyłączona"].</span>"

/obj/item/mecha_parts/mecha_equipment/aq_drop_system
	name = "system zrzutu orbitalnego egzoszkieletu"
	desc = "Silniki startowe, osłona termiczna i amortyzatory: mech startuje z pokładu i ląduje przy wybranej latarni zrzutu. Po zrzucie system musi się schłodzić."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_drop_system"
	aq_slot = AQ_MECHA_UTILITY
	selectable = FALSE
	energy_drain = 2000
	/// Czas do następnego zrzutu
	var/cooldown_time = 5 MINUTES
	COOLDOWN_DECLARE(drop_cooldown)
	var/datum/action/innate/mecha/aq_orbital_drop/drop_action
	/// Mech jest w locie (niewidzialny, wyłączony, bez gęstości): odłączenie albo zniszczenie modułu musi go przywrócić
	var/in_flight = FALSE

/obj/item/mecha_parts/mecha_equipment/aq_drop_system/attach(obj/mecha/M)
	. = ..()
	drop_action = new
	if(M.occupant)
		drop_action.Grant(M.occupant, M)

/obj/item/mecha_parts/mecha_equipment/aq_drop_system/detach(atom/moveto)
	aq_abort_flight()
	if(drop_action)
		if(drop_action.owner)
			drop_action.Remove(drop_action.owner)
		QDEL_NULL(drop_action)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_drop_system/Destroy()
	aq_abort_flight()
	QDEL_NULL(drop_action)
	return ..()

/// Przerwany lot (moduł odłączony albo zniszczony): mech wraca do normalnego stanu tam, gdzie jest
/obj/item/mecha_parts/mecha_equipment/aq_drop_system/proc/aq_abort_flight()
	if(!in_flight)
		return
	in_flight = FALSE
	if(!chassis)
		return
	aq_restore_chassis(chassis)
	chassis.log_message("Orbital drop aborted, drop system lost.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/aq_drop_system/proc/aq_restore_chassis(obj/mecha/M)
	animate(M)
	M.pixel_z = initial(M.pixel_z)
	M.alpha = initial(M.alpha)
	M.density = TRUE
	M.completely_disabled = FALSE

/obj/mecha/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	for(var/obj/item/mecha_parts/mecha_equipment/aq_drop_system/drop in equipment)
		drop.drop_action?.Grant(user, src)

/obj/mecha/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	for(var/obj/item/mecha_parts/mecha_equipment/aq_drop_system/drop in equipment)
		drop.drop_action?.Remove(user)

/obj/item/mecha_parts/mecha_equipment/aq_drop_system/proc/start_drop(mob/user)
	if(!chassis || chassis.occupant != user)
		return
	if(!COOLDOWN_FINISHED(src, drop_cooldown))
		chassis.balloon_alert(user, "system zrzutu stygnie ([DisplayTimeText(COOLDOWN_TIMELEFT(src, drop_cooldown))])")
		return
	var/list/targets = list()
	for(var/obj/item/aq_mech_drop_beacon/B as anything in GLOB.aq_mech_drop_beacons)
		if(B.active && isturf(B.loc))
			targets["[B.beacon_name] ([get_area_name(B, TRUE)])"] = B
	if(!length(targets))
		to_chat(user, "<span class='warning'>Nie wykryto żadnej aktywnej latarni zrzutu.</span>")
		return
	var/choice = input(user, "Gdzie zrzucić mecha?", "Zrzut orbitalny") as null|anything in targets
	if(!choice || !chassis || chassis.occupant != user)
		return
	// input() czeka na gracza: drugie kliknięcie mogło już wystartować zrzut
	if(in_flight || chassis.completely_disabled || !COOLDOWN_FINISHED(src, drop_cooldown))
		return
	var/obj/item/aq_mech_drop_beacon/beacon = targets[choice]
	if(QDELETED(beacon) || !beacon.active)
		return
	if(!chassis.has_charge(energy_drain))
		to_chat(user, "<span class='warning'>Za mało energii na start.</span>")
		return
	chassis.use_power(energy_drain)
	COOLDOWN_START(src, drop_cooldown, cooldown_time)
	chassis.visible_message("<span class='danger'>[chassis] odpala silniki startowe!</span>")
	playsound(chassis, 'sound/effects/podwoosh.ogg', 70, TRUE)
	in_flight = TRUE
	chassis.completely_disabled = TRUE
	chassis.density = FALSE
	animate(chassis, pixel_z = 300, alpha = 0, time = 2 SECONDS, easing = QUAD_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(land), get_turf(beacon)), 6 SECONDS)

/obj/item/mecha_parts/mecha_equipment/aq_drop_system/proc/land(turf/target)
	if(!chassis || !in_flight)
		return
	var/obj/mecha/M = chassis
	if(!target)
		target = get_turf(M)
	new /obj/effect/temp_visual/aq_drop_target(target)
	M.forceMove(target)
	M.pixel_z = 300
	animate(M, pixel_z = 0, alpha = 255, time = 1.5 SECONDS, easing = QUAD_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(impact), target), 1.5 SECONDS)

/obj/item/mecha_parts/mecha_equipment/aq_drop_system/proc/impact(turf/target)
	if(!chassis || !in_flight)
		return
	var/obj/mecha/M = chassis
	in_flight = FALSE
	M.density = TRUE
	M.completely_disabled = FALSE
	playsound(target, 'sound/effects/meteorimpact.ogg', 80, TRUE)
	for(var/mob/living/L in range(1, target))
		if(L == M.occupant || L == M.aq_copilot)
			continue
		L.Knockdown(4 SECONDS)
		L.adjustBruteLoss(get_turf(L) == target ? 60 : 15)
		to_chat(L, "<span class='userdanger'>Spada na ciebie [M]!</span>")
	for(var/obj/structure/S in target)
		if(S.density)
			S.take_damage(200, BRUTE, "melee", FALSE)
	new /obj/effect/temp_visual/explosion/fast(target)
	M.log_message("Orbital drop landed at [AREACOORD(target)].", LOG_MECHA)

/obj/effect/temp_visual/aq_drop_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	duration = 1.5 SECONDS

/datum/action/innate/mecha/aq_orbital_drop
	name = "Zrzut orbitalny"
	desc = "Wybierz latarnię zrzutu i wyślij mecha na miejsce."
	button_icon_state = "mech_eject"

/datum/action/innate/mecha/aq_orbital_drop/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/item/mecha_parts/mecha_equipment/aq_drop_system/drop = locate() in chassis.equipment
	drop?.start_drop(owner)
