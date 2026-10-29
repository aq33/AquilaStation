// Port BeeStation/BeeStation-Hornet#14750 (code/datums/keybinding/carbon.dm): sprint pod samym Shiftem.
// Samo Shift przychodzi w keyDown/keyUp jako "Shift" bez modyfikatorów, ruch WSAD ma any_modifier,
// a Shift+klik idzie przez MouseDown, nie przez keybindy, więc nic się nie gryzie.

/datum/keybinding/carbon/sprint
	key = "Shift"
	name = "sprint"
	full_name = "Sprint"
	description = "Biegnij szybciej kosztem kondycji (tylko w trybie biegu)."
	category = CATEGORY_CARBON
	keybind_signal = COMSIG_KB_CARBON_SPRINT_DOWN

/datum/keybinding/carbon/sprint/up(client/user)
	. = ..()
	if(.)
		return
	SEND_SIGNAL(user.mob, COMSIG_KB_CARBON_SPRINT_UP)

// Zapisane keybindy nie dostają nowych skrótów same. Dopisujemy sprint pod Shift,
// jeśli gracz nie ma go nigdzie przypisanego, a Shift jest wolny.
/datum/preferences/load_from_database()
	. = ..()
	if(!islist(key_bindings))
		return
	for(var/bound_key in key_bindings)
		var/list/names = key_bindings[bound_key]
		if(islist(names) && ("sprint" in names))
			return
	if(length(key_bindings["Shift"]))
		return
	key_bindings["Shift"] = list("sprint")
