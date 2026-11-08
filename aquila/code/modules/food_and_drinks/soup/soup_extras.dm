// AQUILA - dawne zupy-przedmioty jako gotowe miski z zupą (do map, łupów, replikatora i zestawów), zamówienia zup
// w restauracji (tg: /datum/custom_order/reagent/soup) i nasz sprite żurku.

/datum/reagent/consumable/nutriment/soup/zurek
	bowl_icon = 'aquila/icons/obj/food/polskie.dmi'
	bowl_icon_state = "zurek"

/obj/item/reagent_containers/glass/bowl/soup/meatball
	initial_reagent = /datum/reagent/consumable/nutriment/soup/meatball_soup
/obj/item/reagent_containers/glass/bowl/soup/slime
	initial_reagent = /datum/reagent/consumable/nutriment/soup/slime
/obj/item/reagent_containers/glass/bowl/soup/blood
	initial_reagent = /datum/reagent/blood // tg: zupa z krwi to krew w misce
/obj/item/reagent_containers/glass/bowl/soup/wingfangchu
	initial_reagent = /datum/reagent/consumable/nutriment/soup/wingfangchu
/obj/item/reagent_containers/glass/bowl/soup/clownstears
	initial_reagent = /datum/reagent/consumable/nutriment/soup/clown_tears
/obj/item/reagent_containers/glass/bowl/soup/vegetable
	initial_reagent = /datum/reagent/consumable/nutriment/soup/vegetable_soup
/obj/item/reagent_containers/glass/bowl/soup/mystery
	initial_reagent = /datum/reagent/consumable/nutriment/soup/mystery
/obj/item/reagent_containers/glass/bowl/soup/coldchili
	initial_reagent = /datum/reagent/consumable/nutriment/soup/coldchili
/obj/item/reagent_containers/glass/bowl/soup/tomato
	initial_reagent = /datum/reagent/consumable/nutriment/soup/tomato
/obj/item/reagent_containers/glass/bowl/soup/miso
	initial_reagent = /datum/reagent/consumable/nutriment/soup/miso
/obj/item/reagent_containers/glass/bowl/soup/mushroom
	initial_reagent = /datum/reagent/consumable/nutriment/soup/mushroom
/obj/item/reagent_containers/glass/bowl/soup/beet
	initial_reagent = /datum/reagent/consumable/nutriment/soup/red_beet
/obj/item/reagent_containers/glass/bowl/soup/bisque
	initial_reagent = /datum/reagent/consumable/nutriment/soup/bisque
/obj/item/reagent_containers/glass/bowl/soup/electron
	initial_reagent = /datum/reagent/consumable/nutriment/soup/electrons
/obj/item/reagent_containers/glass/bowl/soup/bungocurry
	initial_reagent = /datum/reagent/consumable/nutriment/soup/bungo
/obj/item/reagent_containers/glass/bowl/soup/oatmeal
	initial_reagent = /datum/reagent/consumable/nutriment/soup/oatmeal
/obj/item/reagent_containers/glass/bowl/soup/zurek
	initial_reagent = /datum/reagent/consumable/nutriment/soup/zurek

/// Robot zamawia porcję zupy; przyjmuje miskę, w której ta zupa ma przewagę (tg: /datum/custom_order/reagent/soup)
/datum/custom_order/soup
	/// Zamawiana zupa
	var/datum/reagent/consumable/nutriment/soup/soup_type
	/// Ile jednostek zupy musi być w misce
	var/reagents_needed = 20
	/// Nazwa porcji
	var/serving_name = "średnią porcję"
	/// Cena zamówienia
	var/price = FOOD_PRICE_NORMAL

/datum/custom_order/soup/New(datum/venue/our_venue)
	. = ..()
	var/static/list/serving_sizes = list("małą porcję" = 15, "średnią porcję" = 20, "dużą porcję" = 25)
	serving_name = pick(serving_sizes)
	reagents_needed = serving_sizes[serving_name]

/datum/custom_order/soup/get_order_appearance(datum/venue/our_venue)
	var/image/food_image = ..()
	food_image.add_overlay(image(icon = initial(soup_type.bowl_icon), icon_state = initial(soup_type.bowl_icon_state) || "bowl"))
	return food_image

/datum/custom_order/soup/get_order_name(datum/venue/our_venue)
	return lowertext(initial(soup_type.name))

/datum/custom_order/soup/get_order_line(datum/venue/our_venue)
	return "Poproszę [serving_name] zupy: [get_order_name(our_venue)]."

/datum/custom_order/soup/is_correct_order(obj/item/object_used)
	if(!istype(object_used, /obj/item/reagent_containers/glass/bowl) || isnull(object_used.reagents))
		return FALSE
	var/datum/reagents/holder = object_used.reagents
	if(holder.get_master_reagent_id() != soup_type)
		return FALSE
	if(reagents_needed > holder.total_volume)
		return FALSE
	// Co najmniej jedna trzecia to zamówiona zupa, żeby nie oszukiwać wodą
	return holder.get_reagent_amount(soup_type) >= holder.total_volume * 0.33

/datum/venue/restaurant/get_order_price(obj/item/order_item, order)
	if(istype(order, /datum/custom_order/soup))
		var/datum/custom_order/soup/soup_order = order
		return soup_order.price
	return ..()

/datum/custom_order/soup/bisque
	soup_type = /datum/reagent/consumable/nutriment/soup/bisque
	price = FOOD_PRICE_EXOTIC
/datum/custom_order/soup/miso
	soup_type = /datum/reagent/consumable/nutriment/soup/miso
/datum/custom_order/soup/vegetable
	soup_type = /datum/reagent/consumable/nutriment/soup/vegetable_soup
/datum/custom_order/soup/stew
	soup_type = /datum/reagent/consumable/nutriment/soup/stew
/datum/custom_order/soup/zurek
	soup_type = /datum/reagent/consumable/nutriment/soup/zurek
	price = FOOD_PRICE_EXOTIC
/datum/custom_order/soup/beet
	soup_type = /datum/reagent/consumable/nutriment/soup/red_beet

// Garnki i chochle w automacie z zastawą (tg: drinnerware.dm)
/obj/machinery/vending/dinnerware/Initialize(mapload)
	products[/obj/item/reagent_containers/glass/soup_pot] = 3
	products[/obj/item/reagent_containers/glass/soup_ladle] = 3
	return ..()

// Zupy ćm z tg mają sprite'y w moth.dmi, którego nie mamy (trzy stany wycięte do moth_soups.dmi)
/datum/reagent/consumable/nutriment/soup/cheese
	bowl_icon = 'aquila/icons/obj/food/soup/moth_soups.dmi'
/datum/reagent/consumable/nutriment/soup/moth_oats
	bowl_icon = 'aquila/icons/obj/food/soup/moth_soups.dmi'
/datum/reagent/consumable/nutriment/soup/rice_porridge
	bowl_icon = 'aquila/icons/obj/food/soup/moth_soups.dmi'
