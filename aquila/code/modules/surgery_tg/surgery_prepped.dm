// AQUILA - przygotowanie do operacji z tg (code/datums/elements/surgery_aid.dm, tgstation#93697).
// W tg TRAIT_READY_TO_OPERATE dają tylko "pomoce chirurgiczne" (serwety, prześcieradło) nałożone na strefę ciała.
// Stół operacyjny, łóżko stazy czy zwykłe łóżko nie dają gotowości, tylko zmieniają szybkość (get_location_modifier),
// a leżenie sprawdza każda operacja osobno. U nas element łapie COMSIG_ITEM_ATTACK (tg: COMSIG_ITEM_INTERACTING_WITH_ATOM),
// bez podpowiedzi kontekstowych (nie mamy screentipów kontekstowych).

/// Przedmiot nakładany na pacjenta przygotowuje strefę ciała do operacji (albo zdejmuje przygotowanie)
/datum/element/surgery_aid
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Nazwa pomocy do opisu i komunikatów ("serwety", "prześcieradło")
	var/aid_name

/datum/element/surgery_aid/Attach(datum/target, aid_name = "serwety")
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.aid_name = aid_name
	ADD_TRAIT(target, TRAIT_SURGERY_AID, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))

/datum/element/surgery_aid/Detach(datum/target)
	. = ..()
	REMOVE_TRAIT(target, TRAIT_SURGERY_AID, ELEMENT_TRAIT(type))
	UnregisterSignal(target, COMSIG_ITEM_ATTACK)

/datum/element/surgery_aid/proc/on_item_attack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	if(!isliving(target) || !isliving(user))
		return NONE
	target.toggle_surgery_prep(user, user.zone_selected, aid_name)
	return COMPONENT_ITEM_NO_ATTACK

/// Które strefy ciała są przygotowane do operacji. Daje TRAIT_READY_TO_OPERATE mobowi i kończynom tych stref.
/datum/status_effect/surgery_prepped
	id = SURGERY_PREPPED_ID
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 2 SECONDS

	/// Lazy lista przygotowanych stref. Pusta = status znika.
	var/list/zones
	/// Lazy lista nazw użytych pomocy (serwety, prześcieradło), do opisu
	var/list/surgical_aids
	/// Kroki zrobione na stojąco. Po 4 serwety spadają.
	var/movement_counter = 0

/datum/status_effect/surgery_prepped/on_creation(mob/living/new_owner, target_zone, aid_name = "serwety")
	. = ..()
	if(QDELETED(src) || isnull(owner))
		return
	track_surgery(target_zone)
	LAZYOR(surgical_aids, aid_name)
	ADD_TRAIT(owner, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id)) // po track_surgery

/datum/status_effect/surgery_prepped/refresh(mob/living/new_owner, target_zone, aid_name = "serwety")
	track_surgery(target_zone)
	LAZYOR(surgical_aids, aid_name)

/datum/status_effect/surgery_prepped/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	return TRUE

/datum/status_effect/surgery_prepped/on_remove()
	for(var/zone in zones)
		untrack_surgery(zone)
	REMOVE_TRAIT(owner, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/status_effect/surgery_prepped/get_examine_text(mob/examiner)
	var/list/zones_readable = list()
	for(var/zone in GLOB.all_body_zones & zones)
		zones_readable += strefa_pl(zone)

	// "Ma serwety i prześcieradło na: klatka piersiowa, lewa ręka."
	return "Ma [english_list(surgical_aids)] na: [english_list(zones_readable)]."

/// Na stojąco chodzi się z serwetami tylko chwilę
/datum/status_effect/surgery_prepped/proc/on_move(datum/source, ...)
	SIGNAL_HANDLER

	if(is_standing())
		movement_counter += 1
	if(movement_counter < 4)
		return
	owner.visible_message(span_warning("[capitalize(english_list(surgical_aids))] spada z [owner]!"))
	qdel(src)

/datum/status_effect/surgery_prepped/tick(seconds_between_ticks)
	if(!is_standing() && movement_counter > 0)
		movement_counter -= 1

/// tg: body_position == STANDING_UP. Moby bez kończyn nie umieją się położyć, więc u nas się nie liczą jako stojące.
/datum/status_effect/surgery_prepped/proc/is_standing()
	return !IS_LYING_OR_CANNOT_LIE(owner)

/datum/status_effect/surgery_prepped/proc/track_surgery(body_zone)
	LAZYOR(zones, body_zone)
	if(iscarbon(owner))
		var/obj/item/bodypart/precise_part = owner.get_bodypart(body_zone)
		if(precise_part)
			ADD_TRAIT(precise_part, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))
	else if(body_zone != BODY_ZONE_CHEST)
		stack_trace("Attempting to track surgery on a non-carbon mob with a non-chest body zone! This should not happen.")

/datum/status_effect/surgery_prepped/proc/untrack_surgery(body_zone)
	LAZYREMOVE(zones, body_zone)
	if(iscarbon(owner))
		var/obj/item/bodypart/precise_part = owner.get_bodypart(body_zone)
		if(precise_part)
			REMOVE_TRAIT(precise_part, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))
	if(!LAZYLEN(zones) && !QDELETED(src))
		qdel(src) // nic już nie jest przygotowane

/// Strefy ciała w stałej kolejności (tg: GLOB.all_body_zones)
GLOBAL_LIST_INIT(all_body_zones, list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))

/**
 * Przygotowuje strefę ciała do operacji albo zdejmuje przygotowanie (tg: /datum/element/surgery_aid/proc/surgery_prep)
 *
 * * surgeon - kto nakłada
 * * body_zone - strefa (precyzyjne strefy jak oczy idą do głowy)
 * * aid_name - nazwa pomocy w mianowniku liczby mnogiej albo pojedynczej, do opisu ("serwety", "prześcieradło")
 *
 * Zwraca TRUE, jeśli strefa jest teraz przygotowana
 */
/mob/living/proc/toggle_surgery_prep(mob/living/surgeon, body_zone, aid_name = "serwety")
	body_zone = has_limbs ? check_zone(body_zone) : BODY_ZONE_CHEST
	if(has_limbs && !get_bodypart(body_zone))
		body_zone = BODY_ZONE_CHEST
	var/datum/status_effect/surgery_prepped/prep = has_status_effect(/datum/status_effect/surgery_prepped) || null // u nas FALSE, gdy brak statusu
	if(isnull(prep) || !(body_zone in prep.zones))
		apply_status_effect(/datum/status_effect/surgery_prepped, body_zone, aid_name)
		balloon_alert(surgeon, "przygotowano: [strefa_pl(body_zone)]")
		return TRUE
	prep.untrack_surgery(body_zone)
	balloon_alert(surgeon, "zdjęto przygotowanie")
	return FALSE

/// Czy strefa jest przygotowana do operacji
/mob/living/proc/is_zone_prepped_for_surgery(body_zone)
	if(!HAS_TRAIT(src, TRAIT_READY_TO_OPERATE))
		return FALSE
	if(!has_limbs)
		return TRUE
	var/obj/item/bodypart/part = get_bodypart(check_zone(body_zone))
	return part && HAS_TRAIT(part, TRAIT_READY_TO_OPERATE)
