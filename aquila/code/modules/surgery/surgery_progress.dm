// AQUILA - zaawansowany analizator i monitory funkcji życiowych pokazują operowane strefy: stan chirurgiczny kończyny,
// trwającą operację i operacje możliwe dalej (nowy szkielet z tgstation#93697, aquila/code/modules/surgery_tg/).

/mob/living
	/// Trwające operacje: strefa (check_zone) -> /datum/surgery_operation. Lazy, tylko na czas operacji (try_perform).
	var/list/ongoing_operations

/// Ile operacji "dalej" pokazać przy jednej strefie
#define SURGERY_PROGRESS_MAX_NEXT 6

/// Operowane strefy: przygotowane, otwarte albo z trwającą operacją
/mob/living/proc/get_surgery_progress()
	var/list/progress = list()
	var/list/zones = has_limbs ? GLOB.all_body_zones : list(BODY_ZONE_CHEST)
	for(var/zone in zones)
		var/datum/surgery_operation/ongoing = LAZYACCESS(ongoing_operations, zone)
		if(!ongoing && !is_zone_operated_on(zone))
			continue
		progress += list(list(
			"zone" = strefa_pl(zone),
			"state" = get_surgery_state_as_list(zone),
			"operation" = ongoing ? capitalize(ongoing.name) : null,
			"next" = get_next_operation_names(zone),
		))
	return progress

/// Czy strefa jest przygotowana do operacji albo ma jakiś stan chirurgiczny
/mob/living/proc/is_zone_operated_on(zone)
	if(!has_limbs)
		var/datum/status_effect/basic_surgery_state/state_holder = has_status_effect(/datum/status_effect/basic_surgery_state) || null // u nas FALSE, gdy brak statusu
		return HAS_TRAIT(src, TRAIT_READY_TO_OPERATE) || state_holder?.surgery_state
	var/obj/item/bodypart/part = get_bodypart(zone)
	if(isnull(part))
		return FALSE
	return HAS_TRAIT(part, TRAIT_READY_TO_OPERATE) || part.surgery_state

/**
 * Nazwy operacji, które da się teraz zrobić w tej strefie (bez zablokowanych, bo nie wiadomo, kto operuje).
 * Podpowiadane jako następny krok (OPERATION_PRIORITY_NEXT_STEP) idą pierwsze.
 */
/mob/living/proc/get_next_operation_names(zone)
	var/list/priority = list()
	var/list/other = list()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(GLOB.operations.unlocked))
		if(!operation.show_as_next_step(src, zone))
			continue
		if(operation.operation_flags & OPERATION_PRIORITY_NEXT_STEP)
			priority |= operation.name
		else
			other |= operation.name
	var/list/names = priority + (other - priority)
	if(length(names) > SURGERY_PROGRESS_MAX_NEXT)
		names.Cut(SURGERY_PROGRESS_MAX_NEXT + 1)
		names += "…"
	return names

/// Linie do skanu w czacie (zaawansowany analizator, monitor funkcji życiowych)
/mob/living/proc/get_surgery_scan_lines()
	var/list/lines = list()
	for(var/list/zone_progress as anything in get_surgery_progress())
		var/list/parts = list()
		var/list/state = zone_progress["state"]
		if(length(state))
			parts += lowertext(jointext(state, ", "))
		if(zone_progress["operation"])
			parts += "trwa: <b>[zone_progress["operation"]]</b>"
		var/list/next = zone_progress["next"]
		if(length(next))
			parts += "dalej: [jointext(next, ", ")]"
		lines += "<span class='notice'>Operacja ([zone_progress["zone"]]): [jointext(parts, "; ")].</span>"
	return lines

#undef SURGERY_PROGRESS_MAX_NEXT
