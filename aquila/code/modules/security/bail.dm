// AQUILA - kaucja za więźnia (pomysł z Civ13, program „bail”). Kasa grzywien przyjmuje kaucję za osadzonych w GenPopie
// i w celach z zegarem. Wysokość: stawka za minutę pozostałego wyroku, Naczelnik może ją zmienić.
// Bez kaucji przy dożywociu i przy alarmie bojowym (czerwony i wyżej). Po wpłacie: zwolnienie warunkowe.

/// Kredyty za minutę pozostałego wyroku
#define BAIL_PER_MINUTE 20

/obj/item/card/id/prisoner
	/// Kaucja ustawiona przez Naczelnika (null = wyliczona)
	var/bail_override

/obj/machinery/door_timer
	/// Kaucja ustawiona przez Naczelnika (null = wyliczona)
	var/bail_override

/proc/aq_bail_blocked()
	return GLOB.security_level >= SEC_LEVEL_RED

/// Kaucja za kartę więźnia GenPop albo null, gdy się nie należy
/proc/aq_bail_for_card(obj/item/card/id/prisoner/card)
	if(QDELETED(card) || card.served_time >= card.sentence || aq_bail_blocked())
		return null
	if(card.sentence * 10 >= 60 MINUTES) // dożywocie w GenPopie to MAX_TIMER (60 min)
		return null
	if(!isnull(card.bail_override))
		return card.bail_override
	return max(BAIL_PER_MINUTE, round((card.sentence - card.served_time) / 60 * BAIL_PER_MINUTE))

/// Kaucja za celę z zegarem albo null
/proc/aq_bail_for_timer(obj/machinery/door_timer/cell)
	if(QDELETED(cell) || !cell.prisoner_name || !(cell.timing || !isnull(cell.paused_left)) || aq_bail_blocked())
		return null
	if(cell.machine_stat & (NOPOWER|BROKEN)) // zegar bez zasilania nie otworzy celi
		return null
	if(!isnull(cell.bail_override))
		return cell.bail_override
	var/left = isnull(cell.paused_left) ? cell.time_left() : cell.paused_left
	return max(BAIL_PER_MINUTE, round(left / (1 MINUTES) * BAIL_PER_MINUTE))

/// Zwalnia więźnia z GenPopu po kaucji
/proc/aq_release_on_bail(obj/item/card/id/prisoner/card, payer)
	card.served_time = card.sentence
	card.process(0) // od razu: „Były więzień”, dostęp do bramek, status po odbyciu kary
	STOP_PROCESSING(SSobj, card)
	var/datum/data/record/record = find_record("name", card.registered_name, GLOB.data_core.security)
	if(record)
		GLOB.data_core.set_criminal_status(record, "Paroled", "Kasa grzywien", "kaucja: [payer]")
	else
		aq_security_announce("GenPop: [card.registered_name] wychodzi za kaucją ([payer]).")

/obj/machinery/door_timer/proc/release_on_bail(payer)
	pardon_text = "kaucja: [payer]"
	release_status = "Paroled"
	if(!timing)
		timing = TRUE
	return timer_end(forced = TRUE)

/obj/machinery/computer/warrant/ui_data(mob/user)
	var/list/data = ..()
	var/list/bails = list()
	for(var/obj/item/card/id/prisoner/card as anything in GLOB.prisoner_ids)
		var/amount = aq_bail_for_card(card)
		if(isnull(amount))
			continue
		bails += list(list("ref" = REF(card), "name" = card.registered_name, "where" = "GenPop", "amount" = amount))
	for(var/obj/machinery/door_timer/cell in GLOB.machines)
		var/amount = aq_bail_for_timer(cell)
		if(isnull(amount))
			continue
		bails += list(list("ref" = REF(cell), "name" = cell.prisoner_name, "where" = cell.cell_label(), "amount" = amount))
	data["bails"] = bails
	data["bail_blocked"] = aq_bail_blocked()
	data["can_set_bail"] = (ACCESS_ARMORY in aq_user_access(user))
	return data

/obj/machinery/computer/warrant/ui_act(action, list/params, datum/tgui/ui)
	switch(action)
		if("pay_bail", "bail_holochip", "set_bail")
			if(machine_stat & (NOPOWER|BROKEN))
				return FALSE
			var/datum/target = locate(params["ref"])
			if(!(istype(target, /obj/item/card/id/prisoner) && (target in GLOB.prisoner_ids)) && !istype(target, /obj/machinery/door_timer))
				return FALSE
			if(action == "set_bail")
				return set_bail(usr, target)
			return pay_bail(usr, target, action == "bail_holochip")
	return ..()

/obj/machinery/computer/warrant/proc/set_bail(mob/user, datum/target)
	if(!(ACCESS_ARMORY in aq_user_access(user)))
		to_chat(user, "<span class='warning'>Kaucję zmienia tylko Naczelnik.</span>")
		return FALSE
	var/amount = tgui_input_number(user, "Nowa kaucja (kr)", "Kaucja", 0, 100000, 0)
	if(isnull(amount))
		return FALSE
	if(istype(target, /obj/item/card/id/prisoner))
		var/obj/item/card/id/prisoner/card = target
		card.bail_override = round(amount)
	else
		var/obj/machinery/door_timer/cell = target
		cell.bail_override = round(amount)
	log_game("[key_name(user)] set bail to [amount] for [target]")
	return TRUE

/// Pobiera kaucję z konta karty albo z holożetonu w ręce i zwalnia więźnia
/obj/machinery/computer/warrant/proc/pay_bail(mob/user, datum/target, holochip = FALSE)
	var/amount = istype(target, /obj/item/card/id/prisoner) ? aq_bail_for_card(target) : aq_bail_for_timer(target)
	if(isnull(amount) || !isliving(user) || issilicon(user))
		to_chat(user, "<span class='warning'>Za tego więźnia nie można teraz wpłacić kaucji.</span>")
		return FALSE
	var/datum/bank_account/account
	if(holochip)
		var/obj/item/holochip/chip = user.is_holding_item_of_type(/obj/item/holochip)
		if(!istype(chip) || chip.get_item_credit_value() < amount || !chip.spend(amount))
			to_chat(user, "<span class='warning'>Potrzebujesz w ręce holożetonu na co najmniej [amount] kr.</span>")
			return FALSE
	else
		var/obj/item/card/id/card = user.get_idcard(TRUE)
		account = card?.registered_account
		if(!account || !account.adjust_money(-amount))
			to_chat(user, "<span class='warning'>Brak środków na koncie karty (kaucja: [amount] kr).</span>")
			playsound(src, 'sound/machines/terminal_error.ogg', 100, TRUE)
			return FALSE
		account.bank_card_talk("Wpłacono [amount] cr kaucji.")
	var/payer = aq_record_author(user)
	if(istype(target, /obj/item/card/id/prisoner))
		aq_release_on_bail(target, payer)
	else
		var/obj/machinery/door_timer/cell = target
		if(!cell.release_on_bail(payer)) // zegar nie zwolnił więźnia: zwrot wpłaty
			cell.pardon_text = null
			cell.release_status = null
			if(account)
				account.adjust_money(amount)
				account.bank_card_talk("Zwrócono [amount] cr kaucji.")
			else
				new /obj/item/holochip(drop_location(), amount)
			to_chat(user, "<span class='warning'>Zegar celi nie zwolnił więźnia, kaucja wraca.</span>")
			return FALSE
	var/datum/bank_account/sec = SSeconomy.get_dep_account(ACCOUNT_SEC)
	sec?.adjust_money(amount)
	log_game("[key_name(user)] paid [amount] credits of bail for [target] at [loc_name(src)]")
	playsound(src, "terminal_type", 25, 0)
	add_fingerprint(user)
	return TRUE

#undef BAIL_PER_MINUTE
