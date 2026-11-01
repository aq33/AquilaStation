/obj/machinery/computer/warrant
	name = "konsola nakazów ochrony"
	desc = "Służy do przeglądania aktywnych nakazów."
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/warrant
	light_color = LIGHT_COLOR_RED
	/// The state of the printer
	var/printing = FALSE

/obj/machinery/computer/warrant/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "WarrantConsole", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/// Imię z karty ID użytkownika (do pokazania jego własnych akt z przestępstwami)
/obj/machinery/computer/warrant/proc/get_user_id_name(mob/user)
	if(!isliving(user) || iscyborg(user))
		return
	var/obj/item/card/id/scan = user.get_idcard(TRUE)
	return scan?.registered_name

/obj/machinery/computer/warrant/ui_data(mob/user)
	var/list/data = list()
	var/user_name = get_user_id_name(user)
	var/list/records = list()

	for(var/datum/data/record/target in GLOB.data_core.security)
		var/is_own = user_name && target.fields["name"] == user_name
		if(!length(target.fields["citation"]) && !is_own)
			continue

		var/list/citations = list()
		for(var/datum/data/crime/warrant in target.fields["citation"])
			citations += list(list(
				"author" = warrant.author,
				"details" = warrant.crimeDetails,
				"fine" = max(warrant.fine - warrant.paid, 0),
				"fine_name" = warrant.crimeName,
				"fine_ref" = warrant.dataId,
				"paid" = warrant.paid,
				"time" = warrant.time,
			))

		var/list/record = list(
			"citations" = citations,
			"crew_name" = target.fields["name"],
			"crew_ref" = target.fields["id"],
			"own" = !!is_own,
		)
		// AQUILA: własne akta pokazują też status i przestępstwa (jak stara konsola po zalogowaniu ID)
		if(is_own)
			var/list/crimes = list()
			for(var/datum/data/crime/crime in target.fields["crim"])
				crimes += list(list(
					"name" = crime.crimeName,
					"details" = crime.crimeDetails,
					"author" = crime.author,
					"time" = crime.time,
				))
			record["crimes"] = crimes
			record["criminal"] = target.fields["criminal"]
		records += list(record)

	data["records"] = records
	return data

/obj/machinery/computer/warrant/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return FALSE

	switch(action)
		if("pay")
			pay_fine(usr, params)
			return TRUE

		if("pay_holochip")
			pay_fine_holochip(usr, params)
			return TRUE

		if("print")
			print_bounty(usr, params)
			return TRUE

		if("refresh")
			return TRUE

	return FALSE

/// Znajduje rekord i grzywnę z parametrów okna; wynik dopisuje do out (rekord, grzywna)
/obj/machinery/computer/warrant/proc/find_citation(list/params, list/out)
	var/datum/data/record/target = find_record("id", params["crew_ref"], GLOB.data_core.security)
	if(!target)
		return FALSE
	var/fine_ref = text2num("[params["fine_ref"]]")
	for(var/datum/data/crime/warrant in target.fields["citation"])
		if(warrant.dataId == fine_ref)
			out += target
			out += warrant
			return TRUE
	return FALSE

/// Po wpłacie: log i komunikat o spłacie całości
/obj/machinery/computer/warrant/proc/after_payment(mob/user, datum/data/record/target, datum/data/crime/warrant, amount)
	log_game("[key_name(user)] paid [amount] credits towards [target.fields["name"]]'s [warrant.fine] credit fine at [loc_name(src)]")
	SSblackbox.record_feedback("amount", "credits_transferred", amount)
	playsound(src, "terminal_type", 25, 0)
	if(warrant.paid >= warrant.fine)
		investigate_log("Citation Paid off: <strong>[warrant.crimeName]</strong> Fine: [warrant.fine] | Paid off by [key_name(user)]", INVESTIGATE_RECORDS)
		to_chat(user, "<span class='notice'>Grzywna została spłacona w całości.</span>")

/// Płaci część grzywny z konta przypisanego do karty ID (jak w tg)
/obj/machinery/computer/warrant/proc/pay_fine(mob/user, list/params)
	var/list/found = list()
	if(!find_citation(params, found))
		return FALSE
	var/datum/data/record/target = found[1]
	var/datum/data/crime/warrant = found[2]

	if(!isliving(user) || issilicon(user))
		to_chat(user, "<span class='warning'>ODMOWA DOSTĘPU</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/obj/item/card/id/auth = user.get_idcard(TRUE)
	if(!auth)
		to_chat(user, "<span class='warning'>ODMOWA DOSTĘPU: nie wykryto karty ID.</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/datum/bank_account/account = auth.registered_account
	if(!account)
		to_chat(user, "<span class='warning'>ODMOWA DOSTĘPU: karta nie jest powiązana z kontem.</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/owed = warrant.fine - warrant.paid
	var/amount = round(text2num("[params["amount"]]"))
	if(!amount || amount <= 0 || amount > owed || !account.adjust_money(-amount))
		to_chat(user, "<span class='warning'>ODMOWA DOSTĘPU: nieprawidłowa kwota.</span>")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	account.bank_card_talk("Wpłacono [amount] cr na poczet grzywny: [target.fields["name"]].")
	GLOB.data_core.payCitation(target.fields["id"], warrant.dataId, amount)
	after_payment(user, target, warrant, amount)
	add_fingerprint(user)
	return TRUE

/// Płaci grzywnę holożetonem trzymanym w ręce (sposób ze starej konsoli HTML)
/obj/machinery/computer/warrant/proc/pay_fine_holochip(mob/user, list/params)
	var/list/found = list()
	if(!find_citation(params, found))
		return FALSE
	var/datum/data/record/target = found[1]
	var/datum/data/crime/warrant = found[2]

	var/obj/item/holochip/chip = user.is_holding_item_of_type(/obj/item/holochip)
	if(!istype(chip))
		to_chat(user, "<span class='warning'>Grzywny można płacić tylko holożetonami trzymanymi w ręce.</span>")
		return FALSE
	var/pay = chip.get_item_credit_value()
	if(!pay)
		to_chat(user, "<span class='warning'>[chip] wydaje się nic nie być wart!</span>")
		return FALSE
	GLOB.data_core.payCitation(target.fields["id"], warrant.dataId, pay)
	to_chat(user, "<span class='notice'>Wpłacasz [pay] kredytów na poczet grzywny.</span>")
	qdel(chip)
	after_payment(user, target, warrant, pay)
	add_fingerprint(user)
	return TRUE

/// Finishes printing, resets the printer.
/obj/machinery/computer/warrant/proc/print_finish(obj/item/paper/bounty)
	printing = FALSE
	playsound(src, 'sound/machines/terminal_eject.ogg', 100, TRUE)
	bounty.forceMove(loc)
	return TRUE

/// Drukuje list gończy dla niespłaconej grzywny.
/obj/machinery/computer/warrant/proc/print_bounty(mob/user, list/params)
	if(printing)
		balloon_alert(user, "drukarka zajęta")
		playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
		return FALSE

	var/list/found = list()
	if(!find_citation(params, found))
		return FALSE
	var/datum/data/record/target = found[1]
	var/datum/data/crime/warrant = found[2]
	var/owed = warrant.fine - warrant.paid
	if(owed <= 0)
		return FALSE

	var/bounty_text = "<center><h2><b>List gończy: [target.fields["name"]]</b></h2></center><BR>"
	bounty_text += "<center>Poszukiwany za: [warrant.crimeName]</center><br><br>"
	bounty_text += "<b>Szczegóły:</b><br>[warrant.crimeDetails]<br>"
	bounty_text += "<b>Wystawił:</b><br>[warrant.author]<br>"
	bounty_text += "<b>Data wystawienia:</b><br>[warrant.time]<br>"
	bounty_text += "<b>Uwagi:</b><br>[target.fields["notes"] || "Brak."]<br><br>"
	bounty_text += "<center><b>GRZYWNA:</b> [owed] cr</center>"

	printing = TRUE
	balloon_alert(user, "drukowanie")
	playsound(src, 'sound/machines/terminal_processing.ogg', 100, TRUE)

	var/obj/item/paper/bounty = new(null)
	bounty.name = "list gończy: [target.fields["name"]]"
	bounty.desc = "List gończy na [owed] cr za [target.fields["name"]]."
	bounty.add_raw_text(bounty_text)
	bounty.update_icon()

	addtimer(CALLBACK(src, PROC_REF(print_finish), bounty), 2 SECONDS)
	return TRUE
