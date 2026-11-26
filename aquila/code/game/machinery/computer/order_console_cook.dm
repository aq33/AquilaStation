/**
 * Konsola zamówień kuchni i baru, port /obj/machinery/computer/order_console/cook z tg.
 * Różnice względem tg:
 * - płaci budżet działu usług (ACCOUNT_SRV), nie konto osobiste z karty; zamawiać może ktoś z dostępem do kuchni albo baru,
 * - zwykła dostawa przychodzi jako opłacona z góry zamrażarka na promie zaopatrzenia (supply_pack/order_console, jak u bitrunnerów),
 * - asortyment ograniczony do tego, co u nas istnieje, i poszerzony o bar (trunki, soki, napoje, lód),
 * - ceny pomnożone przez 2 względem tg (u nas ceny cargo są mniej więcej dwa razy wyższe), minimum zwykłej dostawy 400 kr.
 */

#define CATEGORY_KITCHEN_PRODUCE "Warzywa i owoce"
#define CATEGORY_KITCHEN_MEAT_DAIRY "Mięso, nabiał i jajka"
#define CATEGORY_KITCHEN_PANTRY "Spiżarnia i przyprawy"
#define CATEGORY_KITCHEN_BAR "Bar"

/obj/machinery/computer/order_console/cook
	name = "konsola zamówień kuchni"
	desc = "Interfejs do zamawiania świeżych produktów dla kuchni i baru. Płaci budżet działu usług. Drożej niż u botaników, ale cóż."
	circuit = /obj/item/circuitboard/computer/order_console/cook
	req_one_access = list(ACCESS_KITCHEN, ACCESS_BAR)
	cargo_cost_multiplier = 0.65
	purchase_tooltip = "Zakupy przylecą w zamrażarce najbliższym promem zaopatrzenia, mniej więcej po cenach z listy (łączna kwota jest zaokrąglana, dokładną widać na przycisku). Płaci budżet działu usług."
	express_tooltip = "Zakupy spadną od razu w kapsule pod twoje nogi, około trzy razy drożej niż ceny z listy. Płaci budżet działu usług."
	order_categories = list(
		CATEGORY_KITCHEN_PRODUCE,
		CATEGORY_KITCHEN_MEAT_DAIRY,
		CATEGORY_KITCHEN_PANTRY,
		CATEGORY_KITCHEN_BAR,
	)
	blackbox_key = "chef"
	announcement_line = "Kuchnia zamówiła zakupy, które przylecą promem zaopatrzenia! Dopilnujcie, żeby jak najszybciej do niej trafiły!"
	free_uses = 0
	/// Minimalna wartość zwykłej dostawy po rabacie (tg: CARGO_CRATE_VALUE = 200, u nas ×2)
	var/minimum_order_value = 400

/obj/machinery/computer/order_console/cook/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/cooking_voucher))
		return ..()
	if(!user.temporarilyRemoveItemFromInventory(weapon))
		return TRUE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 33, TRUE)
	balloon_alert(user, "bon zrealizowany")
	free_uses += 10
	qdel(weapon)
	SStgui.update_uis(src)
	return TRUE

/// Budżet działu usług, z którego konsola płaci
/obj/machinery/computer/order_console/cook/proc/get_budget()
	return SSeconomy.get_dep_account(ACCOUNT_SRV)

/obj/machinery/computer/order_console/cook/retrieve_points(obj/item/card/id/id_card)
	var/datum/bank_account/budget = get_budget()
	return round(budget?.account_balance)

/obj/machinery/computer/order_console/cook/subtract_points(final_cost, obj/item/card/id/card)
	var/datum/bank_account/budget = get_budget()
	return budget?.adjust_money(-final_cost)

/// Czy zwykła dostawa osiąga minimum. Liczy się wartość koszyka przed odliczeniem bonu, a zamówienie w całości z bonu przechodzi zawsze.
/obj/machinery/computer/order_console/cook/proc/order_minimum_met()
	if(!length(grocery_list))
		return FALSE
	if(get_final_cost(FALSE) <= 0)
		return TRUE
	var/cost = 0
	for(var/datum/orderable_item/item as anything in grocery_list)
		cost += grocery_list[item] * item.cost_per_order
	return round(cost * cargo_cost_multiplier) >= minimum_order_value

/obj/machinery/computer/order_console/cook/ui_data(mob/user)
	var/list/data = ..()
	data["cargo_minimum_met"] = order_minimum_met()
	data["points"] = retrieve_points()
	data["points_label"] = "Budżet usług:"
	return data

/obj/machinery/computer/order_console/cook/ui_static_data(mob/user)
	var/list/data = ..()
	data["cargo_value"] = minimum_order_value
	return data

/obj/machinery/computer/order_console/cook/ui_act(action, list/params)
	if((action == "purchase" || action == "express") && isliving(usr) && !allowed(usr))
		say("Brak dostępu! Zamawiać może tylko kuchnia albo bar.")
		return TRUE
	// okno blokuje zwykłą dostawę poniżej minimum, tu pilnujemy tego samego po stronie serwera
	if(action == "purchase" && !order_minimum_met())
		return TRUE
	return ..()

/obj/machinery/computer/order_console/cook/order_groceries(mob/living/purchaser, obj/item/card/id/card, list/groceries)
	var/list/things_to_order = list()
	for(var/datum/orderable_item/item as anything in groceries)
		if(!(item.category_index in order_categories))
			continue
		for(var/i in 1 to groceries[item])
			things_to_order += item.purchase_path

	var/datum/supply_pack/order_console/pack = new(purchaser, things_to_order, null)
	pack.crate_name = "zamrażarka z zakupami kuchni"
	pack.crate_type = /obj/structure/closet/crate/freezer

	var/datum/supply_order/new_order = new(pack, purchaser, "Konsola zamówień kuchni", purchaser.ckey, "", null)
	say("Dziękujemy za zakup! Przyleci najbliższym promem zaopatrzenia!")
	radio_announce(announcement_line)
	SSshuttle.shoppinglist += new_order

/obj/item/circuitboard/computer/order_console/cook
	name = "konsola zamówień kuchni (płytka komputera)"
	icon_state = "service"
	build_path = /obj/machinery/computer/order_console/cook

/datum/design/board/order_console_cook
	name = "Projekt komputera (konsola zamówień kuchni)"
	desc = "Płytka konsoli, z której kuchnia i bar zamawiają produkty z budżetu działu usług."
	id = "order_console_cook"
	build_path = /obj/item/circuitboard/computer/order_console/cook
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/techweb_node/bio_process/New()
	. = ..()
	design_ids += "order_console_cook"

/// Bon kucharza (tg /obj/item/cooking_voucher): 10 darmowych produktów w konsoli zamówień kuchni
/obj/item/cooking_voucher
	name = "bon kucharski"
	desc = "Żeton na składniki. Włóż go do konsoli zamówień kuchni, a dziesięć wybranych produktów dostaniesz za darmo."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/// Kucharz zaczyna z bonem w kieszeni (tg: r_pocket stroju). Przy profesji, nie w stroju, bo strój noszą też KNPC.
/datum/job/cook/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	if(!ishuman(H))
		return
	var/mob/living/carbon/human/chef = H
	var/obj/item/cooking_voucher/voucher = new(chef)
	if(chef.equip_to_slot_if_possible(voucher, ITEM_SLOT_RPOCKET, disable_warning = TRUE))
		return
	if(chef.equip_to_slot_if_possible(voucher, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
		return
	chef.put_in_hands(voucher)

// Asortyment. Ceny: tg × 2. Pozycje spoza konsoli tg wycenione według najbliższego odpowiednika (opis w raporcie PR-a).
// Nazwy i opisy biorą się z przedmiotów, więc są po polsku tak jak w grze.

/datum/orderable_item/kitchen_produce
	category_index = CATEGORY_KITCHEN_PRODUCE
	cost_per_order = 20

/datum/orderable_item/kitchen_produce/potato
	purchase_path = /obj/item/food/grown/potato

/datum/orderable_item/kitchen_produce/sweet_potato
	purchase_path = /obj/item/food/grown/potato/sweet
	cost_per_order = 50

/datum/orderable_item/kitchen_produce/tomato
	purchase_path = /obj/item/food/grown/tomato

/datum/orderable_item/kitchen_produce/carrot
	purchase_path = /obj/item/food/grown/carrot

/datum/orderable_item/kitchen_produce/parsnip
	purchase_path = /obj/item/food/grown/parsnip

/datum/orderable_item/kitchen_produce/redbeet
	purchase_path = /obj/item/food/grown/redbeet

/datum/orderable_item/kitchen_produce/whitebeet
	purchase_path = /obj/item/food/grown/whitebeet

/datum/orderable_item/kitchen_produce/eggplant
	purchase_path = /obj/item/food/grown/eggplant

/datum/orderable_item/kitchen_produce/cabbage
	purchase_path = /obj/item/food/grown/cabbage

/datum/orderable_item/kitchen_produce/lettuce
	purchase_path = /obj/item/food/grown/lettuce

/datum/orderable_item/kitchen_produce/onion
	purchase_path = /obj/item/food/grown/onion

/datum/orderable_item/kitchen_produce/red_onion
	purchase_path = /obj/item/food/grown/onion/red
	cost_per_order = 50

/datum/orderable_item/kitchen_produce/garlic
	purchase_path = /obj/item/food/grown/garlic

/datum/orderable_item/kitchen_produce/bell_pepper
	purchase_path = /obj/item/food/grown/bell_pepper

/datum/orderable_item/kitchen_produce/chili
	purchase_path = /obj/item/food/grown/chili

/datum/orderable_item/kitchen_produce/ghost_chili
	purchase_path = /obj/item/food/grown/ghost_chili
	cost_per_order = 50

/datum/orderable_item/kitchen_produce/cucumber
	purchase_path = /obj/item/food/grown/cucumber

/datum/orderable_item/kitchen_produce/pumpkin
	purchase_path = /obj/item/food/grown/pumpkin

/datum/orderable_item/kitchen_produce/corn
	purchase_path = /obj/item/food/grown/corn

/datum/orderable_item/kitchen_produce/peas
	purchase_path = /obj/item/food/grown/peas

/datum/orderable_item/kitchen_produce/soybeans
	purchase_path = /obj/item/food/grown/soybeans

/datum/orderable_item/kitchen_produce/peanut
	purchase_path = /obj/item/food/grown/peanut

/datum/orderable_item/kitchen_produce/oat
	purchase_path = /obj/item/food/grown/oat

/datum/orderable_item/kitchen_produce/plumphelmet
	purchase_path = /obj/item/food/grown/mushroom/plumphelmet

/datum/orderable_item/kitchen_produce/chanterelle
	purchase_path = /obj/item/food/grown/mushroom/chanterelle

/datum/orderable_item/kitchen_produce/herbs
	purchase_path = /obj/item/food/grown/herbs
	cost_per_order = 10

/datum/orderable_item/kitchen_produce/olive
	purchase_path = /obj/item/food/grown/olive

/datum/orderable_item/kitchen_produce/apple
	purchase_path = /obj/item/food/grown/apple

/datum/orderable_item/kitchen_produce/banana
	purchase_path = /obj/item/food/grown/banana

/datum/orderable_item/kitchen_produce/cherries
	purchase_path = /obj/item/food/grown/cherries

/datum/orderable_item/kitchen_produce/berries
	purchase_path = /obj/item/food/grown/berries

/datum/orderable_item/kitchen_produce/strawberry
	purchase_path = /obj/item/food/grown/strawberry

/datum/orderable_item/kitchen_produce/grapes
	purchase_path = /obj/item/food/grown/grapes

/datum/orderable_item/kitchen_produce/watermelon
	purchase_path = /obj/item/food/grown/watermelon

/datum/orderable_item/kitchen_produce/pineapple
	purchase_path = /obj/item/food/grown/pineapple

/datum/orderable_item/kitchen_produce/orange
	purchase_path = /obj/item/food/grown/citrus/orange

/datum/orderable_item/kitchen_produce/lemon
	purchase_path = /obj/item/food/grown/citrus/lemon

/datum/orderable_item/kitchen_produce/lime
	purchase_path = /obj/item/food/grown/citrus/lime

/datum/orderable_item/kitchen_produce/cocoa
	purchase_path = /obj/item/food/grown/cocoapod

/datum/orderable_item/kitchen_produce/vanilla
	purchase_path = /obj/item/food/grown/vanillapod
	cost_per_order = 50

/datum/orderable_item/kitchen_produce/sugarcane
	purchase_path = /obj/item/food/grown/sugarcane

/datum/orderable_item/kitchen_produce/coffee
	purchase_path = /obj/item/food/grown/coffee

/datum/orderable_item/kitchen_produce/tea
	purchase_path = /obj/item/food/grown/tea

/datum/orderable_item/kitchen_produce/korta_nut
	purchase_path = /obj/item/food/grown/korta_nut
	cost_per_order = 30

/datum/orderable_item/kitchen_produce/toechtauese
	purchase_path = /obj/item/food/grown/toechtauese
	cost_per_order = 30


/datum/orderable_item/kitchen_meat_dairy
	category_index = CATEGORY_KITCHEN_MEAT_DAIRY

/datum/orderable_item/kitchen_meat_dairy/milk
	purchase_path = /obj/item/reagent_containers/food/condiment/milk
	cost_per_order = 60

/datum/orderable_item/kitchen_meat_dairy/soymilk
	purchase_path = /obj/item/reagent_containers/food/condiment/soymilk
	cost_per_order = 60

/datum/orderable_item/kitchen_meat_dairy/cream
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/cream
	cost_per_order = 80

/datum/orderable_item/kitchen_meat_dairy/butter
	purchase_path = /obj/item/food/butter
	cost_per_order = 30

/datum/orderable_item/kitchen_meat_dairy/cheese_wheel
	purchase_path = /obj/item/food/cheese/wheel
	cost_per_order = 100

/datum/orderable_item/kitchen_meat_dairy/eggs
	purchase_path = /obj/item/storage/fancy/egg_box
	cost_per_order = 80

/datum/orderable_item/kitchen_meat_dairy/tofu
	purchase_path = /obj/item/food/tofu
	cost_per_order = 20

/datum/orderable_item/kitchen_meat_dairy/meat
	purchase_path = /obj/item/food/meat/slab
	cost_per_order = 30

/datum/orderable_item/kitchen_meat_dairy/shrimp
	purchase_path = /obj/item/food/shellfish_meat/shrimp
	cost_per_order = 10

/datum/orderable_item/kitchen_meat_dairy/chicken
	purchase_path = /obj/item/food/meat/slab/chicken
	cost_per_order = 30

/datum/orderable_item/kitchen_meat_dairy/bacon
	purchase_path = /obj/item/food/meat/rawbacon
	cost_per_order = 20

/datum/orderable_item/kitchen_meat_dairy/fish
	purchase_path = /obj/item/food/fishmeat
	cost_per_order = 24

/datum/orderable_item/kitchen_meat_dairy/spider_eggs
	purchase_path = /obj/item/food/spidereggs
	cost_per_order = 20


/datum/orderable_item/kitchen_pantry
	category_index = CATEGORY_KITCHEN_PANTRY

/datum/orderable_item/kitchen_pantry/flour
	purchase_path = /obj/item/reagent_containers/food/condiment/flour
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/sugar
	purchase_path = /obj/item/reagent_containers/food/condiment/sugar
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/rice
	purchase_path = /obj/item/reagent_containers/food/condiment/rice
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/enzyme
	purchase_path = /obj/item/reagent_containers/food/condiment/enzyme
	cost_per_order = 80

/datum/orderable_item/kitchen_pantry/oil
	purchase_path = /obj/item/reagent_containers/food/condiment/vegetable_oil
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/salt
	purchase_path = /obj/item/reagent_containers/food/condiment/saltshaker
	cost_per_order = 30

/datum/orderable_item/kitchen_pantry/pepper
	purchase_path = /obj/item/reagent_containers/food/condiment/peppermill
	cost_per_order = 30

/datum/orderable_item/kitchen_pantry/maggi
	purchase_path = /obj/item/reagent_containers/food/condiment/maggi
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/soysauce
	purchase_path = /obj/item/reagent_containers/food/condiment/soysauce
	cost_per_order = 30

/datum/orderable_item/kitchen_pantry/ketchup
	purchase_path = /obj/item/reagent_containers/food/condiment/ketchup
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/mayonnaise_kielecki
	purchase_path = /obj/item/reagent_containers/food/condiment/mayonnaise/kielecki
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/mayonnaise_winiary
	purchase_path = /obj/item/reagent_containers/food/condiment/mayonnaise/winiary
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/bbqsauce
	purchase_path = /obj/item/reagent_containers/food/condiment/bbqsauce
	cost_per_order = 120

/datum/orderable_item/kitchen_pantry/hotsauce
	purchase_path = /obj/item/reagent_containers/food/condiment/hotsauce
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/coldsauce
	purchase_path = /obj/item/reagent_containers/food/condiment/coldsauce
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/cherryjelly
	purchase_path = /obj/item/reagent_containers/food/condiment/cherryjelly
	cost_per_order = 60

/datum/orderable_item/kitchen_pantry/honey
	purchase_path = /obj/item/reagent_containers/food/condiment/honey
	cost_per_order = 250


/datum/orderable_item/kitchen_bar
	category_index = CATEGORY_KITCHEN_BAR
	cost_per_order = 60

/datum/orderable_item/kitchen_bar/vodka
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/vodka

/datum/orderable_item/kitchen_bar/gin
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/gin

/datum/orderable_item/kitchen_bar/rum
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/rum

/datum/orderable_item/kitchen_bar/whiskey
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/whiskey

/datum/orderable_item/kitchen_bar/tequila
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/tequila

/datum/orderable_item/kitchen_bar/vermouth
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/vermouth

/datum/orderable_item/kitchen_bar/kahlua
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/kahlua

/datum/orderable_item/kitchen_bar/wine
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/wine

/datum/orderable_item/kitchen_bar/sake
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/sake

/datum/orderable_item/kitchen_bar/cognac
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/cognac
	cost_per_order = 100

/datum/orderable_item/kitchen_bar/champagne
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/champagne
	cost_per_order = 100

/datum/orderable_item/kitchen_bar/absinthe
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/absinthe
	cost_per_order = 100

/datum/orderable_item/kitchen_bar/beer
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/beer
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/ale
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/ale
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/grenadine
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/grenadine
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/menthol
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/menthol
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/limejuice
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/limejuice
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/orangejuice
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/orangejuice
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/pineapplejuice
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/pineapplejuice
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/tomatojuice
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	cost_per_order = 40

/datum/orderable_item/kitchen_bar/tymbark
	purchase_path = /obj/item/reagent_containers/food/drinks/bottle/tymbark
	cost_per_order = 20

/datum/orderable_item/kitchen_bar/cola
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/cola
	cost_per_order = 10

/datum/orderable_item/kitchen_bar/tonic
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/tonic
	cost_per_order = 10

/datum/orderable_item/kitchen_bar/sodawater
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/sodawater
	cost_per_order = 10

/datum/orderable_item/kitchen_bar/lemon_lime
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime
	cost_per_order = 10

/datum/orderable_item/kitchen_bar/space_up
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/space_up
	cost_per_order = 10

/datum/orderable_item/kitchen_bar/dr_gibb
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb
	cost_per_order = 10

/datum/orderable_item/kitchen_bar/space_mountain_wind
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	cost_per_order = 10

/datum/orderable_item/kitchen_bar/ice
	purchase_path = /obj/item/reagent_containers/food/drinks/ice
	cost_per_order = 10

#undef CATEGORY_KITCHEN_PRODUCE
#undef CATEGORY_KITCHEN_MEAT_DAIRY
#undef CATEGORY_KITCHEN_PANTRY
#undef CATEGORY_KITCHEN_BAR
