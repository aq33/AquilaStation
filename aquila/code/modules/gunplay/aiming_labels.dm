// AQUILA - polskie podpisy w radialu celowania z broni (code/datums/components/aiming.dm).
// Radial pokazuje nad kołem klucz opcji, więc zamiast "raise_hands" czy "drop_weapon" kluczem jest polski podpis,
// a act() i aim_react_act() zamieniają go z powrotem na identyfikator (ten sam co icon_state w aiming.dmi).

/// Identyfikator opcji (icon_state) -> podpis w radialu
/proc/aiming_choice_label(option)
	var/static/list/labels = list(
		"cancel" = "Anuluj",
		"fire" = "Strzelaj",
		"raise_hands" = "Ręce do góry",
		"drop_weapon" = "Rzuć broń",
		"drop_to_floor" = "Na ziemię",
		"surrender" = "Poddaj się",
		"ignore" = "Ignoruj",
	)
	return labels[option] || option

/// Podpis z radialu -> identyfikator opcji
/proc/aiming_choice_from_label(label)
	var/static/list/options
	if(!options)
		options = list()
		for(var/option in list("cancel", "fire", "raise_hands", "drop_weapon", "drop_to_floor", "surrender", "ignore"))
			options[aiming_choice_label(option)] = option
	if(isnull(label))
		return null
	return options[label] || label
