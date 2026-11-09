// Automat drużyny: jeden zestaw na funkcję (żołnierz, dowódca, medyk, inżynier), wydawany w skrzyni
// przypisanej do funkcji. Skrzynia mieści pancerz i skafander obcisły naraz, więc „trudne warunki”
// nie są już osobnym zestawem. Rejestr wydań widzi XO w konsoli drużyn.

/datum/squad_loadout/aquila
	name = "Żołnierz drużyny"
	desc = "Mundur, pancerz z hełmem do pomieszczeń z ciśnieniem i opancerzony skafander obcisły z hełmem kosmicznym na próżnię. Do tego pistolet z magazynkiem."
	/// Funkcja, dla której jest ten zestaw (SQUAD_POSITION_*)
	var/position = SQUAD_POSITION_SOLDIER
	items = list(
		/obj/item/clothing/under/ship/marine,
		/obj/item/clothing/suit/ship/squad,
		/obj/item/clothing/head/helmet/ship/squad,
		/obj/item/clothing/suit/ship/squad/space,
		/obj/item/clothing/head/helmet/ship/squad/space,
		/obj/item/ammo_box/magazine/glock/lethal,
		/obj/item/gun/ballistic/automatic/pistol/glock,
	)

/datum/squad_loadout/aquila/nt/soldier

/datum/squad_loadout/aquila/nt/leader
	name = "Dowódca drużyny"
	desc = "Zestaw żołnierza z hełmem dowódcy i megafonem."
	position = SQUAD_POSITION_LEADER
	items = list(
		/obj/item/clothing/under/ship/marine,
		/obj/item/megaphone,
		/obj/item/clothing/suit/ship/squad,
		/obj/item/clothing/head/helmet/ship/squad/leader,
		/obj/item/clothing/suit/ship/squad/space,
		/obj/item/clothing/head/helmet/ship/squad/space,
		/obj/item/ammo_box/magazine/glock/lethal,
		/obj/item/gun/ballistic/automatic/pistol/glock,
	)

/datum/squad_loadout/aquila/nt/medic
	name = "Medyk drużyny"
	desc = "Zestaw żołnierza z mundurem medyka, apteczką zwykłą i tlenową oraz sprayami ze sterylizyną i styptykiem."
	position = SQUAD_POSITION_MEDIC
	items = list(
		/obj/item/clothing/under/ship/marine/medic,
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/firstaid/o2,
		/obj/item/reagent_containers/medspray/sterilizine,
		/obj/item/reagent_containers/medspray/styptic,
		/obj/item/clothing/suit/ship/squad,
		/obj/item/clothing/head/helmet/ship/squad,
		/obj/item/clothing/suit/ship/squad/space,
		/obj/item/clothing/head/helmet/ship/squad/space,
		/obj/item/ammo_box/magazine/glock/lethal,
		/obj/item/gun/ballistic/automatic/pistol/glock,
	)

/datum/squad_loadout/aquila/nt/engineer
	name = "Inżynier drużyny"
	desc = "Zestaw żołnierza z mundurem inżyniera, pasem z narzędziami, goglami spawalniczymi i zestawem kontroli uszkodzeń."
	position = SQUAD_POSITION_ENGINEER
	items = list(
		/obj/item/clothing/under/ship/marine/engineer,
		/obj/item/storage/belt/utility/full,
		/obj/item/storage/box/damage_control,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/suit/ship/squad,
		/obj/item/clothing/head/helmet/ship/squad,
		/obj/item/clothing/suit/ship/squad/space,
		/obj/item/clothing/head/helmet/ship/squad/space,
		/obj/item/ammo_box/magazine/glock/lethal,
		/obj/item/gun/ballistic/automatic/pistol/glock,
	)

// Rejestr wydanego sprzętu (konsola XO pokazuje, kto pobrał i czego nie oddał)
GLOBAL_LIST_EMPTY(squad_loans)

/datum/squad_loan
	var/mob/living/carbon/human/owner
	var/owner_name
	var/squad_name
	var/kit_name
	/// Typy, których brakuje do zwrotu (typ może się powtarzać)
	var/list/outstanding = list()
	var/issued_at

/datum/squad_loan/New(mob/living/carbon/human/owner, datum/squad_loadout/kit, list/issued_types)
	src.owner = owner
	owner_name = owner.real_name
	squad_name = owner.squad?.name
	kit_name = kit.name
	outstanding = issued_types.Copy()
	issued_at = world.time
	GLOB.squad_loans += src

/datum/squad_loan/Destroy()
	GLOB.squad_loans -= src
	owner = null
	return ..()

/proc/get_squad_loan(mob/living/owner)
	if(!owner)
		return null
	for(var/datum/squad_loan/loan as anything in GLOB.squad_loans)
		if(loan.owner == owner)
			return loan
	return null

/// Zwraca przedmiot do wypożyczenia; TRUE, jeśli pasował
/datum/squad_loan/proc/accept(obj/item/thing)
	for(var/path in outstanding)
		if(thing.type == path)
			outstanding -= path
			return TRUE
	return FALSE

/// Polskie nazwy brakujących przedmiotów
/datum/squad_loan/proc/outstanding_names()
	. = list()
	for(var/path in outstanding)
		var/obj/item/item_type = path
		. += initial(item_type.name)

// Skrzynia zestawu: noszona w ręce, mieści tylko sprzęt z zestawów drużyn
/obj/item/storage/aq_squad_crate
	name = "skrzynia sprzętu drużyny"
	desc = "Wojskowa skrzynia na zestaw drużyny. Odłóż do niej sprzęt, choćby luzem, i oddaj ją do automatu drużyny."
	icon = 'aquila/icons/squads/squad_crate.dmi'
	icon_state = "crate"
	item_state = "ammobox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	throwforce = 8
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	/// Czyje to wypożyczenie
	var/datum/squad_loan/loan
	var/position = SQUAD_POSITION_SOLDIER
	var/squad_colour = "#888888"

/obj/item/storage/aq_squad_crate/ComponentInitialize()
	. = ..()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	storage.max_w_class = WEIGHT_CLASS_BULKY
	storage.max_combined_w_class = 60
	storage.max_items = 16
	var/static/list/kit_items
	if(!kit_items)
		var/list/paths = list()
		for(var/loadout_type in subtypesof(/datum/squad_loadout))
			var/datum/squad_loadout/loadout = new loadout_type
			paths |= loadout.items
			qdel(loadout)
		kit_items = typecacheof(paths, only_root_path = TRUE)
	storage.can_hold = kit_items

/obj/item/storage/aq_squad_crate/Destroy()
	loan = null
	return ..()

/obj/item/storage/aq_squad_crate/proc/assign(datum/squad_loan/new_loan, new_position, datum/squad/squad)
	loan = new_loan
	position = new_position
	if(squad)
		squad_colour = squad.colour
	name = "skrzynia: [lowertext(squad_position_pl(position))] drużyny [squad?.name || "?"]"
	update_icon()

/obj/item/storage/aq_squad_crate/update_overlays()
	. = ..()
	var/mutable_appearance/stripe = mutable_appearance(icon, "stripe")
	stripe.color = squad_colour
	. += stripe
	. += mutable_appearance(icon, "emblem_[position]")

// Automat
/obj/machinery/squad_vendor
	name = "automat drużyny"
	desc = "Automat wydający drużynom wyposażenie. Każdy dostaje zestaw swojej funkcji w skrzyni. <i>Pobrany zestaw trzeba zwrócić, zanim dostaniesz następny.</i>"
	loadout_type = /datum/squad_loadout/aquila/nt

/obj/machinery/squad_vendor
	/// SolGov: laser retro zamiast pistoletu z magazynkiem
	var/aq_energy_weapons = FALSE

/obj/machinery/squad_vendor/solgov
	loadout_type = /datum/squad_loadout/aquila/nt
	aq_energy_weapons = TRUE

/// Zestaw dla funkcji danej osoby
/obj/machinery/squad_vendor/proc/aq_loadout_for(mob/living/carbon/human/user)
	if(!istype(user) || !user.squad)
		return null
	var/position = user.get_squad_position()
	for(var/datum/squad_loadout/aquila/kit in loadouts)
		if(kit.position == position)
			return kit
	return null

// Pełne nadpisania (LEGACY_OVERRIDES.md): jeden zestaw według funkcji, skrzynia, rejestr wydań
/obj/machinery/squad_vendor/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/human/H = user
	data["user_name"] = ishuman(H) ? "[H.compose_rank()] [H.real_name]" : "Nieprzydzielony"
	data["squad"] = ishuman(H) ? H.squad?.name : null
	data["squad_colour"] = ishuman(H) ? H.squad?.colour : null
	data["position"] = ishuman(H) && H.squad ? squad_position_pl(H.get_squad_position()) : null
	data["weapons_clearance"] = ishuman(H) && H.squad ? H.squad.weapons_clearance : FALSE
	var/datum/squad_loan/loan = get_squad_loan(H)
	data["already_loaned"] = !!loan
	data["missing"] = loan ? loan.outstanding_names() : list()
	data["fine"] = loan ? length(loan.outstanding) * SQUAD_LOAN_FINE : 0
	var/datum/squad_loadout/aquila/kit = aq_loadout_for(H)
	if(kit)
		var/list/contents = list()
		for(var/path in aq_issued_items(kit, H.squad))
			var/obj/item/item_type = path
			contents += initial(item_type.name)
		data["kit"] = list("name" = kit.name, "desc" = kit.desc, "contents" = contents)
	else
		data["kit"] = null
	return data

/// Co faktycznie wyjdzie z automatu (bez zezwolenia na broń bez broni i amunicji)
/obj/machinery/squad_vendor/proc/aq_issued_items(datum/squad_loadout/kit, datum/squad/squad)
	var/list/issued = kit.items.Copy()
	if(aq_energy_weapons && (/obj/item/gun/ballistic/automatic/pistol/glock in issued))
		issued -= /obj/item/ammo_box/magazine/glock/lethal
		issued -= /obj/item/gun/ballistic/automatic/pistol/glock
		issued += /obj/item/gun/energy/laser/retro
	if(!squad?.weapons_clearance)
		for(var/banned in requires_weapons_clearance)
			for(var/path in issued)
				if(ispath(path, banned))
					issued -= path
	return issued

/obj/machinery/squad_vendor/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H) || !H.squad)
		return FALSE
	switch(action)
		if("vend")
			return aq_vend(H)
		if("return_gear")
			aq_return_from_person(H)
			return TRUE
		if("pay_fine")
			return aq_pay_fine(H)

/obj/machinery/squad_vendor/proc/aq_vend(mob/living/carbon/human/H)
	if(get_squad_loan(H))
		to_chat(H, "<span class='warning'>Najpierw zwróć pobrany zestaw.</span>")
		return FALSE
	var/datum/squad_loadout/aquila/kit = aq_loadout_for(H)
	if(!kit)
		return FALSE
	var/list/issued = aq_issued_items(kit, H.squad)
	var/datum/squad_loan/loan = new(H, kit, issued)
	var/obj/item/storage/aq_squad_crate/crate = new(get_turf(src))
	crate.assign(loan, kit.position, H.squad)
	for(var/path in issued)
		var/obj/item/thing = new path(crate)
		thing.forceMove(crate)
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
	H.put_in_hands(crate)
	log_game("[key_name(H)] took squad kit [kit.name] ([H.squad]) from [src] at [AREACOORD(src)]")
	ui_update()
	return TRUE

/// Zwrot wszystkiego z rąk, plecaka i skrzyń przy sobie (bez ubranego sprzętu)
/obj/machinery/squad_vendor/proc/aq_return_from_person(mob/living/carbon/human/H)
	var/list/to_check = list()
	for(var/obj/item/held in H.held_items)
		to_check += held
	var/obj/item/storage/backpack/bag = H.get_item_by_slot(ITEM_SLOT_BACK)
	if(bag)
		to_check += bag.GetAllContents(/obj/item) - bag
	for(var/obj/item/thing in to_check)
		if(QDELETED(thing) || istype(thing.loc, /obj/item/storage/aq_squad_crate))
			continue
		return_item(H, thing, quiet = TRUE)
	notify(H)

/obj/machinery/squad_vendor/return_item(mob/living/user, obj/item/I, quiet = FALSE)
	if(istype(I, /obj/item/storage/aq_squad_crate))
		var/obj/item/storage/aq_squad_crate/crate = I
		var/datum/squad_loan/crate_loan = crate.loan || get_squad_loan(user)
		for(var/obj/item/thing in crate.contents.Copy())
			if(crate_loan?.accept(thing))
				qdel(thing)
		if(length(crate.contents))
			if(!quiet)
				to_chat(user, "<span class='warning'>W skrzyni zostały rzeczy spoza zestawu. Wyjmij je, zanim oddasz skrzynię.</span>")
		else
			qdel(crate)
			if(!quiet)
				say("Skrzynia przyjęta.")
		aq_finish_loan(crate_loan)
		if(!quiet)
			notify(user, crate_loan)
		ui_update()
		return TRUE
	var/datum/squad_loan/loan = get_squad_loan(user)
	if(!loan || !loan.accept(I))
		return FALSE
	if(ismob(I.loc))
		var/mob/holder = I.loc
		holder.temporarilyRemoveItemFromInventory(I, TRUE)
	qdel(I)
	aq_finish_loan(loan)
	if(!quiet)
		notify(user, loan)
	ui_update()
	return TRUE

/// Zamyka wypożyczenie, gdy wszystko wróciło
/obj/machinery/squad_vendor/proc/aq_finish_loan(datum/squad_loan/loan)
	if(loan && !length(loan.outstanding))
		qdel(loan)

/obj/machinery/squad_vendor/notify(mob/living/user, datum/squad_loan/loan)
	if(!loan)
		loan = get_squad_loan(user)
	if(loan && !QDELETED(loan) && length(loan.outstanding))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='warning'>Do zwrotu zostało: [english_list(loan.outstanding_names())].</span>")
	else
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		say("Sprzęt zwrócony. Bezpiecznego dnia.")

/obj/machinery/squad_vendor/proc/aq_pay_fine(mob/living/carbon/human/H)
	var/datum/squad_loan/loan = get_squad_loan(H)
	if(!loan)
		return FALSE
	var/total = length(loan.outstanding) * SQUAD_LOAN_FINE
	if(alert(H, "Zostaniesz obciążony kwotą [total] kredytów.", "Grzywna za zgubiony sprzęt", "OK", "Anuluj") != "OK")
		return FALSE
	if(QDELETED(loan) || !H.canUseTopic(src, BE_CLOSE))
		return FALSE
	var/obj/item/card/id/card = H.get_idcard(TRUE)
	if(!card)
		say("Nie znaleziono karty ID.")
		return FALSE
	if(!card.registered_account)
		say("Nie znaleziono konta bankowego.")
		return FALSE
	if(!card.registered_account.adjust_money(-total))
		say("Nie masz na to środków.")
		return FALSE
	log_game("[key_name(H)] paid a [total] cr fine for unreturned squad gear")
	qdel(loan)
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
	say("Opłata przetworzona. Bezpiecznego dnia.")
	ui_update()
	return TRUE

/mob/living/carbon/human/Destroy()
	var/datum/squad_loan/loan = get_squad_loan(src)
	if(loan)
		loan.owner = null
	return ..()
