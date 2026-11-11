// Rozkazy drużyny: dowódca (z pagerem) albo XO z konsoli wysyła tekst, który drużyna widzi na ekranie
// z portretem nadawcy i słyszy przez TTS (squad_tts.dm). Odstęp 30 s na nadawcę jak w TGMC.

/mob/living
	/// Kiedy ten nadawca może wydać następny rozkaz na ekran
	var/aq_next_squad_order = 0
	/// Kiedy ten nadawca może postawić następny znacznik
	var/aq_next_squad_marker = 0

/// Czy nadawca może już wydać rozkaz; sprawdzane przed oknem z tekstem, żeby wpisany rozkaz nie przepadał
/mob/living/proc/aq_can_issue_order()
	if(world.time < aq_next_squad_order)
		to_chat(src, "<span class='warning'>Następny rozkaz możesz wydać za [DisplayTimeText(aq_next_squad_order - world.time)].</span>")
		return FALSE
	return TRUE

/// Wysyła rozkaz na ekran drużyny. from_console = XO z konsoli (bez wymogu pagera).
/datum/squad/proc/aq_issue_order(mob/living/sender, message, from_console = FALSE)
	if(!sender || !message)
		return FALSE
	if(!sender.aq_can_issue_order())
		return FALSE
	message = trim(replacetext(copytext_char(message, 1, SQUAD_ORDER_MAX_LEN + 1), "\n", " "))
	if(!length(message))
		return FALSE
	if(CHAT_FILTER_CHECK(message))
		to_chat(sender, "<span class='warning'>Rozkaz zawiera zakazane słowo.</span>")
		return FALSE
	sender.aq_next_squad_order = world.time + SQUAD_ORDER_COOLDOWN
	var/title = from_console ? "Wiadomość z CIC od: [sender.real_name]" : "Rozkaz dowódcy drużyny [name]"
	log_say("[key_name(sender)] gave an order to squad [name]: [message]")
	var/span_style = squad_channel?.text_span_style || "sciradio"
	for(var/mob/living/carbon/human/member as anything in members)
		if(member.client && member.aq_has_squad_pager())
			to_chat(member, "<span class='[span_style]'><b>\[[name]\] ROZKAZ ([sender.real_name]):</b> [html_encode(message)]</span>")
	if(from_console)
		to_chat(sender, "<span class='[span_style]'><b>\[[name]\] Wysłano rozkaz:</b> [html_encode(message)]</span>")
	aq_squad_screen_alert(message, title, sender, play_tts = TRUE)
	aq_log_message(sender.real_name, message, "order")
	return TRUE

// Dowódca dostaje akcje rozkazu i znacznika razem ze stanowiskiem
/datum/squad
	var/datum/action/innate/aq_squad_order/aq_order_action
	var/datum/action/innate/aq_squad_marker/aq_marker_action

/datum/squad/set_leader(mob/living/carbon/human/H)
	. = ..()
	if(!leader)
		return
	if(!aq_order_action)
		aq_order_action = new(src)
	if(!aq_marker_action)
		aq_marker_action = new(src)
	aq_order_action.Grant(leader)
	aq_marker_action.Grant(leader)

/datum/squad/unset_leader(mob/living/carbon/human/H)
	var/mob/living/carbon/human/old_leader = leader
	. = ..()
	if(old_leader && leader != old_leader)
		aq_order_action?.Remove(old_leader)
		aq_marker_action?.Remove(old_leader)
		aq_marker_action?.aq_stop_targeting(old_leader)

/datum/action/innate/aq_squad_order
	name = "Wydaj rozkaz drużynie"
	desc = "Rozkaz pojawi się na ekranie każdego członka drużyny z pagerem, z twoim portretem i głosem. Raz na 30 sekund."
	icon_icon = 'aquila/icons/squads/actions.dmi'
	button_icon_state = "order"

/datum/action/innate/aq_squad_order/Trigger()
	var/datum/squad/squad = target
	var/mob/living/carbon/human/user = owner
	if(!istype(squad) || !istype(user) || user.stat != CONSCIOUS)
		return FALSE
	if(squad.leader != user)
		to_chat(user, "<span class='warning'>Nie dowodzisz już drużyną [squad].</span>")
		return FALSE
	if(!user.aq_has_squad_pager())
		to_chat(user, "<span class='warning'>Potrzebujesz pagera drużyny, żeby wydawać rozkazy.</span>")
		return FALSE
	if(!user.aq_can_issue_order())
		return FALSE
	var/message = tgui_input_text(user, "Rozkaz dla drużyny [squad] (do [SQUAD_ORDER_MAX_LEN] znaków):", "Rozkaz", max_length = SQUAD_ORDER_MAX_LEN, multiline = TRUE, encode = FALSE)
	if(!message || QDELETED(src) || squad.leader != user)
		return FALSE
	return squad.aq_issue_order(user, message)
