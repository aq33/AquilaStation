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

/// Gracz jeszcze nie wybrał języka
/client/proc/needs_game_language()
	return prefs && !prefs.game_language_chosen

/// Okno wyboru języka (śpi do odpowiedzi; zamknięte bez wyboru zostawia gracza w lobby)
/client/proc/ask_game_language()
	if(asking_game_language || !needs_game_language())
		return
	asking_game_language = TRUE
	var/choice = tgui_alert(mob, "Wybierz wersję językową gry.\nChoose the game language.", "Język / Language", list("Polski", "English"))
	asking_game_language = FALSE
	if(!prefs || !choice)
		return
	prefs.choose_game_language(choice == "English" ? GAME_LANGUAGE_EN : GAME_LANGUAGE_PL)

/// Przycisk lobby, który wpuszcza do gry (gotowość, obserwowanie, późne dołączenie, wybór zawodu)
/proc/i18n_lobby_href_joins(list/href_list)
	if(href_list["ready"])
		return text2num(href_list["ready"]) != PLAYER_NOT_READY
	return !!(href_list["late_join"] || href_list["SelectedJob"])

/mob/dead/new_player/Login()
	. = ..()
	if(client?.needs_game_language() && !client.interviewee)
		INVOKE_ASYNC(client, TYPE_PROC_REF(/client, ask_game_language))

/mob/dead/new_player/Topic(href, href_list[])
	if(src == usr && client?.needs_game_language() && i18n_lobby_href_joins(href_list))
		to_chat(src, "<span class='warning'>Najpierw wybierz wersję językową. / Choose the game language first.</span>")
		INVOKE_ASYNC(client, TYPE_PROC_REF(/client, ask_game_language))
		return FALSE
	return ..()

// Menu pod Esc: przełącznik języka (przycisk pokazuje się, gdy menu dostanie gameLanguage)
/datum/escape_menu/on_message(type, payload, href_list)
	if(type == "action" && !islist(payload))
		return FALSE // bazowy handler czyta payload["action"]
	if(type == "action" && client && payload["action"] == "toggle_language")
		client.prefs?.choose_game_language(client.wants_english() ? GAME_LANGUAGE_PL : GAME_LANGUAGE_EN)
		return TRUE
	. = ..()
	if(type == "ready")
		send_update(list("gameLanguage" = client?.prefs?.game_language || GAME_LANGUAGE_PL))
