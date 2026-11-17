// AQUILA - zakładka „Markingi” w oknie postaci (tgui/packages/tgui/interfaces/PreferencesMenu/BodyMarkingsPage.tsx).
// Middleware trzyma tylko akcje i dane okna, markingi siedzą w active_character.features[AQ_MARKINGS_FEATURE].

/datum/preference_middleware/aq_body_markings
	action_delegations = list(
		"aq_marking_add" = PROC_REF(add_marking),
		"aq_marking_remove" = PROC_REF(remove_marking),
		"aq_marking_change" = PROC_REF(change_marking),
		"aq_marking_color" = PROC_REF(color_marking),
	)

/datum/preference_middleware/aq_body_markings/get_ui_data(mob/user)
	if(preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES || !preferences.active_character)
		return list()
	return list(
		"aq_markings" = aq_markings_decode(preferences.active_character.features[AQ_MARKINGS_FEATURE]),
		"aq_markings_allowed" = !!preferences.active_character.pref_species?.aq_body_markings,
	)

/datum/preference_middleware/aq_body_markings/get_ui_static_data(mob/user)
	if(preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/static/list/catalog
	if(!catalog)
		catalog = list()
		for(var/id in GLOB.aq_body_markings)
			var/datum/aq_body_marking/marking = GLOB.aq_body_markings[id]
			catalog += list(list("id" = marking.id, "name" = marking.name, "zones" = marking.zones))
	return list(
		"aq_markings_catalog" = catalog,
		"aq_markings_limit" = AQ_MARKINGS_PER_ZONE,
	)

/// Markingi postaci po walidacji, gotowe do zmiany
/datum/preference_middleware/aq_body_markings/proc/current_markings()
	return aq_markings_decode(preferences.active_character.features[AQ_MARKINGS_FEATURE])

/// Zapis do postaci i odświeżenie podglądu
/datum/preference_middleware/aq_body_markings/proc/store_markings(list/markings)
	preferences.active_character.features[AQ_MARKINGS_FEATURE] = aq_markings_encode(markings)
	preferences.update_character_preview()
	return TRUE

/// Wpis o danym numerze (od 1) w danej strefie albo null
/datum/preference_middleware/aq_body_markings/proc/entry_at(list/markings, zone, index)
	var/list/entries = markings[zone]
	index = text2num("[index]")
	if(!isnum(index) || index < 1 || index > length(entries))
		return null
	return entries[index]

/datum/preference_middleware/aq_body_markings/proc/add_marking(list/params, mob/user)
	var/zone = params["zone"]
	var/datum/aq_body_marking/marking = GLOB.aq_body_markings[params["id"]]
	if(!(zone in GLOB.aq_body_marking_zones) || !marking || !(zone in marking.zones))
		return FALSE
	var/list/markings = current_markings()
	var/list/entries = markings[zone] || list()
	if(length(entries) >= AQ_MARKINGS_PER_ZONE)
		to_chat(user, "<span class='warning'>Na jednej części ciała zmieszczą się najwyżej [AQ_MARKINGS_PER_ZONE] markingi.</span>")
		return TRUE
	entries += list(list(marking.id, "#FFFFFF"))
	markings[zone] = entries
	return store_markings(markings)

/datum/preference_middleware/aq_body_markings/proc/remove_marking(list/params, mob/user)
	var/list/markings = current_markings()
	var/list/entry = entry_at(markings, params["zone"], params["index"])
	if(!entry)
		return FALSE
	var/list/entries = markings[params["zone"]]
	entries -= list(entry)
	return store_markings(markings)

/datum/preference_middleware/aq_body_markings/proc/change_marking(list/params, mob/user)
	var/zone = params["zone"]
	var/datum/aq_body_marking/marking = GLOB.aq_body_markings[params["id"]]
	if(!marking || !(zone in marking.zones))
		return FALSE
	var/list/markings = current_markings()
	var/list/entry = entry_at(markings, zone, params["index"])
	if(!entry)
		return FALSE
	entry[1] = marking.id
	return store_markings(markings)

/datum/preference_middleware/aq_body_markings/proc/color_marking(list/params, mob/user)
	var/list/markings = current_markings()
	var/list/entry = entry_at(markings, params["zone"], params["index"])
	if(!entry)
		return FALSE
	var/new_color = input(user, "Wybierz kolor markingu", "Kolor", entry[2]) as color|null
	if(!new_color || QDELETED(src) || !preferences?.active_character)
		return FALSE
	// Okno mogło się zmienić, kiedy gracz wybierał kolor
	markings = current_markings()
	entry = entry_at(markings, params["zone"], params["index"])
	if(!entry)
		return FALSE
	entry[2] = sanitize_hexcolor(new_color, 6, TRUE, "#FFFFFF")
	return store_markings(markings)
