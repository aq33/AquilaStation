// Przepisy krokowe na podstawowe dania. Te dania można też zrobić po staremu (stół, płyta, mikrofalówka);
// krokowo wychodzą lepiej, jeśli wykona się kroki dodatkowe i gotuje na dobrym sprzęcie.

/datum/cooking/recipe/friedegg
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/friedegg
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/friedegg/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 2, "optional" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1, "optional" = TRUE),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/omelette
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/omelette
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/omelette/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 2, "optional" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1, "optional" = TRUE),
		COOK_USE_STOVE(COOK_TEMP_LOW, 20 SECONDS),
	)

/datum/cooking/recipe/boiledspaghetti
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spaghetti/boiledspaghetti
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/boiledspaghetti/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/water, 10),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1, "optional" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/spaghetti/raw),
		COOK_USE_STOVE(COOK_TEMP_HIGH, 15 SECONDS),
	)

/datum/cooking/recipe/meatballspaghetti
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spaghetti/meatballspaghetti
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/meatballspaghetti/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato, "optional" = TRUE),
		COOK_USE_STOVE(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/steak
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meat/steak
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/steak/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1, "optional" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1, "optional" = TRUE),
		COOK_USE_GRILL(30 SECONDS),
	)

/datum/cooking/recipe/fries
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fries
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/fries/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1, "optional" = TRUE),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/bread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/plain
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/bread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_USE_TOOL(TOOL_KNIFE, "optional" = TRUE),
		COOK_USE_OVEN(COOK_TEMP_MED, 40 SECONDS),
	)
