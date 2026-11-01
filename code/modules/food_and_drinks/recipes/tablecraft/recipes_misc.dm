
// see code/module/crafting/table.dm

// MISC

/datum/crafting_recipe/food/candiedapple
	name = "jabłko w karmelu"
	reqs = list(
		/datum/reagent/consumable/caramel = 5,
		/obj/item/food/grown/apple = 1
	)
	result = /obj/item/food/candiedapple
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/spiderlollipop
	name = "pajęczy lizak"
	reqs = list(/obj/item/stack/rods = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 5,
		/obj/item/food/spiderling = 1
	)
	result = /obj/item/food/spiderlollipop
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/chococoin
	name = "czekoladowa moneta"
	reqs = list(
		/obj/item/coin = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/chococoin
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/fudgedice
	name = "kostka do gry z krówki"
	reqs = list(
		/obj/item/dice = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/fudgedice
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/chocoorange
	name = "czekoladowa pomarańcza"
	reqs = list(
		/obj/item/food/grown/citrus/orange = 1,
		/obj/item/food/chocolatebar = 1,
	)
	result = /obj/item/food/chocoorange
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/loaded_baked_potato
	name = "faszerowany pieczony ziemniak"
	reqs = list(
		/obj/item/food/grown/potato = 1,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/loaded_baked_potato
	category = CAT_MISCFOOD

/datum/crafting_recipe/food/cheesyfries
	name = "frytki z serem"
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/cheese/wedge = 1
	)
	result = /obj/item/food/cheesyfries
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/beans
	name = "puszka fasoli"
	time = 40
	reqs = list(/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/grown/soybeans = 2
	)
	result = /obj/item/food/canned/beans
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/eggplantparm
	name ="bakłażan po parmeńsku"
	reqs = list(
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/grown/eggplant = 1
	)
	result = /obj/item/food/eggplantparm
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/melonkeg
	name ="arbuzowa beczka"
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 25,
		/obj/item/food/grown/holymelon = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 1
	)
	parts = list(/obj/item/reagent_containers/food/drinks/bottle/vodka = 1)
	result = /obj/item/food/melonkeg
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/honeybar
	name = "baton miodowo-orzechowy"
	reqs = list(
		/obj/item/food/grown/oat = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/food/honeybar
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/powercrepe
	name = "supernaleśnik"
	time = 40
	reqs = list(
		/obj/item/food/flatdough = 1,
		/datum/reagent/consumable/milk = 1,
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/stock_parts/cell/super =1,
		/obj/item/melee/sabre = 1
	)
	result = /obj/item/food/powercrepe
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/branrequests
	name = "płatki Otrębowe Życzenia"
	reqs = list(
		/obj/item/food/grown/wheat = 1,
		/obj/item/food/no_raisin = 1,
	)
	result = /obj/item/food/branrequests
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/ricepudding
	name = "ryż na mleku"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/boiledrice = 1
	)
	result = /obj/item/food/salad/ricepudding
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/butterbear //ITS ALIVEEEEEE!
	name = "Terrygold"
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/heart = 1,
		/obj/item/food/butter = 10,
		/obj/item/food/meat/slab = 5,
		/datum/reagent/blood = 50,
		/datum/reagent/teslium = 1 //To shock the whole thing into life
	)
	result = /mob/living/simple_animal/hostile/bear/butter
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/crab_rangoon
	name = "krab rangoon"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/datum/reagent/consumable/cream = 5,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/meat/rawcrab = 1
	)
	result = /obj/item/food/crab_rangoon
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/ant_candy
	name = "cukierek z mrówkami"
	reqs = list(/obj/item/stack/rods = 1,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/water = 5,
		/datum/reagent/ants = 10
	)
	result = /obj/item/food/ant_candy
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/pingles
	name = "pingles"
	reqs = list(
		/obj/item/c_tube = 1,
		/obj/item/food/grown/potato/wedges = 1,
		/obj/item/food/onion_slice = 1,
		/datum/reagent/consumable/cream = 10
	)
	result = /obj/item/food/pingles
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/royalcheese
	name = "królewski ser"
	reqs = list(
		/obj/item/food/cheese/wheel/cheddar = 1,
		/obj/item/clothing/head/crown = 1,
		/datum/reagent/medicine/strange_reagent = 5,
		/datum/reagent/toxin/mutagen = 5
	)
	result = /obj/item/food/royalcheese
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/onigiri
	name = "onigiri"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/seaweed_sheet = 1,
	)
	result = /obj/item/food/onigiri
	subcategory = CAT_MISCFOOD
