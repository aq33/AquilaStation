// Automat ekstraktów szlamu. Dawniej pad zamówień z portu SLIMECORE (Monkestation 2.0), teraz działa odwrotnie:
// xenobiolodzy wkładają ekstrakty, które mają, i ustalają ceny, a załoga kupuje je kartą.
// Przy każdym ekstrakcie automat pokazuje, co robi (reakcje z programu PDA „Ekstrakty”).
// Zapłata trafia na konto działu nauki, a rynek dolicza xenobio points (3 za kredyt), jak przy starych zamówieniach.
// Kupno ekstraktu wystawionego z własnego konta nie daje punktów (inaczej kredyty dałoby się wymieniać na punkty bez końca).

/// Ile xenobio points za każdy kredyt zapłacony w automacie
// Używane też w slime_market.dm, który go #undefuje
#define SLIME_REQUEST_POINTS_PER_CREDIT 3
/// Najwyższa cena, jaką xenobiolog może ustawić za jeden ekstrakt
#define EXTRACT_VENDOR_MAX_PRICE 5000

/obj/machinery/slime_extract_requestor
	name = "automat ekstraktów szlamu"
	desc = "Automat, w którym xenobiolodzy wystawiają ekstrakty szlamu na sprzedaż. Płacisz z konta na karcie, a przy każdym ekstrakcie widać, co robi."
	icon = 'aquila/icons/obj/xenobiology/slime_market.dmi'
	icon_state = "civilian_pad"
	base_icon_state = "civilian_pad"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 250
	circuit = /obj/item/circuitboard/machine/slime_extract_requestor
	/// Wystawianie, wyjmowanie i ceny tylko z dostępem xenobiologii; kupować może każdy
	req_access = list(ACCESS_XENOBIOLOGY)
	/// typ ekstraktu -> cena w kredytach ustawiona przez xenobiologa
	var/list/prices = list()
	/// ekstrakt w automacie -> konto osoby, która go wystawiła
	var/list/stocked_by = list()

/obj/machinery/slime_extract_requestor/Destroy()
	// Rozebrany automat wysypuje towar zamiast go kasować
	var/atom/drop = drop_location()
	for(var/obj/item/slime_extract/extract in contents)
		extract.forceMove(drop)
	return ..()

/obj/machinery/slime_extract_requestor/Exited(atom/movable/gone, direction)
	. = ..()
	stocked_by -= gone

/obj/machinery/slime_extract_requestor/examine(mob/user)
	. = ..()
	var/count = 0
	for(var/obj/item/slime_extract/extract in contents)
		count++
	. += "<span class='notice'>Na sprzedaż: <b>[count]</b> ekstraktów. Kliknij, żeby zobaczyć ofertę.</span>"
	. += "<span class='notice'>Xenobiolog wystawia ekstrakty, wkładając je albo torbę bio do automatu.</span>"

/obj/machinery/slime_extract_requestor/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		return
	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return
	if(istype(W, /obj/item/slime_extract) || istype(W, /obj/item/storage/bag/bio))
		if(machine_stat & (NOPOWER|BROKEN))
			return ..()
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Wystawiać ekstrakty mogą tylko xenobiolodzy.</span>")
			return
		if(istype(W, /obj/item/slime_extract))
			if(!user.transferItemToLoc(W, src))
				return
			stock_extract(W, user)
			to_chat(user, "<span class='notice'>Wystawiasz [W] na sprzedaż.</span>")
			return
		var/added = 0
		for(var/obj/item/slime_extract/extract in W)
			if(!SEND_SIGNAL(W, COMSIG_TRY_STORAGE_TAKE, extract, src))
				continue
			stock_extract(extract, user)
			added++
		if(added)
			to_chat(user, "<span class='notice'>Wystawiasz na sprzedaż ekstrakty z [W] ([added]).</span>")
		else
			to_chat(user, "<span class='warning'>W [W] nie ma żadnych ekstraktów!</span>")
		return
	return ..()

/// Ekstrakt jest już w automacie: nowy kolor dostaje cenę domyślną, a automat pamięta konto wystawiającego
/obj/machinery/slime_extract_requestor/proc/stock_extract(obj/item/slime_extract/extract, mob/user)
	var/obj/item/card/id/card = user?.get_idcard(TRUE)
	if(card?.registered_account)
		stocked_by[extract] = card.registered_account
	if(isnull(prices[extract.type]))
		prices[extract.type] = default_price(extract.type)
	flick("[base_icon_state]_vend", src)
	SStgui.update_uis(src)

/// Cena, którą automat bierze teraz za ekstrakt danego typu
/obj/machinery/slime_extract_requestor/proc/current_price(extract_type)
	return prices[extract_type] || default_price(extract_type)

/obj/machinery/slime_extract_requestor/proc/default_price(extract_type)
	var/obj/item/slime_extract/path = extract_type
	return max(1, initial(path.plort_value))

/// Pierwszy ekstrakt danego typu w automacie
/obj/machinery/slime_extract_requestor/proc/find_extract(extract_type)
	for(var/obj/item/slime_extract/extract in contents)
		if(extract.type == extract_type)
			return extract

/// Czy z tego konta można płacić. Zapłata trafia na konto nauki, więc kupowanie z budżetu nauki
/// dawałoby xenobio points za darmo.
/obj/machinery/slime_extract_requestor/proc/can_pay_from(datum/bank_account/account)
	return account && account != SSeconomy.get_dep_account(ACCOUNT_SCI)

/// Kupno jednego ekstraktu kartą kupującego. Zwraca kupiony ekstrakt albo null.
/obj/machinery/slime_extract_requestor/proc/buy_extract(mob/user, extract_type, obj/item/card/id/card)
	var/obj/item/slime_extract/extract = find_extract(extract_type)
	if(!extract)
		return
	if(!card?.registered_account)
		say("Nie wykryto karty z kontem.")
		return
	if(!can_pay_from(card.registered_account))
		say("Zapłata trafia na konto nauki, więc nie da się płacić z budżetu nauki.")
		return
	var/price = current_price(extract_type)
	if(!card.registered_account.adjust_money(-price))
		say("Na koncie nie ma tylu kredytów.")
		return
	var/datum/bank_account/science = SSeconomy.get_dep_account(ACCOUNT_SCI)
	science?.adjust_money(price)
	if(stocked_by[extract] != card.registered_account)
		GLOB.slime_market.points += price * SLIME_REQUEST_POINTS_PER_CREDIT
	extract.forceMove(drop_location())
	user?.put_in_hands(extract)
	flick("[base_icon_state]_vend", src)
	playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
	return extract

/obj/machinery/slime_extract_requestor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeExtractVendor", name)
		ui.open()

/obj/machinery/slime_extract_requestor/ui_static_data(mob/user)
	var/list/data = list()
	var/list/reactions = list()
	for(var/list/entry as anything in get_slime_extract_catalog())
		reactions[entry["id"]] = entry["reactions"]
	data["reactions"] = reactions
	return data

/obj/machinery/slime_extract_requestor/ui_data(mob/user)
	var/list/data = list()
	var/list/counts = list()
	for(var/obj/item/slime_extract/extract in contents)
		counts[extract.type]++
	var/list/stock = list()
	for(var/obj/item/slime_extract/extract_type as anything in counts)
		stock += list(list(
			"id" = "[extract_type]",
			"name" = initial(extract_type.name),
			"icon" = initial(extract_type.icon),
			"icon_state" = initial(extract_type.icon_state),
			"amount" = counts[extract_type],
			"price" = current_price(extract_type),
		))
	data["stock"] = stock
	data["can_manage"] = allowed(user)
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	data["balance"] = card?.registered_account ? card.registered_account.account_balance : null
	return data

/obj/machinery/slime_extract_requestor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	var/extract_type = text2path(params["id"])
	if(!ispath(extract_type, /obj/item/slime_extract))
		return
	switch(action)
		if("buy")
			// Okno odświeża się z opóźnieniem: kupujący płaci tylko cenę, którą widział na przycisku
			if(text2num(params["price"]) != current_price(extract_type))
				say("Cena się zmieniła. Sprawdź ofertę jeszcze raz.")
				return TRUE
			buy_extract(usr, extract_type, usr.get_idcard(TRUE))
			return TRUE
		if("take")
			if(!allowed(usr))
				return
			var/obj/item/slime_extract/extract = find_extract(extract_type)
			if(!extract)
				return
			extract.forceMove(drop_location())
			usr.put_in_hands(extract)
			return TRUE
		if("set_price")
			if(!allowed(usr))
				return
			var/price = round(text2num(params["price"]))
			if(!price || price < 1)
				return
			prices[extract_type] = min(price, EXTRACT_VENDOR_MAX_PRICE)
			return TRUE

/obj/item/circuitboard/machine/slime_extract_requestor
	name = "automat ekstraktów szlamu (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/slime_extract_requestor
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/datum/design/board/slime_extract_requestor
	name = "Projekt maszyny (automat ekstraktów szlamu)"
	desc = "Płytka drukowana automatu, w którym xenobiolodzy sprzedają ekstrakty."
	id = "slime_extract_requestor"
	build_path = /obj/item/circuitboard/machine/slime_extract_requestor
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SERVICE

#undef EXTRACT_VENDOR_MAX_PRICE
