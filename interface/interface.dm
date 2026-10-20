//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki(query as text)
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser. Type nothing to go to the main page."
	set hidden = 1
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		if(query)
			var/output = wikiurl + "/Special:Search/" + query
			src << link(output)
		else if (query != null)
			src << link(wikiurl)
	else
		to_chat(src, "<span class='danger'>Adres wiki nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	var/forumurl = CONFIG_GET(string/forumurl)
	if(forumurl)
		if(alert("To otworzy forum w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(forumurl)
	else
		to_chat(src, "<span class='danger'>Adres forum nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/rules()
	set name = "rules"
	set desc = "Show Server Rules."
	set hidden = 1
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		if(alert("To otworzy zasady w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(rulesurl)
	else
		to_chat(src, "<span class='danger'>Adres zasad nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/github()
	set name = "github"
	set desc = "Visit Github"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		if(alert("To otworzy repozytorium GitHub w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(githuburl)
	else
		to_chat(src, "<span class='danger'>Adres GitHuba nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/reportissue()
	set name = "report-issue"
	set desc = "Report an issue"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		var/message = "To otworzy zgłaszanie błędów na GitHubie w twojej przeglądarce. Na pewno?"
		if(GLOB.revdata.testmerge.len)
			message += "<br>Aktywne są następujące eksperymentalne zmiany, które prawdopodobnie odpowiadają za nowe lub nagłe problemy. Jeśli to możliwe, znajdź konkretny wątek dla swojego problemu, zamiast pisać w ogólnym zgłaszaniu błędów:<br>"
			message += GLOB.revdata.GetTestMergeInfo(FALSE)
		// We still use tgalert here because some people were concerned that if someone wanted to report that tgui wasn't working
		// then the report issue button being tgui-based would be problematic.
		if(tgalert(src, message, "Report Issue","Yes","No")!="Yes")
			return
		var/static/issue_template = rustg_file_read(".github/ISSUE_TEMPLATE.md")
		var/servername = CONFIG_GET(string/servername)
		var/url_params = "Reporting client version: [byond_version].[byond_build]\n\n[issue_template]"
		if(GLOB.round_id || servername)
			url_params = "Issue reported from [GLOB.round_id ? " Round ID: [GLOB.round_id][servername ? " ([servername])" : ""]" : servername]\n\n[url_params]"
		var/issue_label = CONFIG_GET(string/issue_label)
		DIRECT_OUTPUT(src, link("[githuburl]/issues/new?body=[rustg_url_encode(url_params)][issue_label ? "&labels=[rustg_url_encode(issue_label)]" : ""]"))
	else
		to_chat(src, "<span class='danger'>Adres GitHuba nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	// AQ EDIT - port z tgstation: okno TGUI HotkeysHelp zamiast listy w czacie
	if(!GLOB.hotkeys_tgui)
		GLOB.hotkeys_tgui = new /datum/hotkeys_help()
	GLOB.hotkeys_tgui.ui_interact(mob)

// AQ EDIT START - port z tgstation: okno pomocy skrótów klawiszowych
GLOBAL_DATUM(hotkeys_tgui, /datum/hotkeys_help)

/datum/hotkeys_help

/datum/hotkeys_help/ui_state(mob/user)
	return GLOB.always_state

/datum/hotkeys_help/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HotkeysHelp")
		ui.open()

/datum/hotkeys_help/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(action == "open_keybindings")
		if(!user?.client?.prefs)
			return
		user.client.prefs.open_keybindings_menu(user)
		ui.close()
		return TRUE

// Not static data since user could rebind keys.
/datum/hotkeys_help/ui_data(mob/user)
	var/list/keys_list = list()
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return list("hotkeys" = keys_list)

	// Show them in alphabetical order by key
	var/list/key_bindings_by_key = sortList(prefs.key_bindings.Copy(), GLOBAL_PROC_REF(cmp_text_asc))

	for(var/key in key_bindings_by_key)
		if(key == "Unbound")
			continue
		// Get the full names
		var/list/binding_names = list()
		for(var/kb_name in key_bindings_by_key[key])
			var/datum/keybinding/binding = GLOB.keybindings_by_name[kb_name]
			if(!binding)
				continue
			// Admin hotkeys only for admins
			if(binding.category == CATEGORY_ADMIN && !user.client.holder)
				continue
			binding_names += list(list(
				"name" = binding.full_name,
				"desc" = binding.description
			))
		if(!length(binding_names))
			continue

		// Add to list
		keys_list += list(list(
			"key" = key,
			"bindings" = binding_names
		))

	return list(
		"hotkeys" = keys_list
	)
// AQ EDIT END

/client/verb/changelog()
	set name = "Changelog"
	set category = "OOC"
	// AQ EDIT START - port BeeStation #12236: TGUI changelog
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()
	GLOB.changelog_tgui.ui_interact(mob)
	// AQ EDIT END
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "font-style=;")





/client/verb/donate()
	set name = "donate"
	set desc = "Donate to the server"
	set hidden = 1
	var/donateurl = CONFIG_GET(string/donateurl)
	if(donateurl)
		if(alert("To otworzy stronę darowizn w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(donateurl)
	else
		to_chat(src, "<span class='danger'>Adres strony darowizn nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/discord()
	set name = "discord"
	set desc = "Join the Discord"
	set hidden = 1
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(alert("To otworzy zaproszenie na Discorda w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(discordurl)
	else
		to_chat(src, "<span class='danger'>Zaproszenie na Discorda nie jest ustawione w konfiguracji serwera.</span>")
	return

/client/verb/map()
	set name = "View Webmap"
	set desc = "View the current map in the webviewer"
	set category = "OOC"
	if(SSmapping.config.map_link == "None")
		to_chat(src,"<span class='danger'>Obecna mapa nie ma mapy w przeglądarce. </span>")
	else if(SSmapping.config.map_link)
		if(alert("To otworzy obecną mapę w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link("https://webmap.affectedarc07.co.uk/maps/aquila/[SSmapping.config.map_link]")
	else
		to_chat(src, "<span class='danger'>Obecna mapa jest nieprawidłowa lub niedostępna. Zgłoś błąd na GitHubie. </span>")

//NSV13 - alias to "map"
/client/verb/nsv13_map()
	set name = "Map"
	set desc = "View the current map in the webviewer"
	set hidden = 1
	map()
