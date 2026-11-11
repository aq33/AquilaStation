// Polskie przyprawy: Maggi i dwa majonezy (Kielecki i Winiary). Do kupienia w automacie z zastawą.

/datum/reagent/consumable/maggi
	name = "Przyprawa w płynie"
	description = "Ciemna, słona przyprawa w płynie o zapachu lubczyku. Kilka kropel do rosołu i babcia jest zadowolona."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#3B1A0A"
	chem_flags = NONE
	taste_description = "lubczyk i rosół z kostki"

/obj/item/reagent_containers/food/condiment/maggi
	name = "przyprawa Maggi"
	desc = "Butelka przyprawy w płynie Maggi. Kropla do zupy, kropla do jajecznicy, kropla do wszystkiego."
	icon = 'aquila/icons/obj/food/przyprawy_polskie.dmi'
	icon_state = "przyprawa-maggi"
	list_reagents = list(/datum/reagent/consumable/maggi = 50)
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 5, 10)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/mayonnaise/kielecki
	name = "majonez Kielecki"
	desc = "Słoik majonezu Kieleckiego. Dla jednych jedyny prawdziwy majonez, dla drugich herezja."
	icon = 'aquila/icons/obj/food/przyprawy_polskie.dmi'
	icon_state = "majonez-kielecki"

/obj/item/reagent_containers/food/condiment/mayonnaise/winiary
	name = "majonez Winiary"
	desc = "Słoik majonezu Winiary. Odwieczny rywal Kieleckiego, o który kłócą się całe rodziny przy wigilijnej sałatce."
	icon = 'aquila/icons/obj/food/przyprawy_polskie.dmi'
	icon_state = "majonez-winiary"

/obj/machinery/vending/dinnerware/Initialize(mapload)
	products[/obj/item/reagent_containers/food/condiment/maggi] = 2
	products[/obj/item/reagent_containers/food/condiment/mayonnaise/kielecki] = 2
	products[/obj/item/reagent_containers/food/condiment/mayonnaise/winiary] = 2
	return ..()
