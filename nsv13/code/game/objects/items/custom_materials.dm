//Metals

GLOBAL_LIST_INIT(duranium_recipes, list ( \
	new/datum/stack_recipe("szyna działa szynowego",/obj/item/ship_weapon/parts/railgun_rail, 1, time = 20, one_per_turf = FALSE, on_floor = TRUE), \
	new/datum/stack_recipe("lufa MAC", /obj/item/ship_weapon/parts/mac_barrel, 1, time = 20, one_per_turf = FALSE, on_floor = TRUE), \
	))

/obj/item/stack/sheet/duranium
	name = "duranium"
	singular_name = "arkusz duranium"
	desc = "Ten arkusz to wyjątkowo wytrzymały stop durastali i plastali."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-duranium"
	item_state = "sheet-duranium"
	sheettype = "duranium"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT*0.175, /datum/material/plasma = MINERAL_MATERIAL_AMOUNT*0.05, /datum/material/silver = MINERAL_MATERIAL_AMOUNT*0.15, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT*0.625)
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/duranium
	turf_type = /turf/closed/wall/r_wall/ship

/obj/item/stack/sheet/duranium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.duranium_recipes
	return ..()

/obj/item/stack/sheet/duranium/twenty
	amount = 20

/obj/item/stack/sheet/duranium/fifty
	amount = 50

GLOBAL_LIST_INIT(durasteel_recipes, list ( \
	new/datum/stack_recipe("poszycie z nanowłókna", /obj/item/stack/tile/carpet/ship, 1, 4, 20), \
	new/datum/stack_recipe("durastalowe poszycie kadłuba", /obj/item/stack/tile/durasteel, 1, 4, 20), \
	new/datum/stack_recipe("durastalowe poszycie kadłuba - alt.", /obj/item/stack/tile/durasteel/alt, 1, 4, 20), \
	new/datum/stack_recipe("nitowane poszycie kadłuba", /obj/item/stack/tile/durasteel/riveted, 1, 4, 20), \
	new/datum/stack_recipe("wyściełane stalowe poszycie kadłuba", /obj/item/stack/tile/durasteel/padded, 1, 4, 20), \
	new/datum/stack_recipe("tłoczone poszycie kadłuba", /obj/item/stack/tile/durasteel/eris_techfloor, 1, 4, 20), \
	new/datum/stack_recipe("tłoczone poszycie kadłuba - alt.", /obj/item/stack/tile/durasteel/eris_techfloor_alt, 1, 4, 20), \
	new/datum/stack_recipe("podłoga techniczna", /obj/item/stack/tile/durasteel/techfloor, 1, 4, 20), \
	new/datum/stack_recipe("poszycie techniczne", /obj/item/stack/tile/durasteel/techfloor_grid, 1, 4, 20), \
	new/datum/stack_recipe("stalowa monopłytka", /obj/item/stack/tile/durasteel/mono_steel, 1, 4, 20), \
	new/datum/stack_recipe("ciemna monopłytka", /obj/item/stack/tile/durasteel/mono_dark, 1, 4, 20), \
	new/datum/stack_recipe("jasna monopłytka", /obj/item/stack/tile/durasteel/mono_light, 1, 4, 20), \
	new/datum/stack_recipe("monopodłoga", /obj/item/stack/tile/durasteel/monofloor, 1, 4, 20) \
	))

/obj/item/stack/sheet/durasteel
	name = "durastal"
	singular_name = "arkusz durastali"
	desc = "Ten arkusz to wytrzymały stop żelaza i srebra."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-durasteel"
	item_state = "sheet-durasteel"
	sheettype = "durasteel"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT*0.2, /datum/material/silver = MINERAL_MATERIAL_AMOUNT*0.15, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT*0.65)
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/durasteel
	turf_type = /turf/closed/wall/ship

/obj/item/stack/sheet/durasteel/twenty
	amount = 20

/obj/item/stack/sheet/durasteel/fifty
	amount = 50

/obj/item/stack/sheet/durasteel/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.durasteel_recipes
	return ..()

GLOBAL_LIST_INIT(nanocarbon_glass_recipes, list (\
	new/datum/stack_recipe("pełne okno zbrojone nanowęglem", /obj/structure/window/reinforced/fulltile/ship/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
	))

/obj/item/stack/sheet/nanocarbon_glass
	name = "szkło nanowęglowe"
	singular_name = "arkusz szkła nanowęglowego"
	desc = "Ten arkusz szkła jest wzmocniony splotem nanowęglowym."
	icon = 'nsv13/icons/obj/custom_stack_objects.dmi'
	icon_state = "sheet-nanocarbon-glass"
	item_state = "sheet-nanocarbon-glass"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	throwforce = 10
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/nanocarbon_glass

/obj/item/stack/sheet/nanocarbon_glass/twenty
	amount = 20

/obj/item/stack/sheet/nanocarbon_glass/fifty
	amount = 50

/obj/item/stack/sheet/nanocarbon_glass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.nanocarbon_glass_recipes
	return ..()
