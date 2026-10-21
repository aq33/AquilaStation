// AQUILA - zgodność rdzenia heretyka (antagonista, wiedza, runa, wpływy, żywe serce) z naszym kodem.
// Rzeczy z tg, których u nas nie było, w wersji na naszym API. Nazwy procedur i typów jak w tg.

// ---------------------------------------------------------------------------
// Typy abstrakcyjne
// U nas /datum nie ma zmiennej abstract_type (mają ją tylko niektóre typy), więc
// valid_subtypesof() (aquila/code/modules/antagonists/vampire/_compat.dm) pomija je przez is_heretic_abstract_type().


/// Czy typ to abstrakcyjny typ heretyka (abstract_type == sam typ)
/proc/is_heretic_abstract_type(path)
	if(ispath(path, /datum/heretic_knowledge))
		var/datum/heretic_knowledge/knowledge = path
		return initial(knowledge.abstract_type) == path
	if(ispath(path, /datum/heretic_knowledge_tree_column))
		var/datum/heretic_knowledge_tree_column/column = path
		return initial(column.abstract_type) == path
	return FALSE

// ---------------------------------------------------------------------------
// Listy i teksty

/// tg: czy ścieżka jest podtypem któregoś z typów z listy
/proc/is_path_in_list(path_to_check, list/list_to_check, zebra = FALSE)
	if(!LAZYLEN(list_to_check) || !path_to_check)
		return FALSE
	for(var/path in list_to_check)
		if(ispath(path_to_check, path))
			return !zebra || list_to_check[path]
	return FALSE

/// tg: wartości listy asocjacyjnej
/proc/assoc_to_values(list/key_list)
	if(!islist(key_list))
		return null
	. = list()
	for(var/key in key_list)
		. |= LIST_VALUE_WRAP_LISTS(key_list[key])

/// tg: głęboka kopia listy (także list w wartościach)
/proc/deep_copy_list_alt(list/inserted_list)
	if(!islist(inserted_list))
		return inserted_list
	var/copied_list = inserted_list.Copy()
	. = copied_list
	for(var/key_or_value in inserted_list)
		if(isnum(key_or_value) || !inserted_list[key_or_value])
			continue
		var/value = inserted_list[key_or_value]
		var/new_value = value
		if(islist(value))
			new_value = deep_copy_list_alt(value)
		copied_list[key_or_value] = new_value

/// tg: losowe bezpieczne pole na stacji (u nas bez wag działów)
/proc/get_safe_random_station_turf_equal_weight()
	return get_safe_random_station_turfs()

// ---------------------------------------------------------------------------
// Konfiguracja

/// tg: ile minut rundy musi minąć, zanim heretyk może dostąpić wniebowstąpienia
/datum/config_entry/number/minimum_ascension_time
	default = 0
	min_val = 0

// ---------------------------------------------------------------------------
// Runa transmutacji w kolorze ścieżki (GAGS)

/datum/greyscale_config/heretic_rune
	name = "Transmutation Rune"
	icon_file = 'aquila/icons/effects/heretic_96x96.dmi'
	json_config = 'aquila/code/modules/antagonists/heretic/_compat/heretic_rune.json'

// ---------------------------------------------------------------------------
// Obrazy widoczne tylko dla heretyków i ich potworów (tg: basic/heretic i has_antagonist/heretic)

/datum/atom_hud/alternate_appearance/basic/heretic

/datum/atom_hud/alternate_appearance/basic/heretic/New()
	..()
	for(var/mob in GLOB.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/heretic/mobShouldSee(mob/M)
	return IS_HERETIC_OR_MONSTER(M)

/// Wpływy: duchy widzą półprzezroczystą wersję
/datum/atom_hud/alternate_appearance/basic/heretic/influence
	add_ghost_version = TRUE

/// tg: TRAIT_SEE_BLESSED_TILES na umyśle pozwala widzieć poświęcone podłogi
/datum/atom_hud/alternate_appearance/basic/blessedAware/mobShouldSee(mob/M)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_SEE_BLESSED_TILES))
		return TRUE
	return ..()

/**
 * Dodaje albo zabiera mobowi obrazy heretyków (wpływy, statusy, poświęcone podłogi).
 * U nas obrazy dla grup mobów dochodzą tylko przy logowaniu, więc po zmianie roli trzeba je odświeżyć.
 */
/proc/update_heretic_alt_appearances(mob/viewer, force_remove = FALSE)
	if(!viewer)
		return
	for(var/datum/atom_hud/alternate_appearance/basic/hud as anything in GLOB.active_alternate_appearances)
		if(istype(hud, /datum/atom_hud/alternate_appearance/basic/heretic) || istype(hud, /datum/atom_hud/alternate_appearance/basic/heretics))
			if(!force_remove && hud.mobShouldSee(viewer))
				hud.add_hud_to(viewer)
			else
				hud.remove_hud_from(viewer)
		else if(istype(hud, /datum/atom_hud/alternate_appearance/basic/blessedAware))
			if(hud.mobShouldSee(viewer))
				hud.add_hud_to(viewer)
			else
				hud.remove_hud_from(viewer)

// ---------------------------------------------------------------------------
// Chwilowy rentgen przy wpływach

/**
 * Effectively grants a temporary form of x-ray with a cooldown period.
 */
/datum/status_effect/temporary_xray
	id = "temp xray"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	duration = 10 SECONDS

/datum/status_effect/temporary_xray/on_apply()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	return TRUE

/datum/status_effect/temporary_xray/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()

/datum/status_effect/temporary_xray/eldritch // Heretic subtype that plays a sound and screen alert
	id = "temp xray eldritch"
	alert_type = /atom/movable/screen/alert/status_effect/temporary_xray

/datum/status_effect/temporary_xray/eldritch/on_apply()
	. = ..()
	SEND_SOUND(owner, 'sound/hallucinations/i_see_you1.ogg')

/atom/movable/screen/alert/status_effect/temporary_xray
	name = "Eldritch Sight"
	desc = "Dostrzegasz coś nowego..."
	icon = 'aquila/icons/hud/screen_alert_heretic_core.dmi'
	icon_state = "influence"

// ---------------------------------------------------------------------------
// Sygnały organów z tg (żywe serce)

/obj/item/organ/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	if(iscarbon(M) && owner != M)
		var/obj/item/organ/replaced = M.getorganslot(slot)
		if(replaced && replaced != src)
			SEND_SIGNAL(replaced, COMSIG_ORGAN_BEING_REPLACED, src)
	return ..()

/obj/item/organ/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_ORGAN_REMOVED, M)

// ---------------------------------------------------------------------------
// Sygnały akcji i zaklęć z tg

/// tg: COMSIG_ACTION_STATUS_UPDATE po odświeżeniu przycisku (licznik ładunków zaklęć heretyka)
/datum/action/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	. = ..()
	if(button)
		SEND_SIGNAL(src, COMSIG_ACTION_STATUS_UPDATE, button, force)

/// tg: COMSIG_MOB_SPELL_ACTIVATED przy włączeniu celowania zaklęciem
/datum/action/cooldown/spell/set_click_ability(mob/on_who)
	if(SEND_SIGNAL(on_who, COMSIG_MOB_SPELL_ACTIVATED, src) & SPELL_CANCEL_CAST)
		return FALSE
	return ..()

// ---------------------------------------------------------------------------
// Sny heretyka (u nas sny to jedna procedura dream(), bez /datum/dream)

/mob/living/carbon/dream()
	set waitfor = FALSE
	var/datum/status_effect/grouped/heretic_dreams/heretic_dreams = has_status_effect(/datum/status_effect/grouped/heretic_dreams)
	if(heretic_dreams?.try_heretic_dream(src))
		return
	return ..()

// ---------------------------------------------------------------------------
// Cechy z pasywek heretyka, których nasz rdzeń nie obsługiwał

/// tg: COMSIG_LIVING_EAT_FOOD po ugryzieniu jedzenia (pasywka ciała leczy przy jedzeniu mięsa)
/datum/component/edible/TakeBite(mob/living/eater, mob/living/feeder)
	. = ..()
	if(eater)
		SEND_SIGNAL(eater, COMSIG_LIVING_EAT_FOOD, parent, foodtypes)

/// tg: TRAIT_NO_SLIP_WATER / TRAIT_NO_SLIP_ICE / TRAIT_NO_SLIP_SLIDE (pasywka pustki)
/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	if((lube & SLIDE_ICE) && HAS_TRAIT(src, TRAIT_NO_SLIP_ICE))
		return FALSE
	if((lube & SLIDE) && HAS_TRAIT(src, TRAIT_NO_SLIP_SLIDE))
		return FALSE
	if(!(lube & (SLIDE|SLIDE_ICE)) && HAS_TRAIT(src, TRAIT_NO_SLIP_WATER))
		return FALSE
	return ..()

/// tg: TRAIT_BRAIN_TRAUMA_IMMUNITY na mózgu (pasywka księżyca); urazy absolutne dalej przechodzą
/obj/item/organ/brain/can_gain_trauma(datum/brain_trauma/trauma, resilience)
	if(HAS_TRAIT(src, TRAIT_BRAIN_TRAUMA_IMMUNITY))
		var/datum/brain_trauma/trauma_type = ispath(trauma) ? trauma : trauma.type
		if((resilience || initial(trauma_type.resilience)) < TRAUMA_RESILIENCE_ABSOLUTE)
			return FALSE
	return ..()

/// tg: TRAIT_BATON_RESISTANCE - pałka tylko na chwilę ogłusza (rdza, pasywka ciała)
/obj/item/melee/baton/baton_stun(mob/living/target, mob/living/user)
	if(!HAS_TRAIT(target, TRAIT_BATON_RESISTANCE))
		return ..()
	var/old_stunforce = stunforce
	stunforce = round(stunforce * 0.25)
	. = ..()
	stunforce = old_stunforce
	if(.)
		target.balloon_alert_to_viewers("opiera się pałce!")
