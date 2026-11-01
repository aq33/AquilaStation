/* Diffrent misc types of sheets
 * Contains:
 * Metal
 * Plasteel
 * Wood
 * Cloth
 * Plastic
 * Cardboard
 * Paper Frames
 * Runed Metal (cult)
 * Brass (clockwork cult)
 * Bronze (bake brass)
 * Bamboo
 */

/*
 * Metal
 */
//NSV13 - Cannon ball. Torpedo Casing, PDC frame, railgun tray added to the end of this list. Barbed wire and metal cade added, gauss gunner chair added to the end of this list
GLOBAL_LIST_INIT(metal_recipes, list ( \
	new/datum/stack_recipe("stołek",										/obj/structure/chair/stool, one_per_turf = TRUE, on_floor = TRUE, time = 15), \
	new/datum/stack_recipe("stołek barowy",									/obj/structure/chair/stool/bar, one_per_turf = TRUE, on_floor = TRUE, time = 15), \
	new/datum/stack_recipe("krzesło",										/obj/structure/chair, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
	new/datum/stack_recipe("kula armatnia", /obj/item/ship_weapon/ammunition/naval_artillery/cannonball, 20, one_per_turf = TRUE, on_floor = TRUE, time = 40,), \

	null, \
	new/datum/stack_recipe_list("krzesła biurowe", list( \
		new/datum/stack_recipe("ciemne krzesło biurowe",						/obj/structure/chair/office, 5, one_per_turf = TRUE, on_floor = TRUE, time = 15), \
		new/datum/stack_recipe("jasne krzesło biurowe",					/obj/structure/chair/office/light, 5, one_per_turf = TRUE, on_floor = TRUE, time = 15), \
		)), \
	new/datum/stack_recipe_list("łóżka", list( \
		new/datum/stack_recipe("łóżko pojedyncze",							/obj/structure/bed, 2, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new/datum/stack_recipe("łóżko podwójne",							/obj/structure/bed/double, 2, one_per_turf = TRUE, on_floor = TRUE, time = 40), \
		)), \
	new/datum/stack_recipe_list("fotele", list( \
		new/datum/stack_recipe("fotel",							/obj/structure/chair/fancy/comfy, 2, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new/datum/stack_recipe("fotel korporacyjny",						/obj/structure/chair/fancy/corp, 2, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new/datum/stack_recipe("fotel promu",							/obj/structure/chair/fancy/shuttle, 2, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		)), \
	new/datum/stack_recipe_list("stara sofa", list(
		new /datum/stack_recipe("stara sofa (środek)",					/obj/structure/chair/fancy/sofa/old, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("stara sofa (lewa strona)",						/obj/structure/chair/fancy/sofa/old/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("stara sofa (prawa strona)",						/obj/structure/chair/fancy/sofa/old/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("stara sofa (narożnik wklęsły)",			/obj/structure/chair/fancy/sofa/old/corner/concave, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("stara sofa (narożnik wypukły)",				/obj/structure/chair/fancy/sofa/old/corner/convex, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		)), \
	new /datum/stack_recipe_list("sofy korporacyjne", list( \
		new /datum/stack_recipe("sofa korporacyjna (środek)",				/obj/structure/chair/fancy/sofa/corp, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("sofa korporacyjna (lewa strona)",				/obj/structure/chair/fancy/sofa/corp/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("sofa korporacyjna (prawa strona)",				/obj/structure/chair/fancy/sofa/corp/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("sofa korporacyjna (narożnik wklęsły)",		/obj/structure/chair/fancy/sofa/corp/corner/concave, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("sofa korporacyjna (narożnik wypukły)",		/obj/structure/chair/fancy/sofa/corp/corner/convex, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		)), \
	new /datum/stack_recipe_list("ławki", list( \
		new /datum/stack_recipe("ławka (środek)",						/obj/structure/chair/fancy/bench, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("ławka (lewa strona)",							/obj/structure/chair/fancy/bench/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("ławka (prawa strona)",						/obj/structure/chair/fancy/bench/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		)), \
	new /datum/stack_recipe_list("ławki korporacyjne", list( \
		new /datum/stack_recipe("ławka korporacyjna (środek)",				/obj/structure/chair/fancy/bench/corporate, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("ławka korporacyjna (lewa strona)",				/obj/structure/chair/fancy/bench/corporate/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		new /datum/stack_recipe("ławka korporacyjna (prawa strona)",				/obj/structure/chair/fancy/bench/corporate/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
		)),
	null, \
	new/datum/stack_recipe("części stojaka",								/obj/item/rack_parts), \
	new/datum/stack_recipe("szafa",									/obj/structure/closet, 2, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new/datum/stack_recipe("kanister",									/obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new/datum/stack_recipe("płytka podłogowa",								/obj/item/stack/tile/plasteel, 1, 4, 20), \
	new/datum/stack_recipe("żelazny pręt",									/obj/item/stack/rods, 1, 2, 60), \
	null, \
	new/datum/stack_recipe("dźwigary ścienne",								/obj/structure/girder, 2, time = 40, one_per_turf = TRUE, on_floor = TRUE), \
	//NSV13 Start
	null, \
	new/datum/stack_recipe("drut kolczasty", /obj/item/stack/barbed_wire, 2, 1, 20, time = 1 SECONDS), \
	new/datum/stack_recipe("metalowa barykada", /obj/structure/peacekeeper_barricade/metal, 4, time = 8 SECONDS, one_per_turf = 1, on_floor = TRUE), \
	//NSV13 End
	null, \
	new/datum/stack_recipe("rama komputera",							/obj/structure/frame/computer, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("konsola modułowa",							/obj/machinery/modular_computer/console/buildable/, 10, time = 25, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("rama maszyny",								/obj/structure/frame/machine, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new /datum/stack_recipe_list("zespoły śluz", list( \
		new /datum/stack_recipe("zespół śluzy standardowej",			/obj/structure/door_assembly, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy publicznej",				/obj/structure/door_assembly/door_assembly_public, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy dowództwa",				/obj/structure/door_assembly/door_assembly_com, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy ochrony",			/obj/structure/door_assembly/door_assembly_sec, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy inżynierii",			/obj/structure/door_assembly/door_assembly_eng, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy górniczej",				/obj/structure/door_assembly/door_assembly_min, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy atmosferycznej",		/obj/structure/door_assembly/door_assembly_atmo, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy badawczej",			/obj/structure/door_assembly/door_assembly_research, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy chłodni",				/obj/structure/door_assembly/door_assembly_fre, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy naukowej",				/obj/structure/door_assembly/door_assembly_science, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy medycznej",				/obj/structure/door_assembly/door_assembly_med, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy wirusologii",			/obj/structure/door_assembly/door_assembly_viro, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy technicznej",			/obj/structure/door_assembly/door_assembly_mai, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół śluzy zewnętrznej",			/obj/structure/door_assembly/door_assembly_ext, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół zewnętrznej śluzy technicznej",/obj/structure/door_assembly/door_assembly_extmai, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół hermetycznego włazu",				/obj/structure/door_assembly/door_assembly_hatch, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new /datum/stack_recipe("zespół włazu technicznego",			/obj/structure/door_assembly/door_assembly_mhatch, 4, time = 50, one_per_turf = 1, on_floor = 1), \
	)), \
	null, \
	new/datum/stack_recipe("rama grodzi przeciwpożarowej",							/obj/structure/firelock_frame, 3, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("kierunkowa rama grodzi przeciwpożarowej",				/obj/structure/firelock_frame/border, 3, time = 50, one_per_turf = FALSE, on_floor = TRUE), \
	new/datum/stack_recipe("rama wieżyczki",								/obj/machinery/porta_turret_construct, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("rama haka rzeźnickiego",							/obj/structure/kitchenspike_frame, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("podstawa reflektora",							/obj/structure/reflector, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new/datum/stack_recipe("tłuczek",									/obj/item/pestle, 1, time = 50), \
	new/datum/stack_recipe("obudowa granatu",							/obj/item/grenade/chem_grenade), \
	new/datum/stack_recipe("rama oprawy oświetleniowej",						/obj/item/wallframe/light_fixture, 2), \
	new/datum/stack_recipe("rama małej oprawy oświetleniowej",					/obj/item/wallframe/light_fixture/small, 1), \
	null, \
	new/datum/stack_recipe("rama APC",									/obj/item/wallframe/apc, 2), \
	new/datum/stack_recipe("rama alarmu powietrza",							/obj/item/wallframe/airalarm, 2), \
	new/datum/stack_recipe("rama kontrolera śluzy",					/obj/item/wallframe/advanced_airlock_controller, 2), \
	new/datum/stack_recipe("rama alarmu pożarowego",							/obj/item/wallframe/firealarm, 2), \
	new/datum/stack_recipe("rama szafki na gaśnicę",				/obj/item/wallframe/extinguisher_cabinet, 2), \
	new/datum/stack_recipe("rama przycisku",								/obj/item/wallframe/button, 1), \
	new/datum/stack_recipe("rama terminalu więźnia", 					/obj/item/wallframe/genpop_interface, 5), \
	null, \
	new/datum/stack_recipe("żelazne drzwi",									/obj/structure/mineral_door/iron, 20, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("rama naświetlacza",							/obj/structure/floodlight_frame, 5, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("rama prysznica",								/obj/structure/showerframe, 2, time = 2 SECONDS), \
	new/datum/stack_recipe("rama umywalki",								/obj/structure/sinkframe, 2, time = 2 SECONDS), \
	//AQ EDIT - hygienebot, see aquila/code/modules/hygiene/
	new/datum/stack_recipe("zespół hygienebota",						/obj/item/bot_assembly/hygienebot, 2, time = 5 SECONDS), \
	//NSV13 start
	null, \
	new/datum/stack_recipe("obudowa torpedy", /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing, 15, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("obudowa rakiety", /obj/item/ship_weapon/ammunition/missile/missile_casing, 5, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("rama mocowania PDC", /obj/item/wallframe/pdc_frame, 5), \
	new/datum/stack_recipe("podajnik działa szynowego",/obj/item/ship_weapon/parts/loading_tray, 10), \
	new/datum/stack_recipe("fotel strzelca działa Gaussa", /obj/structure/chair/fancy/gauss, 10), \
	new/datum/stack_recipe("fotel promu",/obj/item/wallframe/shuttlecraft_chair, 5, one_per_turf = TRUE, on_floor = TRUE), \
	//NSV13 end
))

/obj/item/stack/sheet/iron
	name = "żelazo"
	desc = "Arkusze z żelaza."
	singular_name = "arkusz żelaza"
	icon_state = "sheet-metal"
	item_state = "sheet-metal"
	materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/iron
	grind_results = list(/datum/reagent/iron = 20)
	point_value = 2
	tableVariant = /obj/structure/table

/obj/item/stack/sheet/iron/ratvar_act()
	new /obj/item/stack/tile/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/iron/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/sheet/iron/fifty
	amount = 50

/obj/item/stack/sheet/iron/twenty
	amount = 20

/obj/item/stack/sheet/iron/ten
	amount = 10

/obj/item/stack/sheet/iron/five
	amount = 5

/obj/item/stack/sheet/iron/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500

/obj/item/stack/sheet/iron/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.metal_recipes
	return ..()

/obj/item/stack/sheet/iron/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna walić się [src] po głowie! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return BRUTELOSS

/*
 * NSV13 - Plasteel cade construction
 */

GLOBAL_LIST_INIT(plasteel_recipes, list ( \
	new/datum/stack_recipe("rdzeń SI", /obj/structure/AIcore, 4, time = 50, one_per_turf = TRUE), \
	new/datum/stack_recipe("zespół bomby", /obj/machinery/syndicatebomb/empty, 10, time = 50), \
	new/datum/stack_recipe("płytka dokowa", /obj/item/stack/tile/dock, 1, 4, 20), \
	new/datum/stack_recipe("płytka suchego doku", /obj/item/stack/tile/drydock, 2, 4, 20), \
	//NSV13 Start
	null, \
	new/datum/stack_recipe("barykada z plastali", /obj/structure/peacekeeper_barricade/metal/plasteel, 5, time = 8 SECONDS, one_per_turf = 1, on_floor = TRUE), \
	//NSV13 End
	null, \
	new /datum/stack_recipe_list("zespoły śluz", list( \
		new/datum/stack_recipe("zespół śluzy wysokiego bezpieczeństwa",		/obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 50, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("zespół drzwi skarbca",					/obj/structure/door_assembly/door_assembly_vault, 6, time = 50, one_per_turf = 1, on_floor = 1), \
	)), \
	//NSV13 start
	new /datum/stack_recipe_list("ramy uzbrojenia okrętowego", list( \
		new/datum/stack_recipe("artyleria okrętowa", /obj/structure/ship_weapon/artillery_frame, 20, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("rama wyrzutni torped", /obj/structure/ship_weapon/torpedo_launcher_assembly, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
		new/datum/stack_recipe("rama towarowej wyrzutni torped", /obj/structure/ship_weapon/torpedo_launcher_assembly/cargo, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	)), \
	//NSV13 end
))

/obj/item/stack/sheet/plasteel
	name = "plastal"
	singular_name = "arkusz plastali"
	desc = "Ten arkusz to stop żelaza i plazmy."
	icon_state = "sheet-plasteel"
	item_state = "sheet-plasteel"
	materials = list(/datum/material/iron=2000, /datum/material/plasma=2000)
	throwforce = 10
	flags_1 = CONDUCT_1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80, "stamina" = 0, "bleed" = 0)
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/plasteel
	grind_results = list(/datum/reagent/iron = 20, /datum/reagent/toxin/plasma = 20)
	point_value = 23
	tableVariant = /obj/structure/table/reinforced

/obj/item/stack/sheet/plasteel/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plasteel_recipes
	return ..()


/obj/item/stack/sheet/plasteel/fifty
	amount = 50

/obj/item/stack/sheet/plasteel/twenty
	amount = 20

/obj/item/stack/sheet/plasteel/ten
	amount = 10

/obj/item/stack/sheet/plasteel/five
	amount = 5

/*
 * Wood
 */

GLOBAL_LIST_INIT(wood_recipes, list ( \
	//AQ EDIT START
	new/datum/stack_recipe("krzyż", 								/obj/item/wallframe/kszysz/kszysz_drewniany, 2, time = 10), \
	new/datum/stack_recipe("duży krzyż", 							/obj/structure/kitchenspike/crucifix, 10, time = 40, one_per_turf = TRUE, on_floor = TRUE), \
	//AQ EDIT STOP
	new/datum/stack_recipe("drewniane sandały",						/obj/item/clothing/shoes/sandal, 1), \
	new/datum/stack_recipe("drewniana płytka podłogowa",						/obj/item/stack/tile/wood, 1, 4, 20), \
	new/datum/stack_recipe("drewniana rama stołu",						/obj/structure/table_frame/wood, 2, time = 10), \
	new/datum/stack_recipe("kolba karabinu",							/obj/item/weaponcrafting/stock, 10, time = 40), \
	new/datum/stack_recipe("wałek do ciasta", 							/obj/item/kitchen/rollingpin, 2, time = 30), \
	new/datum/stack_recipe("drewniane krzesło",							/obj/structure/chair/wood/, 3, time = 20, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("drewniane krzesło uszak",					/obj/structure/chair/wood/wings, 3, time = 30, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("drewniana barykada",						/obj/structure/barricade/wooden, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("drewniane drzwi",							/obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("trumna",								/obj/structure/closet/crate/coffin, 5, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("regał na książki",								/obj/structure/bookcase, 4, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("suszarka",							/obj/machinery/smartfridge/drying_rack, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("legowisko dla psa",								/obj/structure/bed/dogbed, 10, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("komoda",								/obj/structure/dresser, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("ramka na zdjęcie",							/obj/item/wallframe/picture, 1, time = 10),\
	new/datum/stack_recipe("rama na obraz",						/obj/item/wallframe/painting, 1, time = 10),\
	new/datum/stack_recipe("podstawa gabloty",					/obj/structure/displaycase_chassis, 5, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("sztaluga",									/obj/structure/easel, 5, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("drewniany puklerz",						/obj/item/shield/riot/buckler, 20, time = 40), \
	new/datum/stack_recipe("ul",								/obj/structure/beebox, 40, time = 50),\
	new/datum/stack_recipe("maska tiki",								/obj/item/clothing/mask/gas/tiki_mask, 2), \
	new/datum/stack_recipe("ramka na miód",							/obj/item/honey_frame, 5, time = 10),\
	new/datum/stack_recipe("skrzynia na rudę",								/obj/structure/ore_box, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),\
	new/datum/stack_recipe("drewniana skrzynia",							/obj/structure/closet/crate/wooden, 6, time = 50, one_per_turf = TRUE, on_floor = TRUE),\
	new/datum/stack_recipe("kij bejsbolowy",							/obj/item/melee/baseball_bat, 5, time = 15),\
	new/datum/stack_recipe("krosno",									/obj/structure/loom, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("moździerz",								/obj/item/reagent_containers/glass/mortar, 3), \
	new/datum/stack_recipe("żagiew",								/obj/item/match/firebrand, 2, time = 100), \
	null, \
	new/datum/stack_recipe_list("ławki kościelne", list(
		new /datum/stack_recipe("ławka kościelna (środek)",						/obj/structure/chair/fancy/bench/pew, 3, one_per_turf = TRUE, on_floor = TRUE, time = 20),
		new /datum/stack_recipe("ławka kościelna (lewa strona)",						/obj/structure/chair/fancy/bench/pew/left, 3, one_per_turf = TRUE, on_floor = TRUE, time = 20),
		new /datum/stack_recipe("ławka kościelna (prawa strona)",						/obj/structure/chair/fancy/bench/pew/right, 3, one_per_turf = TRUE, on_floor = TRUE, time = 20)
		)),
	null, \
	))

/obj/item/stack/sheet/mineral/wood
	name = "drewniane deski"
	desc = "Można się tylko domyślać, że to sterta drewna."
	singular_name = "deska"
	icon_state = "sheet-wood"
	item_state = "sheet-wood"
	icon = 'icons/obj/stack_objects.dmi'
	sheettype = "wood"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0, "stamina" = 0)
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/mineral/wood
	novariants = TRUE
	grind_results = list(/datum/reagent/carbon = 20)

/obj/item/stack/sheet/mineral/wood/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.wood_recipes
	return ..()

/obj/item/stack/sheet/mineral/wood/fifty
	amount = 50

/obj/item/stack/sheet/mineral/wood/twenty
	amount = 20

/obj/item/stack/sheet/mineral/wood/ten
	amount = 10

/obj/item/stack/sheet/mineral/wood/five
	amount = 5

/*
 * Cloth
 */

/obj/item/stack/sheet/cotton
	name = "wiązka surowej bawełny"
	desc = "Wiązka surowej bawełny gotowa do przędzenia na krośnie."
	singular_name = "kłębek surowej bawełny"
	icon_state = "sheet-cotton"
	item_state = "sheet-cotton"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cotton
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	var/pull_effort = 30
	var/loom_result = /obj/item/stack/sheet/cotton/cloth

GLOBAL_LIST_INIT(cloth_recipes, list ( \
	new/datum/stack_recipe("biały kombinezon",						/obj/item/clothing/under/color/white, 3), \
	new/datum/stack_recipe("białe buty",							/obj/item/clothing/shoes/sneakers/white, 2), \
	new/datum/stack_recipe("biały szalik",							/obj/item/clothing/neck/scarf, 1), \
	null, \
	new/datum/stack_recipe("plecak",								/obj/item/storage/backpack, 4), \
	new/datum/stack_recipe("torba podróżna",							/obj/item/storage/backpack/duffelbag, 6), \
	null, \
	new/datum/stack_recipe("torba na rośliny",								/obj/item/storage/bag/plants, 4), \
	new/datum/stack_recipe("torba na książki",								/obj/item/storage/bag/books, 4), \
	new/datum/stack_recipe("torba na rudę",						/obj/item/storage/bag/ore, 4), \
	new/datum/stack_recipe("torba chemiczna",							/obj/item/storage/bag/chemistry, 4), \
	new/datum/stack_recipe("torba biologiczna",								/obj/item/storage/bag/bio, 4), \
	new/datum/stack_recipe("torba budowlana",						/obj/item/storage/bag/construction, 4), \
	new/datum/stack_recipe("łapacz arkuszy",						/obj/item/storage/bag/sheetsnatcher, 6), \
	null, \
	new/datum/stack_recipe("prowizoryczna gaza",						/obj/item/stack/medical/gauze/improvised, 1, 2, 6), \
	new/datum/stack_recipe("szmata",									/obj/item/reagent_containers/glass/rag, 1), \
	new/datum/stack_recipe("prześcieradło",								/obj/item/bedsheet, 3), \
	new/datum/stack_recipe("podwójne prześcieradło",						/obj/item/bedsheet, 6), \
	new/datum/stack_recipe("pusty worek na piasek",							/obj/item/emptysandbag, 4), \
	null, \
	new/datum/stack_recipe("rękawiczki bez palców",						/obj/item/clothing/gloves/fingerless, 1), \
	new/datum/stack_recipe("białe rękawiczki",							/obj/item/clothing/gloves/color/white, 3), \
	new/datum/stack_recipe("biała czapka",							/obj/item/clothing/head/soft, 2), \
	new/datum/stack_recipe("biała czapka zimowa",							/obj/item/clothing/head/beanie, 2), \
	null, \
	new/datum/stack_recipe("opaska na oczy",								/obj/item/clothing/glasses/blindfold, 2), \
	null, \
	new/datum/stack_recipe("płótno 19x19",							/obj/item/canvas/nineteen_nineteen, 3), \
	new/datum/stack_recipe("płótno 23x19",							/obj/item/canvas/twentythree_nineteen, 4), \
	new/datum/stack_recipe("płótno 23x23",							/obj/item/canvas/twentythree_twentythree, 5), \
	null, \
	new/datum/stack_recipe("materiał na pluszaka",							/obj/item/toy/empty_plush, 5, time = 4 SECONDS), \
	null, \
	))

/obj/item/stack/sheet/cotton/cloth
	name = "tkanina"
	desc = "Bawełna? Len? Dżins? Juta? Płótno? Nie da się stwierdzić."
	singular_name = "rolka tkaniny"
	icon_state = "sheet-cloth"
	item_state = "sheet-cloth"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cotton/cloth
	pull_effort = 50
	loom_result = /obj/item/stack/sheet/silk

/obj/item/stack/sheet/cotton/cloth/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.cloth_recipes
	return ..()


/obj/item/stack/sheet/cotton/cloth/fifty
	amount = 50

/obj/item/stack/sheet/cotton/cloth/twenty
	amount = 20

/obj/item/stack/sheet/cotton/cloth/ten
	amount = 10

/obj/item/stack/sheet/cotton/cloth/five
	amount = 5

/obj/item/stack/sheet/cotton/wool
	name = "wełna"
	desc = "Wiązka wełny gotowa do przędzenia na krośnie."
	singular_name = "kłębek wełny"
	icon_state = "sheet-wool"
	item_state = "sheet-wool"

/*
 * Silk
 */

GLOBAL_LIST_INIT(silk_recipes, list ( \
	new/datum/stack_recipe("jedwabna cięciwa",							/obj/item/weaponcrafting/silkstring, 2, time = 40)
	))

/obj/item/stack/sheet/silk
	name = "jedwab"
	desc = "Długi, miękki materiał. Ten zrobiono z bawełny, a nie z pajęczego jedwabiu."
	singular_name = "arkusz jedwabiu"
	icon_state = "sheet-silk"
	item_state = "sheet-silk"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/silk
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

/obj/item/stack/sheet/silk/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.silk_recipes
	return ..()

GLOBAL_LIST_INIT(durathread_recipes, list ( \
	new/datum/stack_recipe("kombinezon z duranici",					/obj/item/clothing/under/color/durathread, 4, time = 40), \
	new/datum/stack_recipe("beret z duranici",						/obj/item/clothing/head/beret/durathread, 2, time = 40), \
	new/datum/stack_recipe("czapka zimowa z duranici",						/obj/item/clothing/head/beanie/durathread, 2, time = 40), \
	new/datum/stack_recipe("bandana z duranici",					/obj/item/clothing/mask/bandana/durathread, 1, time = 25), \
	))

/obj/item/stack/sheet/durathread
	name = "duranić"
	desc = "Tkanina z niezwykle wytrzymałych nici, ceniona przy produkcji pancerzy."
	singular_name = "rolka duranici"
	icon_state = "sheet-durathread"
	item_state = "sheet-cloth"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/durathread
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

/obj/item/stack/sheet/durathread/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.durathread_recipes
	return ..()

/obj/item/stack/sheet/cotton/durathread
	name = "wiązka surowej duranici"
	desc = "Wiązka surowej duranici gotowa do przędzenia na krośnie."
	singular_name = "kłębek surowej duranici"
	icon_state = "sheet-durathreadraw"
	merge_type = /obj/item/stack/sheet/cotton/durathread
	pull_effort = 70
	loom_result = /obj/item/stack/sheet/durathread

/*
 * Bamboo
 */

GLOBAL_LIST_INIT(bamboo_recipes, list ( \
	new/datum/stack_recipe("pułapka z kolców punji",						/obj/structure/punji_sticks, 5, time = 30, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("bambusowa włócznia",							/obj/item/spear/bamboospear, 25, time = 90), \
	new/datum/stack_recipe("dmuchawka",								/obj/item/gun/syringe/blowgun, 10, time = 70), \
	new/datum/stack_recipe("prymitywna strzykawka",							/obj/item/reagent_containers/syringe/crude, 5, time = 10), \
	null, \
	new/datum/stack_recipe("bambusowy stołek",							/obj/structure/chair/stool/bamboo, 2, time = 10, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("kawałek bambusowej maty",						/obj/item/stack/tile/bamboo, 1, 4, 20), \
	null, \
	new/datum/stack_recipe_list("bambusowe ławki", list(
		new /datum/stack_recipe("bambusowa ławka (środek)",			/obj/structure/chair/fancy/bench/bamboo, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("bambusowa ławka (lewa strona)",				/obj/structure/chair/fancy/bench/bamboo/left, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE),
		new /datum/stack_recipe("bambusowa ławka (prawa strona)",				/obj/structure/chair/fancy/bench/bamboo/right, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE)
		)),	\
	))

/obj/item/stack/sheet/mineral/bamboo
	name = "bambusowe ścinki"
	desc = "Drobno pocięte bambusowe patyczki."
	singular_name = "pocięty bambus"
	icon_state = "sheet-bamboo"
	item_state = "sheet-bamboo"
	icon = 'icons/obj/stack_objects.dmi'
	sheettype = "bamboo"
	force = 10
	throwforce = 10
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0, "stamina" = 0)
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/mineral/bamboo
	grind_results = list("carbon" = 5)

/obj/item/stack/sheet/mineral/bamboo/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.bamboo_recipes
	return ..()

/obj/item/stack/sheet/mineral/bamboo/Topic(href, href_list)
	. = ..()
	if(href_list["make"])
		var/list/recipes_list = recipes
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		if(R.result_type == /obj/structure/punji_sticks)
			var/turf/T = get_turf(src)
			usr.investigate_log("has placed punji sticks trap at [AREACOORD(T)].", INVESTIGATE_BOTANY)

/*
 * Cardboard
 */

GLOBAL_LIST_INIT(cardboard_recipes, list ( \
	new/datum/stack_recipe("pudełko",									/obj/item/storage/box), \
	new/datum/stack_recipe("strój kartonborga",							/obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("hełm kartonborga",						/obj/item/clothing/head/cardborg), \
	new/datum/stack_recipe("duże pudło",								/obj/structure/closet/cardboard, 4, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("tekturowa makieta",						/obj/item/cardboard_cutout, 5), \
	null, \

	new/datum/stack_recipe("pudełko na pizzę",								/obj/item/pizzabox), \
	new/datum/stack_recipe("teczka",								/obj/item/folder), \
	null, \
	//TO-DO: Find a proper way to just change the illustration on the box. Code isn't the issue, input is.
	new/datum/stack_recipe_list("ozdobne pudełka", list(
		new /datum/stack_recipe("pudełko pączków",						/obj/item/storage/fancy/donut_box), \
		new /datum/stack_recipe("wytłaczanka na jajka",							/obj/item/storage/fancy/egg_box), \
		new /datum/stack_recipe("pudełko pierożków Donk",					/obj/item/storage/box/donkpockets), \
		new /datum/stack_recipe("pudełko ostrych pierożków Donk",			/obj/item/storage/box/donkpockets/donkpocketspicy), \
		new /datum/stack_recipe("pudełko pierożków Donk teriyaki",		/obj/item/storage/box/donkpockets/donkpocketteriyaki), \
		new /datum/stack_recipe("pudełko pierożków Donk z pizzą",			/obj/item/storage/box/donkpockets/donkpocketpizza), \
		new /datum/stack_recipe("pudełko jagodowych pierożków Donk",			/obj/item/storage/box/donkpockets/donkpocketberry), \
		new /datum/stack_recipe("pudełko pierożków Donk honk",			/obj/item/storage/box/donkpockets/donkpockethonk), \
		new /datum/stack_recipe("pudełko małpich kostek",					/obj/item/storage/box/monkeycubes),
		new /datum/stack_recipe("pudełko nuggetsów",						/obj/item/storage/fancy/nugget_box), \
		null, \

		new /datum/stack_recipe("pudełko amunicji ostrej",					/obj/item/storage/box/lethalshot), \
		new /datum/stack_recipe("pudełko nabojów z gumowym śrutem",				/obj/item/storage/box/rubbershot), \
		new /datum/stack_recipe("pudełko nabojów z woreczkiem",				/obj/item/storage/box/beanbag), \
		new /datum/stack_recipe("pudełko granatów hukowo-błyskowych",					/obj/item/storage/box/flashbangs), \
		new /datum/stack_recipe("pudełko flashy",						/obj/item/storage/box/flashes), \
		new /datum/stack_recipe("pudełko kajdanek",					/obj/item/storage/box/handcuffs), \
		new /datum/stack_recipe("pudełko identyfikatorów",						/obj/item/storage/box/ids), \
		new /datum/stack_recipe("pudełko PDA",							/obj/item/storage/box/PDAs), \
		null, \

		new /datum/stack_recipe("pudełko pojemników na pigułki",					/obj/item/storage/box/pillbottles), \
		new /datum/stack_recipe("pudełko zlewek",						/obj/item/storage/box/beakers), \
		new /datum/stack_recipe("pudełko strzykawek",						/obj/item/storage/box/syringes), \
		new /datum/stack_recipe("pudełko rękawiczek lateksowych",					/obj/item/storage/box/gloves), \
		new /datum/stack_recipe("pudełko maseczek chirurgicznych",				/obj/item/storage/box/masks), \
		new /datum/stack_recipe("pudełko worków na zwłoki",						/obj/item/storage/box/bodybags), \
		new /datum/stack_recipe("pudełko okularów korekcyjnych",			/obj/item/storage/box/rxglasses), \
		null, \

		new /datum/stack_recipe("pudełko dysków",							/obj/item/storage/box/disks), \
		new /datum/stack_recipe("pudełko świetlówek",					/obj/item/storage/box/lights/tubes), \
		new /datum/stack_recipe("pudełko żarówek",					/obj/item/storage/box/lights/bulbs), \
		new /datum/stack_recipe("pudełko mieszanych żarówek",					/obj/item/storage/box/lights/mixed), \
		new /datum/stack_recipe("pudełko pułapek na myszy",					/obj/item/storage/box/mousetraps), \
		new /datum/stack_recipe("pudełko świec", 						/obj/item/storage/fancy/candle_box), \
		null,	// NSV13 - added squad kit box
		new /datum/stack_recipe("pudełko zestawu drużyny", 					/obj/item/storage/box/squad_kit)
		)),

	null, \
))

/obj/item/stack/sheet/cardboard	//BubbleWrap //it's cardboard you fuck
	name = "tektura"
	desc = "Duże arkusze tektury, jak rozłożone na płasko pudełka."
	singular_name = "arkusz tektury"
	icon_state = "sheet-card"
	item_state = "sheet-card"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cardboard
	novariants = TRUE

/obj/item/stack/sheet/cardboard/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.cardboard_recipes
	return ..()

/obj/item/stack/sheet/cardboard/fifty
	amount = 50

/obj/item/stack/sheet/cardboard/twenty
	amount = 20

/obj/item/stack/sheet/cardboard/ten
	amount = 10

/obj/item/stack/sheet/cardboard/five
	amount = 5

/obj/item/stack/sheet/cardboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stamp/clown) && !istype(loc, /obj/item/storage))
		var/atom/droploc = drop_location()
		if(use(1))
			playsound(I, 'sound/items/bikehorn.ogg', 50, 1, -1)
			to_chat(user, "<span class='notice'>Stemplujesz karton! To pudło klauna! Honk!</span>")
			if (amount >= 0)
				new/obj/item/storage/box/clown(droploc) //bugfix
	else
		. = ..()


/*
 * Runed Metal
 */

// AQ EDIT START - kult krwi „Cult 4”: pylon, kuźnię i ołtarz stawia runa Raise Structure; z metalu zostają archiwa i więzy
GLOBAL_LIST_INIT(runed_metal_recipes, list ( \
	new/datum/stack_recipe("runed door",							/obj/machinery/door/airlock/cult, 1, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("runed girder",							/obj/structure/girder/cult, 1, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("archives",								/obj/structure/destructible/cult/item_dispenser/archives, 3, time = 40, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("ghastly bindings",						/obj/item/restraints/handcuffs/cult, 1, time = 30), \
	))
// AQ EDIT END

/obj/item/stack/sheet/runed_metal
	name = "runiczny metal"
	desc = "Arkusze zimnego metalu pokryte zmieniającymi się inskrypcjami."
	singular_name = "arkusz runicznego metalu"
	icon_state = "sheet-runed"
	item_state = "sheet-runed"
	icon = 'icons/obj/stack_objects.dmi'
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal
	novariants = TRUE
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/blood = 15)

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/tile/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Tylko ktoś z zakazaną wiedzą mógłby mieć nadzieję na obróbkę tego metalu...</span>")
		return
	var/turf/T = get_turf(user) //we may have moved. adjust as needed...
	var/area/A = get_area(user)
	if((!is_station_level(T.z) && !is_mining_level(T.z)) || (A && !(A.area_flags & BLOBS_ALLOWED)))
		to_chat(user, "<span class='warning'>Zasłona nie jest tu wystarczająco słaba.</span>")
		return FALSE
	return ..()

/obj/item/stack/sheet/runed_metal/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.runed_metal_recipes
	return ..()

/obj/item/stack/sheet/runed_metal/fifty
	amount = 50

/obj/item/stack/sheet/runed_metal/twenty
	amount = 20

/obj/item/stack/sheet/runed_metal/ten
	amount = 10

/obj/item/stack/sheet/runed_metal/five
	amount = 5

/*
 * Brass
 */

GLOBAL_LIST_INIT(brass_recipes, list ( \
	new/datum/stack_recipe("zębatka ścienna",								/obj/structure/destructible/clockwork/wall_gear, 2, time = 20, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("zębata krata",							/obj/structure/grille/ratvar, 2, time=20, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new/datum/stack_recipe("mosiężne okno pełne",					/obj/structure/window/reinforced/clockwork/fulltile/unanchored, 4, time=10, on_floor = TRUE, window_checks=TRUE), \
	new/datum/stack_recipe("mosiężne okno kierunkowe",				/obj/structure/window/reinforced/clockwork/unanchored, 2, time=10, on_floor = TRUE, window_checks=TRUE), \
	new/datum/stack_recipe("mosiężne drzwi okienne",							/obj/machinery/door/window/clockwork, 5, time=40, on_floor = TRUE, window_checks=TRUE), \
	null, \
	new/datum/stack_recipe("śluza zębata",						/obj/machinery/door/airlock/clockwork, 5, time=40, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("przeszklona śluza zębata",				/obj/machinery/door/airlock/clockwork/glass, 5, time=40, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new/datum/stack_recipe("mosiężne krzesło",							/obj/structure/chair/fancy/brass, 1, time=40, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("mosiężna rama stołu",						/obj/structure/table_frame/brass, 1, time=40, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new/datum/stack_recipe("przełącznik",									/obj/item/wallframe/clocktrap/lever, 1, time=40, one_per_turf = FALSE, on_floor = FALSE), \
	new/datum/stack_recipe("mechaniczny zegar",									/obj/item/wallframe/clocktrap/delay, 1, time=40, one_per_turf = FALSE, on_floor = FALSE), \
	new/datum/stack_recipe("płyta naciskowa",						/obj/structure/destructible/clockwork/trap/pressure_sensor, 4, time=40, one_per_turf = TRUE, on_floor = TRUE), \
	null, \
	new/datum/stack_recipe("mosiężny szpikulec",							/obj/structure/destructible/clockwork/trap/skewer, 12, time=40, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("mosiężny przerzutnik",							/obj/structure/destructible/clockwork/trap/flipper, 10, time=40, one_per_turf = TRUE, on_floor = TRUE), \
))

/obj/item/stack/tile/brass
	name = "mosiądz"
	desc = "Arkusze z mosiądzu."
	singular_name = "arkusz mosiądzu"
	icon_state = "sheet-brass"
	item_state = "sheet-brass"
	icon = 'icons/obj/stack_objects.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	turf_type = /turf/open/floor/clockwork
	novariants = FALSE
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/teslium = 15)
	merge_type = /obj/item/stack/tile/brass
	materials = list(/datum/material/copper=MINERAL_MATERIAL_AMOUNT*0.5, /datum/material/iron=MINERAL_MATERIAL_AMOUNT*0.5)

/obj/item/stack/tile/brass/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/tile/brass/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='danger'>[src] wydaje się zbyt kruchy, by z niego budować.</span>") //haha that's because it's actually replicant alloy you DUMMY << WOAH TOOO FAR!
	else
		return ..()

/obj/item/stack/tile/brass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.brass_recipes
	pixel_x = 0
	pixel_y = 0

/obj/item/stack/tile/brass/fifty
	amount = 50

/obj/item/stack/tile/brass/twenty
	amount = 20

/obj/item/stack/tile/brass/ten
	amount = 10

/obj/item/stack/tile/brass/five
	amount = 5

/obj/item/stack/tile/brass/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500

/*
 * Bronze
 */

GLOBAL_LIST_INIT(bronze_recipes, list ( \
	new/datum/stack_recipe("zębatka ścienna", /obj/structure/girder/bronze, 2, time = 20, one_per_turf = TRUE, on_floor = TRUE), \
	null,
	new/datum/stack_recipe("kierunkowe okno z brązu",				/obj/structure/window/bronze/unanchored, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("pełne okno z brązu",				/obj/structure/window/bronze/fulltile/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("zespół śluzy zębatej",				/obj/structure/door_assembly/door_assembly_bronze, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("zespół przeszklonej śluzy zębatej",		/obj/structure/door_assembly/door_assembly_bronze/seethru, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("kapelusz z brązu",							/obj/item/clothing/head/bronze), \
	new/datum/stack_recipe("strój z brązu",							/obj/item/clothing/suit/bronze), \
	new/datum/stack_recipe("buty z brązu",							/obj/item/clothing/shoes/bronze), \
	null,
	new/datum/stack_recipe("krzesło z brązu",							/obj/structure/chair/fancy/brass/bronze, 1, time = 40, one_per_turf = TRUE, on_floor = TRUE), \
))

/obj/item/stack/tile/bronze
	name = "mosiądz"
	desc = "Po bliższym przyjrzeniu się to, co wyglądało na mosiądz zupełnie nienadający się do budowy, okazuje się stabilniejszym konstrukcyjnie brązem."
	singular_name = "arkusz brązu"
	icon_state = "sheet-brass"
	item_state = "sheet-brass"
	icon = 'icons/obj/stack_objects.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	turf_type = /turf/open/floor/bronze
	novariants = FALSE
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/copper = 3) //we have no "tin" reagent so this is the closest thing
	merge_type = /obj/item/stack/tile/bronze
	tableVariant = /obj/structure/table/bronze

/obj/item/stack/tile/bronze/attack_self(mob/living/user)
	if(is_servant_of_ratvar(user))
		to_chat(user, "<span class='danger'>Co... co to za tania podróbka? To wcale nie jest mosiądz!</span>")
	else
		return ..()

/obj/item/stack/tile/bronze/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.bronze_recipes
	. = ..()
	pixel_x = 0
	pixel_y = 0

/obj/item/stack/tile/bronze/fifty
	amount = 50

/obj/item/stack/tile/bronze/twenty
	amount = 20

/obj/item/stack/tile/bronze/ten
	amount = 10

/obj/item/stack/tile/bronze/five
	amount = 5

/*
 * Lesser and Greater gems - unused
 */
/obj/item/stack/sheet/lessergem
	name = "pomniejsze klejnoty"
	desc = "Rzadki rodzaj klejnotów, które zdobywa się wyłącznie krwawą ofiarą dla pomniejszych bóstw. Potrzebne do tworzenia potężnych przedmiotów."
	singular_name = "pomniejszy klejnot"
	icon_state = "sheet-lessergem"
	item_state = "sheet-lessergem"
	novariants = TRUE


/obj/item/stack/sheet/greatergem
	name = "większe klejnoty"
	desc = "Rzadki rodzaj klejnotów, które zdobywa się wyłącznie krwawą ofiarą dla pomniejszych bóstw. Potrzebne do tworzenia potężnych przedmiotów."
	singular_name = "większy klejnot"
	icon_state = "sheet-greatergem"
	item_state = "sheet-greatergem"
	novariants = TRUE

	/*
 * Bones
 */
/obj/item/stack/sheet/bone
	name = "kości"
	icon = 'icons/obj/mining.dmi'
	icon_state = "bone"
	item_state = "sheet-bone"
	singular_name = "kość"
	desc = "Ktoś tu pił dużo mleka."
	force = 7
	throwforce = 5
	max_amount = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	grind_results = list(/datum/reagent/carbon = 10)
	merge_type = /obj/item/stack/sheet/bone

GLOBAL_LIST_INIT(plastic_recipes, list(
	new /datum/stack_recipe("plastikowe zasłony",						/obj/structure/plasticflaps, 5, one_per_turf = TRUE, on_floor = TRUE, time = 40), \
	new /datum/stack_recipe("butelka na wodę",							/obj/item/reagent_containers/glass/waterbottle/empty), \
	new /datum/stack_recipe("duża butelka na wodę",					/obj/item/reagent_containers/glass/waterbottle/large/empty,3), \
	new /datum/stack_recipe("znak „mokra podłoga”",						/obj/item/clothing/suit/caution, 2), \
	new /datum/stack_recipe("plastikowe krzesło",						/obj/structure/chair/fancy/plastic, one_per_turf = TRUE, on_floor = TRUE, time = 20), \
	))

/obj/item/stack/sheet/plastic
	name = "plastik"
	desc = "Ściśnij dinozaura przez miliony lat, potem rafinuj, rozdziel i odlej, i voilà! Masz plastik."
	singular_name = "arkusz plastiku"
	icon_state = "sheet-plastic"
	item_state = "sheet-plastic"
	materials = list(/datum/material/plastic=MINERAL_MATERIAL_AMOUNT)
	throwforce = 7
	merge_type = /obj/item/stack/sheet/plastic

/obj/item/stack/sheet/plastic/fifty
	amount = 50

/obj/item/stack/sheet/plastic/twenty
	amount = 20

/obj/item/stack/sheet/plastic/ten
	amount = 10

/obj/item/stack/sheet/plastic/five
	amount = 5

/obj/item/stack/sheet/plastic/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plastic_recipes
	. = ..()

GLOBAL_LIST_INIT(paperframe_recipes, list(
new /datum/stack_recipe("papierowa ścianka działowa", /obj/structure/window/paperframe, 2, one_per_turf = TRUE, on_floor = TRUE, time = 10), \
new /datum/stack_recipe("drzwi z papierowych ram", /obj/structure/mineral_door/paperframe, 3, one_per_turf = TRUE, on_floor = TRUE, time = 10 )))

/obj/item/stack/sheet/paperframes
	name = "papierowe ramy"
	desc = "Cienka drewniana rama z przyklejonym papierem."
	singular_name = "papierowa rama"
	icon_state = "sheet-paper"
	item_state = "sheet-paper"
	merge_type = /obj/item/stack/sheet/paperframes
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sheet/paperframes

/obj/item/stack/sheet/paperframes/Initialize(mapload)
	recipes = GLOB.paperframe_recipes
	. = ..()

/obj/item/stack/sheet/paperframes/fifty
	amount = 50

/obj/item/stack/sheet/paperframes/twenty
	amount = 20

/obj/item/stack/sheet/paperframes/ten
	amount = 10

/obj/item/stack/sheet/paperframes/five
	amount = 5

/obj/item/stack/sheet/capitalisium
	name = "arkusz kapitalizu"
	desc = "Źródło czystego kapitalizmu, zdolne powołać do życia przepowiedzianego Kapitalistycznego Golema."
	icon_state = "sheet-capitalisium"
	merge_type = /obj/item/stack/sheet/capitalisium

/obj/item/stack/sheet/stalinium
	name = "arkusz stalinium"
	desc = "Źródło czystego socjalizmu, zdolne powołać do życia przepowiedzianego Radzieckiego Golema."
	icon_state = "sheet-stalinium"
	merge_type = /obj/item/stack/sheet/stalinium

	/*
 * Cheese
 */
/obj/item/stack/sheet/cheese
	name = "zbrojony ser"
	desc = "Stos sera, który wydaje się wytrzymalszy od zwykłego."
	icon_state = "sheet-cheese"
	item_state = "sheet-cheese"
	icon = 'icons/obj/stack_objects.dmi'
	singular_name = "blok zbrojonego sera"
	sheettype = "cheese"
	max_amount = 15
	grind_results = list(/datum/reagent/consumable/milk = 20)
	merge_type = /obj/item/stack/sheet/cheese

GLOBAL_LIST_INIT(cheese_recipes, list (
	new/datum/stack_recipe("posąg Serusa", /obj/structure/statue/cheese/cheesus, 5, one_per_turf = 1, on_floor = 1)
	))

/obj/item/stack/sheet/cheese/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.cheese_recipes
	. = ..()
