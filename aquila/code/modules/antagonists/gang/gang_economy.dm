// Ekonomia gangów Aquili wzorowana na trybie gang war z Goonstation (kod pisany od nowa według opisu mechaniki).
// Zamiast wspólnych „wpływów” każdy członek ma własne punkty. Każdy przychód gangu dostaje każdy członek,
// a ten, kto go przyniósł, dostaje 25% więcej. Wynik gangu to suma przychodów z terenu, gotówki, broni, narkotyków i zrzutów.

/datum/team/gang
	/// Punkty członków: umysł -> punkty
	var/list/points = list()
	/// Wynik gangu: rodzaj przychodu -> suma
	var/list/score = list()
	/// Stan ikony znaku w crayondecal.dmi; nazwa gangu może się zmienić, ikona zostaje
	var/tag_icon
	/// Szafka gangu (baza)
	var/obj/structure/gang_locker/locker
	/// Ile jednostek każdego narkotyku gang już sprzedał (typ reagentu -> jednostki)
	var/list/drug_units_sold = list()
	/// Przy których członkach zanotowano już startowe punkty
	var/list/minds_with_start_points = list()

/datum/team/gang/New(starting_members)
	tag_icon = name
	. = ..()
	aq_gang_controller()

/datum/team/gang/add_member(datum/mind/new_member)
	. = ..()
	if(!(new_member in minds_with_start_points))
		minds_with_start_points += new_member
		points[new_member] = GANG_START_POINTS

/datum/team/gang/proc/get_points(datum/mind/member)
	return points[member] || 0

/datum/team/gang/proc/adjust_points(datum/mind/member, amount)
	points[member] = max(0, get_points(member) + amount)

/// Przychód gangu: każdy członek dostaje `amount`, a `earner` dodatkowo 25%. Dolicza się do wyniku gangu w rubryce `source`.
/datum/team/gang/proc/add_income(amount, source = GANG_SCORE_EVENT, datum/mind/earner)
	if(amount <= 0)
		return
	for(var/datum/mind/member as anything in members)
		adjust_points(member, amount)
	if(earner && (earner in members))
		adjust_points(earner, round(amount * GANG_EARNER_BONUS))
	score[source] = (score[source] || 0) + amount

/datum/team/gang/proc/total_score()
	. = 0
	for(var/source in score)
		. += score[source]

/// Wiadomość do wszystkich żywych członków gangu (Goon używa radia gangu, my mamy gangtool i czat)
/datum/team/gang/proc/message_gang(message)
	for(var/datum/mind/member as anything in members)
		var/mob/living/M = member.current
		if(!istype(M) || M.stat == DEAD)
			continue
		to_chat(M, "<span class='syndradio'><b>\[Gang [name]\]</b> [message]</span>")
		SEND_SOUND(M, sound('sound/machines/twobeep.ogg', volume = 40))

// Raport co trzy minuty: punkty i teren zamiast wpływów (pełne nadpisanie, wpis w LEGACY_OVERRIDES.md).
// Stary raport podwajał wpływy (update_influence zwracał wpływy razem z przyrostem), wpływów już nie ma.
/datum/team/gang/handle_territories()
	next_point_time = world.time + 3 MINUTES
	addtimer(CALLBACK(src, PROC_REF(handle_territories)), 3 MINUTES)
	for(var/datum/mind/member as anything in members)
		var/mob/living/M = member.current
		if(!istype(M) || M.stat == DEAD)
			continue
		to_chat(M, "<span class='syndradio'><b>Raport gangu [name]:</b> teren [territory_percent()]% stacji, wynik gangu [total_score()], twoje punkty: [get_points(member)].</span>")

/datum/team/gang/roundend_report()
	. = ..()
	. += "<div class='panel redborder'>Wynik gangu [name]: <b>[total_score()]</b> (teren [score[GANG_SCORE_TURF] || 0], gotówka [score[GANG_SCORE_CASH] || 0], broń [score[GANG_SCORE_GUN] || 0], narkotyki [score[GANG_SCORE_DRUG] || 0], zrzuty [score[GANG_SCORE_EVENT] || 0])</div>"

// Wpływy zostają tylko dla zgodności z kodem z core; panel admina zmienia teraz punkty członka
/datum/antagonist/gang/admin_adjust_influence()
	var/new_points = input("Punkty [owner.name] w gangu [gang.name]", "Punkty gangstera", gang.get_points(owner)) as null|num
	if(isnull(new_points))
		return
	gang.points[owner] = max(0, new_points)
	message_admins("[key_name_admin(usr)] zmienia punkty [owner.name] w gangu [gang.name] na [new_points].")
	log_admin("[key_name(usr)] changed [owner.name]'s points in [gang.name] to [new_points].")

/// Punkty za jednostkę narkotyku w skupie szafki
/proc/aq_gang_drug_values()
	var/static/list/values = list(
		/datum/reagent/drug/bath_salts = 3,
		/datum/reagent/drug/krokodil = 3,
		/datum/reagent/drug/methamphetamine = 1.5,
		/datum/reagent/drug/crank = 1,
		/datum/reagent/drug/ketamine = 1,
		/datum/reagent/drug/happiness = 1,
		/datum/reagent/drug/aranesp = 1,
		/datum/reagent/medicine/morphine = 1,
		/datum/reagent/drug/space_drugs = 0.5,
		/datum/reagent/drug/mushroomhallucinogen = 0.5,
	)
	return values

/// Mnożnik skupu narkotyku po `already_sold` jednostkach: pierwsze 300 j. ×3, potem maleje liniowo do zera przy limicie
/proc/aq_gang_drug_multiplier(already_sold)
	if(already_sold < GANG_DRUG_BONUS_UNITS)
		return 3
	if(already_sold >= GANG_DRUG_UNIT_LIMIT)
		return 0
	return 1 - (already_sold - GANG_DRUG_BONUS_UNITS) / (GANG_DRUG_UNIT_LIMIT - GANG_DRUG_BONUS_UNITS)

/// Ile jednostek narkotyku gang jeszcze skupi (0 dla rzeczy, które nie są skupowanymi narkotykami)
/datum/team/gang/proc/drug_units_left(reagent_type)
	if(!aq_gang_drug_values()[reagent_type])
		return 0
	return max(0, GANG_DRUG_UNIT_LIMIT - (drug_units_sold[reagent_type] || 0))

/// Punkty za sprzedaż `units` jednostek narkotyku `reagent_type` (najwyżej do limitu); bez `dry_run` zapisuje sprzedaż w gangu
/datum/team/gang/proc/sell_drug(reagent_type, units, dry_run = FALSE)
	var/value = aq_gang_drug_values()[reagent_type]
	units = min(units, drug_units_left(reagent_type))
	if(!value || units <= 0)
		return 0
	. = 0
	var/sold = drug_units_sold[reagent_type] || 0
	// Liczone porcjami po 10 j., żeby próg 300 j. i spadek mnożnika działały w środku jednej dużej zlewki
	while(units > 0)
		var/portion = min(units, 10)
		. += portion * value * aq_gang_drug_multiplier(sold)
		sold += portion
		units -= portion
	. = round(.)
	if(!dry_run && . > 0)
		drug_units_sold[reagent_type] = sold

///////////////////
// Sklep: ceny w punktach, sklep sprzętu w szafce, narzędzia szefa w gangtoolu
///////////////////

/datum/gang_item
	/// Sprzedawane w szafce gangu (każdy członek), a nie w gangtoolu (szefowie)
	var/locker_item = FALSE

// Zakup za punkty kupującego (pełne nadpisanie, wpis w LEGACY_OVERRIDES.md: core sprawdzał wspólne wpływy)
/datum/gang_item/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return gang && user?.mind && gang.get_points(user.mind) >= get_cost(user, gang, gangtool) && can_see(user, gang, gangtool)

/datum/gang_item/can_see(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	// Gangtool pokazuje narzędzia szefa, szafka (bez gangtoola) sprzęt dla wszystkich
	if(locker_item == !isnull(gangtool))
		return FALSE
	return ..()

/datum/gang_item/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, gangtool))
		return FALSE
	var/real_cost = get_cost(user, gang, gangtool)
	if(spawn_item(user, gang, gangtool))
		return FALSE
	gang.adjust_points(user.mind, -real_cost)
	to_chat(user, "<span class='notice'>Kupujesz: [name] ([real_cost] pkt).</span>")
	return TRUE

/datum/gang_item/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return "([get_cost(user, gang, gangtool)] pkt)"

// Gangtool nie pokazuje pustych kategorii sklepu szafki
/obj/item/device/gangtool/Initialize(mapload)
	. = ..()
	for(var/cat in buyable_items.Copy())
		var/list/items = buyable_items[cat]
		var/any_tool_item = FALSE
		for(var/id in items)
			var/datum/gang_item/G = items[id]
			if(!G.locker_item)
				any_tool_item = TRUE
				break
		if(!any_tool_item)
			buyable_items -= cat

/// Towary szafki według kategorii (te same datumy co w gangtoolu, ale z locker_item)
/proc/aq_gang_locker_items()
	var/static/list/items
	if(!items)
		items = list()
		for(var/datum/gang_item/path as anything in subtypesof(/datum/gang_item))
			if(!initial(path.id) || !initial(path.locker_item))
				continue
			var/datum/gang_item/G = new path
			if(!islist(items[G.category]))
				items[G.category] = list()
			items[G.category][G.id] = G
	return items

// Narzędzia szefa (gangtool)
/datum/gang_item/essentials/spraycan
	cost = 300

/datum/gang_item/essentials/implant_breaker
	cost = 2500

/datum/gang_item/essentials/gangtool
	cost = 3000

/datum/gang_item/essentials/pen
	cost = 3000

/datum/gang_item/essentials/reinforce
	cost = 6000

// Ubrania (szafka). Mundur odbiera się w szafce za darmo co 5 minut.
/datum/gang_item/clothing
	category = "Ubrania gangu"
	locker_item = TRUE

/datum/gang_item/clothing/basic
	id = null

/datum/gang_item/clothing/armor
	cost = 3500

/datum/gang_item/clothing/ssuit
	cost = 3500

/datum/gang_item/clothing/mask
	cost = 500

/datum/gang_item/clothing/shoes
	cost = 500

/datum/gang_item/clothing/neck
	cost = 300

/datum/gang_item/clothing/hands
	cost = 500

/datum/gang_item/clothing/belt
	cost = 300

// Broń (szafka): broń biała jak u Goona, broń palna z wyższej półki przychodzi ze zrzutów
/datum/gang_item/weapon
	category = "Broń"
	locker_item = TRUE

/datum/gang_item/weapon/emp
	id = null

/datum/gang_item/weapon/c4
	id = null

/datum/gang_item/weapon/uzi
	id = null

/datum/gang_item/weapon/uzi_ammo
	id = null

/datum/gang_item/weapon/laser
	id = null

/datum/gang_item/weapon/switchblade
	cost = 1700

/datum/gang_item/weapon/shuriken
	cost = 800

/datum/gang_item/weapon/pistol
	cost = 8000

/datum/gang_item/weapon/pistol_ammo
	cost = 800

/datum/gang_item/weapon/throwing_knife
	name = "Nóż do rzucania"
	id = "throwing_knife"
	cost = 700
	item_path = /obj/item/kitchen/knife/gang_throwing

/datum/gang_item/weapon/cleaver
	name = "Tasak"
	id = "cleaver"
	cost = 1200
	item_path = /obj/item/kitchen/knife/butcher

/datum/gang_item/weapon/baseball_bat
	name = "Kij bejsbolowy"
	id = "baseball_bat"
	cost = 2000
	item_path = /obj/item/melee/baseball_bat

/datum/gang_item/weapon/cheap_katana
	name = "Tania katana"
	id = "cheap_katana"
	cost = 10000
	item_path = /obj/item/katana/gang_cheap

// Sprzęt (szafka)
/datum/gang_item/equipment
	category = "Sprzęt"
	locker_item = TRUE

/datum/gang_item/equipment/healcigs
	cost = 800

// Gotówka kupiona za punkty wracałaby do szafki jako punkty z prania
/datum/gang_item/equipment/mulah
	id = null

/datum/gang_item/equipment/drugs
	cost = 1500

/datum/gang_item/equipment/aids
	cost = 800

/datum/gang_item/equipment/hangover
	cost = 800

///////////////////
// Nowa broń biała
///////////////////

/obj/item/kitchen/knife/gang_throwing
	name = "nóż do rzucania"
	desc = "Wyważony nóż bez rękojeści, robiony do rzucania, nie do krojenia."
	icon = 'aquila/icons/obj/munitions_forge/smithing.dmi'
	icon_state = "throwing_knife"
	force = 8
	throwforce = 18
	throw_speed = 4
	embedding = list("pain_mult" = 3, "embed_chance" = 75, "fall_chance" = 10, "armour_block" = 60)
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 40

/obj/item/katana/gang_cheap
	name = "tania katana"
	desc = "Katana z targu z podróbkami. Tnie, ale stal pęknie przy pierwszej okazji."
	force = 22
	throwforce = 8
	block_power = 5
	bleed_force = BLEED_CUT
	max_integrity = 80
