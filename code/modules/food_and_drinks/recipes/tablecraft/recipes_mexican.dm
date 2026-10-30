// see code/module/crafting/table.dm

// MEXICAN

/datum/crafting_recipe/food/burrito
	name ="burrito"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/soybeans = 2
	)
	result = /obj/item/food/burrito
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/cheesyburrito
	name ="serowe burrito"
	reqs = list(
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/cheesyburrito
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/carneburrito
	name ="burrito carne asada"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/carneburrito
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/fuegoburrito
	name ="plazmowe burrito fuego"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/grown/ghost_chili = 2,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/fuegoburrito
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/nachos
	name ="nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/tortilla = 1
	)
	result = /obj/item/food/nachos
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/cheesynachos
	name ="serowe nachos"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/tortilla = 1
	)
	result = /obj/item/food/cheesynachos
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/cubannachos
	name ="kubańskie nachos"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/tortilla = 1
	)
	result = /obj/item/food/cubannachos
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/taco
	name ="klasyczne taco"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/taco
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/tacoplain
	name ="zwykłe taco"
	reqs = list(
		/obj/item/food/tortilla = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/cutlet = 1,
	)
	result = /obj/item/food/taco/plain
	subcategory = CAT_MEXICAN

/datum/crafting_recipe/food/enchiladas
	name = "enchiladas"
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/tortilla = 2
	)
	result = /obj/item/food/enchiladas
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/stuffedlegion
	name = "faszerowany legion"
	time = 40
	reqs = list(
		/obj/item/food/meat/steak/goliath = 1,
		/obj/item/organ/regenerative_core/legion = 1,
		/datum/reagent/consumable/ketchup = 2,
		/datum/reagent/consumable/capsaicin = 2
	)
	result = /obj/item/food/stuffedlegion
	subcategory = CAT_MEXICAN
