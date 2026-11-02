
// see code/module/crafting/table.dm

////////////////////////////////////////////////SPAGHETTI////////////////////////////////////////////////

/datum/crafting_recipe/food/tomatopasta
	name = "spaghetti z pomidorami"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/grown/tomato = 2
	)
	result = /obj/item/food/spaghetti/pastatomato
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/copypasta
	name = "kopiopasta"
	reqs = list(
		/obj/item/food/spaghetti/pastatomato = 2
	)
	result = /obj/item/food/spaghetti/copypasta
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettimeatball
	name = "spaghetti z klopsikami"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meatball = 2
	)
	result = /obj/item/food/spaghetti/meatballspaghetti
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/spesslaw
	name = "kosmoprawnik"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meatball = 4
	)
	result = /obj/item/food/spaghetti/spesslaw
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/beefnoodle
	name = "makaron z wołowiną"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/cabbage = 1
	)
	result = /obj/item/food/spaghetti/beefnoodle
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/chowmein
	name = "chow mein"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/cabbage = 2,
		/obj/item/food/grown/carrot = 1
	)
	result = /obj/item/food/spaghetti/chowmein
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/butternoodles
	name = "makaron z masłem"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/butter = 1
	)
	result = /obj/item/food/spaghetti/butternoodles
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/kasespatzle
	name = "käsespätzle"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/datum/reagent/consumable/eggyolk = 10,
		/obj/item/food/cheese/wedge = 1
	)
	result = /obj/item/food/spaghetti/kasespatzle
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettinapolitan
	name = "spaghetti napolitan"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/datum/reagent/consumable/ketchup = 10,
		/obj/item/food/sausage = 1,
		/obj/item/food/grown/chili = 1
	)
	result = /obj/item/food/spaghetti/spaghettinapolitan
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/lasagna
	name = "lasagne"
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/spaghetti/raw = 1
	)
	result = /obj/item/food/spaghetti/lasagna
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/glassnoodles
	name = "makaron szklany"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/tofu = 1,
		/obj/item/stack/sheet/glass = 1
	)
	result = /obj/item/food/spaghetti/glassnoodles
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/carbonara
	name = "spaghetti carbonara"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/egg = 1,
		/datum/reagent/consumable/blackpepper = 2
	)
	result = /obj/item/food/spaghetti/carbonara
	category = CAT_SPAGHETTI
