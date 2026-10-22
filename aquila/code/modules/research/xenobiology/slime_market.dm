// Rynek ekstraktów szlamu (port SLIMECORE z Monkestation 2.0, Monkestation/Monkestation2.0#1442).
// Zastępuje maszynę do plortów. Pad skupuje ekstrakty za xenobio points i daje punkty badań jak dawniej,
// ale cena każdego koloru spada przy sprzedaży i rośnie, gdy sprzedaje się inne kolory.
// Za punkty kupuje się rzeczy w sklepie konsoli rynku. Pad zamówień pozwala załodze zamawiać ekstrakty za kredyty.

/// O ile procent spada cena sprzedanego ekstraktu (losowo między MIN a MAX)
#define SLIME_SELL_MODIFIER_MIN -0.08
#define SLIME_SELL_MODIFIER_MAX -0.01
/// O ile procent rośnie cena pozostałych ekstraktów przy każdej sprzedaży
#define SLIME_SELL_OTHER_MODIFIER_MIN 0.005
#define SLIME_SELL_OTHER_MODIFIER_MAX 0.01
/// Cena nie przekroczy tylu razy ceny bazowej
#define SLIME_SELL_MAXIMUM_MODIFIER 2
/// Cena nie spadnie poniżej tej części ceny bazowej
#define SLIME_SELL_MINIMUM_MODIFIER 0.1
/// Losowe wahanie cen co sekundę
#define SLIME_RANDOM_MODIFIER_MIN -0.0003
#define SLIME_RANDOM_MODIFIER_MAX 0.0003
/// Cena bazowa w xenobio points to plort_value ekstraktu razy tyle
#define SLIME_MARKET_PRICE_PER_PLORT 20

GLOBAL_DATUM_INIT(slime_market, /datum/slime_market, new)

/// Punkty i ceny rynku są wspólne dla całej rundy, jak SSresearch u Monke
/datum/slime_market
	/// Xenobio points do wydania w sklepie
	var/points = 0
	/// typ ekstraktu -> obecna cena w punktach
	var/list/prices = list()
	/// typ ekstraktu -> cena bazowa
	var/list/base_prices = list()

/datum/slime_market/New()
	for(var/obj/item/slime_extract/core as anything in subtypesof(/obj/item/slime_extract))
		base_prices[core] = initial(core.plort_value) * SLIME_MARKET_PRICE_PER_PLORT
		prices[core] = base_prices[core]
	START_PROCESSING(SSprocessing, src)

/datum/slime_market/process(delta_time)
	for(var/core_type in prices)
		var/price_mod = rand(SLIME_RANDOM_MODIFIER_MIN * 1000000, SLIME_RANDOM_MODIFIER_MAX * 1000000) / 1000000
		var/price_limiter = 1 - ((base_prices[core_type] * SLIME_SELL_MINIMUM_MODIFIER) / prices[core_type])
		prices[core_type] = (1 + price_mod * price_limiter) * prices[core_type]

/// Ile punktów dostaje się teraz za ten ekstrakt
/datum/slime_market/proc/get_price(core_type)
	return round(prices[core_type])

/// Obecna cena jako ułamek ceny bazowej
/datum/slime_market/proc/get_price_ratio(core_type)
	if(!base_prices[core_type])
		return 1
	return prices[core_type] / base_prices[core_type]

/// Dolicza punkty za ekstrakt i przesuwa ceny. Zwraca liczbę zdobytych punktów.
/datum/slime_market/proc/sell(core_type)
	if(!prices[core_type])
		return 0
	var/earned = get_price(core_type)
	points += earned

	var/price_mod = rand(SLIME_SELL_MODIFIER_MIN * 10000, SLIME_SELL_MODIFIER_MAX * 10000) / 10000
	var/price_limiter = 1 - ((base_prices[core_type] * SLIME_SELL_MINIMUM_MODIFIER) / prices[core_type])
	prices[core_type] = (1 + price_mod * price_limiter) * prices[core_type]

	for(var/other_type in prices)
		if(other_type == core_type)
			continue
		price_mod = rand(SLIME_SELL_OTHER_MODIFIER_MIN * 100000, SLIME_SELL_OTHER_MODIFIER_MAX * 100000) / 100000
		price_limiter = 1 - (prices[other_type] / (base_prices[other_type] * SLIME_SELL_MAXIMUM_MODIFIER))
		prices[other_type] = (1 + price_mod * price_limiter) * prices[other_type]
	return earned

/obj/machinery/slime_market_pad
	name = "intergalactic market pad"
	desc = "Wysoki pad z otworem na ekstrakty szlamu. Sprzedaje je na rynku międzygalaktycznym za xenobio points i przesyła dane do sieci badań."
	icon = 'aquila/icons/obj/xenobiology/slime_market.dmi'
	icon_state = "market_pad"
	base_icon_state = "market_pad"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 250
	circuit = /obj/item/circuitboard/machine/slime_market_pad
	/// Mnożnik punktów badań, jak w dawnej maszynie do plortów
	var/research_point_multiplier = 1
	var/datum/techweb/linked_techweb

/obj/machinery/slime_market_pad/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech

/obj/machinery/slime_market_pad/Destroy()
	linked_techweb = null
	return ..()

/obj/machinery/slime_market_pad/RefreshParts()
	var/rating = 0
	var/parts = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating += M.rating
		parts++
	research_point_multiplier = parts ? rating / parts : 1

/obj/machinery/slime_market_pad/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: dane badawcze za <b>[research_point_multiplier * 100]%</b> wartości rdzeni.</span>"
	if(panel_open)
		. += "<span class='notice'>Panel jest <i>odkręcony</i>.</span>"
	. += "<span class='notice'>Zamówienia załogi realizujesz, wkładając pasujący ekstrakt. Ceny i sklep są w konsoli rynku szlamów.</span>"

/obj/machinery/slime_market_pad/update_overlays()
	. = ..()
	if(panel_open)
		. += "market_pad-panel"

/obj/machinery/slime_market_pad/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		update_appearance()
		return
	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return ..()

	if(istype(W, /obj/item/slime_extract))
		if(try_fill_request(W, user))
			return
		flick("[base_icon_state]_vend", src)
		var/earned = sell_extract(W)
		to_chat(user, "<span class='notice'>Sprzedajesz [W] za [earned] xenobio points.</span>")
		qdel(W)
		return

	if(istype(W, /obj/item/storage/bag/bio))
		var/sold = 0
		var/earned = 0
		for(var/obj/item/slime_extract/extract in W)
			if(!SEND_SIGNAL(W, COMSIG_TRY_STORAGE_TAKE, extract, src))
				continue
			earned += sell_extract(extract)
			qdel(extract)
			sold++
		if(sold)
			flick("[base_icon_state]_vend", src)
			to_chat(user, "<span class='notice'>Wysypujesz rdzenie szlamu ([sold]) z [W] do [src] i zarabiasz [earned] xenobio points.</span>")
		else
			to_chat(user, "<span class='warning'>W [W] nie ma żadnych rdzeni szlamu!</span>")
		return
	return ..()

/// Sprzedaje ekstrakt: xenobio points według ceny rynkowej i punkty badań według plort_value. Nie usuwa przedmiotu.
/obj/machinery/slime_market_pad/proc/sell_extract(obj/item/slime_extract/extract)
	var/ratio = GLOB.slime_market.get_price_ratio(extract.type)
	linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, round(extract.plort_value * ratio * research_point_multiplier))
	return GLOB.slime_market.sell(extract.type)

/// Gdy któreś zamówienie czeka na taki ekstrakt, pyta, czy go sprzedać, czy oddać do zamówienia. TRUE = obsłużone.
/obj/machinery/slime_market_pad/proc/try_fill_request(obj/item/slime_extract/extract, mob/user)
	var/obj/machinery/computer/slime_market/console = GLOB.default_slime_market
	var/obj/machinery/slime_extract_requestor/request_pad = console?.request_pad
	if(QDELETED(request_pad))
		return FALSE
	var/list/choices = list()
	var/list/choice_to_request = list()
	for(var/datum/extract_request_data/request as anything in request_pad.current_requests)
		if(request.extract_path != extract.type || request.ready_for_pickup)
			continue
		choices[request.request_name] = image(icon = extract.icon, icon_state = extract.icon_state)
		choice_to_request[request.request_name] = request
	if(!length(choices))
		return FALSE
	choices["Sprzedaj"] = image(icon = 'icons/obj/economy.dmi', icon_state = "spacecash100")
	var/choice = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	if(!choice || QDELETED(extract) || !user.is_holding(extract))
		return TRUE
	if(choice == "Sprzedaj")
		return FALSE
	var/datum/extract_request_data/chosen = choice_to_request[choice]
	if(QDELETED(chosen) || chosen.ready_for_pickup)
		return TRUE
	chosen.add_extract()
	flick("[base_icon_state]_vend", src)
	to_chat(user, "<span class='notice'>Oddajesz [extract] do zamówienia: [chosen.request_name].</span>")
	qdel(extract)
	return TRUE

GLOBAL_DATUM(default_slime_market, /obj/machinery/computer/slime_market)

/obj/machinery/computer/slime_market
	name = "slime market console"
	desc = "Konsola rynku ekstraktów szlamu: aktualne ceny, zamówienia załogi i sklep za xenobio points."
	icon = 'aquila/icons/obj/xenobiology/slime_market.dmi'
	icon_state = "market"
	icon_screen = "market_screen"
	icon_keyboard = null
	light_color = LIGHT_COLOR_LAVENDER
	circuit = /obj/item/circuitboard/computer/slime_market
	/// Pad zamówień, z którego załoga zamawia ekstrakty
	var/obj/machinery/slime_extract_requestor/request_pad
	var/static/list/slime_shop_items

/obj/machinery/computer/slime_market/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(!GLOB.default_slime_market && is_station_level(z))
		GLOB.default_slime_market = src
	if(!slime_shop_items)
		slime_shop_items = list()
		for(var/datum/slime_store_item/item_type as anything in subtypesof(/datum/slime_store_item))
			slime_shop_items += new item_type

/obj/machinery/computer/slime_market/Destroy()
	if(GLOB.default_slime_market == src)
		GLOB.default_slime_market = null
	if(request_pad?.console == src)
		request_pad.console = null
	request_pad = null
	return ..()

/obj/machinery/computer/slime_market/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/M = I
	if(!istype(M))
		return FALSE
	if(!istype(M.buffer, /obj/machinery/slime_extract_requestor))
		M.buffer = src
		to_chat(user, "<span class='notice'>Zapisujesz [src] w buforze multitoola.</span>")
		return TRUE
	var/obj/machinery/slime_extract_requestor/pad = M.buffer
	pad.link_console(src)
	to_chat(user, "<span class='notice'>Łączysz [pad] z [src].</span>")
	return TRUE

/obj/machinery/computer/slime_market/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenobioMarket", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/slime_market/ui_static_data(mob/user)
	var/list/data = list()
	data["shop_items"] = list()
	for(var/datum/slime_store_item/item as anything in slime_shop_items)
		var/obj/item/path = item.item_path
		data["shop_items"] += list(list(
			"name" = item.name,
			"desc" = item.desc,
			"icon" = initial(path.icon),
			"icon_state" = initial(path.icon_state),
			"cost" = item.cost,
			"ref" = REF(item),
		))
	return data

/obj/machinery/computer/slime_market/ui_data(mob/user)
	var/list/data = list()
	data["points"] = GLOB.slime_market.points
	data["prices"] = list()
	for(var/obj/item/slime_extract/core as anything in GLOB.slime_market.prices)
		data["prices"] += list(list(
			"name" = initial(core.name),
			"icon" = initial(core.icon),
			"icon_state" = initial(core.icon_state),
			"price" = GLOB.slime_market.get_price(core),
			"ratio" = GLOB.slime_market.get_price_ratio(core),
		))
	data["requests"] = list()
	if(request_pad)
		for(var/datum/extract_request_data/request as anything in request_pad.current_requests)
			var/obj/item/request_item = request.extract_path
			data["requests"] += list(list(
				"name" = request.request_name,
				"icon" = initial(request_item.icon),
				"icon_state" = initial(request_item.icon_state),
				"amount" = request.extracts_needed,
				"amount_given" = request.extracts_given,
				"payout" = request.payout,
				"points" = request.payout * SLIME_REQUEST_POINTS_PER_CREDIT,
				"ready" = request.ready_for_pickup,
			))
	data["has_request_pad"] = !!request_pad
	return data

/obj/machinery/computer/slime_market/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy")
			var/datum/slime_store_item/item = locate(params["ref"]) in slime_shop_items
			if(!item)
				return
			if(GLOB.slime_market.points < item.cost)
				say("Za mało xenobio points.")
				return
			GLOB.slime_market.points -= item.cost
			new item.item_path(drop_location())
			playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
			return TRUE

/// Oddaje ekstrakty z anulowanego zamówienia
/obj/machinery/computer/slime_market/proc/return_extracts(extract_type, amount)
	for(var/i in 1 to amount)
		new extract_type(drop_location())

/// Pozycja sklepu rynku szlamów
/datum/slime_store_item
	var/name = "przedmiot"
	var/desc = ""
	var/obj/item/item_path
	var/cost = 0

/datum/slime_store_item/monkey_cubes
	name = "Pudełko kostek małp"
	desc = "Cztery kostki małp na pokarm dla szlamów."
	item_path = /obj/item/storage/box/monkeycubes
	cost = 400

/datum/slime_store_item/bio_bag
	name = "Torba bio"
	desc = "Torba na ekstrakty szlamu."
	item_path = /obj/item/storage/bag/bio
	cost = 200

/datum/slime_store_item/slime_scanner
	name = "Skaner szlamów"
	desc = "Pokazuje głód, kolor i możliwe mutacje szlama."
	item_path = /obj/item/slime_scanner
	cost = 200

/datum/slime_store_item/docility
	name = "Mikstura uległości"
	desc = "Szlam staje się na zawsze potulny i przestaje głodnieć."
	item_path = /obj/item/slimepotion/slime/docility
	cost = 1500

/datum/slime_store_item/steroid
	name = "Steryd dla szlamów"
	desc = "Młody szlam da więcej ekstraktów."
	item_path = /obj/item/slimepotion/slime/steroid
	cost = 1500

/datum/slime_store_item/stabilizer
	name = "Stabilizator szlamów"
	desc = "Obniża szansę mutacji szlama."
	item_path = /obj/item/slimepotion/slime/stabilizer
	cost = 1500

/datum/slime_store_item/mutator
	name = "Mutator szlamów"
	desc = "Podnosi szansę mutacji szlama."
	item_path = /obj/item/slimepotion/slime/mutator
	cost = 2000

/datum/slime_store_item/random_color
	name = "Strzykawka losowej mutacji"
	desc = "Od razu zmienia kolor szlama na jedną z jego możliwych mutacji."
	item_path = /obj/item/slime_mutation_syringe/random_color
	cost = 3000

/datum/slime_store_item/speed
	name = "Mikstura szybkości"
	desc = "Przedmiot staje się lżejszy w noszeniu i nie spowalnia."
	item_path = /obj/item/slimepotion/speed
	cost = 3000

/// Strzykawka mutacji szlamów (Monke ma też strzykawki cech, tu na razie tylko losowy kolor)
/obj/item/slime_mutation_syringe
	name = "slime mutation syringe"
	desc = "Wstrzykuje szlamowi mutację."
	icon = 'aquila/icons/obj/xenobiology/mutation_syringe.dmi'
	icon_state = "mutation_syringe"
	w_class = WEIGHT_CLASS_SMALL
	/// Ile razy można jej jeszcze użyć
	var/uses = 1

/obj/item/slime_mutation_syringe/examine(mob/user)
	. = ..()
	if(uses)
		. += "<span class='notice'>Zostało użyć: <b>[uses]</b>.</span>"
	else
		. += "<span class='warning'>Jest całkiem pusta.</span>"

/obj/item/slime_mutation_syringe/update_icon_state()
	icon_state = uses ? initial(icon_state) : "[initial(icon_state)]-empty"
	return ..()

/obj/item/slime_mutation_syringe/attack(mob/living/M, mob/living/user)
	if(!isslime(M))
		return ..()
	if(!uses)
		to_chat(user, "<span class='warning'>[src] jest pusta!</span>")
		return
	var/mob/living/simple_animal/slime/slime = M
	if(slime.stat == DEAD)
		to_chat(user, "<span class='warning'>Ten szlam nie żyje!</span>")
		return
	if(!on_inject(slime, user))
		return
	uses--
	update_appearance()

/// Działanie strzykawki. FALSE = nie zużywa się.
/obj/item/slime_mutation_syringe/proc/on_inject(mob/living/simple_animal/slime/slime, mob/living/user)
	return FALSE

/obj/item/slime_mutation_syringe/random_color
	name = "random color slime mutation syringe"
	desc = "Wstrzykuje szlamowi zmutowany materiał. Szlam od razu zmienia kolor na jedną ze swoich możliwych mutacji."

/obj/item/slime_mutation_syringe/random_color/on_inject(mob/living/simple_animal/slime/slime, mob/living/user)
	var/list/options = list()
	for(var/colour in slime.slime_mutation)
		if(colour && colour != slime.colour)
			options |= colour
	if(!length(options))
		to_chat(user, "<span class='warning'>[slime] nie może już zmutować w inny kolor.</span>")
		return FALSE
	var/old_name = slime.name
	slime.set_colour(pick(options))
	slime.visible_message("<span class='notice'>[old_name] drży i zmienia kolor: teraz to [slime].</span>")
	return TRUE

/obj/item/circuitboard/machine/slime_market_pad
	name = "Intergalactic Market Pad (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/slime_market_pad
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/computer/slime_market
	name = "Slime Market Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/slime_market

/datum/design/board/slime_market_pad
	name = "Machine Design (Intergalactic Market Pad)"
	desc = "The circuit board for a slime market pad."
	id = "slime_market_pad"
	build_path = /obj/item/circuitboard/machine/slime_market_pad
	category = list("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/slime_market
	name = "Computer Design (Slime Market Console)"
	desc = "The circuit board for a slime market console."
	id = "slime_market"
	build_path = /obj/item/circuitboard/computer/slime_market
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

#undef SLIME_SELL_MODIFIER_MIN
#undef SLIME_SELL_MODIFIER_MAX
#undef SLIME_SELL_OTHER_MODIFIER_MIN
#undef SLIME_SELL_OTHER_MODIFIER_MAX
#undef SLIME_SELL_MAXIMUM_MODIFIER
#undef SLIME_SELL_MINIMUM_MODIFIER
#undef SLIME_RANDOM_MODIFIER_MIN
#undef SLIME_RANDOM_MODIFIER_MAX
#undef SLIME_MARKET_PRICE_PER_PLORT
#undef SLIME_REQUEST_POINTS_PER_CREDIT
