// Okno pagera drużyny (użycie w ręce): członkowie i ich stan, zadanie, ostatnie wiadomości
// i mapa taktyczna z pozycjami drużyny i znacznikami. Dowódca wydaje stąd rozkazy i stawia znaczniki.

#define SQUAD_MESSAGE_LOG_SIZE 15

/datum/squad
	/// Ostatnie wiadomości i rozkazy drużyny do okna pagera
	var/list/aq_message_log = list()

/datum/squad/proc/aq_log_message(sender_name, text, kind = "chat")
	aq_message_log += list(list(
		"time" = station_time_timestamp("hh:mm"),
		"sender" = sender_name,
		"text" = text,
		"kind" = kind,
	))
	if(length(aq_message_log) > SQUAD_MESSAGE_LOG_SIZE)
		aq_message_log.Cut(1, length(aq_message_log) - SQUAD_MESSAGE_LOG_SIZE + 1)

/datum/component/simple_teamchat/radio_dependent/squad/send_message(atom/movable/user, text, list/receipt_sound_override)
	. = ..()
	if(. == FALSE)
		return
	var/datum/squad/target_squad = squad || GLOB.squad_manager.get_squad(key)
	target_squad?.aq_log_message("[user]", html_decode(text))

/obj/item/squad_pager
	/// Wybrany poziom mapy w oknie
	var/aq_map_z

// Pełne nadpisanie (LEGACY_OVERRIDES.md): zamiast ostatniej wiadomości otwiera okno pagera
/obj/item/squad_pager/attack_self(mob/user)
	if(!squad_channel && squad)
		squad_channel = AddComponent(squad.squad_channel_type)
		squad_channel.squad = squad
	// Pager z autolatu nie ma drużyny, dopóki nie założy go ktoś z drużyny
	if(!global_access && !aq_view_squad(user))
		to_chat(user, "<span class='warning'>Pager nie jest przypisany do drużyny. Załóż go, będąc w drużynie.</span>")
		return
	ui_interact(user)

/obj/item/squad_pager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadPager", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/squad_pager/ui_state(mob/user)
	return GLOB.deep_inventory_state

/// Drużyna, którą pokazuje pager: drużyna noszącego, a gdy jej nie ma, drużyna pagera
/obj/item/squad_pager/proc/aq_view_squad(mob/user)
	var/mob/living/carbon/human/human_user = user
	if(istype(human_user) && human_user.squad)
		return human_user.squad
	return squad

/obj/item/squad_pager/ui_data(mob/user)
	var/list/data = list()
	var/datum/squad/view_squad = aq_view_squad(user)
	var/mob/living/carbon/human/human_user = user
	data["squad"] = view_squad ? view_squad.aq_squad_data() : null
	data["primary_objective"] = view_squad ? squad_role_pl(view_squad.role) : null
	data["is_leader"] = !!(view_squad && istype(human_user) && view_squad.leader == human_user)
	data["position"] = istype(human_user) && human_user.squad ? squad_position_pl(human_user.get_squad_position()) : null
	data["user_ref"] = REF(user)
	data["log"] = view_squad ? view_squad.aq_message_log : list()
	data["marker_types"] = aq_marker_types_data()
	data["map"] = aq_squad_map_data(user, aq_map_z, view_squad?.aq_active_levels())
	data["order_cooldown"] = view_squad ? view_squad.aq_order_cooldown_left() : 0
	data["tts"] = !!user.client?.prefs?.squad_tts
	data["tts_available"] = !!squad_tts_active()
	return data

/obj/item/squad_pager/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return FALSE
	var/datum/squad/view_squad = aq_view_squad(user)
	switch(action)
		if("select_z")
			aq_map_z = text2num(params["z"])
			return TRUE
		if("toggle_tts")
			if(!user.client?.prefs)
				return FALSE
			user.client.prefs.squad_tts = !user.client.prefs.squad_tts
			INVOKE_ASYNC(user.client.prefs, TYPE_PROC_REF(/datum/preferences, save_preferences))
			return TRUE
	if(!view_squad || view_squad.leader != user)
		return FALSE
	switch(action)
		if("order")
			if(!view_squad.aq_can_issue_order(user))
				return FALSE
			var/message = tgui_input_text(user, "Rozkaz dla drużyny [view_squad] (do [SQUAD_ORDER_MAX_LEN] znaków):", "Rozkaz", max_length = SQUAD_ORDER_MAX_LEN, multiline = TRUE, encode = FALSE)
			if(!message || view_squad.leader != user)
				return FALSE
			return view_squad.aq_issue_order(user, message)
		if("place_marker")
			return view_squad.aq_place_marker_from_map(user, params)
		if("clear_marker")
			return view_squad.aq_clear_marker(params["marker"])
	return FALSE

#undef SQUAD_MESSAGE_LOG_SIZE
