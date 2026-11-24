// AQUILA - NIFSoft „Poemat Wspólnych Dusz”: nosiciele NIF-ów, którzy staną obok siebie, wymieniają się krótkimi wiadomościami („wersami”).
// Port z Monkestation (nifsofts/soul_poem.dm), bez zapisu nazwy i wiadomości między rundami.

/obj/item/disk/nifsoft_uploader/soul_poem
	loaded_nifsoft = /datum/nifsoft/soul_poem

/datum/nifsoft/soul_poem
	name = "Poemat Wspólnych Dusz"
	program_desc = "Poemat Wspólnych Dusz był pierwszym zleceniem, jakie przyjął Altspace Coven, rzadkim przypadkiem jego udziału w tworzeniu NIFSoftów. Zamówiła go działająca wtedy w podziemiu grupa imprezowiczów jako „zaraźliwy” program szerzący pokój, miłość, jedność i szacunek. Nosiciele z tym programem bez udziału woli wymieniają się „wersami”: drobnymi fragmentami własnego pola nanomaszyn, niosącymi wiadomość ustawioną przez nosiciela. Bywa to prawdziwa poezja, krótki życiorys albo zwykła nadzieja na poznanie innych użytkowników NIF-ów. Każda wymiana to fizyczne wspomnienie drugiej osoby, więc starzy „poeci” otoczeni są tęczą zebranych wiadomości."
	purchase_price = 0 // przychodzi za darmo z NIF-em
	buying_category = NIFSOFT_CATEGORY_FUN
	ui_icon = "scroll"

	/// Czy program wysyła wiadomość
	var/transmitting_data = TRUE
	/// Czy program przyjmuje wiadomości
	var/receiving_data = TRUE
	/// Podpis wysyłanej wiadomości
	var/transmitted_name = ""
	/// Treść wysyłanej wiadomości
	var/transmitted_message = ""
	/// Identyfikator nadawcy, żeby jedna osoba nie zapchała listy
	var/transmitted_identifier = ""

	/// Otrzymane wiadomości
	var/list/message_list = list()
	/// Pole, które wykrywa innych nosicieli
	var/datum/proximity_monitor/advanced/soul_poem/proximity_datum

/datum/nifsoft/soul_poem/New()
	. = ..()
	if(QDELETED(src))
		return

	if(!transmitted_name)
		transmitted_name = linked_mob.name

	if(!transmitted_message)
		transmitted_message = "Cześć, jestem [transmitted_name], miło cię poznać!"

	transmitted_identifier = REF(src) // anonimowy: identyfikator trafia w danych okna do innych graczy, więc nie ckey

	add_message("soul_poem_nifsoft", name, "Witaj, świecie")
	proximity_datum = new(linked_mob, 1)
	proximity_datum.parent_nifsoft = WEAKREF(src)

/datum/nifsoft/soul_poem/Destroy()
	QDEL_NULL(proximity_datum)
	SStgui.close_uis(src)
	return ..()

/**
 * Dopisuje wiadomość do listy. Od jednego nadawcy trzymamy tylko najnowszą.
 *
 * * sender_identifier - kto wysłał (anonimowy identyfikator programu nadawcy), żeby ta sama osoba nie dodała wielu wiadomości
 * * received_name - podpis wiadomości
 * * received_message - treść
 */
/datum/nifsoft/soul_poem/proc/add_message(sender_identifier, received_name, received_message)
	if(!received_message || !receiving_data)
		return FALSE

	var/message_name = received_name || "Nieznany użytkownik"

	for(var/list/message as anything in message_list)
		if(message["identifier"] == sender_identifier)
			message["sender_name"] = message_name
			message["message"] = received_message
			message["timestamp"] = station_time_timestamp()
			return TRUE

	message_list.Insert(1, list(list("identifier" = sender_identifier, "sender_name" = message_name, "message" = received_message, "timestamp" = station_time_timestamp())))
	return TRUE

/// Usuwa wiadomość od danego nadawcy. FALSE, jeśli jej nie ma
/datum/nifsoft/soul_poem/proc/remove_message(sender_identifier)
	if(!sender_identifier)
		return FALSE

	for(var/list/message as anything in message_list)
		if(message["identifier"] == sender_identifier)
			message_list -= list(message)
			return TRUE

	return FALSE

/datum/nifsoft/soul_poem/activate()
	. = ..()
	if(.)
		ui_interact(linked_mob)

/// Wysyła własną wiadomość do innego programu. FALSE, jeśli się nie udało
/datum/nifsoft/soul_poem/proc/send_message(datum/nifsoft/soul_poem/target_nifsoft)
	if(!transmitting_data || !target_nifsoft || !transmitted_message)
		return FALSE

	return target_nifsoft.add_message(transmitted_identifier, transmitted_name, transmitted_message)

/// Pole wymiany wiadomości wokół nosiciela
/datum/proximity_monitor/advanced/soul_poem
	/// Program, do którego należy pole
	var/datum/weakref/parent_nifsoft

/datum/proximity_monitor/advanced/soul_poem/on_entered(turf/source, atom/movable/entered)
	. = ..()
	if(host == entered || !ishuman(entered))
		return FALSE

	var/datum/nifsoft/soul_poem/receiving_nifsoft = parent_nifsoft?.resolve()
	if(!receiving_nifsoft || (!receiving_nifsoft.transmitting_data && !receiving_nifsoft.receiving_data))
		return FALSE

	var/mob/living/carbon/human/entered_human = entered
	var/datum/nifsoft/soul_poem/sending_nifsoft = entered_human.find_nifsoft(/datum/nifsoft/soul_poem)
	if(!sending_nifsoft)
		return FALSE

	sending_nifsoft.send_message(receiving_nifsoft)
	receiving_nifsoft.send_message(sending_nifsoft)
	return TRUE

/datum/nifsoft/soul_poem/ui_interact(mob/user, datum/tgui/ui)
	if(!linked_mob)
		return
	ui = SStgui.try_update_ui(linked_mob, src, ui)
	if(!ui)
		ui = new(linked_mob, src, "NifSoulPoem", name)
		ui.set_autoupdate(TRUE) // nowe wiadomości przychodzą same
		ui.open()

/datum/nifsoft/soul_poem/ui_status(mob/user, datum/ui_state/state)
	if(user != linked_mob)
		return UI_CLOSE
	return state.can_use_topic(src, user)

/datum/nifsoft/soul_poem/ui_data(mob/user)
	var/list/data = list()
	data["messages"] = message_list
	data["theme"] = ui_theme
	data["receiving_data"] = receiving_data
	data["transmitting_data"] = transmitting_data
	return data

/datum/nifsoft/soul_poem/ui_static_data(mob/user)
	var/list/data = list()
	data["name_to_send"] = transmitted_name
	data["text_to_send"] = transmitted_message
	return data

/datum/nifsoft/soul_poem/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_message")
			var/new_message = trim(copytext_char("[params["new_message"]]", 1, MAX_MESSAGE_LEN))
			if(!new_message)
				return FALSE
			transmitted_message = new_message
			update_static_data_for_all_viewers()
			return TRUE

		if("change_name")
			var/new_name = trim(copytext_char("[params["new_name"]]", 1, MAX_NAME_LEN))
			if(!new_name)
				return FALSE
			transmitted_name = new_name
			update_static_data_for_all_viewers()
			return TRUE

		if("remove_message")
			return remove_message(params["identifier"])

		if("toggle_transmitting")
			transmitting_data = !transmitting_data
			return TRUE

		if("toggle_receiving")
			receiving_data = !receiving_data
			return TRUE
