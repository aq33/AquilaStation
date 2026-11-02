// Tea
/obj/item/food/grown/tea
	seed = /obj/item/plant_seeds/preset/tea
	name = "liść herbaty"
	desc = "Te aromatyczne listki herbaty można wysuszyć i zaparzyć."
	icon_state = "tea_aspera_leaves"
	filling_color = "#008000"
	dry_grind = TRUE
	grind_results = list(/datum/reagent/toxin/teapowder = 0)
	can_distill = FALSE

// Tea Astra
/obj/item/food/grown/tea/astra
	name = "liść herbaty astra"
	desc = "Specjalna mieszanka herbaty, która koi umysł."
	icon_state = "tea_astra_leaves"
	bite_consumption_mod = 2
	grind_results = list(/datum/reagent/toxin/teapowder = 0, /datum/reagent/medicine/salglu_solution = 0)
	discovery_points = 300


// Coffee
/obj/item/food/grown/coffee
	seed = /obj/item/plant_seeds/preset/coffee
	name = "ziarna kawy arabika"
	desc = "Wysusz je, żeby zrobić kawę."
	icon_state = "coffee_arabica"
	dry_grind = TRUE
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/kahlua

// Coffee Robusta
/obj/item/food/grown/coffee/robusta
	name = "ziarna kawy robusta"
	desc = "Zwiększa krzepkość o 37 procent!"
	icon_state = "coffee_robusta"
	grind_results = list(/datum/reagent/toxin/coffeepowder = 0, /datum/reagent/medicine/morphine = 0)
	discovery_points = 300
