// AQUILA - arkusze mięsa, port BeeStation/BeeStation-Hornet#10703. Robi je Arkuszomistrz 2000 z surowego mięsa.

/* Meat */
GLOBAL_LIST_INIT(meat_recipes, list (
	//new/datum/stack_recipe("meat recipe example", /obj/structure/bed/meat, 2, one_per_turf = TRUE, on_floor = TRUE),
	))

/obj/item/stack/sheet/meat
	name = "arkusze mięsa"
	desc = "Czyjeś krwiste mięso sprasowane w ładny, twardy arkusz."
	singular_name = "arkusz mięsa"
	icon_state = "sheet-meat"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	mats_per_unit = list(/datum/material/meat = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/meat
	material_type = /datum/material/meat
	material_modifier = 1 //None of that wussy stuff

/obj/item/stack/sheet/meat/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.meat_recipes
	return ..()

/obj/item/stack/sheet/meat/fifty
	amount = 50

/obj/item/stack/sheet/meat/twenty
	amount = 20

/obj/item/stack/sheet/meat/ten
	amount = 10

/obj/item/stack/sheet/meat/five
	amount = 5
