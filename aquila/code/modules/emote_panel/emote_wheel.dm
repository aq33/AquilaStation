// Koło emotek szybkiego wyboru: przycisk akcji w lewym górnym rogu otwiera radial (jak przy operacjach)
// tylko z emotkami, które gracz oznaczył gwiazdką w Panelu emotek. Wybór zapisuje się w preferencjach.

/// Ile emotek mieści się w kole, żeby radial nie robił się ogromny
#define EMOTE_WHEEL_MAX 12

/datum/preferences
	/// Klucze emotek wybranych do koła emotek, zapisywane w bazie (PREFERENCE_TAG_QUICK_EMOTES)
	var/list/quick_emotes = list()

/datum/preferences/proc/get_quick_emotes()
	RETURN_TYPE(/list)
	if(!islist(quick_emotes))
		quick_emotes = list()
	return quick_emotes

/// Dodaje albo usuwa emotkę z koła. Zwraca FALSE, gdy koło jest już pełne.
/datum/preferences/proc/toggle_quick_emote(emote_key)
	var/list/quick = get_quick_emotes()
	if(emote_key in quick)
		quick -= emote_key
	else
		if(length(quick) >= EMOTE_WHEEL_MAX)
			return FALSE
		quick += emote_key
	save_preferences()
	return TRUE

/datum/action/emote_wheel
	name = "Koło emotek"
	desc = "Szybki wybór emotek. Emotki do koła wybierasz gwiazdką w Panelu emotek."
	icon_icon = 'aquila/icons/hud/emote_wheel.dmi'
	button_icon_state = "emote_wheel"
	/// TRUE, póki radial jest otwarty, żeby nie otworzyć drugiego
	var/radial_open = FALSE

/datum/action/emote_wheel/Trigger()
	if(!..())
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(show_wheel), owner)
	return TRUE

/datum/action/emote_wheel/proc/show_wheel(mob/living/user)
	if(radial_open || !user.client)
		return
	var/list/choices = list()
	for(var/emote_key in user.client.prefs.get_quick_emotes())
		var/datum/emote/emote = GLOB.emote_list[emote_key]?[1]
		if(!emote || !emote.can_run_emote(user, status_check = FALSE, intentional = FALSE))
			continue
		choices[emote_key] = get_emote_image(emote)
	var/static/image/edit_image = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_use")
	edit_image.name = "Wybierz emotki do koła"
	choices["edit"] = edit_image

	if(length(choices) == 1)
		to_chat(user, "<span class='notice'>Koło emotek jest puste. Oznacz emotki gwiazdką w Panelu emotek (do [EMOTE_WHEEL_MAX]).</span>")
		open_emote_panel(user)
		return

	radial_open = TRUE
	var/picked = show_radial_menu(user, user, choices, tooltips = TRUE)
	radial_open = FALSE
	if(!picked || QDELETED(user))
		return
	if(picked == "edit")
		open_emote_panel(user)
		return
	var/datum/emote/emote = GLOB.emote_list[picked]?[1]
	if(!emote)
		return
	var/emote_param
	if(emote.message_param && tgui_alert(user, "Dodać parametr do emotki?", emote.name, list("Nie", "Tak")) == "Tak")
		emote_param = tgui_input_text(user, "Dodaj parametr do emotki...", emote.message_param)
	user.emote(picked, message = emote_param, intentional = TRUE)

/// Kafelek koła: nazwa emotki drobnym tekstem, pełna nazwa w podpowiedzi
/datum/action/emote_wheel/proc/get_emote_image(datum/emote/emote)
	var/static/list/image/images_by_key = list()
	if(images_by_key[emote.key])
		return images_by_key[emote.key]
	var/image/emote_image = image(icon = 'icons/effects/effects.dmi', icon_state = "nothing")
	emote_image.maptext_width = 64
	emote_image.maptext_height = 32
	emote_image.maptext_x = -16
	emote_image.maptext_y = 4
	emote_image.maptext = MAPTEXT(CENTER(capitalize(emote.name)))
	emote_image.name = capitalize(emote.name)
	images_by_key[emote.key] = emote_image
	return emote_image

/datum/action/emote_wheel/proc/open_emote_panel(mob/living/user)
	user.emote_panel()

// Gwiazdki w Panelu emotek

/datum/emote_panel/ui_data(mob/user)
	var/list/data = list()
	data["quick"] = user.client?.prefs?.get_quick_emotes() || list()
	data["quick_max"] = EMOTE_WHEEL_MAX
	return data

/datum/emote_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || action != "toggle_quick")
		return
	var/emote_key = params["emote_key"]
	var/datum/preferences/prefs = ui.user.client?.prefs
	if(!prefs || isnull(emote_key) || !GLOB.emote_list[emote_key])
		return
	if(!prefs.toggle_quick_emote(emote_key))
		to_chat(ui.user, "<span class='warning'>Koło emotek jest pełne (najwyżej [EMOTE_WHEEL_MAX]).</span>")
	return TRUE

/mob/living/Login()
	. = ..()
	if(!client)
		return
	for(var/datum/action/emote_wheel/existing in actions)
		return
	var/datum/action/emote_wheel/wheel = new(src)
	wheel.Grant(src)

#undef EMOTE_WHEEL_MAX
