// AQUILA - Citationinator, ręczna drukarka mandatów (port Monkestation2.0 monkestation/code/modules/security/code/citationinator.dm).
// Mandat trafia do akt przez nasze data_core (jak HUD ochrony i konsola akt), a drukarka wydaje różowy kwit.

/obj/item/citationinator
	name = "Citationinator"
	desc = "Tanie plastikowe ustrojstwo do wystawiania mandatów wszelkiej maści łobuzom. Drukuje też kwitek ze szczegółami mandatu."
	icon = 'aquila/icons/monke/citationinator.dmi'
	icon_state = "doohickey_closed"
	item_state = "doohickey"
	worn_icon_state = "electronic"
	lefthand_file = 'aquila/icons/monke/citationinator_lefthand.dmi'
	righthand_file = 'aquila/icons/monke/citationinator_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	req_access = list(ACCESS_SECURITY)
	custom_price = 50
	/// Skips access checks, if true
	var/access_check_skipped = FALSE
	/// Is someone filling in a citation right now
	var/busy = FALSE

/obj/item/citationinator/attack_self(mob/living/user)
	if(!isliving(user) || busy)
		return
	add_fingerprint(user)
	busy = TRUE
	icon_state = "doohickey_open"
	issue_fine(user)
	icon_state = initial(icon_state)
	busy = FALSE

/obj/item/citationinator/emag_act(mob/user)
	. = ..()
	if(access_check_skipped)
		balloon_alert(user, "nie ma już czego obejść!")
		return
	access_check_skipped = TRUE
	obj_flags |= EMAGGED
	do_sparks(2, TRUE, src)
	balloon_alert(user, "blokada dostępu obejścia")

/obj/item/citationinator/examine(mob/user)
	. = ..()
	if(access_check_skipped)
		. += "<span class='notice'>Czytnik kart iskrzy i wygląda na zepsuty.</span>"

/obj/item/citationinator/proc/issue_fine(mob/living/user)
	var/obj/item/card/id/using_id = user.get_idcard()
	if(!access_check_skipped)
		if(!istype(using_id) || QDELETED(using_id))
			balloon_alert(user, "brak identyfikatora!")
			return
		if(!check_access(using_id))
			balloon_alert(user, "brak dostępu!")
			return
	var/victim_name
	var/datum/data/record/victim
	switch(tgui_alert(user, "Komu wystawić mandat?", "Mandat", list("Z manifestu załogi", "Spoza manifestu"), timeout = 1 MINUTES))
		if("Spoza manifestu")
			victim_name = trim(tgui_input_text(user, "Imię i nazwisko", "Mandat", max_length = MAX_NAME_LEN, encode = FALSE, timeout = 1 MINUTES))
		if("Z manifestu załogi")
			var/list/choices = list()
			for(var/datum/data/record/person in GLOB.data_core.general)
				var/person_name = person.fields["name"]
				if(!person_name)
					continue
				choices[person_name] = person
			victim_name = tgui_input_list(user, "Wybierz członka załogi", "Masz na to licencję?", sort_list(choices), timeout = 1 MINUTES)
			victim = choices[victim_name]
			if(!victim)
				return
	if(!victim_name || !can_still_use(user))
		return
	var/max_fine = CONFIG_GET(number/maxfine)
	var/fine = tgui_input_number(user, "Ile kredytów mandatu? (maksymalnie [max_fine])", "Cywilna konfiskata mienia", 50, max_fine, 1, 1 MINUTES)
	if(!fine || !can_still_use(user))
		return
	fine = clamp(round(fine), 1, max_fine)
	var/citation_name = trim(tgui_input_text(user, "Za jakie przewinienie?", "Podejrzane obchodzenie się z rybą", max_length = MAX_NAME_LEN, encode = FALSE, timeout = 1 MINUTES))
	if(!citation_name || !can_still_use(user))
		return
	var/reason = trim(tgui_input_text(user, "Szczegóły mandatu (opcjonalnie)", "Podejrzane obchodzenie się z rybą", multiline = TRUE, encode = FALSE, timeout = 1 MINUTES))
	if(!can_still_use(user))
		return
	var/issuer_name = istype(using_id) ? "[using_id.assignment] [using_id.registered_name]" : "Nieznany"
	var/time = station_time_timestamp()
	if(victim)
		// victim to wpis z akt ogólnych; akta ochrony mają to samo id
		var/datum/data/crime/crime = GLOB.data_core.createCrimeEntry(citation_name, reason, issuer_name, time, fine)
		GLOB.data_core.addCitation(victim.fields["id"], crime)
		send_pda_alert(user, victim_name, "Otrzymujesz mandat w wysokości [fine] kredytów za „[citation_name]” od: [issuer_name]. Mandaty można opłacić w ochronie.")
		investigate_log("New Citation: <strong>[citation_name]</strong> Fine: [fine] | Added to [victim_name] by [key_name(user)] (citationinator)", INVESTIGATE_RECORDS)
	else
		investigate_log("Off-manifest Citation: <strong>[citation_name]</strong> Fine: [fine] | Printed for [victim_name] by [key_name(user)] (citationinator)", INVESTIGATE_RECORDS)

	print_slip(user, victim_name, citation_name, reason, issuer_name, time, fine)

/// The citationinator must stay in hand while the long form is filled in
/obj/item/citationinator/proc/can_still_use(mob/living/user)
	return !QDELETED(src) && !QDELETED(user) && user.is_holding(src) && !user.incapacitated()

/obj/item/citationinator/proc/send_pda_alert(mob/living/user, target_name, message)
	for(var/obj/item/modular_computer/tablet in GLOB.TabletMessengers)
		if(tablet.saved_identification != target_name)
			continue
		var/datum/signal/subspace/messaging/tablet_msg/signal = new(src, list(
			"name" = "Security Citation",
			"job" = "Citation Server",
			"message" = message,
			"targets" = list(tablet),
			"automated" = TRUE
		))
		signal.send_to_receivers()
		user.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)

/obj/item/citationinator/proc/print_slip(mob/living/user, victim_name, citation_name, details, issuer_name, time, fine)
	var/final_paper_text = "# <u>MANDAT OCHRONY</u>\n"
	final_paper_text += "Ochrona stacji wystawiła ci mandat za następujące wykroczenie:<br>"
	final_paper_text += {"<table style="text-align:left;" border="1" cellspacing="0" width="100%">"}
	final_paper_text += "<tr><th>Wykroczenie: </th><td>[sanitize(citation_name)]</td></tr>"
	final_paper_text += "<tr><th>Ukarany: </th><td>[sanitize(victim_name)]</td></tr>"
	final_paper_text += "<tr><th>Szczegóły: </th><td>[length(details) ? sanitize(details) : "Brak."]</td></tr>"
	final_paper_text += "<tr><th>Wystawił: </th><td>[sanitize(issuer_name)]</td></tr>"
	final_paper_text += "<tr><th>Czas: </th><td>[time]</td></tr>"
	final_paper_text += "<tr><th>Kwota: </th><td>[fine] kr</td></tr>"
	final_paper_text += "</table><br>"
	final_paper_text += "Mandat można opłacić przy konsoli nakazów przy wejściu do brygu.<br><br>"
	final_paper_text += "<i>Przyjęcie mandatu nie oznacza przyznania się do winy. Aby go zakwestionować, zwróć się do Kapitana, Szefa Ochrony albo prawnika na pokładzie.</i><br><br>"
	final_paper_text += "<i>Odmowa przyjęcia mandatu albo brak zapłaty lub odwołania w rozsądnym czasie może skończyć się zarzutem uchylania się od grzywny i odsiadką w brygu.</i><br>"

	var/obj/item/paper/slip = new(drop_location())
	slip.name = "mandat - [victim_name], [citation_name]"
	slip.color = COLOR_FADED_PINK
	slip.add_raw_text(final_paper_text)
	slip.update_appearance()
	user.put_in_hands(slip)

	user.visible_message("<span class='warning'>[src] bzyczy i klika, po czym wypluwa świstek papieru!</span>")
	playsound(src, 'aquila/sound/machines/printer.ogg', 40, TRUE)

// Pas ochrony go mieści
/obj/item/storage/belt/security/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.can_hold[/obj/item/citationinator] = TRUE
