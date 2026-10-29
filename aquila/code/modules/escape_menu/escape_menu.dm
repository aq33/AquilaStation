// AQ - menu pod Esc, port z tgstation (code/modules/escape_menu, pakiet tgui-escape-menu).
// Menu to osobny pakiet tgui renderowany w przezroczystej kontrolce przeglądarki
// "mapwindow.escape_menu" (interface/skin.dmf), nałożonej na mapę. Klawisz Esc
// (makro ustawiane w /client/proc/set_macros) wysyła do niej wiadomość "toggle"
// bez udziału serwera, a skrypt menu sam pokazuje i chowa kontrolkę.

#define SKIN_ESCAPE_MENU "mapwindow.escape_menu"
#define ESCAPE_MENU_ID "escape_menu"

PROCESSING_SUBSYSTEM_DEF(escape_menu)
	name = "Escape Menu"
	flags = SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 2 SECONDS

/// Ikona klauna leżącego na boku (base64) do przycisku samobójstwa; generowana raz, przy pierwszym otwarciu menu.
GLOBAL_VAR(escape_menu_suicide_icon_base64)

/proc/generate_escape_menu_suicide_icon()
	if(!isnull(GLOB.escape_menu_suicide_icon_base64))
		return
	GLOB.escape_menu_suicide_icon_base64 = ""
	var/mob/living/carbon/human/dummy/clown = generate_or_wait_for_human_dummy(null)
	clown.equipOutfit(/datum/outfit/job/clown, TRUE)
	COMPILE_OVERLAYS(clown)
	var/icon/clown_icon = getFlatIcon(clown, SOUTH)
	clown_icon.Turn(90)
	qdel(clown)
	GLOB.escape_menu_suicide_icon_base64 = icon2base64(clown_icon)

/// Komenda makra Esc: zamyka okno mówienia (tgui-say), a resztę robi /client/verb/escape_pressed -
/// najpierw zamyka koła wyboru i okna, dopiero potem przełącza menu. Stan okna mówienia trafia
/// do verba przez embedded winget, żeby Esc przy otwartym tgui-say tylko je zamykał.
/client/proc/escape_menu_create_toggle_command(close_tgui_say = TRUE)
	var/command = ".escape_pressed \\\"\[\[tgui_say.is-visible\]\]\\\""
	if(close_tgui_say)
		command += "\\n.output tgui_say.browser:update [TGUI_CREATE_MESSAGE_EMPTY("close")]"
	return "\"[command]\""

/// Esc: zamyka otwarte koła wyboru i okna TGUI; jeśli nic nie było otwarte, przełącza menu pod Esc.
/client/verb/escape_pressed(say_visible as text|null)
	set name = ".escape_pressed"
	set hidden = TRUE
	set instant = TRUE
	escape_menu_reset_keys()
	if(say_visible == "true")
		return
	if(!escape_menu?.is_open && close_popups())
		return
	escape_menu?.window?.send_message("toggle", list("say" = "false"))

/// Zamyka koła wyboru (radial) i okna TGUI gracza. Zwraca TRUE, jeśli coś zamknęło.
/client/proc/close_popups()
	. = FALSE
	for(var/id in GLOB.radial_menus)
		var/datum/radial_menu/menu = GLOB.radial_menus[id]
		if(menu?.current_user != src)
			continue
		. = TRUE
		if(istype(menu, /datum/radial_menu/persistent))
			var/datum/radial_menu/persistent/persistent_menu = menu
			persistent_menu.select_proc_callback?.Invoke(null)
		else
			menu.finished = TRUE
	if(SStgui.close_user_uis(mob))
		. = TRUE

/// Po otwarciu menu fokus znika z mapy i puszczenie klawisza może nie dotrzeć - zwalniamy wszystkie.
/client/verb/escape_menu_reset_keys()
	set name = ".escape_menu_reset_keys"
	set hidden = TRUE
	set instant = TRUE
	for(var/key in keys_held.Copy())
		keyUp(key)

/client/var/datum/escape_menu/escape_menu

/client/proc/initialize_escape_menu()
	set waitfor = FALSE
	// Jak tgui-say: po konstruktorze klienta, żeby skin zdążył się załadować
	sleep(3 SECONDS)
	if(!src) // klient zdążył się rozłączyć
		return
	escape_menu = new(src)

/datum/escape_menu
	var/client/client
	var/datum/tgui_window/window
	/// Czy gracz został już ostrzeżony, że jego BYOND nie obsługuje przezroczystych przeglądarek
	var/version_warned = FALSE
	/// Czy menu jest teraz pokazane (wg wiadomości "opened"/"closed" od skryptu menu)
	var/is_open = FALSE

/datum/escape_menu/New(client/client)
	src.client = client
	window = new(client, ESCAPE_MENU_ID)
	window.is_browser = TRUE
	window.subscribe(src, PROC_REF(on_message))
	window.initialize(
		strict_mode = TRUE,
		inline_css = file("tgui/public/tgui-escape-menu.bundle.css"),
		inline_js = file("tgui/public/tgui-escape-menu.bundle.js"),
	)
	if(!client)
		return
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/escape_menu_font))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/escape_menu_sounds))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet/escape_menu_icons))
	send_init()

/datum/escape_menu/Destroy(force, ...)
	STOP_PROCESSING(SSescape_menu, src)
	window?.unsubscribe(src)
	window = null
	if(client?.escape_menu == src)
		client.escape_menu = null
	client = null
	return ..()

/datum/escape_menu/process(delta_time)
	if(!client)
		qdel(src)
		return PROCESS_KILL
	send_update(build_dynamic_data())

/// Dane zmieniające się w trakcie rundy - odświeżane co 2 s, gdy menu jest otwarte.
/datum/escape_menu/proc/build_dynamic_data()
	return list(
		"stationName" = station_name(),
		"serverTime" = time_stamp(),
		"shiftTime" = SSticker.round_start_time ? gameTimestamp("hh:mm:ss", world.time - SSticker.round_start_time) : "Przed rundą",
		"timeDilation" = "[round(SStime_track.time_dilation_current, 1)]",
		"canLeaveBody" = isliving(client?.mob),
		"canAdminHelp" = !!(/client/verb/adminhelp in client?.verbs),
		"hasTicket" = !isnull(client?.current_ticket),
		"admins" = build_admin_list(),
		"players" = build_player_list(),
		"ignoredOffline" = build_ignored_offline(),
	)

/datum/escape_menu/proc/send_init()
	var/list/resources = list()

	if(CONFIG_GET(string/githuburl))
		resources += list(list("id" = "bug", "label" = "Zgłoś błąd", "tooltip" = "Zgłoś błąd lub problem"))
		resources += list(list("id" = "github", "label" = "GitHub", "tooltip" = "Otwórz repozytorium gry"))
	if(CONFIG_GET(string/discordurl))
		resources += list(list("id" = "discord", "icon" = "forums", "label" = "Discord", "tooltip" = "Dołącz do Discorda serwera"))
	if(CONFIG_GET(string/forumurl))
		resources += list(list("id" = "forums", "label" = "Forum", "tooltip" = "Odwiedź forum serwera"))
	if(CONFIG_GET(string/rulesurl))
		resources += list(list("id" = "rules", "label" = "Zasady", "tooltip" = "Przeczytaj zasady serwera"))
	if(CONFIG_GET(string/wikiurl))
		resources += list(list("id" = "wiki", "label" = "Wiki", "tooltip" = "Otwórz wiki gry"))
	resources += list(list("id" = "changelog", "label" = "Zmiany", "tooltip" = "Zobacz listę zmian na serwerze"))

	var/map_link = SSmapping.config?.map_link
	var/list/data = build_dynamic_data()
	data["roundId"] = GLOB.round_id ? "[GLOB.round_id]" : "Brak"
	data["mapName"] = SSmapping.config?.map_name || "Wczytywanie..."
	data["mapWebmap"] = (map_link && map_link != "None") ? "https://webmap.affectedarc07.co.uk/maps/aquila/[map_link]" : null
	data["canSeeNotes"] = !!CONFIG_GET(flag/see_own_notes)
	data["resources"] = resources
	data["controls"] = list()
	data["suicideIcon"] = GLOB.escape_menu_suicide_icon_base64 || null
	window.send_message("init", data)

/datum/escape_menu/proc/build_admin_list()
	var/list/result = list()
	for(var/client/admin as anything in GLOB.admins)
		if(admin.holder?.fakekey && !client?.holder)
			continue
		result += list(list(
			"ref" = REF(admin),
			"displayName" = admin.holder?.fakekey || admin.key,
			"rank" = admin.holder?.rank?.name,
			"ping" = round(admin.avgping, 1),
			"ignored" = (admin.key in client?.prefs?.ignoring),
			"isSelf" = (admin == client),
		))
	return result

/datum/escape_menu/proc/build_player_list()
	var/list/result = list()
	for(var/client/player as anything in GLOB.clients)
		var/fakekey = player.holder?.fakekey
		// Admini są w osobnej sekcji, chyba że ukrywają się pod fałszywym kluczem przed zwykłym graczem
		if(player.holder && !(fakekey && !client?.holder))
			continue
		result += list(list(
			"ref" = REF(player),
			"displayName" = fakekey || player.key,
			"ping" = round(player.avgping, 1),
			"ignored" = (player.key in client?.prefs?.ignoring),
			"isSelf" = (player == client),
		))
	return result

/datum/escape_menu/proc/build_ignored_offline()
	var/list/result = list()
	for(var/ignored_key in client?.prefs?.ignoring)
		if(!(ckey(ignored_key) in GLOB.directory))
			result += ignored_key
	return result

/datum/escape_menu/proc/send_update(list/data)
	window?.send_message("state", data)

/datum/escape_menu/proc/on_message(type, payload, href_list)
	if(type == "ready")
		send_init()
		return TRUE

	if(type != "action" || !client)
		return FALSE

	var/action = payload["action"]
	switch(action)
		if("opened")
			if(!version_warned && client.byond_build < 1680)
				to_chat(client, "<span class='warning'>Twoja wersja BYOND jest za stara, żeby poprawnie wyświetlić menu pod Esc. Zaktualizuj do 516.1680 lub nowszej.</span>")
				version_warned = TRUE
			is_open = TRUE
			var/list/opened_data = build_dynamic_data()
			opened_data["controls"] = build_controls()
			send_update(opened_data)
			START_PROCESSING(SSescape_menu, src)
			if(isnull(GLOB.escape_menu_suicide_icon_base64))
				INVOKE_ASYNC(src, PROC_REF(send_suicide_icon))
		if("closed")
			is_open = FALSE
			STOP_PROCESSING(SSescape_menu, src)
		if("character")
			client.prefs?.open_character_menu(client.mob)
		if("settings")
			client.prefs?.open_game_menu(client.mob)
		if("leaderboard")
			INVOKE_ASYNC(client, TYPE_VERB_REF(/client, economy_leaderboard))
		if("create_ticket")
			if(!(/client/verb/adminhelp in client.verbs))
				return TRUE
			client.get_adminhelp()
		if("pray")
			winset(client, null, "command=Pray")
		if("see_notes")
			if(!CONFIG_GET(flag/see_own_notes))
				to_chat(client, "<span class='notice'>Podgląd własnych notatek jest wyłączony na tym serwerze.</span>")
				return TRUE
			browse_messages(null, client.ckey, null, TRUE)
		if("ghost")
			var/mob/user = client.mob
			if(isliving(user) && hascall(user, "ghost"))
				call(user, "ghost")()
		if("suicide")
			var/mob/user = client.mob
			if(isliving(user) && hascall(user, "suicide"))
				call(user, "suicide")()
		if("quit")
			winset(client, null, "command=.quit")
		if("resource_bug")
			client.reportissue()
		if("resource_github")
			client.github()
		if("resource_discord")
			client.discord()
		if("resource_forums")
			client.forum()
		if("resource_rules")
			client.rules()
		if("resource_wiki")
			client.wiki("")
		if("resource_changelog")
			client.changelog()
		if("admin_notice")
			client.admin_notice()
		if("toggle_ignore")
			toggle_ignore(payload["ref"], payload["key"])

	return TRUE

/datum/escape_menu/proc/send_suicide_icon()
	generate_escape_menu_suicide_icon()
	send_update(list("suicideIcon" = GLOB.escape_menu_suicide_icon_base64))

/// Przełącza ignorowanie gracza w OOC - online po REF klienta (żeby nie zdradzać kluczy adminów
/// pod fałszywym kluczem), offline po zapisanym kluczu.
/datum/escape_menu/proc/toggle_ignore(ref, ignored_key)
	var/list/ignoring = client.prefs?.ignoring
	if(!islist(ignoring))
		return
	var/displayed_key
	if(ref)
		var/client/target = locate(ref) in GLOB.clients
		if(!target || target == client)
			return
		ignored_key = target.key
		displayed_key = target.holder?.fakekey || target.key
	else
		if(!ignored_key || !(ignored_key in ignoring))
			return
		displayed_key = ignored_key
	if(ignored_key in ignoring)
		ignoring -= ignored_key
	else
		ignoring |= ignored_key
	client.prefs.save_preferences()
	to_chat(client, "[(ignored_key in ignoring) ? "Ignorujesz teraz" : "Już nie ignorujesz"] gracza [displayed_key] na kanale OOC.")
	send_update(list(
		"admins" = build_admin_list(),
		"players" = build_player_list(),
		"ignoredOffline" = build_ignored_offline(),
	))

// Assety menu

/datum/asset/simple/namespaced/escape_menu_font
	assets = list(
		"Pixellari.ttf" = 'aquila/interface/fonts/Pixellari.ttf',
		"Grand9K_Pixel.ttf" = 'aquila/interface/fonts/Grand9K_Pixel.ttf',
	)
	parents = list(
		"fonts.css" = 'tgui/packages/tgui-escape-menu/styles/fonts.css',
	)

/datum/asset/simple/namespaced/escape_menu_sounds
	assets = list(
		"esc_open.ogg" = 'aquila/sound/misc/escape_menu/esc_open.ogg',
		"esc_middle.ogg" = 'aquila/sound/misc/escape_menu/esc_middle.ogg',
		"esc_close.ogg" = 'aquila/sound/misc/escape_menu/esc_close.ogg',
	)

/datum/asset/spritesheet/escape_menu_icons
	name = "escape-menu-icons"

/datum/asset/spritesheet/escape_menu_icons/register()
	var/icon/icons_small = 'aquila/icons/hud/escape_menu_icons.dmi'
	for(var/state in icon_states(icons_small))
		Insert(state, icons_small, icon_state = state)
	var/icon/icons_large = 'aquila/icons/hud/escape_menu_leave_body.dmi'
	for(var/state in icon_states(icons_large))
		Insert("leave-[state]", icons_large, icon_state = state)
	return ..()

#undef SKIN_ESCAPE_MENU
#undef ESCAPE_MENU_ID
