#define STORAGE_CAPACITY 30
#define LIQUID_CAPACIY 200
#define MIXER_CAPACITY 100

/obj/machinery/food_cart
	name = "food cart"
	desc = "New generation hot dog stand."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "foodcart"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	var/food_stored = 0
	var/glasses = 0
	var/portion = 10
	var/selected_drink
	var/list/stored_food = list()
	var/obj/item/reagent_containers/mixer

/obj/machinery/food_cart/Initialize(mapload)
	. = ..()
	create_reagents(LIQUID_CAPACIY, OPENCONTAINER | NO_REACT)
	mixer = new /obj/item/reagent_containers(src, MIXER_CAPACITY)
	mixer.name = "Mixer"

/obj/machinery/food_cart/Destroy()
	QDEL_NULL(mixer)
	return ..()

/obj/machinery/food_cart/proc/isFull()
	return food_stored >= STORAGE_CAPACITY

/obj/machinery/food_cart/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, O, 0)
		return TRUE
	if(istype(O, /obj/item/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/reagent_containers/food/drinks/drinkingglass/DG = O
		if(!DG.reagents.total_volume) //glass is empty
			qdel(DG)
			glasses++
			to_chat(user, "<span class='notice'>[src] przyjmuje szklankę, sterylizując ją.</span>")
	else if(IS_EDIBLE(O))
		if(isFull())
			to_chat(user, "<span class='warning'>[src] jest pełny.</span>")
		else
			var/obj/item/S = O
			if(!user.transferItemToLoc(S, src))
				return
			if(stored_food[sanitize(S.name)])
				stored_food[sanitize(S.name)]++
			else
				stored_food[sanitize(S.name)] = 1
	else if(istype(O, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = O
		if(G.get_amount() >= 1)
			G.use(1)
			glasses += 4
			to_chat(user, "<span class='notice'>[src] przyjmuje arkusz szkła.</span>")
	else if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = O
		for(var/obj/item/S in T.contents)
			if(isFull())
				to_chat(user, "<span class='warning'>[src] jest pełny.</span>")
				break
			else
				if(!IS_EDIBLE(S))
					continue
				if(SEND_SIGNAL(T, COMSIG_TRY_STORAGE_TAKE, S, src))
					if(stored_food[sanitize(S.name)])
						stored_food[sanitize(S.name)]++
					else
						stored_food[sanitize(S.name)] = 1
	else if(O.is_drainable())
		return
	else
		. = ..()
	SStgui.update_uis(src)

/obj/machinery/food_cart/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FoodCart", name)
		ui.open()

/obj/machinery/food_cart/ui_data(mob/user)
	var/list/data = list()
	data["glasses"] = glasses
	data["portion"] = portion
	data["food_stored"] = food_stored
	var/list/drinks = list()
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		drinks += list(list("name" = R.name, "volume" = R.volume, "id" = "[R.type]"))
	data["drinks"] = drinks
	var/list/mixed = list()
	for(var/datum/reagent/R as anything in mixer.reagents.reagent_list)
		mixed += list(list("name" = R.name, "volume" = R.volume, "id" = "[R.type]"))
	data["mixer"] = mixed
	var/list/food = list()
	for(var/V in stored_food)
		if(stored_food[V] > 0)
			food += list(list("name" = V, "amount" = stored_food[V]))
	data["food"] = food
	return data

/obj/machinery/food_cart/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/reagent_type = text2path(params["id"])
	switch(action)
		if("purge")
			if(reagent_type)
				reagents.del_reagent(reagent_type)
			return TRUE
		if("dispense")
			var/food_name = params["name"]
			if(!stored_food[food_name])
				return
			if(stored_food[food_name]-- <= 0)
				stored_food[food_name] = 0
			else
				for(var/obj/O in contents)
					if(sanitize(O.name) == food_name)
						O.forceMove(drop_location())
						break
			return TRUE
		if("portion")
			portion = clamp(round(text2num(params["amount"])), 0, 50)
			return TRUE
		if("pour", "m_pour")
			if(!reagent_type)
				return
			if(glasses-- <= 0)
				to_chat(usr, "<span class='warning'>Nie ma już szklanek!</span>")
				glasses = 0
			else
				var/obj/item/reagent_containers/food/drinks/drinkingglass/DG = new(loc)
				if(action == "pour")
					reagents.trans_id_to(DG, reagent_type, portion)
				else
					mixer.reagents.trans_id_to(DG, reagent_type, portion)
			return TRUE
		if("mix")
			if(!reagent_type)
				return
			if(!reagents.trans_id_to(mixer, reagent_type, portion))
				to_chat(usr, "<span class='warning'>[mixer] jest pełny!</span>")
			return TRUE
		if("transfer")
			if(!reagent_type)
				return
			if(!mixer.reagents.trans_id_to(src, reagent_type, portion))
				to_chat(usr, "<span class='warning'>[src] jest pełny!</span>")
			return TRUE

/obj/machinery/food_cart/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 4)
	qdel(src)

/obj/machinery/food_cart/coffee
	name = "coffee cart"
	desc = "Ah! The bitter drink of the Gods."
	icon_state = "icecream_vat"
	glasses = 10
	portion = 20

/obj/machinery/food_cart/coffee/Initialize(mapload)
	..()
	var/A = rand(0,3)
	var/B = rand(0,3)
	var/C = rand(0,3)
	var/D = rand(0,1)
	reagents.add_reagent(/datum/reagent/consumable/cafe_latte, A*20)
	reagents.add_reagent(/datum/reagent/consumable/icecoffee, B*20)
	reagents.add_reagent(/datum/reagent/consumable/soy_latte, C*20)
	reagents.add_reagent(/datum/reagent/consumable/pumpkin_latte, D*20)
	reagents.add_reagent(/datum/reagent/consumable/coffee, (10-A-B-C-D)*20)

#undef STORAGE_CAPACITY
#undef LIQUID_CAPACIY
#undef MIXER_CAPACITY
