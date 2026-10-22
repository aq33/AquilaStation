// AQUILA - biblioteka kaset z Monkestation (machines/cassette_library.dm, cassette_purchase_tracker.dm).
// Płaci się z konta na karcie ID (pieniądze idą do budżetu serwisu). Ranking „najpopularniejsze” tylko w JSON-ie, bez tabeli SQL.

/obj/machinery/cassette_library
	name = "terminal biblioteki kaset"
	desc = "Drukuje kasety zatwierdzone przez Kosmiczną Radę Muzyczną."
	icon = 'aquila/icons/obj/cassettes/cassette_library.dmi'
	icon_state = "cassette_library"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 20
	var/cassette_cost = 100
	/// Trwa drukowanie
	var/busy = FALSE
	/// Ile razy w tej rundzie gracz kupił własną kasetę (ckey -> liczba) - sygnał dla adminów przy nabijaniu rankingu
	var/static/list/self_purchases = list()

/obj/machinery/cassette_library/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/cassette_library/power_change()
	. = ..()
	update_icon()

/obj/machinery/cassette_library/update_icon_state()
	icon_state = "cassette_library[powered() ? "" : "-off"]"
	return ..()

/obj/machinery/cassette_library/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kaseta kosztuje [cassette_cost] kr, płatne kartą ID.</span>"

/obj/machinery/cassette_library/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteLibrary", name)
		ui.open()

/obj/machinery/cassette_library/ui_static_data(mob/user)
	var/list/cassette_list = list()
	for(var/datum/cassette/cassette as anything in SScassettes.filtered_cassettes(CASSETTE_STATUS_APPROVED))
		var/list/songs = list()
		for(var/datum/cassette_song/song as anything in cassette.front.songs + cassette.back.songs)
			songs += song.name
		cassette_list += list(list(
			"id" = cassette.id,
			"name" = html_decode(cassette.name),
			"desc" = html_decode(cassette.desc),
			"author" = cassette.author.name,
			"icon_state" = cassette.front.design,
			"songs" = songs,
		))
	return list(
		"icon" = 'aquila/icons/obj/cassettes/walkman.dmi',
		"cassettes" = cassette_list,
		"top_cassettes" = SScassettes.top_cassettes(10),
	)

/obj/machinery/cassette_library/ui_data(mob/user)
	var/datum/bank_account/account = get_account(user)
	return list(
		"cost" = cassette_cost,
		"busy" = busy,
		"balance" = account ? account.account_balance : null,
	)

/obj/machinery/cassette_library/proc/get_account(mob/user)
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	return card?.registered_account

/obj/machinery/cassette_library/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "purchase")
		return
	var/mob/user = usr
	if(busy)
		balloon_alert(user, "drukuje!")
		return TRUE
	var/datum/cassette/cassette = SScassettes.cassettes[params["id"]]
	if(cassette?.status != CASSETTE_STATUS_APPROVED)
		return TRUE
	var/datum/bank_account/account = get_account(user)
	if(!account)
		balloon_alert(user, "brak karty z kontem!")
		return TRUE
	if(!account.adjust_money(-cassette_cost))
		balloon_alert(user, "za mało kredytów!")
		return TRUE
	SSeconomy.get_dep_account(ACCOUNT_SRV)?.adjust_money(cassette_cost)
	record_purchase(cassette, user)
	busy = TRUE
	playsound(src, 'sound/machines/terminal_processing.ogg', 50, TRUE)
	addtimer(CALLBACK(src, .proc/finish_printing, cassette.id, user), 2 SECONDS)
	return TRUE

/obj/machinery/cassette_library/proc/record_purchase(datum/cassette/cassette, mob/user)
	if(!user.ckey)
		return
	SScassettes.record_purchase(cassette.id, user.ckey)
	if(user.ckey != ckey(cassette.author.ckey))
		return
	self_purchases[user.ckey]++
	if(self_purchases[user.ckey] == 5)
		message_admins("[key_name_admin(user)] kupił(a) własną kasetę już 5 razy w tej rundzie.")

/obj/machinery/cassette_library/proc/finish_printing(cassette_id, mob/user)
	busy = FALSE
	var/obj/item/cassette_tape/new_tape = new(drop_location(), cassette_id)
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE)
	if(user && user.Adjacent(src))
		user.put_in_hands(new_tape)
	SStgui.update_uis(src)
	if(user)
		update_static_data(user) // ranking
