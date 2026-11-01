
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIES////////////////////////////////////////////////

/datum/crafting_recipe/food/bananacreampie
	name = "tort z kremem bananowym"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pie/plain = 1,
		 /obj/item/food/grown/banana = 1
	)
	result = /obj/item/food/pie/cream
	subcategory = CAT_PIE

/datum/crafting_recipe/food/meatpie
	name = "placek z mięsem"
	reqs = list(
		/datum/reagent/consumable/blackpepper = 1,
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/meat/steak/plain = 1
	)
	result = /obj/item/food/pie/meatpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/tofupie
	name = "placek z tofu"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/tofu = 1
	)
	result = /obj/item/food/pie/tofupie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/xenopie
	name = "ksenoplacek"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/meat/cutlet/xeno = 1
	)
	result = /obj/item/food/pie/xemeatpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/cherrypie
	name = "placek wiśniowy"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/cherries = 1
	)
	result = /obj/item/food/pie/cherrypie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/berryclafoutis
	name = "clafoutis jagodowe"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/pie/berryclafoutis
	subcategory = CAT_PIE

/datum/crafting_recipe/food/bearypie
	name = "placek z niedźwiedziem"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/food/meat/steak/bear = 1
	)
	result = /obj/item/food/pie/bearypie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/amanitapie
	name = "placek z muchomorem"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/mushroom/amanita = 1
	)
	result = /obj/item/food/pie/amanita_pie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/plumppie
	name = "placek z pulchnym hełmem"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/food/pie/plump_pie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/applepie
	name = "szarlotka"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/apple = 1
	)
	result = /obj/item/food/pie/applepie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/pumpkinpie
	name = "placek dyniowy"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/pumpkin = 1
	)
	result = /obj/item/food/pie/pumpkinpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/goldenappletart
	name = "tarta kruszonkowa ze złotym jabłkiem"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/apple/gold = 1
	)
	result = /obj/item/food/pie/appletart
	subcategory = CAT_PIE

/datum/crafting_recipe/food/grapetart
	name = "tarta winogronowa"
	reqs = list(
            /datum/reagent/consumable/milk = 5,
            /datum/reagent/consumable/sugar = 5,
            /obj/item/food/pie/plain = 1,
	        /obj/item/food/grown/grapes = 3
	        )
	result = /obj/item/food/pie/grapetart
	subcategory = CAT_PIE

/datum/crafting_recipe/food/mimetart
	name = "tarta mima"
	always_available = FALSE
	reqs = list(
            /datum/reagent/consumable/milk = 5,
            /datum/reagent/consumable/sugar = 5,
            /obj/item/food/pie/plain = 1,
	        /datum/reagent/consumable/nothing = 5
	        )
	result = /obj/item/food/pie/mimetart
	subcategory = CAT_PIE

/datum/crafting_recipe/food/berrytart
	name = "tarta jagodowa"
	always_available = FALSE
	reqs = list(
            /datum/reagent/consumable/milk = 5,
            /datum/reagent/consumable/sugar = 5,
            /obj/item/food/pie/plain = 1,
	        /obj/item/food/grown/berries = 3
	        )
	result = /obj/item/food/pie/berrytart
	subcategory = CAT_PIE

/datum/crafting_recipe/food/cocoalavatart
	name = "czekoladowa tarta lawowa"
	always_available = FALSE
	reqs = list(
            /datum/reagent/consumable/milk = 5,
            /datum/reagent/consumable/sugar = 5,
            /obj/item/food/pie/plain = 1,
	        /obj/item/food/chocolatebar = 3,
	        /obj/item/slime_extract = 1 //The reason you dont know how to make it!
	        )
	result = /obj/item/food/pie/cocoalavatart
	subcategory = CAT_PIE

/datum/crafting_recipe/food/blumpkinpie
	name = "placek z niebieskiej dyni"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/blumpkin = 1
	)
	result = /obj/item/food/pie/blumpkinpie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/dulcedebatata
	name = "dulce de batata"
	reqs = list(
		/datum/reagent/consumable/vanilla = 5,
		/datum/reagent/water = 5,
		/obj/item/food/grown/potato/sweet = 2
	)
	result = /obj/item/food/pie/dulcedebatata
	subcategory = CAT_PIE

/datum/crafting_recipe/food/frostypie
	name = "mroźny placek"
	reqs = list(
		/obj/item/food/pie/plain = 1,
		/obj/item/food/grown/bluecherries = 1
	)
	result = /obj/item/food/pie/frostypie
	subcategory = CAT_PIE

/datum/crafting_recipe/food/baklava
	name = "baklawa"
	reqs = list(
		/obj/item/food/butter = 2,
		/obj/item/food/tortilla = 4,	//Layers
		/obj/item/plant_seeds/preset/oats = 4
	)
	result = /obj/item/food/pie/baklava
	subcategory = CAT_PIE
