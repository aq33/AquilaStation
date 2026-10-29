// see code/module/crafting/table.dm

////////////////////////////////////////////////KEBABS////////////////////////////////////////////////

/datum/crafting_recipe/food/humankebab
	name = "ludzki kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/meat/steak/plain/human = 2
	)
	result = /obj/item/food/kebab/human
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/kebab
	name = "kebab mięsny"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/meat/steak = 2
	)
	result = /obj/item/food/kebab/monkey
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/tofukebab
	name = "kebab z tofu"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/tofu = 2
	)
	result = /obj/item/food/kebab/tofu
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/tailkebab
	name = "kebab z ogona jaszczura"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/organ/tail/lizard = 1
	)
	result = /obj/item/food/kebab/tail
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fiestaskewer
	name = "szaszłyk fiesta"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/kebab/fiesta
	subcategory = CAT_MEAT

////////////////////////////////////////////////MR SPIDER////////////////////////////////////////////////

/datum/crafting_recipe/food/spidereggsham
	name = "zielone jajka i szynka"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/spidereggs = 1,
		/obj/item/food/meat/cutlet/spider = 2
	)
	result = /obj/item/food/spidereggsham
	subcategory = CAT_MEAT

////////////////////////////////////////////////MISC RECIPE's////////////////////////////////////////////////

/datum/crafting_recipe/food/cornedbeef
	name = "peklowana wołowina z kapustą"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/grown/cabbage = 2
	)
	result = /obj/item/food/cornedbeef
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/bearsteak
	name = "filet migrrrnon"
	reqs = list(
		/datum/reagent/consumable/ethanol/manly_dorf = 5,
		/obj/item/food/meat/steak/bear = 1,
	)
	tools = list(/obj/item/lighter)
	result = /obj/item/food/bearsteak
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/stewedsoymeat
	name = "duszone mięso sojowe"
	reqs = list(
		/obj/item/food/soydope = 2,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/stewedsoymeat
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/sausage
	name = "surowa kiełbasa"
	reqs = list(
		/obj/item/food/raw_meatball = 1,
		/obj/item/food/meat/rawcutlet = 2
	)
	result = /obj/item/food/raw_sausage
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/nugget
	name = "nugget z kurczaka"
	reqs = list(
		/obj/item/food/meat/cutlet = 1
	)
	result = /obj/item/food/nugget
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/rawkhinkali
	name = "surowe chinkali"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/meatball = 1
	)
	result =  /obj/item/food/rawkhinkali
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/meatbun
	name = "bułka z mięsem"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/cabbage = 1
	)
	result = /obj/item/food/meatbun
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/pigblanket
	name = "parówka w cieście"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 1,
		/obj/item/food/meat/cutlet = 1
	)
	result = /obj/item/food/pigblanket
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/meatbun
	name = "bułka z mięsem"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/cabbage = 1
	)
	result = /obj/item/food/meatbun
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/ratkebab
	name = "szczurzy kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/deadmouse = 1
	)
	result = /obj/item/food/kebab/rat
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/doubleratkebab
	name = "podwójny szczurzy kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/deadmouse = 2
	)
	result = /obj/item/food/kebab/rat/double
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/ricepork
	name = "ryż z wieprzowiną"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/meat/cutlet = 2
	)
	result = /obj/item/food/salad/ricepork
	subcategory = CAT_MEAT


/datum/crafting_recipe/food/ashsteak
	name = "stek w popiele"
	reqs = list(
		/obj/item/food/meat/steak/goliath = 1,
		/obj/item/food/grown/ash_flora/cactus_fruit = 1,
		/obj/item/food/grown/ash_flora/mushroom_leaf = 1
	)
	result = /obj/item/food/meat/steak/ashflake
	subcategory = CAT_MEAT


/datum/crafting_recipe/food/ribs
	name = "żeberka BBQ"
	reqs = list(
		/datum/reagent/consumable/bbqsauce = 5,
		/obj/item/food/meat/steak/plain = 2,
		/obj/item/stack/rods = 2
	)
	result = /obj/item/food/bbqribs
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/meatclown
	name = "mięsny klaun"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/food/grown/banana = 1
	)
	result = /obj/item/food/meatclown
	subcategory = CAT_MEAT
