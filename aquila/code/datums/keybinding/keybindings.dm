/// Creates and sorts all the keybinding datums
/proc/init_keybindings()
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.key))
			continue
		add_keybinding(new keybinding)
	init_emote_keybinds()
	for(var/key in GLOB.keybinding_list_by_key)
		GLOB.keybinding_list_by_key[key] = sortList(GLOB.keybinding_list_by_key[key])

/// Adds an instanced keybinding to the global tracker
/proc/add_keybinding(datum/keybinding/instance)
	GLOB.keybindings_by_name[instance.name] = instance

	if(!(instance.key in GLOB.keybinding_list_by_key))
		GLOB.keybinding_list_by_key[instance.key] = list()
	GLOB.keybinding_list_by_key[instance.key] |= instance.name

/proc/init_emote_keybinds()
	for(var/i in subtypesof(/datum/emote))
		var/datum/emote/faketype = i
		if(!initial(faketype.key))
			continue
		var/datum/keybinding/emote/emote_kb = new
		emote_kb.link_to_emote(faketype)
		add_keybinding(emote_kb)

/// Plik z nazwami domyślnych keybindów, które gracz już raz dostał (ckey -> lista nazw).
/proc/offered_keybinds_file()
	return "data/offered_keybinds.json"

/// ckey -> lista nazw keybindów, które już raz zaproponowano graczowi
/proc/offered_keybinds()
	var/static/list/offered
	if(isnull(offered))
		offered = list()
		if(fexists(offered_keybinds_file()))
			var/list/saved = json_decode(rustg_file_read(offered_keybinds_file()))
			if(islist(saved))
				offered = saved
	return offered

/**
 * Zapisane keybindy nie dostają nowych skrótów same. Dopisuje bind pod klawisz, jeśli gracz nie ma go
 * nigdzie przypisanego, a klawisz jest wolny. Robi to tylko raz na gracza: bind, który gracz potem
 * usunie, nie wraca przy następnym wejściu do gry.
 */
/datum/preferences/proc/offer_default_keybind(keybind_name, key)
	if(!islist(key_bindings))
		return FALSE
	var/player_ckey = parent?.ckey
	var/remember = player_ckey && !IS_GUEST_KEY(parent.key)
	var/list/offered = offered_keybinds()
	if(remember && (keybind_name in offered[player_ckey]))
		return FALSE
	. = FALSE
	var/bound = FALSE
	for(var/bound_key in key_bindings)
		var/list/names = key_bindings[bound_key]
		if(islist(names) && (keybind_name in names))
			bound = TRUE
			break
	if(!bound && !length(key_bindings[key]))
		key_bindings[key] = list(keybind_name)
		. = TRUE
	if(!remember)
		return
	var/list/names = offered[player_ckey]
	if(!islist(names))
		names = list()
		offered[player_ckey] = names
	names += keybind_name
	rustg_file_write(json_encode(offered), offered_keybinds_file())
