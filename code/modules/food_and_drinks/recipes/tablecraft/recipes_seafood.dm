
//SEAFOOD

/datum/crafting_recipe/food/cubancarp
	name = "kubański karp"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/cubancarp
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/fishandchips
	name = "ryba z frytkami"
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/fishandchips
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/fishfingers
	name = "paluszki rybne"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/fishfingers
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/sashimi
	name = "sashimi z karpia"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/spidereggs = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/sashimi
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/vegetarian_sushi_roll
	name = "wegetariańska rolka sushi"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/cabbage = 1
	)
	result = /obj/item/food/sushi_roll/vegetarian
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/spicy_filet_sushi_roll
	name = "pikantna rolka sushi z filetem"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/onion = 1
	)
	result = /obj/item/food/sushi_roll/spicyfilet
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/futomaki_sushi_roll
	name = "rolka sushi futomaki"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/sushi_roll/futomaki
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/philadelphia_sushi_roll
	name = "rolka sushi Philadelphia"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/fishmeat/carp = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/sushi_roll/philadelphia
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/nigiri_sushi
	name = "sushi nigiri"
	reqs = list(
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/fishmeat/carp = 1,
		/datum/reagent/consumable/soysauce = 2
	)
	result = /obj/item/food/nigiri_sushi
	subcategory = CAT_SEAFOOD
