// AQUILA - jedna droga zmiany statusu karnego w kartotece.
// Konsola rekordów, HUD, obwód, GenPop, gułag, mandaty, timer celi i kaucja wołają set_criminal_status():
// zapis w rekordzie OCHRONY, wpis do historii, odświeżenie HUD-u, log, ogłoszenie na radiu Żandarmerii i sygnał.

/// Nazwy statusów do komunikatów (klucze zostają po angielsku, bo porównuje je kod)
GLOBAL_LIST_INIT(aq_criminal_status_names, list(
	"None" = "bez statusu",
	"Arrest" = "do aresztowania",
	"Search" = "do przeszukania",
	"Monitor" = "pod obserwacją",
	"Incarcerated" = "w areszcie",
	"Paroled" = "na zwolnieniu warunkowym",
	"Discharged" = "po odbyciu kary",
))

/proc/aq_criminal_status_name(status)
	return GLOB.aq_criminal_status_names[status] || status

/// Ogłoszenie przez automatyczny nadajnik telekomunikacji (sabotaż nadajnika wycina ogłoszenia). TRUE, gdy poszło w eter
/proc/aq_security_announce(message, list/channels = list(RADIO_CHANNEL_SECURITY))
	if(!message || !length(channels))
		return FALSE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AQ_SECURITY_ANNOUNCE, message, channels)
	for(var/obj/machinery/announcement_system/announcer as anything in GLOB.announcement_systems)
		if(!announcer.is_operational)
			continue
		for(var/channel in channels)
			announcer.radio.talk_into(announcer, message, channel)
		return TRUE
	return FALSE

/// Komunikat dla każdego, kto ma na sobie HUD ochrony (ostrzeżenia timera celi, nakazy)
/proc/aq_security_hud_message(message)
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		if(H.client && HAS_TRAIT(H, TRAIT_SECURITY_HUD))
			to_chat(H, "<span class='notice'><b>HUD ochrony:</b> [message]</span>")

/// Rekord ochrony dla rekordu ogólnego albo ochrony (wspólne pole „id”)
/datum/datacore/proc/aq_security_record_of(datum/data/record/record)
	if(!record)
		return null
	if(!(record in general)) // rekord ochrony (także spoza listy, np. z obwodu)
		return record
	return find_record("id", record.fields["id"], security)

/// Zmienia status karny. record: rekord ochrony albo ogólny. author: tekst (imię i stanowisko albo nazwa systemu).
/// Zwraca TRUE, gdy status się zmienił
/datum/datacore/proc/set_criminal_status(datum/data/record/record, new_status, author = "System", reason = "", announce = TRUE)
	var/datum/data/record/sec_record = aq_security_record_of(record)
	if(!sec_record || !new_status)
		return FALSE
	var/old_status = sec_record.fields["criminal"]
	if(old_status == new_status)
		return FALSE
	sec_record.fields["criminal"] = new_status
	var/name = sec_record.fields["name"]
	var/history = "[station_time_timestamp()] [author]: [aq_criminal_status_name(old_status)] → [aq_criminal_status_name(new_status)]"
	if(reason)
		history += ". Powód: [reason]"
	aq_add_record_comment(sec_record, history)
	log_game("Criminal status of [name] changed from [old_status] to [new_status] by [author][reason ? " ([reason])" : ""]")
	aq_refresh_sec_huds(name)
	if(announce)
		aq_announce_criminal_status(name, new_status, author, reason)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AQ_CRIMINAL_STATUS_CHANGED, sec_record, old_status, new_status, author, reason)
	return TRUE

/// Dopisuje komentarz com_N tak samo, jak robi to konsola rekordów
/datum/datacore/proc/aq_add_record_comment(datum/data/record/sec_record, text)
	var/counter = 1
	while(sec_record.fields["com_[counter]"])
		counter++
	sec_record.fields["com_[counter]"] = text

/// Odświeża ikonę statusu na HUD-zie osób o tym imieniu (albo wszystkich, gdy imię puste)
/datum/datacore/proc/aq_refresh_sec_huds(name)
	for(var/mob/living/carbon/human/H in GLOB.carbon_list) // carbon_list ma też małpy (Pun Pun)
		if(!name || H.get_face_name(H.get_id_name("")) == name || H.real_name == name)
			H.sec_hud_set_security_status()

/datum/datacore/proc/aq_announce_criminal_status(name, new_status, author, reason)
	var/message
	if(new_status == "None")
		message = "Kartoteka: [name] – status zdjęty ([author])."
	else
		message = "Kartoteka: [name] – [aq_criminal_status_name(new_status)] ([author])."
		if(reason)
			message += " Powód: [reason]."
	aq_security_announce(message, aq_criminal_status_channels(new_status))

/// Kanały ogłoszenia zmiany statusu: aresztowanie i osadzenie także Dowództwu
/proc/aq_criminal_status_channels(status)
	. = list(RADIO_CHANNEL_SECURITY)
	if(status in AQ_CRIMINAL_STATUSES_TO_COMMAND)
		. += RADIO_CHANNEL_COMMAND

/// Imię i stanowisko do pola „autor” z karty moba
/proc/aq_record_author(mob/user)
	if(!user)
		return "System"
	var/obj/item/card/id/id = user.get_idcard(TRUE)
	if(id?.registered_name)
		return id.assignment ? "[id.registered_name], [id.assignment]" : id.registered_name
	return user.name

/// Dostępy z karty moba (ręka albo slot ID); pusta lista, gdy nie ma karty
/proc/aq_user_access(mob/user)
	var/obj/item/card/id/id = user?.get_idcard(TRUE)
	return id ? id.GetAccess() : list()

/// Pyta o powód dla statusów, które go wymagają. Zwraca "" gdy niepotrzebny, null gdy gracz anulował
/proc/aq_ask_criminal_reason(mob/user, new_status)
	if(!(new_status in AQ_CRIMINAL_STATUSES_NEED_REASON))
		return ""
	var/reason = tgui_input_text(user, "Podaj powód: [aq_criminal_status_name(new_status)]", "Kartoteka", max_length = MAX_MESSAGE_LEN)
	reason = trim(reason)
	if(!reason)
		return null
	return reason
