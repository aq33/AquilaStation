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

// Zapisane keybindy nie dostają nowych skrótów same. Dopisujemy sprint pod Shift (raz na gracza), jeśli jest wolny.
// Najpierw usuwamy nieznane skróty: Shift z samym usuniętym skrótem wyglądał na zajęty i sprint nie trafiał pod niego.
/datum/preferences/load_from_database()
	. = ..()
	remove_unknown_keybindings()
	add_sprint_keybind()

/// Dopisuje sprint pod Shift, jeśli nie jest nigdzie przypisany, a Shift jest wolny (raz na gracza)
/datum/preferences/proc/add_sprint_keybind()
	offer_default_keybind("sprint", "Shift")
