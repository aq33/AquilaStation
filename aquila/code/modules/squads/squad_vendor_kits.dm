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
	// tylko rzeczy z automatu: prywatna apteczka tego samego typu z plecaka nie jest zwrotem
	if(!thing.aq_squad_issued)
		return FALSE
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

/obj/item
	/// Wydany przez automat drużyny (razem z początkową zawartością); tylko takie rzeczy przyjmuje zwrot
	var/aq_squad_issued = FALSE

// Skrzynia zestawu: noszona w ręce, mieści tylko sprzęt z zestawów drużyn
/obj/item/storage/aq_squad_crate
	name = "skrzynia sprzętu drużyny"
	desc = "Wojskowa skrzynia na zestaw drużyny. Odłóż do niej sprzęt, choćby luzem, i oddaj ją do automatu drużyny."
	icon = 'aquila/icons/squads/squad_eqbox.dmi'
	icon_state = "eq-box-closed"
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
	/// Drużyna, której kolor mają paski skrzyni (po zmianie koloru drużyny skrzynia też się zmienia)
	var/datum/squad/squad
	/// Ile rzeczy było w skrzyni przy wydaniu: póki wszystkie są w środku, skrzynia jest zamknięta
	var/full_count = 0

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
		paths |= /obj/item/clothing/suit/ship/squad/aq_heavy
		kit_items = typecacheof(paths, only_root_path = TRUE)
	storage.can_hold = kit_items

/obj/item/storage/aq_squad_crate/Destroy()
	loan = null
	squad = null
	return ..()

/obj/item/storage/aq_squad_crate/proc/assign(datum/squad_loan/new_loan, new_position, datum/squad/squad)
	loan = new_loan
	position = new_position
	src.squad = squad
	name = "skrzynia: [lowertext(squad_position_pl(position))] drużyny [squad?.name || "?"]"
	update_icon()

/// Wypełniona przy wydaniu: zapamiętuje pełny stan (przedmioty stworzone w środku nie wywołują Entered())
/obj/item/storage/aq_squad_crate/proc/aq_filled()
	full_count = length(contents)
	update_icon()

// Skrzynia sprzętu (sprite eqbox z Aquili): zamknięta z pełnym zestawem, otwarta z widoczną zawartością,
// paski w kolorze drużyny
/obj/item/storage/aq_squad_crate/update_icon_state()
	icon_state = (full_count && length(contents) >= full_count) ? "eq-box-closed" : "eq-box-open"
	return ..()

/obj/item/storage/aq_squad_crate/update_overlays()
	. = ..()
	var/closed = icon_state == "eq-box-closed"
	var/mutable_appearance/stripes = mutable_appearance(icon, closed ? "eq-box-closed-colour-overlay" : "eq-box-open-colour-overlay")
	stripes.color = squad?.colour || "#888888"
	. += stripes
	if(closed)
		return
	var/magazines = 0
	var/has_armor = FALSE
	var/has_helmet = FALSE
	for(var/obj/item/thing in contents)
		if(istype(thing, /obj/item/clothing/suit))
			has_armor = TRUE
		else if(istype(thing, /obj/item/clothing/head))
			has_helmet = TRUE
		else if(istype(thing, /obj/item/ammo_box) || istype(thing, /obj/item/gun))
			magazines++
	if(has_armor)
		. += mutable_appearance(icon, "eq-box-armor-overlay")
	if(has_helmet)
		. += mutable_appearance(icon, "eq-box-helmet-overlay")
	if(magazines >= 1)
		. += mutable_appearance(icon, "eq-box-mag1-overlay")
	if(magazines >= 2)
		. += mutable_appearance(icon, "eq-box-mag2-overlay")

/obj/item/storage/aq_squad_crate/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_icon()

/obj/item/storage/aq_squad_crate/Exited(atom/movable/gone, direction)
	. = ..()
	update_icon()

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
	// XO wybiera w konsoli ciężki pancerz dla całej drużyny
	if(squad?.aq_heavy_armor && (/obj/item/clothing/suit/ship/squad in issued))
		issued -= /obj/item/clothing/suit/ship/squad
		issued += /obj/item/clothing/suit/ship/squad/aq_heavy
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

/obj/machinery/squad_vendor/ui_act(action, list/params)
	// stara obsługa NSV13 (w ..()) wydaje zestaw z params["item_id"] bez rejestru wydań; bez tego klucza nic nie robi
	params?.Remove("item_id")
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
		var/obj/item/issued_item = new path(crate)
		for(var/obj/item/part in issued_item.GetAllContents())
			part.aq_squad_issued = TRUE
	crate.aq_filled()
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
				aq_release_foreign(thing)
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
	aq_release_foreign(I)
	qdel(I)
	aq_finish_loan(loan)
	if(!quiet)
		notify(user, loan)
	ui_update()
	return TRUE

/// Przed skasowaniem zwróconego pojemnika (apteczka, pas, pudełko) wykłada to, czego automat nie wydał, np. dołożone pigułki
/obj/machinery/squad_vendor/proc/aq_release_foreign(obj/item/returned)
	for(var/obj/item/inner in returned.GetAllContents() - returned)
		if(!inner.aq_squad_issued && !QDELETED(inner))
			inner.forceMove(drop_location())

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

// Ciężki pancerz drużyny: wydawany zamiast lekkiego, gdy XO tak ustawi w konsoli. Lepsza ochrona kosztem szybkości.
// Sprite kamizelki piechoty morskiej NSV (nsv13/icons/obj/clothing/suits.dmi, stan "marine"), bez pasków drużyny.
/datum/squad
	/// Czy automat wydaje drużynie ciężki pancerz zamiast lekkiego
	var/aq_heavy_armor = FALSE

/obj/item/clothing/suit/ship/squad/aq_heavy
	name = "ciężki pancerz"
	desc = "Ciężki pancerz z płytami balistycznymi dla drużyn wysyłanych do walki. Chroni dużo lepiej od lekkiego, ale spowalnia."
	icon_state = "marine"
	item_state = "marine"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 1
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	armor = list("melee" = 45, "bullet" = 60, "laser" = 25, "energy" = 20, "bomb" = 50, "bio" = 20, "rad" = 25, "fire" = 40, "acid" = 60, "bleed" = 30)

/// Sprite "marine" nie ma warstwy pasków ("marine_stripes"), więc tylko nazwa i drużyna (pełne nadpisanie dla podtypu)
/obj/item/clothing/suit/ship/squad/aq_heavy/apply_squad(datum/squad/squad)
	if(!istype(squad))
		var/mob/living/carbon/human/user = ishuman(loc) ? loc : loc?.loc
		if(!ishuman(user) || !user.squad)
			return
		squad = user.squad
	name = "[initial(name)] drużyny [squad]"
	src.squad = squad
