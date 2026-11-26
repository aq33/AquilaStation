// AQUILA - Ankieta Centrali: na faks dowództwa przychodzi żartobliwa ankieta o zmianie; odesłana faksem do Centrali, wypełniona i podpisana, daje premię w budżecie zaopatrzenia (port z BlueMoon-Labs/BlueMoon-Station modular_bluemoon/code/modules/events/minor_incidents/centcom_questionnaire.dm)
// BlueMoon also needs a command stamp, rewards a crew member named in the form and posts the survey results to the news.
// Ours keeps the core: the form goes to the bridge fax (then the captain's or HoP's office, then any ship fax), it must
// come back to the "Centrala" fax within 20 minutes with every field filled and the signature field signed, and the
// cargo budget gets 500 cr with a thank-you fax. No stamp and no commendation, so a ship without heads can still answer.
// A late or incomplete form gets a polite reply fax, without a penalty, like BlueMoon. Texts written anew in Polish.

/datum/round_event_control/aquila_hex_centcom_questionnaire
	name = "Ankieta Centrali"
	typepath = /datum/round_event/aquila_hex_centcom_questionnaire
	weight = 8
	min_players = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_centcom_questionnaire
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Fax the form was sent to, answers come back to it
	var/datum/weakref/home_fax_ref
	/// Name of that fax, for the announcement
	var/fax_name
	/// world.time of the deadline
	var/deadline
	/// The reward was paid
	var/answered = FALSE
	/// Cargo budget reward for a filled form
	var/reward = 500

/datum/round_event/aquila_hex_centcom_questionnaire/setup()
	endWhen = 600 // 20 minutes in 2 second event ticks

/datum/round_event/aquila_hex_centcom_questionnaire/start()
	var/obj/machinery/fax/fax = find_command_fax()
	if(!fax)
		log_game("Central Command Questionnaire: no working fax on the ship, cancelling the event.")
		return kill()
	home_fax_ref = WEAKREF(fax)
	fax_name = fax.fax_name
	deadline = world.time + endWhen * 2 SECONDS
	fax.receive(make_form(), "Centrala")
	log_game("Central Command Questionnaire: form sent to [fax_name] at [AREACOORD(fax)].")

/datum/round_event/aquila_hex_centcom_questionnaire/announce(fake)
	if(!fax_name)
		return
	priority_announce("Dział Badania Zadowolenia Załogi przesłał na faks „[fax_name]” ankietę o przebiegu zmiany. Prosimy ją wypełnić, podpisać i odesłać faksem do Centrali w ciągu 20 minut. Za terminową odpowiedź budżet zaopatrzenia otrzyma [reward] kr.", "Dział Badania Zadowolenia Załogi Centrali")

/datum/round_event/aquila_hex_centcom_questionnaire/end()
	if(!answered && home_fax_ref)
		send_reply("<center><b>CENTRALA NANOTRASEN</b><br>Dział Badania Zadowolenia Załogi</center><br>Termin odesłania ankiety minął. Rozumiemy, że zmiana bywa pracowita. Nieodesłana ankieta nie wpływa na ocenę okrętu. Prawie wcale.")

/// The bridge fax, then the captain's and HoP's office, then any fax on the ship
/datum/round_event/aquila_hex_centcom_questionnaire/proc/find_command_fax()
	var/list/candidates = list()
	for(var/obj/machinery/fax/fax in GLOB.machines)
		if(fax.syndicate_network || !fax.visible_to_network || !fax.is_operational)
			continue
		var/turf/T = get_turf(fax)
		if(T && is_station_level(T.z))
			candidates += fax
	for(var/area_type in list(/area/bridge, /area/crew_quarters/heads/captain, /area/crew_quarters/heads/hop))
		var/list/in_area = list()
		for(var/obj/machinery/fax/fax as anything in candidates)
			if(istype(get_area(fax), area_type))
				in_area += fax
		if(length(in_area))
			return pick(in_area)
	if(length(candidates))
		return pick(candidates)
	return null

/// The blank form
/datum/round_event/aquila_hex_centcom_questionnaire/proc/make_form()
	var/obj/item/paper/aquila_hex_questionnaire/form = new
	form.survey_ref = WEAKREF(src)
	form.add_raw_text("<center><b>CENTRALA NANOTRASEN</b><br>Dział Badania Zadowolenia Załogi<br>Ankieta AZ-7 „Jak mija zmiana?”</center><br>\
1. Oceń zmianę od 1 do 10, gdzie 1 to „ewakuacja przed czasem”, a 10 to „ewakuacja zgodnie z planem”: \[____\]<br><br>\
2. Najdziwniejsze zdarzenie zmiany w jednym zdaniu. Wybuchów prosimy nie zgłaszać, o nich wiemy: \[____\]<br><br>\
3. Podpis osoby wypełniającej (wpisz %sign): \[____\]<br><br>\
<i>Wypełnij wszystkie pola długopisem i odeślij ankietę faksem do Centrali (lista faksów specjalnych) w ciągu 20 minut. Za terminową odpowiedź budżet zaopatrzenia okrętu otrzyma [reward] kr.</i>")
	form.update_appearance()
	return form

/// Called when a questionnaire is faxed to Central Command
/datum/round_event/aquila_hex_centcom_questionnaire/proc/receive_answer(obj/item/paper/aquila_hex_questionnaire/form)
	if(answered)
		return FALSE
	if(world.time > deadline)
		send_reply("<center><b>CENTRALA NANOTRASEN</b><br>Dział Badania Zadowolenia Załogi</center><br>Dziękujemy za ankietę, ale dotarła po terminie. Trafi do archiwum, gdzie ktoś ją kiedyś przeczyta.")
		return FALSE
	if(!form.questionnaire_complete())
		send_reply("<center><b>CENTRALA NANOTRASEN</b><br>Dział Badania Zadowolenia Załogi</center><br>Otrzymana ankieta jest niekompletna: wypełnij wszystkie pola i podpisz ją, a potem odeślij ponownie. Wydział Formularzy jest bardzo zawiedziony.")
		return FALSE
	answered = TRUE
	var/datum/bank_account/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo?.adjust_money(reward)
	send_reply("<center><b>CENTRALA NANOTRASEN</b><br>Dział Badania Zadowolenia Załogi</center><br>Dziękujemy za wypełnienie ankiety! Na budżet zaopatrzenia przelano [reward] kr. Twoja opinia jest dla nas ważna i zostanie przeanalizowana w ciągu 6–8 lat roboczych.")
	log_game("Central Command Questionnaire: answered in time, [reward] cr paid to the cargo budget.")
	return TRUE

/// Sends a reply fax from Central Command to the fax the form went to
/datum/round_event/aquila_hex_centcom_questionnaire/proc/send_reply(text)
	var/obj/machinery/fax/fax = home_fax_ref?.resolve()
	if(QDELETED(fax))
		return null
	var/obj/item/paper/reply = new
	reply.name = "odpowiedź Centrali"
	reply.add_raw_text(text)
	reply.update_appearance()
	fax.receive(reply, "Centrala")
	return reply

/obj/item/paper/aquila_hex_questionnaire
	name = "ankieta Centrali"
	desc = "Formularz Działu Badania Zadowolenia Załogi. Ma pola do wypełnienia i miejsce na podpis."
	/// The questionnaire event this form belongs to
	var/datum/weakref/survey_ref

/// All three fields are filled and the last one is signed
/obj/item/paper/aquila_hex_questionnaire/proc/questionnaire_complete()
	var/filled = 0
	var/signed = FALSE
	for(var/datum/paper_field/field as anything in raw_field_input_data)
		var/answer = field.field_data?.raw_text
		if(!answer || !length(trim(answer)))
			continue
		filled++
		if(field.is_signature)
			signed = TRUE
	return filled >= 3 && signed

// Odesłana ankieta wraca do eventu, gdy faks wysyła ją do Centrali z listy faksów specjalnych
/obj/machinery/fax/send_to_additional_faxes(obj/item/loaded, mob/sender, receiver_name, receiver_color)
	. = ..()
	if(!. || receiver_name != "Centrala" || !istype(loaded, /obj/item/paper/aquila_hex_questionnaire))
		return
	var/obj/item/paper/aquila_hex_questionnaire/form = loaded
	var/datum/round_event/aquila_hex_centcom_questionnaire/survey = form.survey_ref?.resolve()
	if(survey)
		survey.receive_answer(form)
