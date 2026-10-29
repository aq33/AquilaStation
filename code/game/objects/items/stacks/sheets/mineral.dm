/*
Mineral Sheets
	Contains:
		- Sandstone
		- Sandbags
		- Diamond
		- Snow
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Copper
		- Clown
		- Titanium
		- Plastitanium
	Others:
		- Adamantine
		- Mythril
		- Alien Alloy
		- Coal
*/

/obj/item/stack/sheet/mineral/Initialize(mapload)
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)
	. = ..()

/*
 * Sandstone
 */

GLOBAL_LIST_INIT(sandstone_recipes, list ( \
	new/datum/stack_recipe("kupka ziemi", /obj/item/plant_tray/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("drzwi z piaskowca", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg asystenta", /obj/structure/statue/sandstone/assistant, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("rozkrusz na piasek", /obj/item/stack/ore/glass, 1, one_per_turf = 0, on_floor = 1) \
	))

/obj/item/stack/sheet/mineral/sandstone
	name = "cegły z piaskowca"
	desc = "Wygląda to na połączenie piasku i kamienia."
	singular_name = "cegła z piaskowca"
	icon_state = "sheet-sandstone"
	item_state = "sheet-sandstone"
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	sheettype = "sandstone"
	merge_type = /obj/item/stack/sheet/mineral/sandstone

/obj/item/stack/sheet/mineral/sandstone/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sandstone_recipes
	. = ..()

/obj/item/stack/sheet/mineral/sandstone/thirty
	amount = 30

/*
 * Sandbags
 */

/obj/item/stack/sheet/mineral/sandbags
	name = "worki z piaskiem"
	icon_state = "sandbags"
	singular_name = "worek z piaskiem"
	layer = LOW_ITEM_LAYER
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/mineral/sandbags

GLOBAL_LIST_INIT(sandbag_recipes, list ( \
	new/datum/stack_recipe("worki z piaskiem", /obj/structure/barricade/sandbags, 1, time = 25, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/sandbags/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sandbag_recipes
	. = ..()

/obj/item/emptysandbag
	name = "pusty worek na piasek"
	desc = "Worek do napełnienia piaskiem."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "sandbag"
	w_class = WEIGHT_CLASS_TINY

/obj/item/emptysandbag/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/G = W
		to_chat(user, "<span class='notice'>Napełniasz worek z piaskiem.</span>")
		var/obj/item/stack/sheet/mineral/sandbags/I = new /obj/item/stack/sheet/mineral/sandbags(drop_location())
		qdel(src)
		if (Adjacent(user) && !issilicon(user))
			user.put_in_hands(I)
		G.use(1)
	else
		return ..()

/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diament"
	icon_state = "sheet-diamond"
	item_state = "sheet-diamond"
	singular_name = "diament"
	sheettype = "diamond"
	materials = list(/datum/material/diamond=MINERAL_MATERIAL_AMOUNT)
	novariants = TRUE
	grind_results = list(/datum/reagent/carbon = 20)
	point_value = 25
	merge_type = /obj/item/stack/sheet/mineral/diamond

GLOBAL_LIST_INIT(diamond_recipes, list ( \
	new/datum/stack_recipe("diamentowe drzwi", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("diamentowa płytka", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),  \
	new/datum/stack_recipe("posąg Kapitana", /obj/structure/statue/diamond/captain, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg hologramu SI", /obj/structure/statue/diamond/ai1, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg rdzenia SI", /obj/structure/statue/diamond/ai2, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/diamond/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.diamond_recipes
	. = ..()

/obj/item/stack/sheet/mineral/diamond/fifty
	amount = 50

/obj/item/stack/sheet/mineral/diamond/twenty
	amount = 20

/obj/item/stack/sheet/mineral/diamond/five
	amount = 5

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uran"
	icon_state = "sheet-uranium"
	item_state = "sheet-uranium"
	singular_name = "arkusz uranu"
	sheettype = "uranium"
	materials = list(/datum/material/uranium=MINERAL_MATERIAL_AMOUNT)
	novariants = TRUE
	grind_results = list(/datum/reagent/uranium = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/uranium

GLOBAL_LIST_INIT(uranium_recipes, list ( \
	new/datum/stack_recipe("uranowe drzwi", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("uranowa płytka", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	new/datum/stack_recipe("posąg bomby atomowej", /obj/structure/statue/uranium/nuke, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg inżyniera", /obj/structure/statue/uranium/eng, 5, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("kierunkowe okno ze zubożonego uranu", /obj/structure/window/depleteduranium/unanchored, 1, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("pełne okno ze zubożonego uranu", /obj/structure/window/depleteduranium/fulltile/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
	))

/obj/item/stack/sheet/mineral/uranium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.uranium_recipes
	. = ..()

/obj/item/stack/sheet/mineral/uranium/fifty
	amount = 50

/obj/item/stack/sheet/mineral/uranium/twenty
	amount = 20

/obj/item/stack/sheet/mineral/uranium/five
	amount = 5

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "stała plazma"
	icon_state = "sheet-plasma"
	item_state = "sheet-plasma"
	singular_name = "arkusz plazmy"
	sheettype = "plasma"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	materials = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/toxin/plasma = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/plasma

/obj/item/stack/sheet/mineral/plasma/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna lizać [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return TOXLOSS//dont you kids know that stuff is toxic?

GLOBAL_LIST_INIT(plasma_recipes, list ( \
	new/datum/stack_recipe("plazmowe drzwi", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plazmowa płytka", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	new/datum/stack_recipe("posąg naukowca", /obj/structure/statue/plasma/scientist, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/plasma/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plasma_recipes
	. = ..()

/obj/item/stack/sheet/mineral/plasma/attackby(obj/item/W as obj, mob/user as mob, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("[ADMIN_LOOKUPFLW(user)] podpala arkusze plazmy w [ADMIN_VERBOSEJMP(T)]")
		log_game("Plasma sheets ignited by [key_name(user)] in [AREACOORD(T)]")
		fire_act(W.is_hot())
	else
		return ..()

/obj/item/stack/sheet/mineral/plasma/fire_act(exposed_temperature, exposed_volume)
	atmos_spawn_air("plasma=[amount*10];TEMP=[exposed_temperature]")
	qdel(src)

/obj/item/stack/sheet/mineral/plasma/fifty
	amount = 50

/obj/item/stack/sheet/mineral/plasma/twenty
	amount = 20

/obj/item/stack/sheet/mineral/plasma/five
	amount = 5

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "złoto"
	icon_state = "sheet-gold"
	item_state = "sheet-gold"
	singular_name = "sztabka złota"
	sheettype = "gold"
	materials = list(/datum/material/gold=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/gold = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/gold

GLOBAL_LIST_INIT(gold_recipes, list ( \
	new/datum/stack_recipe("złote drzwi", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("złota płytka", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("posąg Komendanta", /obj/structure/statue/gold/hos, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg Starszego Oficera", /obj/structure/statue/gold/hop, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg Głównego Inżyniera", /obj/structure/statue/gold/ce, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg Dyrektora Naukowego", /obj/structure/statue/gold/rd, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("prosta korona", /obj/item/clothing/head/crown, 5), \
	new/datum/stack_recipe("posąg Ordynatora", /obj/structure/statue/gold/cmo, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/gold/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.gold_recipes
	. = ..()

/obj/item/stack/sheet/mineral/gold/fifty
	amount = 50

/obj/item/stack/sheet/mineral/gold/twenty
	amount = 20

/obj/item/stack/sheet/mineral/gold/five
	amount = 5

/*
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "srebro"
	icon_state = "sheet-silver"
	item_state = "sheet-silver"
	singular_name = "sztabka srebra"
	sheettype = "silver"
	materials = list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/silver = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/silver
	tableVariant = /obj/structure/table/optable

GLOBAL_LIST_INIT(silver_recipes, list ( \
	new/datum/stack_recipe("srebrne drzwi", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("srebrna płytka", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	new/datum/stack_recipe("posąg lekarza", /obj/structure/statue/silver/md, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg woźnego", /obj/structure/statue/silver/janitor, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg policjanta", /obj/structure/statue/silver/sec, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg cyborga ochrony", /obj/structure/statue/silver/secborg, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("posąg cyborga medycznego", /obj/structure/statue/silver/medborg, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/silver/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.silver_recipes
	. = ..()

/obj/item/stack/sheet/mineral/silver/fifty
	amount = 50

/obj/item/stack/sheet/mineral/silver/twenty
	amount = 20

/obj/item/stack/sheet/mineral/silver/five
	amount = 5

/*
 * Copper
 */
/obj/item/stack/sheet/mineral/copper
	name = "miedź"
	icon_state = "sheet-copper"
	item_state = "sheet-copper"
	singular_name = "sztabka miedzi"
	sheettype = "copper"
	materials = list(/datum/material/copper=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/copper = 20)
	point_value = 3
	merge_type = /obj/item/stack/sheet/mineral/copper

GLOBAL_LIST_INIT(copper_recipes, list ( \
	new/datum/stack_recipe("miedziane drzwi", /obj/structure/mineral_door/copper, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("miedziana płytka", /obj/item/stack/tile/mineral/copper, 1, 4, 20), \
	new/datum/stack_recipe("posąg Kwatermistrza", /obj/structure/statue/copper/dimas, 10, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/copper/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.copper_recipes
	. = ..()

/obj/item/stack/sheet/mineral/copper/fifty
	amount = 50

/obj/item/stack/sheet/mineral/copper/twenty
	amount = 20

/obj/item/stack/sheet/mineral/copper/five
	amount = 5

/*
 * Clown
 */
/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-bananium"
	item_state = "sheet-bananium"
	singular_name = "arkusz bananium"
	sheettype = "bananium"
	materials = list(/datum/material/bananium=MINERAL_MATERIAL_AMOUNT)
	novariants = TRUE
	grind_results = list(/datum/reagent/consumable/banana = 20)
	point_value = 50
	merge_type = /obj/item/stack/sheet/mineral/bananium

GLOBAL_LIST_INIT(bananium_recipes, list ( \
	new/datum/stack_recipe("płytka z bananium", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	new/datum/stack_recipe("posąg klauna", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	))

/obj/item/stack/sheet/mineral/bananium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.bananium_recipes
	. = ..()

/obj/item/stack/sheet/mineral/bananium/five
	amount = 5

/*
 * Titanium
 */
/obj/item/stack/sheet/mineral/titanium
	name = "tytan"
	icon_state = "sheet-titanium"
	item_state = "sheet-titanium"
	singular_name = "arkusz tytanu"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	sheettype = "titanium"
	materials = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/titanium

GLOBAL_LIST_INIT(titanium_recipes, list ( \
	new/datum/stack_recipe("tytanowa płytka", /obj/item/stack/tile/mineral/titanium, 1, 4, 20), \
	))

/obj/item/stack/sheet/mineral/titanium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.titanium_recipes
	. = ..()

/obj/item/stack/sheet/mineral/titanium/fifty
	amount = 50

/obj/item/stack/sheet/mineral/titanium/twenty
	amount = 20

/obj/item/stack/sheet/mineral/titanium/five
	amount = 5


/*
 * Plastitanium
 */
/obj/item/stack/sheet/mineral/plastitanium
	name = "plastytan"
	icon_state = "sheet-plastitanium"
	item_state = "sheet-plastitanium"
	singular_name = "arkusz plastytanu"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	sheettype = "plastitanium"
	materials = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT, /datum/material/plasma=MINERAL_MATERIAL_AMOUNT)
	point_value = 45
	merge_type = /obj/item/stack/sheet/mineral/plastitanium

GLOBAL_LIST_INIT(plastitanium_recipes, list ( \
	new/datum/stack_recipe("plastytanowa płytka", /obj/item/stack/tile/mineral/plastitanium, 1, 4, 20), \
	))

/obj/item/stack/sheet/mineral/plastitanium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plastitanium_recipes
	. = ..()


/*
 * Snow
 */
/obj/item/stack/sheet/mineral/snow
	name = "śnieg"
	icon_state = "sheet-snow"
	item_state = "sheet-snow"
	singular_name = "blok śniegu"
	force = 1
	throwforce = 2
	grind_results = list(/datum/reagent/consumable/ice = 20)
	merge_type = /obj/item/stack/sheet/mineral/snow

GLOBAL_LIST_INIT(snow_recipes, list ( \
	new/datum/stack_recipe("śnieżna ściana", /turf/closed/wall/mineral/snow, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("bałwan", /obj/structure/statue/snow/snowman, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("śnieżka", /obj/item/toy/snowball, 1), \
	new/datum/stack_recipe("śnieżna płytka", /obj/item/stack/tile/mineral/snow, 1, 4, 20), \
	))

/obj/item/stack/sheet/mineral/snow/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.snow_recipes
	. = ..()

/****************************** Others ****************************/

/*
 * Adamantine
 */
GLOBAL_LIST_INIT(adamantine_recipes, list(
	new /datum/stack_recipe("niedokończona skorupa golema-sługi", /obj/item/golem_shell/servant, req_amount=25, res_amount=1),
	))

/obj/item/stack/sheet/mineral/adamantine
	name = "adamantyt"
	icon_state = "sheet-adamantine"
	item_state = "sheet-adamantine"
	singular_name = "arkusz adamantytu"
	merge_type = /obj/item/stack/sheet/mineral/adamantine
	grind_results = list(/datum/reagent/liquidadamantine = 10)

/obj/item/stack/sheet/mineral/adamantine/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.adamantine_recipes
	. = ..()

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mithril"
	icon_state = "sheet-mythril"
	item_state = "sheet-mythril"
	singular_name = "arkusz mithrilu"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/mineral/mythril

/*
 * Alien Alloy
 */
/obj/item/stack/sheet/mineral/abductor
	name = "stop obcych"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	item_state = "sheet-abductor"
	singular_name = "arkusz stopu obcych"
	sheettype = "abductor"
	merge_type = /obj/item/stack/sheet/mineral/abductor

GLOBAL_LIST_INIT(abductor_recipes, list ( \
	new/datum/stack_recipe("łóżko obcych", /obj/structure/bed/abductor, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("obca szafka", /obj/structure/closet/abductor, 2, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("rama obcego stołu", /obj/structure/table_frame/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("zespół obcej śluzy", /obj/structure/door_assembly/door_assembly_abductor, 4, time = 20, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("płytka podłogowa obcych", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
	))

/obj/item/stack/sheet/mineral/abductor/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.abductor_recipes
	. = ..()

/*
 * Coal
 */

/obj/item/stack/sheet/mineral/coal
	name = "węgiel"
	desc = "Ktoś trafił na listę niegrzecznych dzieci."
	icon = 'icons/obj/mining.dmi'
	icon_state = "slag"
	singular_name = "bryłka węgla"
	merge_type = /obj/item/stack/sheet/mineral/coal
	grind_results = list(/datum/reagent/carbon = 20)

/obj/item/stack/sheet/mineral/coal/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("[ADMIN_LOOKUPFLW(user)] podpala węgiel w [ADMIN_VERBOSEJMP(T)]")
		log_game("Coal ignited by [key_name(user)] in [AREACOORD(T)]")
		fire_act(W.is_hot())
		return TRUE
	else
		return ..()

/obj/item/stack/sheet/mineral/coal/fire_act(exposed_temperature, exposed_volume)
	atmos_spawn_air("co2=[amount*10];TEMP=[exposed_temperature]")
	qdel(src)

/obj/item/stack/sheet/mineral/coal/five
	amount = 5

/obj/item/stack/sheet/mineral/coal/ten
	amount = 10

/*
 * Wax
 */
/obj/item/stack/sheet/mineral/wax
	name = "wosk"
	icon_state = "sheet-wax"
	item_state = "sheet-wax"
	singular_name = "blok wosku"
	force = 1
	throwforce = 2
	grind_results = list(/datum/reagent/consumable/honey = 20)
	merge_type = /obj/item/stack/sheet/mineral/wax

GLOBAL_LIST_INIT(wax_recipes, list (new/datum/stack_recipe("woskowa płytka", /obj/item/stack/tile/mineral/wax, 1, 4, 20)))

/obj/item/stack/sheet/mineral/wax/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.wax_recipes
	. = ..()
