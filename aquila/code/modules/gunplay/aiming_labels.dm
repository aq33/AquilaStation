// AQUILA - polskie podpisy w radialu celowania z broni (code/datums/components/aiming.dm).
// Radial pokazuje nad kołem klucz opcji, więc zamiast "raise_hands" czy "drop_weapon" kluczem jest polski podpis,
// a act() i aim_react_act() zamieniają go z powrotem na identyfikator (ten sam co icon_state w aiming.dmi).

/// Identyfikator opcji (icon_state) -> podpis w radialu. Jedyna lista opcji: odwrotną buduje aiming_choice_from_label().
GLOBAL_LIST_INIT(aiming_choice_labels, list(
	"cancel" = "Anuluj",
	"fire" = "Strzelaj",
	"raise_hands" = "Ręce do góry",
	"drop_weapon" = "Rzuć broń",
	"drop_to_floor" = "Na ziemię",
	"surrender" = "Poddaj się",
	"ignore" = "Ignoruj",
))

/proc/aiming_choice_label(option)
	return GLOB.aiming_choice_labels[option] || option

/// Podpis z radialu -> identyfikator opcji
/proc/aiming_choice_from_label(label)
	if(isnull(label))
		return null
	var/static/list/options
	if(!options)
		options = list()
		for(var/option in GLOB.aiming_choice_labels)
			options[GLOB.aiming_choice_labels[option]] = option
	return options[label] || label
