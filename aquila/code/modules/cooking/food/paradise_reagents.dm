// AQUILA - odczynniki z przepisów Paradise, których nie mieliśmy. Kupuje się je w spiżarni konsoli zamówień kuchni,
// a guacamole robi się w misce do mieszania.

/datum/reagent/consumable/vinegar
	name = "Ocet"
	description = "Kwaśny płyn do marynat i sosów."
	color = "#661F1E"
	taste_description = "ocet"
	chem_flags = CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/wasabi
	name = "Wasabi"
	description = "Bardzo ostra zielona pasta z chrzanu, podawana do sushi."
	color = "#B0B73F"
	taste_description = "ostry chrzan"
	chem_flags = CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/cream_cheese
	name = "Serek śmietankowy"
	description = "Gęsty, kremowy serek do smarowania."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#F7F3E3"
	taste_description = "kremowy ser"
	chem_flags = CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/gravy
	name = "Sos pieczeniowy"
	description = "Gęsty brązowy sos z pieczeni."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#623301"
	taste_description = "sos pieczeniowy"
	chem_flags = CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/guacamole
	name = "Guacamole"
	description = "Kremowa, kwaskowata pasta z awokado."
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#A0C734"
	taste_description = "awokado"
	chem_flags = CHEMICAL_RNG_BOTANY

/obj/item/reagent_containers/food/condiment/vinegar
	name = "ocet"
	desc = "Butelka octu do marynat i sosów."
	icon_state = "vinegar"
	list_reagents = list(/datum/reagent/consumable/vinegar = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/wasabi
	name = "wasabi"
	desc = "Butelka bardzo ostrej pasty wasabi do sushi."
	list_reagents = list(/datum/reagent/consumable/wasabi = 50)

/obj/item/reagent_containers/food/condiment/cream_cheese
	name = "serek śmietankowy"
	desc = "Opakowanie gęstego serka śmietankowego."
	icon_state = "yoghurt"
	list_reagents = list(/datum/reagent/consumable/cream_cheese = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/food/condiment/gravy
	name = "sos pieczeniowy"
	desc = "Butelka gęstego sosu pieczeniowego."
	list_reagents = list(/datum/reagent/consumable/gravy = 50)

/datum/orderable_item/kitchen_pantry/vinegar
	purchase_path = /obj/item/reagent_containers/food/condiment/vinegar
	cost_per_order = 40

/datum/orderable_item/kitchen_pantry/wasabi
	purchase_path = /obj/item/reagent_containers/food/condiment/wasabi
	cost_per_order = 50

/datum/orderable_item/kitchen_pantry/cream_cheese
	purchase_path = /obj/item/reagent_containers/food/condiment/cream_cheese
	cost_per_order = 50

/datum/orderable_item/kitchen_pantry/gravy
	purchase_path = /obj/item/reagent_containers/food/condiment/gravy
	cost_per_order = 40
