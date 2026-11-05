#define ICECREAM_VANILLA 1
#define ICECREAM_CHOCOLATE 2
#define ICECREAM_STRAWBERRY 3
#define ICECREAM_BLUE 4
#define CONE_WAFFLE 5
#define CONE_CHOC 6

/obj/machinery/icecream_vat
	name = "kadź do lodów"
	desc = "Dzyń-dzyń, dzyń-dong. Lody z atestem Nanotrasen!"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "icecream_vat"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	layer = BELOW_OBJ_LAYER
	max_integrity = 300
	var/list/product_types = list()
	var/dispense_flavour = ICECREAM_VANILLA
	var/flavour_name = "vanilla"
	var/static/list/icecream_vat_reagents = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/ice = 5,
		/datum/reagent/consumable/cocoa = 5,
		/datum/reagent/consumable/vanilla = 5,
		/datum/reagent/consumable/berryjuice = 5,
		/datum/reagent/consumable/ethanol/singulo = 5)

/obj/machinery/icecream_vat/proc/get_ingredient_list(type)
	switch(type)
		if(ICECREAM_CHOCOLATE)
			return list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/cocoa)
		if(ICECREAM_STRAWBERRY)
			return list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/berryjuice)
		if(ICECREAM_BLUE)
			return list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/ethanol/singulo)
		if(CONE_WAFFLE)
			return list(/datum/reagent/consumable/flour, /datum/reagent/consumable/sugar)
		if(CONE_CHOC)
			return list(/datum/reagent/consumable/flour, /datum/reagent/consumable/sugar, /datum/reagent/consumable/cocoa)
		else //ICECREAM_VANILLA
			return list(/datum/reagent/consumable/milk, /datum/reagent/consumable/ice, /datum/reagent/consumable/vanilla)


/obj/machinery/icecream_vat/proc/get_flavour_name(flavour_type)
	switch(flavour_type)
		if(ICECREAM_CHOCOLATE)
			return "chocolate"
		if(ICECREAM_STRAWBERRY)
			return "strawberry"
		if(ICECREAM_BLUE)
			return "blue"
		if(CONE_WAFFLE)
			return "waffle"
		if(CONE_CHOC)
			return "chocolate"
		else //ICECREAM_VANILLA
			return "vanilla"


/obj/machinery/icecream_vat/Initialize(mapload)
	. = ..()
	while(product_types.len < 6)
		product_types.Add(5)
	create_reagents(100, NO_REACT | OPENCONTAINER)
	for(var/reagent in icecream_vat_reagents)
		reagents.add_reagent(reagent, icecream_vat_reagents[reagent])

/obj/machinery/icecream_vat/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IcecreamVat", name)
		ui.open()

/obj/machinery/icecream_vat/ui_static_data(mob/user)
	var/list/data = list()
	data["flavours"] = list(
		list("id" = ICECREAM_VANILLA, "name" = "Lody waniliowe", "ingredients" = "mleko, lód, wanilia w proszku"),
		list("id" = ICECREAM_STRAWBERRY, "name" = "Lody truskawkowe", "ingredients" = "mleko, lód, sok jagodowy"),
		list("id" = ICECREAM_CHOCOLATE, "name" = "Lody czekoladowe", "ingredients" = "mleko, lód, kakao w proszku"),
		list("id" = ICECREAM_BLUE, "name" = "Lody niebieskie", "ingredients" = "mleko, lód, singulo"),
	)
	data["cones"] = list(
		list("id" = CONE_WAFFLE, "name" = "Rożki waflowe", "ingredients" = "mąka, cukier"),
		list("id" = CONE_CHOC, "name" = "Rożki czekoladowe", "ingredients" = "mąka, cukier, kakao w proszku"),
	)
	return data

/obj/machinery/icecream_vat/ui_data(mob/user)
	var/list/data = list()
	data["dispense_flavour"] = dispense_flavour
	data["flavour_name"] = flavour_name
	data["product_amounts"] = product_types
	var/list/vat_reagents = list()
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		vat_reagents += list(list("name" = R.name, "volume" = R.volume, "id" = "[R.type]"))
	data["reagents"] = vat_reagents
	return data

/obj/machinery/icecream_vat/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select")
			var/flavour = text2num(params["id"])
			if(flavour < ICECREAM_VANILLA || flavour > ICECREAM_BLUE)
				return
			dispense_flavour = flavour
			flavour_name = get_flavour_name(dispense_flavour)
			src.visible_message("<span class='notice'>[usr] ustawia [src] na wydawanie lodów o smaku [flavour_name].</span>")
			return TRUE
		if("cone")
			var/dispense_cone = text2num(params["id"])
			if(dispense_cone != CONE_WAFFLE && dispense_cone != CONE_CHOC)
				return
			var/cone_name = get_flavour_name(dispense_cone)
			if(product_types[dispense_cone] >= 1)
				product_types[dispense_cone] -= 1
				var/obj/item/food/icecream/I = new(src.loc)
				I.set_cone_type(cone_name)
				src.visible_message("<span class='info'>[usr] wyjmuje z [src] chrupiący rożek ([cone_name]).</span>")
			else
				to_chat(usr, "<span class='warning'>Nie ma już rożków ([cone_name])!</span>")
			return TRUE
		if("make")
			var/amount = text2num(params["amount"])
			var/make_type = text2num(params["id"])
			if((amount != 1 && amount != 5) || make_type < ICECREAM_VANILLA || make_type > CONE_CHOC)
				return
			make(usr, make_type, amount)
			return TRUE
		if("purge")
			var/reagent_type = text2path(params["id"])
			if(reagent_type)
				reagents.del_reagent(reagent_type)
			return TRUE

/obj/machinery/icecream_vat/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/food/icecream))
		var/obj/item/food/icecream/I = O
		if(!I.ice_creamed)
			if(product_types[dispense_flavour] > 0)
				visible_message("[icon2html(src, viewers(src))] <span class='info'>[user] nakłada do [I] pyszne lody o smaku [flavour_name].</span>")
				product_types[dispense_flavour] -= 1
				I.add_ice_cream(flavour_name)
				if(I.reagents.total_volume < 10)
					I.reagents.add_reagent(/datum/reagent/consumable/sugar, 10 - I.reagents.total_volume)
			else
				to_chat(user, "<span class='warning'>Zostało za mało lodów!</span>")
		else
			to_chat(user, "<span class='notice'>W [O] już są lody.</span>")
		return 1
	else if(O.is_drainable())
		return
	else
		return ..()

/obj/machinery/icecream_vat/proc/make(mob/user, make_type, amount)
	for(var/R in get_ingredient_list(make_type))
		if(reagents.has_reagent(R, amount))
			continue
		amount = 0
		break
	if(amount)
		for(var/R in get_ingredient_list(make_type))
			reagents.remove_reagent(R, amount)
		product_types[make_type] += amount
		var/flavour = get_flavour_name(make_type)
		if(make_type > 4)
			src.visible_message("<span class='info'>[user] przygotowuje rożki ([flavour]).</span>")
		else
			src.visible_message("<span class='info'>[user] ubija lody o smaku [flavour].</span>")
	else
		to_chat(user, "<span class='warning'>Nie masz składników, by to zrobić!</span>")

/obj/item/food/icecream
	name = "rożek waflowy"
	desc = "Pyszny rożek waflowy, ale bez lodów."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "icecream_cone_waffle" //default for admin-spawned cones, href_list["cone"] should overwrite this all the time
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	bite_consumption = 4
	foodtypes = DAIRY | SUGAR
	max_volume = 20
	food_flags = FOOD_FINGER_FOOD
	var/ice_creamed = 0
	var/cone_type

/obj/item/food/icecream/proc/set_cone_type(var/cone_name)
	cone_type = cone_name
	icon_state = "icecream_cone_[cone_name]"
	switch (cone_type)
		if ("waffle")
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 1)
		if ("chocolate")
			reagents.add_reagent(/datum/reagent/consumable/cocoa, 1) // chocolate ain't as nutritious kids

	desc = "Pyszny rożek ([cone_name]), ale bez lodów."


/obj/item/food/icecream/proc/add_ice_cream(var/flavour_name)
	name = "lody ([flavour_name])"
	src.add_overlay("icecream_[flavour_name]")
	switch (flavour_name) // adding the actual reagents advertised in the ingredient list
		if ("vanilla")
			desc = "Pyszny rożek ([cone_type]) z lodami waniliowymi. Wszystkie inne lody biorą z nich przykład."
		if ("chocolate")
			desc = "Pyszny rożek ([cone_type]) z lodami czekoladowymi. Co zaskakujące, z prawdziwego kakao."
			reagents.add_reagent(/datum/reagent/consumable/cocoa, 2)
		if ("strawberry")
			desc = "Pyszny rożek ([cone_type]) z lodami truskawkowymi. Na pewno nie z prawdziwych truskawek."
			reagents.add_reagent(/datum/reagent/consumable/berryjuice, 2)
		if ("blue")
			desc = "Pyszny rożek ([cone_type]) z niebieskimi lodami. Z prawdziwego... niebieskiego?"
			reagents.add_reagent(/datum/reagent/consumable/ethanol/singulo, 2)
		if ("mob")
			desc = "Podejrzany rożek ([cone_type]) z jaskrawoczerwonymi lodami. To chyba nie truskawka..."
			reagents.add_reagent(/datum/reagent/liquidgibs, 2)
	ice_creamed = 1

/obj/item/food/icecream/proc/add_mob_flavor(var/mob/M)
	add_ice_cream("mob")
	name = "lody: [M.name]"

/obj/machinery/icecream_vat/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 4)
	qdel(src)


#undef ICECREAM_VANILLA
#undef ICECREAM_CHOCOLATE
#undef ICECREAM_STRAWBERRY
#undef ICECREAM_BLUE
#undef CONE_WAFFLE
#undef CONE_CHOC
