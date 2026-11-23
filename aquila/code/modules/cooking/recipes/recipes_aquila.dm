// AQUILA - nasze dania (tg, Bee, Aquila), których nie ma w przepisach Paradise: kroki ułożone u nas na podstawie
// dawnych przepisów stołowych (te same składniki, do tego naczynie i maszyna według rodzaju dania).
// Przepis stołowy dania, które robi się krok po kroku, nie trafia do menu craftingu (recipes_bee.dm).

/datum/cooking/recipe/aq_antspizza
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/pizzaslice/ants
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_antspizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pizzaslice/margherita),
		COOK_ADD_REAGENT(/datum/reagent/ants, 4),
	)

/datum/cooking/recipe/aq_arnold
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/arnold
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/aq_arnold/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/ammo_casing/c9mm),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_ashsteak
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meat/steak/ashflake
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_ashsteak/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/steak/goliath),
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/cactus_fruit),
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/mushroom_leaf),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/aq_baklava
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/baklava
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_baklava/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/butter),
		COOK_ADD_ITEM(/obj/item/food/butter),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/plant_seeds/preset/oats),
		COOK_ADD_ITEM(/obj/item/plant_seeds/preset/oats),
		COOK_ADD_ITEM(/obj/item/plant_seeds/preset/oats),
		COOK_ADD_ITEM(/obj/item/plant_seeds/preset/oats),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_bananacreampie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/cream
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_bananacreampie/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_ITEM(/obj/item/food/pie/plain),
		COOK_ADD_ITEM(/obj/item/food/grown/banana),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_bearsteak
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/bearsteak
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_bearsteak/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/manly_dorf, 5),
		COOK_ADD_ITEM(/obj/item/food/meat/steak/bear),
		COOK_USE_STOVE(COOK_TEMP_HIGH, 10 SECONDS),
	)

/datum/cooking/recipe/aq_beefnoodle
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spaghetti/beefnoodle
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/aq_beefnoodle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
		COOK_USE_STOVE(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_blackburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/black
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/aq_blackburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/toy/crayon/black),
		COOK_ADD_ITEM(/obj/item/food/bun),
	)

/datum/cooking/recipe/aq_branrequests
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/branrequests
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_branrequests/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/grown/wheat),
		COOK_ADD_ITEM(/obj/item/food/no_raisin),
	)

/datum/cooking/recipe/aq_briochecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/brioche
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_briochecake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cake/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_butterbiscuit
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/butterbiscuit
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/aq_butterbiscuit/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/butter),
		COOK_USE_OVEN(COOK_TEMP_LOW, 10 SECONDS),
	)

/datum/cooking/recipe/aq_butternoodles
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/spaghetti/butternoodles
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/aq_butternoodles/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_ITEM(/obj/item/food/butter),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_carbonara
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/spaghetti/carbonara
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_carbonara/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 2),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_carneburrito
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/carneburrito
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_carneburrito/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/grown/soybeans),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_cheese_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/cheese_sandwich
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_cheese_sandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
	)

/datum/cooking/recipe/aq_cheesyburrito
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/cheesyburrito
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_cheesyburrito/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/grown/soybeans),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_cheesynachos
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cheesynachos
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_cheesynachos/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_USE_OVEN(COOK_TEMP_LOW, 10 SECONDS),
	)

/datum/cooking/recipe/aq_chowmein
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/spaghetti/chowmein
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/aq_chowmein/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
		COOK_ADD_ITEM(/obj/item/food/grown/carrot),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_clown_sc
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/clown
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_clown_sc/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/laughter, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/aq_copypasta
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/spaghetti/copypasta
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/aq_copypasta/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/pastatomato),
		COOK_ADD_ITEM(/obj/item/food/spaghetti/pastatomato),
	)

/datum/cooking/recipe/aq_corgiburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/corgi
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/aq_corgiburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/patty/corgi),
		COOK_ADD_ITEM(/obj/item/food/bun),
	)

/datum/cooking/recipe/aq_cornedbeef
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cornedbeef
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_cornedbeef/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 5),
		COOK_ADD_ITEM(/obj/item/food/meat/steak),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
		COOK_USE_STOVE(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_crab_rangoon
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/crab_rangoon
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_crab_rangoon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/doughslice),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcrab),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/aq_crabburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/crab
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/aq_crabburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/crab),
		COOK_ADD_ITEM(/obj/item/food/meat/crab),
		COOK_ADD_ITEM(/obj/item/food/bun),
	)

/datum/cooking/recipe/aq_cubannachos
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cubannachos
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_cubannachos/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/ketchup, 5),
		COOK_ADD_ITEM(/obj/item/food/grown/chili),
		COOK_ADD_ITEM(/obj/item/food/grown/chili),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_USE_OVEN(COOK_TEMP_LOW, 10 SECONDS),
	)

/datum/cooking/recipe/aq_donkpocket_berry
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket/berry
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_donkpocket_berry/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_ITEM(/obj/item/food/grown/berries),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_donkpocket_dankpocket
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket/dankpocket
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_donkpocket_dankpocket/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_ITEM(/obj/item/food/grown/cannabis),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_donkpocket_gondola
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket/gondola
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_donkpocket_gondola/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_REAGENT(/datum/reagent/tranquility, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_donkpocket_honk
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket/honk
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_donkpocket_honk/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_ITEM(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 3),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_donkpocket_pizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket/pizza
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_donkpocket_pizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_ITEM(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_donkpocket_spicy
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket/spicy
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_donkpocket_spicy/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_ITEM(/obj/item/food/grown/chili),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_donkpocket_teriyaki
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket/teriyaki
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_donkpocket_teriyaki/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_REAGENT(/datum/reagent/consumable/soysauce, 3),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_donut_jelly
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/plain
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_donut_jelly/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/aq_donut_slimejelly
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/plain
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_donut_slimejelly/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/aq_doubleratkebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/rat/double
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_doubleratkebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/deadmouse),
		COOK_ADD_ITEM(/obj/item/food/deadmouse),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/aq_eggbowl
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/eggbowl
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/aq_eggbowl/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/boiledegg),
		COOK_ADD_ITEM(/obj/item/food/grown/carrot),
		COOK_ADD_ITEM(/obj/item/food/grown/corn),
	)

/datum/cooking/recipe/aq_energycake
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/cake/birthday/energy
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_energycake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cake/birthday),
		COOK_ADD_ITEM(/obj/item/melee/transforming/energy/sword),
	)

/datum/cooking/recipe/aq_fiestaskewer
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/fiesta
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_fiestaskewer/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/grown/chili),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/grown/corn),
		COOK_ADD_ITEM(/obj/item/food/grown/tomato),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/aq_fuegoburrito
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/fuegoburrito
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_fuegoburrito/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/grown/ghost_chili),
		COOK_ADD_ITEM(/obj/item/food/grown/ghost_chili),
		COOK_ADD_ITEM(/obj/item/food/grown/soybeans),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_futomaki_sushi_roll
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/futomaki
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/aq_futomaki_sushi_roll/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/boiledegg),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
	)

/datum/cooking/recipe/aq_garlicbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/garlicbread
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/aq_garlicbread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/grown/garlic),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/butter),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_glassnoodles
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spaghetti/glassnoodles
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/aq_glassnoodles/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_ITEM(/obj/item/food/grown/carrot),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/stack/sheet/glass),
		COOK_USE_STOVE(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_golabki
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/golabki
	catalog_category = COOK_CATEGORY_POLISH

/datum/cooking/recipe/aq_golabki/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
		COOK_ADD_ITEM(/obj/item/food/grown/tomato),
		COOK_USE_STOVE(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_honeybar
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/honeybar
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_honeybar/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/grown/oat),
		COOK_ADD_REAGENT(/datum/reagent/consumable/honey, 5),
	)

/datum/cooking/recipe/aq_hotcrossbun
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/hotcrossbun
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_hotcrossbun/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bread/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 1),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_jupitercupcake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/jupitercupcake
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_jupitercupcake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_ITEM(/obj/item/food/grown/mushroom/jupitercup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/caramel, 3),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_kasespatzle
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/spaghetti/kasespatzle
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/aq_kasespatzle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_REAGENT(/datum/reagent/consumable/eggyolk, 10),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_khachapuri
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/khachapuri
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_khachapuri/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/eggyolk, 5),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/bread/plain),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_kremowka
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/kremowka
	catalog_category = COOK_CATEGORY_POLISH

/datum/cooking/recipe/aq_kremowka/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_meatclown
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/meatclown
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_meatclown/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/steak/plain),
		COOK_ADD_ITEM(/obj/item/food/grown/banana),
	)

/datum/cooking/recipe/aq_melonkeg
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/melonkeg
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_melonkeg/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/vodka, 25),
		COOK_ADD_ITEM(/obj/item/food/grown/holymelon),
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/bottle/vodka),
	)

/datum/cooking/recipe/aq_mimanabread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/mimana
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/aq_mimanabread/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/soymilk, 5),
		COOK_ADD_ITEM(/obj/item/food/bread/plain),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/grown/banana/mime),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_nachos
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/nachos
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_nachos/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_USE_OVEN(COOK_TEMP_LOW, 10 SECONDS),
	)

/datum/cooking/recipe/aq_nigiri_sushi
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/nigiri_sushi
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/aq_nigiri_sushi/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_REAGENT(/datum/reagent/consumable/soysauce, 2),
	)

/datum/cooking/recipe/aq_nugget
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/nugget
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_nugget/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/aq_onigiri
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/onigiri
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_onigiri/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/aq_peto_parowek
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/peto_parowek
	catalog_category = COOK_CATEGORY_POLISH

/datum/cooking/recipe/aq_peto_parowek/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/paper),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_philadelphia_sushi_roll
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/philadelphia
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/aq_philadelphia_sushi_roll/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
	)

/datum/cooking/recipe/aq_pigblanket
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pigblanket
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_pigblanket/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/butter),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_USE_OVEN(COOK_TEMP_LOW, 10 SECONDS),
	)

/datum/cooking/recipe/aq_pingles
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/pingles
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_pingles/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/c_tube),
		COOK_ADD_ITEM(/obj/item/food/grown/potato/wedges),
		COOK_ADD_ITEM(/obj/item/food/onion_slice),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 10),
	)

/datum/cooking/recipe/aq_powercrepe
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/powercrepe
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_powercrepe/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_ADD_ITEM(/obj/item/stock_parts/cell/super),
		COOK_ADD_ITEM(/obj/item/melee/sabre),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_ptasie_mleczko
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/ptasie_mleczko
	catalog_category = COOK_CATEGORY_POLISH

/datum/cooking/recipe/aq_ptasie_mleczko/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/aq_pwrgame_sc
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/pwrgame
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_pwrgame_sc/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/pwr_game, 15),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/aq_ratkebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/rat
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_ratkebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/deadmouse),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/aq_ravtart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/ravtart
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_ravtart/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_ADD_ITEM(/obj/item/stack/tile/bronze),
		COOK_ADD_ITEM(/obj/item/food/grown/berries),
		COOK_ADD_ITEM(/obj/item/food/grown/berries),
		COOK_ADD_ITEM(/obj/item/food/grown/citrus/orange),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_rawkhinkali
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/rawkhinkali
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_rawkhinkali/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/doughslice),
		COOK_ADD_ITEM(/obj/item/food/grown/garlic),
		COOK_ADD_ITEM(/obj/item/food/meatball),
	)

/datum/cooking/recipe/aq_ricepork
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/salad/ricepork
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_ricepork/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_royalcheese
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/royalcheese
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_royalcheese/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cheese/wheel/cheddar),
		COOK_ADD_ITEM(/obj/item/clothing/head/crown),
		COOK_ADD_REAGENT(/datum/reagent/medicine/strange_reagent, 5),
		COOK_ADD_REAGENT(/datum/reagent/toxin/mutagen, 5),
	)

/datum/cooking/recipe/aq_sassysagepizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/sassysage
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/aq_sassysagepizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/raw_meatball),
		COOK_ADD_ITEM(/obj/item/food/raw_meatball),
		COOK_ADD_ITEM(/obj/item/food/raw_meatball),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_sausage
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/raw_sausage
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_sausage/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/raw_meatball),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
	)

/datum/cooking/recipe/aq_scotchegg
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/scotchegg
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_scotchegg/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_ADD_ITEM(/obj/item/food/boiledegg),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/aq_soylentburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/soylent
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/aq_soylentburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/soylentgreen),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/bun),
	)

/datum/cooking/recipe/aq_spaghettinapolitan
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/spaghetti/spaghettinapolitan
	catalog_category = COOK_CATEGORY_PASTA

/datum/cooking/recipe/aq_spaghettinapolitan/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti/boiledspaghetti),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ketchup, 10),
		COOK_ADD_ITEM(/obj/item/food/sausage),
		COOK_ADD_ITEM(/obj/item/food/grown/chili),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_spicy_filet_sushi_roll
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/spicyfilet
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/aq_spicy_filet_sushi_roll/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_ITEM(/obj/item/food/grown/chili),
		COOK_ADD_ITEM(/obj/item/food/grown/onion),
	)

/datum/cooking/recipe/aq_spiderlollipop
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/spiderlollipop
	catalog_category = COOK_CATEGORY_MISC

/datum/cooking/recipe/aq_spiderlollipop/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_ITEM(/obj/item/food/spiderling),
	)

/datum/cooking/recipe/aq_stuffedlegion
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/stuffedlegion
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_stuffedlegion/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/steak/goliath),
		COOK_ADD_ITEM(/obj/item/organ/regenerative_core/legion),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ketchup, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/capsaicin, 2),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_sugarcookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cookie/sugar
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/aq_sugarcookie/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_ITEM(/obj/item/food/pastrybase),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/aq_tacoplain
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/taco/plain
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_tacoplain/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/aq_tailkebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/tail
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/aq_tailkebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/organ/tail/lizard),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/aq_vegetarian_sushi_roll
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/vegetarian
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/aq_vegetarian_sushi_roll/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/grown/carrot),
		COOK_ADD_ITEM(/obj/item/food/grown/cabbage),
	)
