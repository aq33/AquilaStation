// AQUILA - przepisy krokowe z Paradise (ParadiseSS13/Paradise, code/modules/cooking/recipes), przeniesione na nasze
// makra. Pominięte: zupy (u nas są płynem w garnku), warianty na kości, dania z ras, których nie mamy, i dania
// z dubli z recipes_basic.dm. Ryby z wędkarstwa Paradise zastąpione filetem rybnym.

// ---------- Piekarnik ----------

/datum/cooking/recipe/amanita_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/amanita_pie
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/amanita_pie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/applecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/apple
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/applecake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/applepie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/applepie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/applepie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/appletart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/appletart
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/appletart/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple/gold),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 10),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/baguette
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/baguette
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/baguette/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bananabread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/banana
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/bananabread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bananacake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/banana
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/bananacake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/banarnarbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/banarnar
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/banarnarbread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/blood, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/beary_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/bearypie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/beary_pie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/bear),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berry_muffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/muffin/berry
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/berry_muffin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/berryclafoutis
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/berryclafoutis
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/berryclafoutis/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/birthdaycake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/birthday
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/birthdaycake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/candle),
		COOK_ADD_ITEM(/obj/item/candle),
		COOK_ADD_ITEM(/obj/item/candle),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vanilla, 10),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/blue
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherrycupcake/blue
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/blue/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/bluecherries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/blumpkin_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/blumpkinpie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/blumpkin_pie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/blumpkin, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/booberry_muffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/muffin/booberry
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/booberry_muffin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/ectoplasm),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/braincake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/brain
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/braincake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/organ/brain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/plain
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/bread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/bun
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bun
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/bun/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cannoli
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cannoli
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/cannoli/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/rawpastrybase),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 3),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/carrotcake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/carrot
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/carrotcake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/carrot),
		COOK_ADD_PRODUCE(/obj/item/food/grown/carrot),
		COOK_ADD_PRODUCE(/obj/item/food/grown/carrot),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/cheesecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/cheese
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/cheesecake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cheesepizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/cheese
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/cheesepizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/cherry_cupcake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cherrycupcake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/cherry_cupcake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cherrypie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/cherrypie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/cherrypie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 10),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolate_cornet
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/chococornet
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/chocolate_cornet/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/rawpastrybase),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolate_lava_tart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/cocoalavatart
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/chocolate_lava_tart/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/slime_extract),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/chocolatecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/chocolate
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/chocolatecake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/clowncake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/clown_cake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/clowncake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/sundae),
		COOK_ADD_ITEM(/obj/item/food/sundae),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 30 SECONDS),
	)

/datum/cooking/recipe/cracker
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cracker
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/cracker/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/doughslice),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/creamcheesebread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/creamcheese
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/creamcheesebread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream_cheese, 20),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/croissant
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/croissant
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/croissant/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/dankpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/dank
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/dankpizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cannabis),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/donkpocket
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/donkpocket
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/donkpocket/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/donkpocketpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/donkpocket
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/donkpocketpizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/donkpocket),
		COOK_ADD_ITEM(/obj/item/food/donkpocket),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/firecrackerpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/firecracker
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/firecrackerpizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/chili),
		COOK_ADD_PRODUCE(/obj/item/food/grown/chili),
		COOK_ADD_REAGENT(/datum/reagent/consumable/capsaicin, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/flatbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/flatbread
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/flatbread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fortunecookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/fortunecookie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/fortunecookie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/doughslice),
		COOK_ADD_ITEM(/obj/item/paper),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/french_silk_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/french_silk
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/french_silk_pie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/frosty_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/frostypie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/frosty_pie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/bluecherries),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/garlicpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/garlic
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/garlicpizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_ADD_REAGENT(/datum/reagent/consumable/garlic, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/grape_tart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/grapetart
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/grape_tart/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/grapes),
		COOK_ADD_PRODUCE(/obj/item/food/grown/grapes),
		COOK_ADD_PRODUCE(/obj/item/food/grown/grapes),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/ham_leg
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/ham_leg

/datum/cooking/recipe/ham_leg/New()
	steps = list(
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
		COOK_ADD_LIMB(list(SPECIES_HUMAN), "name" = "ludzka kończyna"),
	)

/datum/cooking/recipe/hardware_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/hardware_cake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/hardware_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/circuitboard),
		COOK_ADD_ITEM(/obj/item/circuitboard),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_ADD_REAGENT(/datum/reagent/toxin/acid, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/hawaiianpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/pineapple
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/hawaiianpizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/pineappleslice),
		COOK_ADD_ITEM(/obj/item/food/pineappleslice),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/holy_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/holy_cake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/holy_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_ADD_REAGENT(/datum/reagent/water/holywater, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/honey_bun
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/honeybun
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/honey_bun/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/rawpastrybase),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/honey, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/lasagna
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/spaghetti/lasagna
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/lasagna/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/lemoncake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/lemon
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/lemoncake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/liars_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/berry_chocolate_cake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/liars_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 30 SECONDS),
	)

/datum/cooking/recipe/limecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/lime
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/limecake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/loadedbakedpotato
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/loaded_baked_potato
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/loadedbakedpotato/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/macncheesepizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/macncheese
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/macncheesepizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/macncheese),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/meat
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/meatbread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatpie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/meatpie
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/meatpie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/meatpizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/meat
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/meatpizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/mime_tart
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/mimetart
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/mime_tart/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nothing, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/moffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/muffin/moffin
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/moffin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/grown/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/mothmallow
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/mothmallow_tray
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/mothmallow/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vanilla, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/rum, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/muffin
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/muffin
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/muffin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/mushroompizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/mushroom
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/mushroompizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/oatmeal_cookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cookie/oatmeal
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/oatmeal_cookie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/oat),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/orangecake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/orange
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/orangecake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/peanut_butter_cookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/peanut_butter_cookie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/peanut_butter_cookie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/peanut_butter, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pepperonipizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/pepperoni
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/pepperonipizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/sausage),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pestopizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/pesto
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/pestopizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_REAGENT(/datum/reagent/consumable/wasabi, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/pie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pizzamargherita
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/margherita
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/pizzamargherita/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plaincake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/plain
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/plaincake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plum_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/plum
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/plum_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/plum),
		COOK_ADD_PRODUCE(/obj/item/food/grown/plum),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plump_pie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/plump_pie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/plump_pie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/plumphelmetbiscuit
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/plumphelmetbiscuit
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/plumphelmetbiscuit/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/poppypretzel
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/poppypretzel
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/poppypretzel/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/plant_seeds/preset/poppy),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pound_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/pound_cake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/pound_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cake/plain),
		COOK_ADD_ITEM(/obj/item/food/cake/plain),
		COOK_ADD_ITEM(/obj/item/food/cake/plain),
		COOK_ADD_ITEM(/obj/item/food/cake/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pumpkin_spice_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/pumpkinspice
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/pumpkin_spice_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/pumpkin),
		COOK_ADD_PRODUCE(/obj/item/food/grown/pumpkin),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pumpkinpie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/pumpkinpie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/pumpkinpie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/pumpkin, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/raisin_cookie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cookie/raisin
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/raisin_cookie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/no_raisin),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/slime_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/slimecake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/slime_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/slime_extract),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/spaceman_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/trumpet
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/spaceman_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		COOK_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/spidermeatbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/spidermeat
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/spidermeatbread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/spider),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/spider),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/spider),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/syntibread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/meat
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/syntibread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/synthmeat),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/synthmeat),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/synthmeat),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/toastedsandwich
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/toastedsandwich
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/toastedsandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sandwich),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofubread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/tofu
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/tofubread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofupie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/tofupie
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/tofupie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/tofurkey
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/tofurkey
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/tofurkey/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/stuffing),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/turkey
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/roast_turkey
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/turkey/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/stuffing),
		COOK_ADD_ITEM(/obj/item/food/stuffing),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/vanilla_berry_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/berry_vanilla_cake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/vanilla_berry_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/vanilla_cake
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/cake/vanilla_cake
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/vanilla_cake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/vanillapod),
		COOK_ADD_PRODUCE(/obj/item/food/grown/vanillapod),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/vegetablepizza
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pizza/vegetable
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/vegetablepizza/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		COOK_ADD_PRODUCE(/obj/item/food/grown/carrot),
		COOK_ADD_PRODUCE(/obj/item/food/grown/corn),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_OVEN(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/xemeatpie
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/pie/xemeatpie
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/xemeatpie/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/xeno),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/xenomeatbread
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/bread/xenomeat
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/xenomeatbread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/xeno),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/xeno),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/xeno),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/yakiimo
	container_type = /obj/item/reagent_containers/cooking/oven
	product_type = /obj/item/food/yakiimo
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/yakiimo/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		COOK_USE_OVEN(COOK_TEMP_MED, 10 SECONDS),
	)

// ---------- Kuchenka ----------

/datum/cooking/recipe/amanitajelly
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/amanitajelly
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/amanitajelly/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/amanita),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/vodka, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/beans
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/canned/beans
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/beans/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		COOK_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ketchup, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/benedict
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/benedict
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/benedict/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/friedegg),
		COOK_ADD_ITEM(/obj/item/food/meat/steak/plain),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/berry_pancake
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/pancakes/blueberry
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/berry_pancake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/rawpastrybase),
		COOK_ADD_PRODUCE(/obj/item/food/grown/berries),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/boiled_shrimp
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiled_shrimp
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/boiled_shrimp/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/shellfish_meat/shrimp),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledegg
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledegg
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/boiledegg/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledrice
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledrice

/datum/cooking/recipe/boiledrice/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/rice, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledslimeextract
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledslimecore

/datum/cooking/recipe/boiledslimeextract/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/slime_extract),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/boiledspiderleg
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/boiledspiderleg

/datum/cooking/recipe/boiledspiderleg/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spiderleg),
		COOK_ADD_REAGENT(/datum/reagent/water, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/candiedapple
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/candiedapple
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/candiedapple/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/caribean_paradise
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/caribean_paradise

/datum/cooking/recipe/caribean_paradise/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/grown/mango),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/limejuice, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 15 SECONDS),
	)

/datum/cooking/recipe/chawanmushi
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/chawanmushi
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/chawanmushi/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/soysauce, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cheese_balls
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cheese_balls
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/cheese_balls/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/honey, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/cheesyfries
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cheesyfries
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/cheesyfries/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fries),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/choc_chip_pancake
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/pancakes/chocolatechip
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/choc_chip_pancake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/rawpastrybase),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/cubancarp
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/cubancarp
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/cubancarp/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_PRODUCE(/obj/item/food/grown/chili),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/dulce_de_batata
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/pie/dulcedebatata
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/dulce_de_batata/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato/sweet),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vanilla, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/eggplantparm
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/eggplantparm
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/eggplantparm/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/eggplant),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/enchiladas
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/enchiladas
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/enchiladas/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet/plain),
		COOK_ADD_PRODUCE(/obj/item/food/grown/chili),
		COOK_ADD_PRODUCE(/obj/item/food/grown/chili),
		COOK_ADD_PRODUCE(/obj/item/food/grown/corn),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/fishandchips
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/fishandchips
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/fishandchips/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fries),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/friedbanana
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/friedbanana
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/friedbanana/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 10),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/friedrice
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/friedrice
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/friedrice/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/rice, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/fufu
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/fufu
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/fufu/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/water, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/gigapuddi
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/gigapuddi
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/gigapuddi/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_STOVE(COOK_TEMP_LOW, 5 SECONDS),
	)

/datum/cooking/recipe/macncheese
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/macncheese
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/macncheese/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/spaghetti),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mashedtaters
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/mashed_potatoes
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/mashedtaters/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato),
		COOK_ADD_REAGENT(/datum/reagent/consumable/gravy, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/meatbun
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/meatbun
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/meatbun/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		COOK_ADD_REAGENT(/datum/reagent/consumable/soysauce, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/monkeysdelight
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/monkeysdelight
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/monkeysdelight/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/monkeycube),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/mousse_avocado
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/mousse_avocado
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/mousse_avocado/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cocoa, 5),
		COOK_ADD_ITEM(/obj/item/food/grown/avocado),
		COOK_USE_STOVE(COOK_TEMP_HIGH, 10 SECONDS),
	)

/datum/cooking/recipe/mushrooms_curry
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/mushrooms_curry
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/mushrooms_curry/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/chanterelle),
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_ADD_PRODUCE(/obj/item/food/grown/onion),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/pancake
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/pancakes
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/pancake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/rawpastrybase),
		COOK_USE_STOVE(COOK_TEMP_MED, 10 SECONDS),
	)

/datum/cooking/recipe/pastatomato
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spaghetti/pastatomato
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/pastatomato/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/plasmabone_broth
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/plasmabone_broth

/datum/cooking/recipe/plasmabone_broth/New()
	steps = list(
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
		COOK_ADD_LIMB(list(SPECIES_PLASMAMAN), "name" = "kończyna plazmoluda"),
	)

/datum/cooking/recipe/popcorn
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/popcorn
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/popcorn/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/corn),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/ricepudding
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/salad/ricepudding
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/ricepudding/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/rice, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/salmoncurry
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/salmoncurry
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/salmoncurry/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/sashimi
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/sashimi
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sashimi/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spidereggs),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_REAGENT(/datum/reagent/consumable/soysauce, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/soylentgreen
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soylentgreen

/datum/cooking/recipe/soylentgreen/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab/human),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/human),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/soylentviridians
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soylenviridians

/datum/cooking/recipe/soylentviridians/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/soybeans),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 10),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spacylibertyduff
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soup/spacylibertyduff

/datum/cooking/recipe/spacylibertyduff/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/libertycap),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/libertycap),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/libertycap),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/vodka, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spesslaw
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spaghetti/spesslaw
	catalog_category = COOK_CATEGORY_PIZZA

/datum/cooking/recipe/spesslaw/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spaghetti),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/spidereggsham
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/spidereggsham

/datum/cooking/recipe/spidereggsham/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/spidereggs),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/spider),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stewedsoymeat
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/stewedsoymeat

/datum/cooking/recipe/stewedsoymeat/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/soydope),
		COOK_ADD_ITEM(/obj/item/food/soydope),
		COOK_ADD_PRODUCE(/obj/item/food/grown/carrot),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

/datum/cooking/recipe/stuffing
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/stuffing

/datum/cooking/recipe/stuffing/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bread/plain),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_STOVE(COOK_TEMP_MED, 20 SECONDS),
	)

// ---------- Grill ----------

/datum/cooking/recipe/arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 5),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/arepa_cheese
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/cheese
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_cheese/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/arepa_cheesier
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/cheesier
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_cheesier/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/food/cheese/wheel),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/arepa_ham
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ham
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_ham/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/arepa_ham_cheese
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ham_cheese
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_ham_cheese/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/arepa_ice
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ice
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_ice/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_REAGENT(/datum/reagent/consumable/frostoil, 10),
		COOK_ADD_REAGENT(/datum/reagent/water, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/arepa_industrial
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/industrial
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_industrial/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_USE_GRILL(15 SECONDS),
		COOK_ADD_ITEM(/obj/item/bodypart/head/robot),
	)

/datum/cooking/recipe/arepa_infernal
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/infernal
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_infernal/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_REAGENT(/datum/reagent/consumable/capsaicin, 10),
		COOK_ADD_REAGENT(/datum/reagent/napalm, 1),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/arepa_life
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/life
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_life/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_REAGENT(/datum/reagent/medicine/strange_reagent, 5),
		COOK_ADD_REAGENT(/datum/reagent/water/holywater, 1),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/arepa_magma
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/magma
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_magma/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_REAGENT(/datum/reagent/consumable/capsaicin, 10),
		COOK_ADD_REAGENT(/datum/reagent/blood, 10),
		COOK_ADD_REAGENT(/datum/reagent/toxin/plasma, 10),
		COOK_USE_GRILL(20 SECONDS),
	)

/datum/cooking/recipe/arepa_plasma
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/plasma
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_plasma/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_REAGENT(/datum/reagent/toxin/plasma, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/arepa_plumphelmet
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/plumphelmet
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_plumphelmet/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		COOK_ADD_PRODUCE(/obj/item/food/grown/mushroom/plumphelmet),
		COOK_ADD_REAGENT(/datum/reagent/consumable/enzyme, 5),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/arepa_salmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/salmon
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_salmon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/arepa_slime
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/slime
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/arepa_slime/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/slime_extract),
		COOK_ADD_REAGENT(/datum/reagent/water, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/ash_kebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/ash
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/ash_kebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/mushroom_leaf),
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/cactus_fruit),
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/cactus_fruit),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/goliath),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/avocadosalmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/avocadosalmon
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/avocadosalmon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_PRODUCE(/obj/item/food/grown/avocado),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/bacon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meat/bacon
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/bacon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/rawbacon),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/bbqribs
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/bbqribs
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/bbqribs/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_REAGENT(/datum/reagent/consumable/bbqsauce, 5),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/birdsteak
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meat/steak/chicken
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/birdsteak/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab/chicken),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/citrussalmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/citrussalmon
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/citrussalmon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/cutlet
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meat/cutlet/plain
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/cutlet/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/rawcutlet),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/fish_skewer
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/fish
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/fish_skewer/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/fishfingers
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/fishfingers
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/fishfingers/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/fruit_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/fruit
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/fruit_arepa/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/ghost_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/ghost
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ghost_arepa/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/ectoplasm),
		COOK_ADD_REAGENT(/datum/reagent/consumable/enzyme, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/goliath
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meat/steak/goliath
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/goliath/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab/goliath),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/grilledcheese
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/grilled_cheese_sandwich
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/grilledcheese/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/hiss_kebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/hiss

/datum/cooking/recipe/hiss_kebab/New()
	steps = list(
		COOK_USE_GRILL(10 SECONDS),
		COOK_ADD_LIMB(list(SPECIES_LIZARD), "name" = "kończyna jaszczura"),
	)

/datum/cooking/recipe/human_kebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/human

/datum/cooking/recipe/human_kebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/human),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/human),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/meatkeb
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/monkey
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/meatkeb/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/meatsteak
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meat/steak/plain
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/meatsteak/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/meatsteak_cactus
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatsteak_cactus
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/meatsteak_cactus/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_PRODUCE(/obj/item/food/grown/prickly_pear),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/picoss_kebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/picoss
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/picoss_kebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_PRODUCE(/obj/item/food/grown/onion),
		COOK_ADD_PRODUCE(/obj/item/food/grown/chili),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vinegar, 5),
		COOK_USE_GRILL(20 SECONDS),
	)

/datum/cooking/recipe/rofflewaffles
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/rofflewaffles
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/rofflewaffles/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/drug/mushroomhallucinogen, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/salmonsteak
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/salmonsteak
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/salmonsteak/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/sausage
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sausage
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/sausage/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet/plain),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/shrimp_skewer
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/shrimp
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/shrimp_skewer/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/shellfish_meat/shrimp),
		COOK_ADD_ITEM(/obj/item/food/shellfish_meat/shrimp),
		COOK_ADD_ITEM(/obj/item/food/shellfish_meat/shrimp),
		COOK_ADD_ITEM(/obj/item/food/shellfish_meat/shrimp),
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_USE_GRILL(20 SECONDS),
	)

/datum/cooking/recipe/smokedsalmon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/smokedsalmon
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/smokedsalmon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/spider_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/spider
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/spider_arepa/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/food/spiderleg),
		COOK_ADD_ITEM(/obj/item/food/spiderleg),
		COOK_ADD_ITEM(/obj/item/food/spiderleg),
		COOK_ADD_ITEM(/obj/item/food/spiderleg),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 5),
		COOK_ADD_REAGENT(/datum/reagent/medicine/charcoal, 1),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/sushi_tamago
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sushi_piece/tamago
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sushi_tamago/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/sake, 5),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/sushi_unagi
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/sushi_piece/unagi
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sushi_unagi/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/sake, 5),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/sweet_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/sweet
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/sweet_arepa/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/syntikebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/synth
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/syntikebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/synthmeat),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/synthmeat),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/syntisteak_cactus
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/syntisteak_cactus
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/syntisteak_cactus/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab/synthmeat, "exact" = TRUE),
		COOK_ADD_PRODUCE(/obj/item/food/grown/prickly_pear),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_USE_GRILL(15 SECONDS),
	)

/datum/cooking/recipe/telebacon
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/telebacon
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/telebacon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_ITEM(/obj/item/assembly/signaler),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/toast
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/toast
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/toast/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/tofukebab
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/kebab/tofu
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/tofukebab/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/stack/rods),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/waffles
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/waffles
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/waffles/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 10),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/wingfangchu
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/wingfangchu
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/wingfangchu/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/slab/xeno),
		COOK_ADD_REAGENT(/datum/reagent/consumable/soysauce, 5),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/xeno_arepa
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/arepa/xeno
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/xeno_arepa/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/arepa),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/xeno),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/enzyme, 5),
		COOK_USE_GRILL(15 SECONDS),
	)

// ---------- Frytkownica ----------

/datum/cooking/recipe/apple_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/apple
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/apple_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/applejuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/apple_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/apple
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/apple_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/applejuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/apple_slime_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/apple
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/apple_slime_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/applejuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/blumpkin_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/blumpkin
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/blumpkin_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blumpkinjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/bungo_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/bungo
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/bungo_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/bungojuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/frostoil, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/caramel_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/caramel
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/caramel_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/sweet/caramel),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/carrotfries
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/carrotfries
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/carrotfries/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/carrot),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/chaosdonut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/chaos
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/chaosdonut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/frostoil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/capsaicin, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry_blumpkin
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/blumpkin
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherry_blumpkin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blumpkinjuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry_bungo_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/bungo
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherry_bungo_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/bungojuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/frostoil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry_caramel_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/caramel
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherry_caramel_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/sweet/caramel),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry_choco_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/choco
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherry_choco_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/cherryjelly
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherry_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry_matcha_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/matcha
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherry_matcha_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/toxin/teapowder, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherry_spaceman_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/trumpet
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherry_spaceman_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/cherryapple_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/apple
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/cherryapple_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/applejuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/chimichanga
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/chimichanga
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/chimichanga/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/burrito),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/choco
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/chocolate_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/corn_chips
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/cornchips
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/corn_chips/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/corn),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/deepfryer_friedbanana
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/friedbanana
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/deepfryer_friedbanana/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/fried_tofu
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fried_tofu
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/fried_tofu/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/jelly_blumpkin_berry_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/blumpkin
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/jelly_blumpkin_berry_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blumpkinjuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly_bungo_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/bungo
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/jelly_bungo_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/bungojuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/frostoil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly_caramel_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/caramel
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/jelly_caramel_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/sweet/caramel),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly_choco_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/choco
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/jelly_choco_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly_matcha_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/matcha
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/jelly_matcha_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/toxin/teapowder, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jelly_spaceman_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/trumpet
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/jelly_spaceman_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/jellydonut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/jellydonut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/matcha_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/matcha
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/matcha_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/toxin/teapowder, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/meat_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/meat
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/meat_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/rawpastrybase),
		COOK_ADD_ITEM(/obj/item/food/meat/slab),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ketchup, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/onionrings
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/onionrings
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/onionrings/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/onion_slice),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/pink_cherry_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/berry
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/pink_cherry_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/pink_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/berry
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/pink_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/pink_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/berry
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/pink_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/pink_slime_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/berry
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/pink_slime_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/potato_chips
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/chips
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/potato_chips/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato/wedges),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/shrimp
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fried_shrimp
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/shrimp/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/shellfish_meat/shrimp),
		COOK_USE_FRYER(10 SECONDS),
	)

/datum/cooking/recipe/slime_blumpkin_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/blumpkin
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/slime_blumpkin_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blumpkinjuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime_bungo_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/bungo
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/slime_bungo_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/consumable/bungojuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/frostoil, 5),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime_caramel_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/caramel
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/slime_caramel_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/sweet/caramel),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime_chocolate_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/choco
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/slime_chocolate_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime_matcha_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/matcha
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/slime_matcha_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_REAGENT(/datum/reagent/toxin/teapowder, 5),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slime_spaceman_jelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly/trumpet
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/slime_spaceman_jelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/slimejelly_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/jelly/slimejelly
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/slimejelly_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/spaceman_donut
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/trumpet
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/spaceman_donut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/donut, "exact" = TRUE),
		COOK_ADD_PRODUCE(/obj/item/food/grown/trumpet),
		COOK_USE_FRYER(20 SECONDS),
	)

/datum/cooking/recipe/sprinkles
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/donut/plain
	catalog_category = COOK_CATEGORY_DONUTS

/datum/cooking/recipe/sprinkles/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sprinkles, 2),
		COOK_USE_FRYER(20 SECONDS),
	)

// ---------- Deska do krojenia ----------

/datum/cooking/recipe/appendixburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/appendix
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/appendixburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/organ/appendix),
	)

/datum/cooking/recipe/avocadosandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/avocadosandwich
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/avocadosandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/toast),
		COOK_ADD_ITEM(/obj/item/food/grown/avocado),
		COOK_ADD_ITEM(/obj/item/food/grown/avocado),
		COOK_ADD_REAGENT(/datum/reagent/consumable/mayonnaise, 10),
		COOK_ADD_ITEM(/obj/item/food/toast),
	)

/datum/cooking/recipe/baconburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/baconburger
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/baconburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/baconrolled
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/baconrolled
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/baconrolled/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/grown/avocado),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
	)

/datum/cooking/recipe/baseballburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/baseball
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/baseballburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/melee/baseball_bat),
	)

/datum/cooking/recipe/bearger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bearger
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/bearger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/bear),
	)

/datum/cooking/recipe/bigbiteburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bigbite
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/bigbiteburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/burger/plain),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
	)

/datum/cooking/recipe/blt
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/blt
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/blt/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_ITEM(/obj/item/food/grown/tomato),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/brainburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/brain
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/brainburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/organ/brain),
	)

/datum/cooking/recipe/burrito
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burrito
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/burrito/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet/plain),
		COOK_ADD_ITEM(/obj/item/food/canned/beans),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_REAGENT(/datum/reagent/consumable/capsaicin, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/rice, 5),
	)

/datum/cooking/recipe/butter_dog
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/butterdog
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/butter_dog/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/butter),
	)

/datum/cooking/recipe/butter_toast
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/butteredtoast
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/butter_toast/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/toast),
		COOK_ADD_ITEM(/obj/item/food/butter),
	)

/datum/cooking/recipe/cheeseburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/cheese
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/cheeseburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/cherrysandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jellysandwich/cherry
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/cherrysandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
	)

/datum/cooking/recipe/chickenburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/chicken
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/chickenburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/chicken),
	)

/datum/cooking/recipe/clownburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/clown
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/clownburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/clothing/mask/gas/clown_hat),
	)

/datum/cooking/recipe/crazyburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/crazy
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/crazyburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/toy/crayon/green),
		COOK_ADD_ITEM(/obj/item/flashlight/flare),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_PRODUCE(/obj/item/food/grown/chili),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 15),
	)

/datum/cooking/recipe/elecburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/empoweredburger
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/elecburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/stack/sheet/mineral/plasma),
		COOK_ADD_ITEM(/obj/item/stack/sheet/mineral/plasma),
	)

/datum/cooking/recipe/fishburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/fish
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/fishburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/fishmeat/carp),
	)

/datum/cooking/recipe/fivealarmburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/fivealarm
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/fivealarmburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/friedriceegg
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/friedriceegg
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/friedriceegg/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/friedrice),
		COOK_ADD_ITEM(/obj/item/food/friedegg),
	)

/datum/cooking/recipe/ghostburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ghost
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ghostburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/ectoplasm),
	)

/datum/cooking/recipe/glass_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/glass_sandwich
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/glass_sandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/shard, "exact" = TRUE),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/hamborger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/roburger
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/hamborger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/bodypart/head/robot),
	)

/datum/cooking/recipe/hotdog
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/hotdog
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/hotdog/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/sausage),
	)

/datum/cooking/recipe/human_burger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/human

/datum/cooking/recipe/human_burger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/human),
	)

/datum/cooking/recipe/jellied_slime_toast
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jelliedtoast/slime
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/jellied_slime_toast/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/toast),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
	)

/datum/cooking/recipe/jelliedtoast
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jelliedtoast/cherry
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/jelliedtoast/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/toast),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
	)

/datum/cooking/recipe/jellyburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/cherry
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/jellyburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
	)

/datum/cooking/recipe/mcguffin
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mcguffin
	catalog_category = COOK_CATEGORY_BREAKFAST

/datum/cooking/recipe/mcguffin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
		COOK_ADD_ITEM(/obj/item/food/friedegg),
	)

/datum/cooking/recipe/mcrib
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/rib
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/mcrib/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/bbqribs),
		COOK_ADD_ITEM(/obj/item/food/onion_slice),
	)

/datum/cooking/recipe/mimeburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mime
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/mimeburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/clothing/head/beret),
	)

/datum/cooking/recipe/notasandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/notasandwich
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/notasandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/clothing/mask/fakemoustache),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/nothingburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/nothing
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/nothingburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nothing, 10),
	)

/datum/cooking/recipe/pbj_cherry
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_jelly/cherry
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/pbj_cherry/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/peanut_butter, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/peanut_butter_banana
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_banana
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/peanut_butter_banana/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/peanut_butter, 5),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/philly_cheesesteak
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/philly_cheesesteak
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/philly_cheesesteak/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/onion),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/plainburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/plain
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/plainburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/plasma_glass_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/glass_sandwich/plasma
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/plasma_glass_sandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/shard/plasma),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/ppattyblue
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/blue
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattyblue/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
	)

/datum/cooking/recipe/ppattygreen
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/green
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattygreen/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/limejuice, 5),
	)

/datum/cooking/recipe/ppattyorange
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/orange
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattyorange/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 5),
	)

/datum/cooking/recipe/ppattypurple
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/purple
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattypurple/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/grapejuice, 5),
	)

/datum/cooking/recipe/ppattyrainbow
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/rainbow
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattyrainbow/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/burger/red),
		COOK_ADD_ITEM(/obj/item/food/burger/orange),
		COOK_ADD_ITEM(/obj/item/food/burger/yellow),
		COOK_ADD_ITEM(/obj/item/food/burger/green),
		COOK_ADD_ITEM(/obj/item/food/burger/blue),
		COOK_ADD_ITEM(/obj/item/food/burger/purple),
		COOK_ADD_ITEM(/obj/item/food/burger/white),
	)

/datum/cooking/recipe/ppattyred
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/red
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattyred/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
	)

/datum/cooking/recipe/ppattywhite
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/white
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattywhite/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
	)

/datum/cooking/recipe/ppattyyellow
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/yellow
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ppattyyellow/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/lemonjuice, 5),
	)

/datum/cooking/recipe/ratburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/rat
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/ratburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/deadmouse),
	)

/datum/cooking/recipe/salmoncreamtoast
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/salmoncreamtoast
	catalog_category = COOK_CATEGORY_SEAFOOD

/datum/cooking/recipe/salmoncreamtoast/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/baguette),
		COOK_ADD_ITEM(/obj/item/food/smokedsalmon),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream_cheese, 10),
	)

/datum/cooking/recipe/sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/sandwich
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/sandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/meat/steak/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/slime
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_jelly/slime

/datum/cooking/recipe/slime/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/peanut_butter, 5),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/slimeburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/slime
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/slimeburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
	)

/datum/cooking/recipe/slimesandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jellysandwich/slime
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/slimesandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_REAGENT(/datum/reagent/toxin/slimejelly, 5),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
	)

/datum/cooking/recipe/spellburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/spell
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/spellburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/clothing/head/wizard),
	)

/datum/cooking/recipe/superbiteburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/superbite
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/superbiteburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/burger/bigbite),
		COOK_ADD_ITEM(/obj/item/food/dough),
		COOK_ADD_ITEM(/obj/item/food/patty/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/meat/bacon),
		COOK_ADD_ITEM(/obj/item/food/grown/tomato),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 5),
	)

/datum/cooking/recipe/supermatter_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/supermatter_sandwich
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/supermatter_sandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/nuke_core/supermatter_sliver),
	)

/datum/cooking/recipe/tofuburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/tofu
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/tofuburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/tofu),
	)

/datum/cooking/recipe/turkish_delight
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/turkish_delight

/datum/cooking/recipe/turkish_delight/New()
	steps = list(
		COOK_ADD_LIMB(list(SPECIES_JELLYPERSON), "name" = "galaretowata kończyna"),
	)

/datum/cooking/recipe/twobread
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/twobread
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/twobread/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ethanol/wine, 5),
	)

/datum/cooking/recipe/wafers
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/wafers

/datum/cooking/recipe/wafers/New()
	steps = list(
		COOK_ADD_ROBOTIC_LIMB(),
	)

/datum/cooking/recipe/wrap
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/eggwrap
	catalog_category = COOK_CATEGORY_VEGE

/datum/cooking/recipe/wrap/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/friedegg),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		COOK_ADD_REAGENT(/datum/reagent/consumable/soysauce, 10),
	)

/datum/cooking/recipe/xenoburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/xeno
	catalog_category = COOK_CATEGORY_BURGERS

/datum/cooking/recipe/xenoburger/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/bun),
		COOK_ADD_ITEM(/obj/item/food/meat/slab/xeno),
	)

// ---------- Miska do mieszania ----------

/datum/cooking/recipe/aesirsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/aesirsalad
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/aesirsalad/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/deus),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple/gold),
	)

/datum/cooking/recipe/antipasto_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/antipasto
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/antipasto_salad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_PRODUCE(/obj/item/food/grown/olive),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
	)

/datum/cooking/recipe/ash_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/ash_salad
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/ash_salad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/mushroom_leaf),
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/mushroom_leaf),
		COOK_ADD_ITEM(/obj/item/food/grown/ash_flora/cactus_fruit),
		COOK_ADD_ITEM(/obj/item/food/meat/steak/goliath),
	)

/datum/cooking/recipe/caesar_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/caesar
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/caesar_salad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/onion_slice/red),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/breadslice/plain),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil/olive, 5),
	)

/datum/cooking/recipe/citrusdelight
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/citrusdelight
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/citrusdelight/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lime),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
	)

/datum/cooking/recipe/ensaladacactus
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/ensaladacactus
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/ensaladacactus/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/prickly_pear),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
	)

/datum/cooking/recipe/fruitsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/fruit
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/fruitsalad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/watermelonslice),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_ADD_PRODUCE(/obj/item/food/grown/grapes),
	)

/datum/cooking/recipe/garlic_snack
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/garlic_snack
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/garlic_snack/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_ADD_REAGENT(/datum/reagent/consumable/guacamole, 10),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
		COOK_ADD_ITEM(/obj/item/food/baguette),
	)

/datum/cooking/recipe/greek_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/greek
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/greek_salad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/onion_slice/red),
		COOK_ADD_ITEM(/obj/item/food/onion_slice/red),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
		COOK_ADD_PRODUCE(/obj/item/food/grown/olive),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil/olive, 5),
	)

/datum/cooking/recipe/guacamole
	container_type = /obj/item/reagent_containers/cooking/bowl
	reagent_type = /datum/reagent/consumable/guacamole
	reagent_amount = 20
	catalog_category = COOK_CATEGORY_SIDES

/datum/cooking/recipe/guacamole/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/avocado),
		COOK_ADD_PRODUCE(/obj/item/food/grown/avocado),
		COOK_ADD_PRODUCE(/obj/item/food/grown/tomato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/onion),
		COOK_ADD_PRODUCE(/obj/item/food/grown/garlic),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blackpepper, 1),
	)

/datum/cooking/recipe/herbsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/herbsalad
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/herbsalad/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
	)

/datum/cooking/recipe/junglesalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/jungle
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/junglesalad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/watermelonslice),
		COOK_ADD_ITEM(/obj/item/food/watermelonslice),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_ADD_PRODUCE(/obj/item/food/grown/grapes),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
	)

/datum/cooking/recipe/kale_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/kale
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/kale_salad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/onion_slice/red),
		COOK_ADD_ITEM(/obj/item/food/onion_slice/red),
		COOK_ADD_PRODUCE(/obj/item/food/grown/carrot),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil/olive, 5),
	)

/datum/cooking/recipe/melonfruitbowl
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/melonfruitbowl
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/melonfruitbowl/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/watermelon),
		COOK_ADD_PRODUCE(/obj/item/food/grown/apple),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/lemon),
	)

/datum/cooking/recipe/potato_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/potato
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/potato_salad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledegg),
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato),
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato),
		COOK_ADD_REAGENT(/datum/reagent/consumable/mayonnaise, 5),
	)

/datum/cooking/recipe/salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/salad/New()
	steps = list(
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		COOK_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/tree_salad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/tree_salad

/datum/cooking/recipe/tree_salad/New()
	steps = list(
		COOK_ADD_LIMB(list("pod"), "name" = "kończyna roślinoluda"),
	)

/datum/cooking/recipe/validsalad
	container_type = /obj/item/reagent_containers/cooking/bowl
	product_type = /obj/item/food/salad/validsalad
	catalog_category = COOK_CATEGORY_SALADS

/datum/cooking/recipe/validsalad/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/meatball),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_ADD_PRODUCE(/obj/item/food/grown/potato),
	)

// ---------- Mata do sushi ----------

/datum/cooking/recipe/ebi_maki
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/ebi
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/ebi_maki/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/boiled_shrimp),
		COOK_ADD_ITEM(/obj/item/food/boiled_shrimp),
		COOK_ADD_ITEM(/obj/item/food/boiled_shrimp),
		COOK_ADD_ITEM(/obj/item/food/boiled_shrimp),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/inari_maki
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/inari
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/inari_maki/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/fried_tofu),
		COOK_ADD_ITEM(/obj/item/food/fried_tofu),
		COOK_ADD_ITEM(/obj/item/food/fried_tofu),
		COOK_ADD_ITEM(/obj/item/food/fried_tofu),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/sake_maki
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/sake
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sake_maki/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/smoked_salmon_maki
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_roll/smoked_salmon
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/smoked_salmon_maki/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/smokedsalmon),
		COOK_ADD_ITEM(/obj/item/food/smokedsalmon),
		COOK_ADD_ITEM(/obj/item/food/smokedsalmon),
		COOK_ADD_ITEM(/obj/item/food/smokedsalmon),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/sushi_ebi
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_piece/ebi
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sushi_ebi/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/boiled_shrimp),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/sushi_inari
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_piece/inari
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sushi_inari/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/fried_tofu),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/sushi_sake
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_piece/sake
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sushi_sake/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/fishmeat),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

/datum/cooking/recipe/sushi_smoked_salmon
	container_type = /obj/item/reagent_containers/cooking/sushimat
	product_type = /obj/item/food/sushi_piece/smoked_salmon
	catalog_category = COOK_CATEGORY_SUSHI

/datum/cooking/recipe/sushi_smoked_salmon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/boiledrice),
		COOK_ADD_ITEM(/obj/item/food/smokedsalmon),
		COOK_ADD_ITEM(/obj/item/food/seaweed_sheet),
	)

// ---------- Mikser lodów ----------

/datum/cooking/recipe/antpopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/ant_candy
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/antpopsicle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/ants, 10),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/apple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/apple
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/apple/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/applejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/bananatopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/bananatop
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/bananatopsicle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/banana, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/berry
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/berry
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/berry/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/berrycreamsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/berrycream
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/berrycreamsicle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 4),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vanilla, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/berryicecreamsandwich
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/strawberryicecreamsandwich
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/berryicecreamsandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/icecream),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/berrytopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/berrytop
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/berrytopsicle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/bluecherry
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/blue
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/bluecherry/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/bluecherryjelly, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/candied_pineapple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/candied_pineapple
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/candied_pineapple/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/pineappleslice),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_ADD_REAGENT(/datum/reagent/water, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/candybar
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/candy
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/candybar/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_ITEM(/obj/item/paper),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/candycane
	container_type = /obj/item/reagent_containers/cooking/mould/cane
	product_type = /obj/item/food/sweet/candycane
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/candycane/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/mint),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/caramel
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/caramel
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/caramel/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cash
	container_type = /obj/item/reagent_containers/cooking/mould/cash
	product_type = /obj/item/food/sweet/cash
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cash/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cherry_snowcone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/red
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/cherry_snowcone/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bar
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolatebar
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/chocolate_bar/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/soymilk, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cocoa, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bar2
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolatebar
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/chocolate_bar2/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cocoa, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_bunny
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolatebunny
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/chocolate_bunny/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_coin
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chococoin
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/chocolate_coin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/coin),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/chocolate_orange
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocoorange
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/chocolate_orange/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_PRODUCE(/obj/item/food/grown/citrus/orange),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/chocolateegg
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/chocolateegg
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/chocolateegg/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/coin
	container_type = /obj/item/reagent_containers/cooking/mould/coin
	product_type = /obj/item/food/chococoin
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/coin/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cola
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/soda
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/cola/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/space_cola, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cornuto
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen_dessert/cornuto
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/cornuto/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/flatdough),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 4),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 4),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/c_tube),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 15),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_blue
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/blue
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_blue/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_green
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/green
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_green/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/limejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_orange
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/orange
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_orange/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_pink
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/pink
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_pink/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/watermelonjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_poison
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/poison
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_poison/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/poisonberryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_purple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/purple
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_purple/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/grapejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_rainbow
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/rainbow
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_rainbow/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/red),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/blue),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/green),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/yellow),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/orange),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/purple),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/pink),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_rainbow2
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/bad_rainbow
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_rainbow2/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/red),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/poison),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/green),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/yellow),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/orange),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/purple),
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton/pink),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_red
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/red
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_red/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/cottoncandy_yellow
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/cotton/yellow
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/cottoncandy_yellow/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/sweet/cotton),
		COOK_ADD_REAGENT(/datum/reagent/consumable/lemonjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/crunch
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/confectionery/rice
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/crunch/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/candy),
		COOK_ADD_REAGENT(/datum/reagent/consumable/rice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/flavorless
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/flavorless/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/frozenpineapplepop
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/frozenpineapple
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/frozenpineapplepop/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_ITEM(/obj/item/food/pineappleslice),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/fruitsalad_snowcone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/fruitsalad
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/fruitsalad_snowcone/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/banana, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/watermelonjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/fudge
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/fudge
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/fudge/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/fudge_cherry
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/fudge/cherry
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/fudge_cherry/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/fudge_cookies_n_cream
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/fudge/cookies_n_cream
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/fudge_cookies_n_cream/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/food/cookie),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/fudge_dice
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/fudgedice
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/fudge_dice/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/dice),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/fudge_peanut
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/fudge/peanut
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/fudge_peanut/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_PRODUCE(/obj/item/food/grown/peanut),
		COOK_ADD_PRODUCE(/obj/item/food/grown/peanut),
		COOK_ADD_PRODUCE(/obj/item/food/grown/peanut),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/fudge_turtle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/fudge/turtle
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/fudge_turtle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_ITEM(/obj/item/food/sweet/caramel),
		COOK_ADD_PRODUCE(/obj/item/food/grown/peanut),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/grape
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/grape
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/grape/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/grapejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gum
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/gum
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gum/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/honey
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/honey
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/honey/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/honey, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/honkdae
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/honkdae
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/honkdae/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/icecream),
		COOK_ADD_ITEM(/obj/item/clothing/mask/gas/clown_hat),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 5),
		COOK_USE_ICE_CREAM(20 SECONDS),
	)

/datum/cooking/recipe/icecreamsandwich
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/icecreamsandwich
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/icecreamsandwich/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/icecream),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jawbreaker
	container_type = /obj/item/reagent_containers/cooking/mould/ball
	product_type = /obj/item/food/sweet/jawbreaker
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jawbreaker/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 10),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jumboicecream
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/jumbo
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/jumboicecream/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vanilla, 3),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/lemon
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/lemon
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/lemon/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/lemonjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/licoricecreamsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/licoricecream
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/licoricecreamsicle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/blumpkinjuice, 4),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vanilla, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/lime
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/lime
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/lime/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/limejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/malper
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/confectionery/caramel
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/malper/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/candy),
		COOK_ADD_ITEM(/obj/item/food/sweet/caramel),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/mime
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/mime
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/mime/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nothing, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/mint
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/mint
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/mint/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/toxin, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/mint_2
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/mint
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/mint_2/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/frostoil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/nougat
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/nougat
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/nougat/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/egg),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/orange
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/orange
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/orange/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/orangecreamsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/orangecream
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/orangecreamsicle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 4),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/vanilla, 2),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/peanutbuttermochi
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/frozen_dessert/peanutbuttermochi
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/peanutbuttermochi/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/icecream),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/rice, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/peanut_butter, 2),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/pineapple
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/pineapple
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/pineapple/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/pineapplejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/pineappletopsicle
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/pineappletop
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/pineappletopsicle/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_ITEM(/obj/item/food/tofu),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/pineapplejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/rainbow
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/rainbow
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/rainbow/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/colorful_reagent, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/seasalticecream
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/popsicle/sea_salt
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/seasalticecream/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/popsicle_stick),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 3),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/spacefreezy
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/spacefreezy
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/spacefreezy/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/icecream),
		COOK_ADD_REAGENT(/datum/reagent/consumable/bluecherryjelly, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/spacemountainwind, 15),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/spacemountainwind
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/snowcones/spacemountainwind
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/spacemountainwind/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/reagent_containers/food/drinks/sillycup),
		COOK_ADD_REAGENT(/datum/reagent/consumable/ice, 15),
		COOK_ADD_REAGENT(/datum/reagent/consumable/spacemountainwind, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/sucker
	container_type = /obj/item/reagent_containers/cooking/mould/loli
	product_type = /obj/item/food/lollipop
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/sucker/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 10),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/sundae
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sundae
	catalog_category = COOK_CATEGORY_DESSERTS

/datum/cooking/recipe/sundae/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/icecream),
		COOK_ADD_PRODUCE(/obj/item/food/grown/cherries),
		COOK_ADD_PRODUCE(/obj/item/food/grown/banana),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cream, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/taffy
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/taffy
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/taffy/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/medicine/salglu_solution, 15),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/toffee
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/toffee
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/toffee/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/flour, 10),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/toolerone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/confectionery/nougat
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/toolerone/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/candy),
		COOK_ADD_ITEM(/obj/item/food/sweet/nougat),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/toxinstest
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/confectionery/caramel_nougat
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/toxinstest/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/candy),
		COOK_ADD_ITEM(/obj/item/food/sweet/caramel),
		COOK_ADD_ITEM(/obj/item/food/sweet/nougat),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/wafflecone
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/icecream
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/wafflecone/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/milk, 1),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 1),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/yumbaton
	container_type = /obj/item/reagent_containers/cooking/icecream_bowl
	product_type = /obj/item/food/sweet/confectionery/toffee
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/yumbaton/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/candy),
		COOK_ADD_ITEM(/obj/item/food/sweet/toffee),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

// ---------- Różne (poprawki Paradise) ----------

/datum/cooking/recipe/cooked_meatball
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/meatball
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/cooked_meatball/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/raw_meatball),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1, "optional" = TRUE),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/cooked_patty
	container_type = /obj/item/reagent_containers/cooking/grill_grate
	product_type = /obj/item/food/patty/plain
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/cooked_patty/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/raw_patty),
		COOK_ADD_REAGENT(/datum/reagent/consumable/sodiumchloride, 1, "optional" = TRUE),
		COOK_USE_GRILL(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_blue
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/blue
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_blue/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_green
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/green
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_green/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/limejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_orange
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/orange
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_orange/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_poison
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/poison
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_poison/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/poisonberryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_purple
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/purple
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_purple/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/grapejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_red
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/red
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_red/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_wtf
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/wtf
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_wtf/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/drug/space_drugs, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_wtf2
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/wtf
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_wtf2/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummybear_yellow
	container_type = /obj/item/reagent_containers/cooking/mould/bear
	product_type = /obj/item/food/sweet/gummybear/yellow
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummybear_yellow/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/lemonjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_blue
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/blue
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_blue/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_green
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/green
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_green/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/limejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_orange
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/orange
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_orange/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_poison
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/poison
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_poison/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/poisonberryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_purple
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/purple
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_purple/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/grapejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_red
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/red
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_red/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_wtf
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/wtf
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_wtf/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/drug/space_drugs, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_wtf2
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/wtf
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_wtf2/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/gummyworm_yellow
	container_type = /obj/item/reagent_containers/cooking/mould/worm
	product_type = /obj/item/food/sweet/gummyworm/yellow
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/gummyworm_yellow/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/lemonjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_blue
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/blue
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_blue/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/berryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_chocolate
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/chocolate
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_chocolate/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_ITEM(/obj/item/food/chocolatebar),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_coffee
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/coffee
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_coffee/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/coffee, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_cola
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/cola
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_cola/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/space_cola, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_drgibb
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/drgibb
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_drgibb/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/dr_gibb, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_green
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/green
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_green/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/limejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_orange
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/orange
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_orange/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/orangejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_poison
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/poison
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_poison/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/poisonberryjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_popcorn
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/popcorn
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_popcorn/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_ITEM(/obj/item/food/popcorn),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_purple
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/purple
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_purple/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/grapejuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_red
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/red
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_red/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/cherryjelly, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_wtf
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/wtf
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_wtf/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/drug/space_drugs, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_wtf2
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/wtf
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_wtf2/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_PRODUCE(/obj/item/food/grown/ambrosia/vulgaris),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/jellybean_yellow
	container_type = /obj/item/reagent_containers/cooking/mould/bean
	product_type = /obj/item/food/sweet/jellybean/yellow
	catalog_category = COOK_CATEGORY_CANDY

/datum/cooking/recipe/jellybean_yellow/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/sugar, 5),
		COOK_ADD_REAGENT(/datum/reagent/water, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/nutriment/fat/oil, 5),
		COOK_ADD_REAGENT(/datum/reagent/consumable/lemonjuice, 5),
		COOK_USE_ICE_CREAM(10 SECONDS),
	)

/datum/cooking/recipe/moffolo_wild_wings
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fried_nian_bbq

/datum/cooking/recipe/moffolo_wild_wings/New()
	steps = list(
		COOK_ADD_REAGENT(/datum/reagent/consumable/bbqsauce, 5),
		COOK_USE_FRYER(10 SECONDS),
		COOK_ADD_LIMB(list(SPECIES_MOTH), "name" = "kończyna ćmy"),
	)

/datum/cooking/recipe/moffolo_wings
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/fried_nian

/datum/cooking/recipe/moffolo_wings/New()
	steps = list(
		COOK_USE_FRYER(10 SECONDS),
		COOK_ADD_LIMB(list(SPECIES_MOTH), "name" = "kończyna ćmy"),
	)

/datum/cooking/recipe/pork_rind
	container_type = /obj/item/reagent_containers/cooking/deep_basket
	product_type = /obj/item/food/pork_rind
	product_count = 3

/datum/cooking/recipe/pork_rind/New()
	steps = list(
		COOK_USE_FRYER(10 SECONDS),
		COOK_ADD_LIMB(list(SPECIES_HUMAN), "name" = "ludzka kończyna"),
	)

/datum/cooking/recipe/taco
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/taco
	catalog_category = COOK_CATEGORY_MEAT

/datum/cooking/recipe/taco/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/tortilla),
		COOK_ADD_ITEM(/obj/item/food/meat/cutlet/plain),
		COOK_ADD_ITEM(/obj/item/food/cheese/wedge),
	)

/datum/cooking/recipe/torilla
	container_type = /obj/item/reagent_containers/cooking/pan
	product_type = /obj/item/food/tortilla
	catalog_category = COOK_CATEGORY_BREAD

/datum/cooking/recipe/torilla/New()
	steps = list(
		COOK_ADD_ITEM(/obj/item/food/doughslice),
		COOK_USE_STOVE(COOK_TEMP_LOW, 10 SECONDS),
	)
