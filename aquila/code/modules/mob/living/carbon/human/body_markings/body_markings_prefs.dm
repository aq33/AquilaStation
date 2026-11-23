// AQUILA - zakładka „Markingi” w oknie postaci (tgui/packages/tgui/interfaces/PreferencesMenu/BodyMarkingsPage.tsx).
// Middleware trzyma tylko akcje i dane okna, markingi siedzą w active_character.features[AQ_MARKINGS_FEATURE].

/datum/preference_middleware/aq_body_markings
	action_delegations = list(
		"aq_marking_add" = PROC_REF(add_marking),
		"aq_marking_remove" = PROC_REF(remove_marking),
		"aq_marking_change" = PROC_REF(change_marking),
		"aq_marking_color" = PROC_REF(color_marking),
		"aq_marking_side" = PROC_REF(side_marking),
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
			catalog += list(list("id" = marking.id, "name" = marking.name, "zones" = marking.zones, "sides" = length(marking.sides) > 0))
	return list(
		"aq_markings_catalog" = catalog,
		"aq_markings_limit" = AQ_MARKINGS_PER_ZONE,
	)

/datum/preference_middleware/aq_body_markings/get_ui_assets()
	return list(get_asset_datum(/datum/asset/spritesheet/aq_body_markings))

/// Podgląd markingu na liście: sama część ciała z markingiem (klasa "[id]_[strefa]")
/datum/asset/spritesheet/aq_body_markings
	name = "aq_body_markings"

/datum/asset/spritesheet/aq_body_markings/register()
	for(var/id in GLOB.aq_body_markings)
		var/datum/aq_body_marking/marking = GLOB.aq_body_markings[id]
		for(var/zone in marking.zones)
			var/icon/preview = aq_marking_preview_icon(marking.sides ? marking.sides["left"] : marking.id, zone)
			if(preview)
				Insert(sanitize_css_class_name("[id]_[zone]"), preview)
			if(marking.sides) // prawa wersja ma klasę "[id]_r_[strefa]"
				var/icon/right_preview = aq_marking_preview_icon(marking.sides["right"], zone)
				if(right_preview)
					Insert(sanitize_css_class_name("[id]_r_[zone]"), right_preview)
	return ..()

/// Kolory podglądu: jasna skóra i wyraźny marking
#define AQ_MARKING_PREVIEW_SKIN "#e8c4a0"
#define AQ_MARKING_PREVIEW_COLOR "#c0302a"
/// Kierunki, w których szukamy najlepiej widocznego markingu (np. tatuaż na plecach widać tylko z tyłu)
#define AQ_MARKING_PREVIEW_DIRS list(SOUTH, NORTH, EAST, WEST)

/// Część ciała z markingiem w kierunku, w którym marking ma najwięcej pikseli, wycięta w kwadrat i powiększona do 48x48
/proc/aq_marking_preview_icon(sprite_id, zone)
	var/marking_state = zone == BODY_ZONE_CHEST ? "[sprite_id]_chest_m" : "[sprite_id]_[zone]"
	var/part_state = zone == BODY_ZONE_CHEST || zone == BODY_ZONE_HEAD ? "human_[zone]_m" : "human_[zone]"
	if(!icon_exists(AQ_BODY_MARKINGS_ICON, marking_state) || !icon_exists('icons/mob/human_parts_greyscale.dmi', part_state))
		return null
	var/best_dir = SOUTH
	var/best_count = -1
	for(var/dir in AQ_MARKING_PREVIEW_DIRS)
		var/icon/probe = icon(AQ_BODY_MARKINGS_ICON, marking_state, dir, 1)
		var/count = 0
		for(var/x in 1 to 32 step 2)
			for(var/y in 1 to 32 step 2)
				if(probe.GetPixel(x, y))
					count++
		if(count > best_count)
			best_count = count
			best_dir = dir
	var/icon/part = icon('icons/mob/human_parts_greyscale.dmi', part_state, best_dir, 1)
	part.Blend(AQ_MARKING_PREVIEW_SKIN, ICON_MULTIPLY)
	var/icon/overlay = icon(AQ_BODY_MARKINGS_ICON, marking_state, best_dir, 1)
	overlay.Blend(AQ_MARKING_PREVIEW_COLOR, ICON_MULTIPLY)
	part.Blend(overlay, ICON_OVERLAY)
	// Kwadrat wokół części ciała, żeby mała dłoń nie ginęła w pustym polu 32x32
	var/min_x = 33
	var/min_y = 33
	var/max_x = 0
	var/max_y = 0
	for(var/x in 1 to 32)
		for(var/y in 1 to 32)
			if(!part.GetPixel(x, y))
				continue
			min_x = min(min_x, x)
			min_y = min(min_y, y)
			max_x = max(max_x, x)
			max_y = max(max_y, y)
	if(max_x)
		var/size = max(max_x - min_x, max_y - min_y) + 3
		var/center_x = round((min_x + max_x) / 2)
		var/center_y = round((min_y + max_y) / 2)
		var/x1 = center_x - round(size / 2)
		var/y1 = center_y - round(size / 2)
		part.Crop(x1, y1, x1 + size - 1, y1 + size - 1)
	part.Scale(48, 48)
	return part

#undef AQ_MARKING_PREVIEW_SKIN
#undef AQ_MARKING_PREVIEW_COLOR
#undef AQ_MARKING_PREVIEW_DIRS

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
	entries += list(length(marking.sides) ? list(marking.id, "#FFFFFF", "left") : list(marking.id, "#FFFFFF"))
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
	if(length(marking.sides) && length(entry) < 3)
		entry += "left"
	else if(!length(marking.sides) && length(entry) > 2)
		entry.len = 2
	return store_markings(markings)

/// Marking z wersją lewą i prawą: przełącza stronę
/datum/preference_middleware/aq_body_markings/proc/side_marking(list/params, mob/user)
	var/list/markings = current_markings()
	var/list/entry = entry_at(markings, params["zone"], params["index"])
	var/datum/aq_body_marking/marking = entry && GLOB.aq_body_markings[entry[1]]
	if(!length(marking?.sides) || length(entry) < 3)
		return FALSE
	entry[3] = entry[3] == "right" ? "left" : "right"
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
