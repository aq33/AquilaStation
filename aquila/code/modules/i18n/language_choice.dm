// AQ - wybór wersji językowej: przy pierwszym wejściu na serwer (bez wyboru nie da się dołączyć
// do gry ani obserwować) i przełącznik w menu pod Esc (tgui/packages/tgui-escape-menu/pages/HomePage.tsx).
// Teksty okna wyboru są w obu językach, bo gracz jeszcze żadnego nie wybrał.

/datum/preferences
	/// Czy gracz sam wybrał język (zapisany wiersz w bazie albo wybór w tej rundzie)
	var/game_language_chosen = FALSE

/// Ustawia język gracza z jego wyboru, odświeża okna (on_changed) i zapisuje preferencje
/datum/preferences/proc/choose_game_language(language)
	if(!(language in GLOB.game_languages))
		return FALSE
	update_preference(GLOB.preference_entries[/datum/preference/choiced/game_language], language)
	game_language_chosen = TRUE
	save_preferences()
	return TRUE

/client
	/// Okno wyboru języka jest otwarte (bez drugiego naraz)
	var/asking_game_language = FALSE
	/// Otwarte okno wyboru języka (TGUI), zamykane też po wyborze w menu pod Esc
	var/datum/tgui_modal/game_language_modal
	/// Samouczek czeka na wybór języka (offer_tutorial() przed wyborem)
	var/tutorial_offer_pending = FALSE
	/// Changelog czeka na wybór języka (aggressive_changelog otwierał go przed oknem wyboru)
	var/changelog_pending = FALSE

/// Gracz jeszcze nie wybrał języka
/client/proc/needs_game_language()
	return prefs && !prefs.game_language_chosen

/// Najdłużej czekamy na gotowy panel czatu, zanim zapytamy mimo to (zepsuty panel nie blokuje gry)
#define GAME_LANGUAGE_CLIENT_WAIT (20 SECONDS)

/// Okno wyboru języka (śpi do odpowiedzi; zamknięte bez wyboru zostawia gracza w lobby)
/client/proc/ask_game_language()
	if(asking_game_language || !needs_game_language())
		return
	asking_game_language = TRUE
	// Klient musi najpierw skończyć start (client/New, panel czatu): wybór od razu odświeża okna (on_changed)
	var/wait_until = world.time + GAME_LANGUAGE_CLIENT_WAIT
	UNTIL(QDELETED(src) || tgui_panel?.is_ready() || world.time > wait_until)
	if(QDELETED(src))
		return
	var/message = "Wybierz wersję językową gry.\nChoose the game language.\nВыберите язык игры."
	var/title = "Język / Language / Язык"
	var/list/names = list()
	for(var/language in GLOB.game_languages)
		names += GLOB.game_language_names[language]
	var/choice
	var/opened = FALSE
	// Własny modal zamiast tgui_alert(): wybór w menu pod Esc musi móc go zamknąć (close_game_language_window)
	if(mob && (prefs?.toggles2 & PREFTOGGLE_2_TGUI_INPUT))
		game_language_modal = new(mob, message, title, names, 0, TRUE)
		game_language_modal.ui_interact(mob)
		if(SStgui.get_open_ui(mob, game_language_modal))
			opened = TRUE
			game_language_modal.wait()
			choice = game_language_modal?.choice
		QDEL_NULL(game_language_modal)
		if(QDELETED(src))
			return
	// Bez TGUI (wyłączone w preferencjach albo okno się nie otworzyło) zwykłe okno BYOND, inaczej bramka pytałaby bez końca
	if(!opened && mob && needs_game_language())
		// alert() ma najwyżej trzy przyciski: tyle, ile języków
		choice = alert(mob, message, title, GLOB.game_language_names[GAME_LANGUAGE_PL], GLOB.game_language_names[GAME_LANGUAGE_EN], GLOB.game_language_names[GAME_LANGUAGE_RU])
		if(QDELETED(src))
			return
	asking_game_language = FALSE
	if(!prefs || !choice)
		return
	for(var/language in GLOB.game_language_names)
		if(GLOB.game_language_names[language] == choice)
			prefs.choose_game_language(language)
			return

#undef GAME_LANGUAGE_CLIENT_WAIT

/// Przycisk lobby, który wpuszcza do gry (gotowość, obserwowanie, późne dołączenie, wybór zawodu)
/proc/i18n_lobby_href_joins(list/href_list)
	if(href_list["ready"])
		return text2num(href_list["ready"]) != PLAYER_NOT_READY
	return !!(href_list["late_join"] || href_list["SelectedJob"])

// Bramka: bez wyboru języka lobby się nie otwiera, gracz widzi tylko okno wyboru.
// Login() i inne odświeżenia lobby idą przez new_player_panel(), więc bramka jest tutaj.
/mob/dead/new_player/new_player_panel()
	if(client?.needs_game_language() && !client.interviewee)
		INVOKE_ASYNC(src, PROC_REF(language_gate))
		return
	return ..()

/// Pyta o język (aż do wyboru), potem otwiera lobby już w wybranym języku
/mob/dead/new_player/proc/language_gate()
	while(client?.needs_game_language())
		if(client.asking_game_language)
			return // okno już jest otwarte, lobby otworzy ten, kto je otworzył
		client.ask_game_language()
		if(QDELETED(src) || !client || client.mob != src)
			return
		if(client.needs_game_language())
			sleep(1 SECONDS) // zamknięte okno: zapytaj znowu, nie od razu
	if(!client || client.mob != src)
		return
	new_player_panel()
	if(client.changelog_pending)
		client.changelog_pending = FALSE
		INVOKE_ASYNC(client, TYPE_VERB_REF(/client, changelog))
	if(client.tutorial_offer_pending)
		client.tutorial_offer_pending = FALSE
		INVOKE_ASYNC(client, TYPE_PROC_REF(/client, offer_tutorial))

/mob/dead/new_player/Topic(href, href_list[])
	if(src == usr && client?.needs_game_language() && i18n_lobby_href_joins(href_list))
		to_chat(src, "<span class='warning'>Najpierw wybierz wersję językową. / Choose the game language first. / Сначала выберите язык игры.</span>")
		INVOKE_ASYNC(src, PROC_REF(language_gate)) // przez bramkę: po wyborze otwiera lobby
		return FALSE
	return ..()

// Menu pod Esc: wybór języka (przyciski pokazują się, gdy menu dostanie gameLanguage)
/datum/escape_menu/on_message(type, payload, href_list)
	if(type == "action" && !islist(payload))
		return FALSE // bazowy handler czyta payload["action"]
	if(type == "action" && client && payload["action"] == "set_language")
		if(!client.prefs?.choose_game_language(payload["language"]))
			return TRUE
		// język już wybrany: okno wyboru zamyka się, a bramka otwiera lobby
		QDEL_NULL(client.game_language_modal)
		return TRUE
	. = ..()
	if(type == "ready")
		send_update(list("gameLanguage" = client?.game_language() || GAME_LANGUAGE_PL, "gameLanguages" = GLOB.game_language_names))

// Samouczek proponujemy dopiero po wyborze języka (okno w wybranym języku, nie dwa okna naraz)
/client/offer_tutorial()
	if(needs_game_language())
		tutorial_offer_pending = TRUE // language_gate() zaproponuje po wyborze
		return
	return ..()

// Changelog (też aggressive_changelog przy wejściu) dopiero po wyborze języka: przed bramką nie pokazuje się nic
/client/changelog()
	if(needs_game_language() && isnewplayer(mob))
		changelog_pending = TRUE // language_gate() otworzy po wyborze
		return
	return ..()
