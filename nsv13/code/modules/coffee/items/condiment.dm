/obj/item/reagent_containers/food/condiment/pack/creamer
	name = "saszetka śmietanki"
	originalname = "śmietanka"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/cream = 5)

/obj/item/reagent_containers/food/condiment/pack/sugar
	name = "saszetka cukru"
	originalname = "cukier"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/sugar = 5)

///Technically condiment packs but they are non transparent
/obj/item/reagent_containers/food/condiment/creamer
	name = "saszetka zabielacza do kawy"
	desc = "Lepiej nie myśleć, z czego to robią."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "condi_creamer"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/creamer = 5)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/creamer/update_icon()
	icon_state = initial(icon_state)

/obj/item/reagent_containers/food/condiment/chocolate
	name = "saszetka posypki czekoladowej"
	desc= "Mało ci cukru, który już tam jest?"
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "condi_chocolate"
	list_reagents = list(/datum/reagent/consumable/chocolatepudding = 10)

/obj/item/reagent_containers/food/condiment/chocolate/update_icon()
	icon_state = initial(icon_state)

/*
 *	Syrup bottles, basically a unspillable cup that transfers reagents upon clicking on it with a cup
 *	Exclusive, can only be ordered from cargo, you cant refill them.
 */

/obj/item/reagent_containers/glass/bottle/syrup_bottle
	name = "butelka syropu"
	desc = "Butelka z pompką, która dozuje pyszny syrop prosto do twojego kubka z kawą."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "syrup"
	fill_icon_state = "syrup"
	fill_icon_thresholds = list(0, 20, 40, 60, 80, 100)
	possible_transfer_amounts = list(5, 10)
	reagent_flags = DRAINABLE | TRANSPARENT
	volume = 50
	amount_per_transfer_from_this = 5
	spillable = FALSE
	///variable to tell if the bottle can be refilled
	var/cap_on = TRUE

/obj/item/reagent_containers/glass/bottle/syrup_bottle/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-kliknij, by przełączyć nakrętkę z pompką.</span>"
	return

//when you attack the syrup bottle with a container it refills it
/obj/item/reagent_containers/glass/bottle/syrup_bottle/attackby(obj/item/attacking_item, mob/user, params)
	SHOULD_CALL_PARENT(FALSE)
	if(!cap_on)
		return ..()

	if(!check_allowed_items(attacking_item, target_self = TRUE))
		return

	if(attacking_item.is_refillable())
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
			return

		if(attacking_item.reagents.holder_full())
			to_chat(user, "<span class='warning'>[attacking_item] jest pełny.</span>")

		var/trans = reagents.trans_to(attacking_item, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Przelewasz [trans] j. roztworu do [attacking_item].</span>")
		flick("syrup_anim", src)
	attacking_item.update_icon()
	return TRUE

/obj/item/reagent_containers/glass/bottle/syrup_bottle/afterattack(obj/target, mob/user, proximity)
	SHOULD_CALL_PARENT(FALSE)
	return TRUE

/obj/item/reagent_containers/glass/bottle/syrup_bottle/AltClick(mob/user)
	cap_on = !cap_on
	if(!cap_on)
		icon_state = "syrup_open"
		to_chat(user, "<span class='notice'>Zdejmujesz nakrętkę z pompką.</span>")
	else
		icon_state = "syrup"
		to_chat(user, "<span class='notice'>Zakładasz nakrętkę z pompką.</span>")
	update_icon_state()
	return ..()

//types of syrups

/obj/item/reagent_containers/glass/bottle/syrup_bottle/caramel
	name = "butelka syropu karmelowego"
	desc = "Butelka z pompką ze skarmelizowanym cukrem, czyli karmelem. Nie lizać."
	list_reagents = list(/datum/reagent/consumable/caramel = 50)

/obj/item/reagent_containers/glass/bottle/syrup_bottle/liqueur
	name = "butelka syropu z likierem kawowym"
	desc = "Butelka z pompką z syropem z meksykańskiego likieru kawowego. Produkowany od 1936 roku, HONK."
	list_reagents = list(/datum/reagent/consumable/ethanol/kahlua = 50)

/obj/item/reagent_containers/glass/bottle/syrup_bottle/honey
	name = "butelka syropu miodowego"
	desc = "Butelka z pompką z miodem, bardzo lepkim. Nie lizać."
	list_reagents = list(/datum/reagent/consumable/honey = 50)

/obj/item/reagent_containers/glass/bottle/syrup_bottle/vanilla
	name = "butelka syropu waniliowego"
	desc = "Butelka z pompką z syropem waniliowym. Nie lizać."
	list_reagents = list(/datum/reagent/consumable/vanilla = 50)

/obj/item/reagent_containers/glass/bottle/syrup_bottle/tea
	name = "butelka syropu herbacianego"
	desc = "Butelka z pompką z syropem o smaku herbaty. Nawet nie próbuj."
	list_reagents = list(/datum/reagent/consumable/tea = 50)

/obj/item/reagent_containers/glass/bottle/syrup_bottle/creme_de_cacao
	name = "butelka syropu z likieru kakaowego"
	desc = "Butelka z pompką z likierem kakaowym. Nie lizać."
	list_reagents = list(/datum/reagent/consumable/ethanol/creme_de_cacao = 50)

/obj/item/reagent_containers/glass/bottle/syrup_bottle/creme_de_menthe
	name = "butelka syropu z likieru miętowego"
	desc = "Butelka z pompką z likierem miętowym. Nie lizać."
	list_reagents = list(/datum/reagent/consumable/ethanol/creme_de_menthe = 50)
