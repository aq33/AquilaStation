
// see code/module/crafting/table.dm

////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/crafting_recipe/food/meatbread
	name = "bochenek chleba mięsnego"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/plain = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/meat
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/xenomeatbread
	name = "bochenek chleba z mięsem ksenomorfa"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/xeno = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/xenomeat
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/spidermeatbread
	name = "pieczeń z mięsa pająka"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/spider = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/spidermeat
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/banananutbread
	name = "chlebek bananowo-orzechowy"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/boiledegg = 3,
		/obj/item/food/grown/banana = 1
	)
	result = /obj/item/food/bread/banana
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/tofubread
	name = "chleb z tofu"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/tofu = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/tofu
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/creamcheesebread
	name = "chleb z serkiem śmietankowym"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/cheese/wedge = 2
	)
	result = /obj/item/food/bread/creamcheese
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/mimanabread
	name = "chleb z mimany"
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/tofu = 3,
		/obj/item/food/grown/banana/mime = 1
	)
	result = /obj/item/food/bread/mimana
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/garlicbread
	name = "chleb czosnkowy"
	time = 40
	reqs = list(/obj/item/food/grown/garlic = 1,
				/obj/item/food/breadslice/plain = 1,
				/obj/item/food/butter = 1
	)
	result = /obj/item/food/garlicbread
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/butterbiscuit
	name = "maślane ciastko"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 1
	)
	result = /obj/item/food/butterbiscuit
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/butterdog
	name = "maślany hot dog"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 3,
		)
	result = /obj/item/food/butterdog
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/baguette
	name = "bagietka"
	time = 40
	reqs = list(/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/baguette
	subcategory = CAT_BREAD

////////////////////////////////////////////////TOAST////////////////////////////////////////////////

/datum/crafting_recipe/food/slimetoast
	name = "tost z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 1
	)
	result = /obj/item/food/jelliedtoast/slime
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/jelliedyoast
	name = "tost z dżemem"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 1
	)
	result = /obj/item/food/jelliedtoast/cherry
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/butteredtoast
	name = "tost z masłem"
	reqs = list(
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/butter = 1
	)
	result = /obj/item/food/butteredtoast
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/twobread
	name = "dwa chleby"
	reqs = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/obj/item/food/breadslice/plain = 2
	)
	result = /obj/item/food/twobread
	subcategory = CAT_BREAD

////////////////////////////////////////////////WEIRD////////////////////////////////////////////////

/datum/crafting_recipe/food/breadcat
	name = "kot w chlebie"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/organ/ears/cat = 1,
		/obj/item/organ/tail/cat = 1,
		/obj/item/food/meat/slab = 3,
		/datum/reagent/blood = 50,
		/datum/reagent/medicine/strange_reagent = 5
		)
	result = /mob/living/simple_animal/pet/cat/breadcat
	subcategory = CAT_BREAD
