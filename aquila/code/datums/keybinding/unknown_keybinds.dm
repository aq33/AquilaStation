// Zapisane prefy mogą mieć nazwy keybindów, których już nie ma (usunięte albo przemianowane).
// keyDown/keyUp dorzucały wtedy null do listy, sortowanie się wywalało i klawisz nie działał.
/datum/preferences/load_from_database()
	. = ..()
	remove_unknown_keybindings()

/// Usuwa z key_bindings nazwy, których nie ma w GLOB.keybindings_by_name, i klawisze bez żadnego bindu
/datum/preferences/proc/remove_unknown_keybindings()
	if(!islist(key_bindings))
		return
	for(var/bound_key in key_bindings.Copy())
		var/list/names = key_bindings[bound_key]
		if(!islist(names))
			key_bindings -= bound_key
			continue
		for(var/kb_name in names.Copy())
			if(!GLOB.keybindings_by_name[kb_name])
				names -= kb_name
		if(!length(names))
			key_bindings -= bound_key
