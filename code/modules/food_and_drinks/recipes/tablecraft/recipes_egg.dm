
// see code/module/crafting/table.dm

////////////////////////////////////////////////EGG RECIPE's////////////////////////////////////////////////

/datum/crafting_recipe/food/friedegg
	name = "jajko sadzone"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/egg = 1
	)
	result = /obj/item/food/friedegg
	subcategory = CAT_EGG

/datum/crafting_recipe/food/omelette
	name = "omelette du fromage"
	result = /obj/item/food/omelette
	reqs = list(
		/obj/item/food/egg = 2,
		/obj/item/food/cheese/wedge = 2
	)
	result = /obj/item/food/omelette
	subcategory = CAT_EGG

/datum/crafting_recipe/food/chocolateegg
	name = "czekoladowe jajko"
	reqs = list(
		/obj/item/food/boiledegg = 1,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chocolateegg
	subcategory = CAT_EGG

/datum/crafting_recipe/food/eggsbenedict
	name = "jajka po benedyktyńsku"
	reqs = list(
		/obj/item/food/friedegg = 1,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/breadslice/plain = 1,
	)
	result = /obj/item/food/benedict
	subcategory = CAT_EGG

/datum/crafting_recipe/food/eggbowl
	name = "miska ryżu z jajkiem"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1
	)
	result = /obj/item/food/salad/eggbowl
	subcategory = CAT_EGG

/datum/crafting_recipe/food/wrap
	name = "wrap z jajkiem"
	reqs = list(/datum/reagent/consumable/soysauce = 10,
		/obj/item/food/friedegg = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/eggwrap
	category = CAT_EGG

/datum/crafting_recipe/food/chawanmushi
	name = "chawanmushi"
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/boiledegg = 2,
		/obj/item/food/grown/mushroom/chanterelle = 1
	)
	result = /obj/item/food/chawanmushi
	category = CAT_EGG
