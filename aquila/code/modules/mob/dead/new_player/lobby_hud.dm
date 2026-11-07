// Lobby w stylu tgstation: przyciski z grafiką tg (icons/hud/lobby/png/, CC BY-SA 3.0) na ekranie tytułowym,
// roleta przy zwijaniu menu i telewizorek z odliczaniem po prawej. W tg to strona HTML w przeglądarce nad mapą;
// u nas obiekty ekranowe, bez zmian w skin.dmf. Akcje idą przez dawny Topic() nowego gracza.
// Polskie napisy na wyświetlaczach: aquila/icons/hud/lobby.dmi, angielski oryginał: aquila/icons/hud/en/lobby.dmi.
// Wszystkie grafiki leżą na płótnie 176x144 przyklejone do lewego górnego rogu, a pozycje są jak w tg
// (piksele od środka górnej krawędzi ekranu do lewego górnego rogu grafiki).
// Dźwięki menu z tg (sound/misc/menu/): ui_select - sadboysuss, CC BY-SA; rollup/rolldown - przeróbka
// „Yunon YN500 Camera Shutter” (yfjesse, freesound.org/s/579884, CC0).

#define LOBBY_CANVAS_HEIGHT 144
#define LOBBY_SHUTTER_TRAVEL 143
#define LOBBY_COLLAPSE_SLIDE 82

/// screen_loc dla grafiki, której lewy górny róg jest `left` px od środka i `top` px pod górną krawędzią ekranu
/proc/aq_lobby_screen_loc(left, top, anchor_x = "CENTER")
	// CENTER: lewa krawędź środkowego kafelka jest 16 px na lewo od środka ekranu; RIGHT: lewa krawędź ostatniego kafelka
	var/x_from_tile = anchor_x == "CENTER" ? left + 16 : left + 32
	var/x_tiles = round(x_from_tile / 32)
	var/x_px = x_from_tile - x_tiles * 32
	// dół grafiki względem dolnej krawędzi górnego kafelka (w górę dodatnio)
	var/y_from_tile = 32 - (top + LOBBY_CANVAS_HEIGHT)
	var/y_tiles = round(y_from_tile / 32)
	var/y_px = y_from_tile - y_tiles * 32
	return "[anchor_x][x_tiles >= 0 ? "+[x_tiles]" : "[x_tiles]"]:[x_px],TOP[y_tiles >= 0 ? "+[y_tiles]" : "[y_tiles]"]:[y_px]"

/mob/dead/new_player
	/// Menu lobby w stylu tg (obiekty ekranowe)
	var/datum/aq_lobby_hud/lobby_hud

/// Pokazuje (albo odświeża) menu lobby; woła je new_player_panel() w lobby_menu.dm
/mob/dead/new_player/proc/show_lobby_hud()
	if(!client)
		return
	if(!lobby_hud || lobby_hud.client_ref != client)
		QDEL_NULL(lobby_hud)
		lobby_hud = new(src)
	lobby_hud.refresh()

/mob/dead/new_player/Logout()
	QDEL_NULL(lobby_hud)
	return ..()

/mob/dead/new_player/Destroy()
	QDEL_NULL(lobby_hud)
	return ..()

/// Gracz siedzi na tym samym komputerze co serwer (przycisk „START!” jak w tg tylko lokalnie)
/proc/aq_client_is_localhost(client/viewer)
	return !viewer.address || viewer.address == "127.0.0.1" || viewer.address == "::1"

/datum/aq_lobby_hud
	var/mob/dead/new_player/owner
	var/client/client_ref
	/// Wszystkie elementy na ekranie gracza
	var/list/atom/movable/screen/aq_lobby/elements = list()
	/// Elementy chowane pod roletą
	var/list/atom/movable/screen/aq_lobby/collapsible = list()
	var/atom/movable/screen/aq_lobby/shutter
	var/atom/movable/screen/aq_lobby/button/collapse/collapse_button
	var/atom/movable/screen/aq_lobby/tv/tv
	var/collapsed = FALSE
	var/animating = FALSE

/datum/aq_lobby_hud/New(mob/dead/new_player/player)
	owner = player
	client_ref = player.client
	var/lobby_icon = client_ref.wants_english() ? 'aquila/icons/hud/en/lobby.dmi' : 'aquila/icons/hud/lobby.dmi'
	add_element(/atom/movable/screen/aq_lobby/background, lobby_icon, -61, 0, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/ready, lobby_icon, -65, 8, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/join, lobby_icon, -58, 13, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/observe, lobby_icon, -54, 40, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/character_setup, lobby_icon, -54, 70, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/small/tutorial, lobby_icon, -54, 122, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/small/poll, lobby_icon, -26, 122, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/small/crew_manifest, lobby_icon, 2, 122, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/small/settings, lobby_icon, 29, 122, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/small/changelog, lobby_icon, 57, 122, TRUE)
	add_element(/atom/movable/screen/aq_lobby/button/start_now, lobby_icon, -54, 146, TRUE)
	// roleta stoi w pozycji „zasłoniętej” i jest odsunięta w górę przez pixel_y: obiekt ekranu poza widokiem poszerzyłby mapę
	shutter = add_element(/atom/movable/screen/aq_lobby/shutter, lobby_icon, -73, 0, FALSE)
	collapse_button = add_element(/atom/movable/screen/aq_lobby/button/collapse, lobby_icon, -54, 82, FALSE)
	// płótno (176 px) całe w widoku, a obrazek telewizorka (128 px) dosunięty do prawej krawędzi przez pixel_x
	tv = add_element(/atom/movable/screen/aq_lobby/tv, lobby_icon, -176, 32, FALSE, "RIGHT")
	tv.pixel_x = 48
	client_ref.screen += elements
	START_PROCESSING(SSprocessing, src)

/datum/aq_lobby_hud/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(client_ref)
		client_ref.screen -= elements
	QDEL_LIST(elements)
	collapsible = null
	shutter = null
	collapse_button = null
	tv = null
	owner = null
	client_ref = null
	return ..()

/datum/aq_lobby_hud/proc/add_element(path, lobby_icon, left, top, can_collapse, anchor_x = "CENTER")
	var/atom/movable/screen/aq_lobby/element = new path(null, src)
	element.icon = lobby_icon
	element.screen_loc = aq_lobby_screen_loc(left, top, anchor_x)
	elements += element
	if(can_collapse)
		collapsible += element
	element.update_state()
	return element

/datum/aq_lobby_hud/process(delta_time)
	if(QDELETED(owner) || owner.client != client_ref)
		qdel(src)
		return PROCESS_KILL
	refresh()

/// Odświeża widoczność i stan przycisków oraz telewizorek
/datum/aq_lobby_hud/proc/refresh()
	for(var/atom/movable/screen/aq_lobby/element as anything in elements)
		element.update_state()

/datum/aq_lobby_hud/proc/game_phase()
	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP)
			return "startup"
		if(GAME_STATE_PREGAME)
			return "pregame"
		if(GAME_STATE_SETTING_UP)
			return "setting_up"
		if(GAME_STATE_PLAYING)
			return "playing"
	return "postgame"

/datum/aq_lobby_hud/proc/toggle_collapse()
	if(animating)
		return
	animating = TRUE
	// roleta zjeżdża, menu się chowa (albo wraca), roleta odjeżdża
	shutter.alpha = 255
	animate(shutter, pixel_y = 0, time = 4, easing = CUBIC_EASING | EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(finish_collapse)), 6)
	SEND_SOUND(client_ref, sound('aquila/sound/misc/menu_rolldown.ogg', volume = 40))

/datum/aq_lobby_hud/proc/finish_collapse()
	if(QDELETED(src))
		return
	collapsed = !collapsed
	for(var/atom/movable/screen/aq_lobby/element as anything in collapsible)
		element.invisibility = collapsed ? INVISIBILITY_ABSTRACT : 0
	animate(collapse_button, pixel_y = collapsed ? LOBBY_COLLAPSE_SLIDE : 0, time = 4)
	collapse_button.update_state()
	animate(shutter, pixel_y = LOBBY_SHUTTER_TRAVEL, time = 4, easing = CUBIC_EASING | EASE_IN)
	animate(alpha = 0, time = 0)
	SEND_SOUND(client_ref, sound('aquila/sound/misc/menu_rollup.ogg', volume = 40))
	addtimer(VARSET_CALLBACK(src, animating, FALSE), 4)
	refresh()

/// Akcja przycisku (jak w tg), przez dawny Topic() nowego gracza
/datum/aq_lobby_hud/proc/act(action, list/modifiers)
	var/mob/dead/new_player/player = owner
	if(QDELETED(player) || !player.client || player.client.interviewee)
		return
	switch(action)
		if("ready_toggle")
			player.Topic(null, list("ready" = player.ready == PLAYER_READY_TO_PLAY ? PLAYER_NOT_READY : PLAYER_READY_TO_PLAY))
		if("join")
			player.Topic(null, list("late_join" = LAZYACCESS(modifiers, CTRL_CLICK) ? "override" : 1))
		if("observe")
			player.Topic(null, list("ready" = PLAYER_READY_TO_OBSERVE))
		if("character_setup")
			player.client.prefs.open_menu(player, PREFERENCE_TAB_CHARACTER_PREFERENCES)
		if("settings")
			player.client.prefs.open_menu(player, PREFERENCE_TAB_GAME_PREFERENCES)
		if("changelog")
			player.client.changelog()
		if("crew_manifest")
			player.ViewManifest()
		if("poll")
			player.Topic(null, list("showpoll" = 1))
		if("tutorial")
			player.open_tutorial_menu()
		if("start_now")
			if(!aq_client_is_localhost(player.client) || !check_rights_for(player.client, R_SERVER))
				return
			SSticker.start_immediately = TRUE
			if(SSticker.current_state == GAME_STATE_STARTUP)
				to_chat(player, "<span class='adminnotice'>Serwer jeszcze się uruchamia, runda zacznie się, gdy tylko będzie to możliwe.</span>")
	if(!QDELETED(src))
		refresh()

/// Tekst telewizorka jak w tg
/datum/aq_lobby_hud/proc/tv_lines()
	var/phase = game_phase()
	var/players = length(GLOB.clients)
	if(phase == "postgame")
		return list("Koniec gry,", "zaraz restart")
	if(phase == "playing")
		return list(SSmapping.config?.map_name || "Ładowanie...", "Graczy: [players]", "Zmiana: [station_time_timestamp("hh:mm")]")
	var/time_left = SSticker.GetTimeLeft()
	var/countdown = time_left > 0 ? "[round(time_left / 10)] s" : (time_left == -10 ? "WSTRZYMANE" : "ZARAZ")
	var/list/lines = list("Start za [countdown]", "Graczy: [players]")
	if(client_ref?.holder)
		var/admins_ready = 0
		for(var/client/admin as anything in GLOB.admins)
			var/mob/dead/new_player/admin_player = admin.mob
			if(istype(admin_player) && admin_player.ready == PLAYER_READY_TO_PLAY)
				admins_ready++
		lines += "Gotowych: [SSticker.totalPlayersReady]"
		lines += "Admini: [admins_ready] / [length(GLOB.admins)]"
	return lines

////////////////////////////////////////////////////////////////////
//							ELEMENTY								  //
////////////////////////////////////////////////////////////////////

/atom/movable/screen/aq_lobby
	plane = SPLASHSCREEN_PLANE
	layer = SPLASHSCREEN_LAYER + 1
	var/datum/aq_lobby_hud/lobby

/atom/movable/screen/aq_lobby/Initialize(mapload, datum/aq_lobby_hud/new_lobby)
	. = ..()
	lobby = new_lobby

/atom/movable/screen/aq_lobby/Destroy()
	lobby = null
	return ..()

/// Stan grafiki i widoczność (wołane co sekundę i po każdej akcji)
/atom/movable/screen/aq_lobby/proc/update_state()
	return

/atom/movable/screen/aq_lobby/background
	name = "Lobby"
	icon_state = "background"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/aq_lobby/shutter
	name = "Roleta"
	icon_state = "shutter"
	pixel_y = LOBBY_SHUTTER_TRAVEL
	alpha = 0
	layer = SPLASHSCREEN_LAYER + 5
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/aq_lobby/button
	layer = SPLASHSCREEN_LAYER + 3
	/// Bazowy stan grafiki (z wariantami _highlighted, _pressed, _disabled)
	var/base_state
	/// Akcja wysyłana do lobby
	var/action
	var/hovered = FALSE
	var/enabled = TRUE
	/// Przycisk w ogóle widoczny w tej fazie gry
	var/shown = TRUE
	/// Czy grafika ma wariant _disabled
	var/has_disabled_state = FALSE

/atom/movable/screen/aq_lobby/button/update_state()
	shown = should_show()
	enabled = is_enabled()
	if(!shown)
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		icon_state = ""
		return
	mouse_opacity = MOUSE_OPACITY_ICON
	if(!enabled)
		icon_state = has_disabled_state ? "[base_state]_disabled" : base_state
	else
		icon_state = hovered ? "[base_state]_highlighted" : base_state
	update_overlays_lobby()

/atom/movable/screen/aq_lobby/button/proc/should_show()
	return TRUE

/atom/movable/screen/aq_lobby/button/proc/is_enabled()
	return TRUE

/atom/movable/screen/aq_lobby/button/proc/update_overlays_lobby()
	return

/atom/movable/screen/aq_lobby/button/MouseEntered(location, control, params)
	. = ..()
	hovered = TRUE
	update_state()
	if(shown && enabled)
		SEND_SOUND(usr, sound('aquila/sound/misc/menu_select.ogg', volume = 25))

/atom/movable/screen/aq_lobby/button/MouseExited(location, control, params)
	. = ..()
	hovered = FALSE
	update_state()

/atom/movable/screen/aq_lobby/button/Click(location, control, params)
	if(!shown || !enabled || !lobby || usr != lobby.owner)
		return
	if(lobby.collapsed && !istype(src, /atom/movable/screen/aq_lobby/button/collapse))
		return
	flick("[base_state]_pressed", src)
	on_click(params2list(params))

/atom/movable/screen/aq_lobby/button/proc/on_click(list/modifiers)
	lobby.act(action, modifiers)

/atom/movable/screen/aq_lobby/button/ready
	name = "Gotowość"
	base_state = "not_ready"
	action = "ready_toggle"

/atom/movable/screen/aq_lobby/button/ready/should_show()
	var/phase = lobby.game_phase()
	return phase == "pregame" || phase == "startup"

/atom/movable/screen/aq_lobby/button/ready/update_state()
	base_state = lobby.owner?.ready == PLAYER_READY_TO_PLAY ? "ready" : "not_ready"
	name = base_state == "ready" ? "Gotowy (kliknij, żeby się wycofać)" : "Niegotowy (kliknij, żeby zgłosić gotowość)"
	return ..()

/atom/movable/screen/aq_lobby/button/join
	name = "Dołącz do gry"
	base_state = "join_game"
	action = "join"

/atom/movable/screen/aq_lobby/button/join/should_show()
	var/phase = lobby.game_phase()
	return phase == "setting_up" || phase == "playing"

/atom/movable/screen/aq_lobby/button/observe
	name = "Obserwuj"
	base_state = "observe"
	action = "observe"
	has_disabled_state = TRUE

/atom/movable/screen/aq_lobby/button/observe/is_enabled()
	return SSticker.current_state > GAME_STATE_STARTUP

/atom/movable/screen/aq_lobby/button/character_setup
	name = "Ustaw postać"
	base_state = "character_setup"
	action = "character_setup"
	has_disabled_state = TRUE

/atom/movable/screen/aq_lobby/button/character_setup/is_enabled()
	return length(SSjob.occupations) > 0

/atom/movable/screen/aq_lobby/button/small
	layer = SPLASHSCREEN_LAYER + 6

/atom/movable/screen/aq_lobby/button/small/tutorial
	name = "Samouczek"
	base_state = "tutorial"
	action = "tutorial"

/atom/movable/screen/aq_lobby/button/small/poll
	name = "Ankiety"
	base_state = "poll"
	action = "poll"
	has_disabled_state = TRUE

/atom/movable/screen/aq_lobby/button/small/poll/is_enabled()
	return lobby.owner?.lobby_polls_available

/atom/movable/screen/aq_lobby/button/small/poll/update_overlays_lobby()
	cut_overlays()
	if(lobby.owner?.lobby_new_polls)
		add_overlay(mutable_appearance(icon, "new_poll"))
		name = "Ankiety (nowe!)"
	else
		name = "Ankiety"

/atom/movable/screen/aq_lobby/button/small/crew_manifest
	name = "Lista załogi"
	base_state = "crew_manifest"
	action = "crew_manifest"

/atom/movable/screen/aq_lobby/button/small/settings
	name = "Ustawienia gry"
	base_state = "settings"
	action = "settings"
	has_disabled_state = TRUE

/atom/movable/screen/aq_lobby/button/small/settings/is_enabled()
	return length(SSjob.occupations) > 0

/atom/movable/screen/aq_lobby/button/small/changelog
	name = "Lista zmian"
	base_state = "changelog"
	action = "changelog"

/atom/movable/screen/aq_lobby/button/start_now
	name = "Rozpocznij rundę teraz"
	base_state = "start_now"
	action = "start_now"

/atom/movable/screen/aq_lobby/button/start_now/should_show()
	var/client/viewer = lobby.client_ref
	return viewer && aq_client_is_localhost(viewer) && check_rights_for(viewer, R_SERVER) && SSticker.current_state <= GAME_STATE_PREGAME

/atom/movable/screen/aq_lobby/button/collapse
	name = "Zwiń menu"
	base_state = "collapse"
	layer = SPLASHSCREEN_LAYER + 2

/atom/movable/screen/aq_lobby/button/collapse/update_state()
	base_state = lobby.collapsed ? "expand" : "collapse"
	name = lobby.collapsed ? "Rozwiń menu" : "Zwiń menu"
	return ..()

/atom/movable/screen/aq_lobby/button/collapse/on_click(list/modifiers)
	lobby.toggle_collapse()

/// Lampka gotowości na sznurku rolety
/atom/movable/screen/aq_lobby/button/collapse/update_overlays_lobby()
	cut_overlays()
	var/blip
	if(lobby.game_phase() != "pregame" && lobby.game_phase() != "startup")
		blip = "ready_blip_disabled"
	else
		blip = lobby.owner?.ready == PLAYER_READY_TO_PLAY ? "ready_blip_ready" : "ready_blip_not_ready"
	add_overlay(mutable_appearance(icon, blip))

/atom/movable/screen/aq_lobby/tv
	name = "Stan serwera"
	icon_state = "newplayer"
	layer = SPLASHSCREEN_LAYER + 3
	maptext_x = 14
	maptext_y = LOBBY_CANVAS_HEIGHT - 28 - 50
	maptext_width = 80
	maptext_height = 50

/atom/movable/screen/aq_lobby/tv/Initialize(mapload, datum/aq_lobby_hud/new_lobby)
	. = ..()
	add_overlay(mutable_appearance(icon, "newplayer_overlay"))
	add_overlay(mutable_appearance(icon, "scanline"))

/atom/movable/screen/aq_lobby/tv/update_state()
	if(!lobby)
		return
	maptext = MAPTEXT("<span style='color:#8CF0B4;text-align:center;font-size:6px'>[jointext(lobby.tv_lines(), "<br>")]</span>")

#undef LOBBY_CANVAS_HEIGHT
#undef LOBBY_SHUTTER_TRAVEL
#undef LOBBY_COLLAPSE_SLIDE
