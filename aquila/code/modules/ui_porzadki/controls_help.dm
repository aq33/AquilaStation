// AQ - porządki w UI: dane do strony "Pomoc" w menu pod Esc - aktualne klawisze gracza.

/// Nazwy kategorii skrótów w kolejności wyświetlania
GLOBAL_LIST_INIT(controls_help_categories, list(
	CATEGORY_HUMAN = "Postać",
	CATEGORY_CARBON = "Walka i przedmioty",
	CATEGORY_CLIENT = "Gra",
	CATEGORY_ROBOT = "Cyborg",
	CATEGORY_OVERMAP = "Statek",
	CATEGORY_VEHICLE = "Pojazdy",
	CATEGORY_EMOTE = "Emotki",
	CATEGORY_MISC = "Inne",
	CATEGORY_ADMIN = "Administracja",
))

/// Lista sekcji [{title, entries: [{name, keys}]}] z klawiszami przypisanymi przez gracza
/datum/escape_menu/proc/build_controls()
	var/list/keys_by_name = list()
	var/list/bindings = client?.prefs?.key_bindings
	for(var/key in bindings)
		for(var/kb_name in bindings[key])
			LAZYADD(keys_by_name[kb_name], key)

	var/list/entries_by_category = list()
	for(var/kb_name in keys_by_name)
		var/datum/keybinding/keybinding = GLOB.keybindings_by_name[kb_name]
		if(!keybinding || (keybinding.category == CATEGORY_ADMIN && !client.holder))
			continue
		LAZYADD(entries_by_category[keybinding.category], list(list(
			"name" = keybinding.full_name || keybinding.name,
			"keys" = keys_by_name[kb_name],
		)))

	var/list/result = list()
	for(var/category in GLOB.controls_help_categories)
		if(length(entries_by_category[category]))
			result += list(list(
				"title" = GLOB.controls_help_categories[category],
				"entries" = entries_by_category[category],
			))
	return result
