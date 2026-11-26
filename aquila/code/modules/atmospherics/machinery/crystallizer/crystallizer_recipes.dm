// AQUILA - Receptury krystalizatora (plan maszynowni E14), port z Yogstation (atmos_machines_recipes.dm),
// pellety paliwowe i odłamek SM z tg. Tylko gazy, które mamy:
// - diament, arkusz plazmy, kryształ amoniaku: liczby z Yoga;
// - pellety exodronów: standardowy i zaawansowany jak w tg, egzotyczny z hipernoblium i trytem (w tg z nitrium, którego nie mamy);
// - odłamek supermaterii (decyzja D8, bardzo drogi): jak w tg, tryt zamiast antynoblium; z krystalizatora nie da się go sprzedać w cargo.
// Bez metalicznego wodoru (D9).

/// Receptury maszyn gazowych, klucz to id receptury
GLOBAL_LIST_INIT(gas_recipe_meta, gas_recipes_list())

/proc/gas_recipes_list()
	. = list()
	for(var/recipe_path in subtypesof(/datum/gas_recipe))
		var/datum/gas_recipe/recipe = new recipe_path()
		if(!recipe.id)
			continue
		.[recipe.id] = recipe

/datum/gas_recipe
	/// Id receptury (klucz w GLOB.gas_recipe_meta i w oknie)
	var/id = ""
	/// Dla jakiej maszyny
	var/machine_type = ""
	/// Nazwa w oknie
	var/name = ""
	/// Dolna granica okna temperatury (K)
	var/min_temp = TCMB
	/// Górna granica okna temperatury (K)
	var/max_temp = INFINITY
	/// Energia na tik pracy: dodatnia grzeje wnętrze (egzotermiczna), ujemna chłodzi (endotermiczna)
	var/energy_release = 0
	/// Czy powiadamiać adminów o wytworzeniu
	var/dangerous = FALSE
	/// Gazy na jeden przedmiot: GAS_X = mole
	var/list/requirements
	/// Produkty: ścieżka = liczba sztuk
	var/list/products

/datum/gas_recipe/crystallizer
	machine_type = "Crystallizer"

/datum/gas_recipe/crystallizer/diamond
	id = "diamond"
	name = "Diament"
	min_temp = 10000
	max_temp = 30000
	energy_release = -9500000
	requirements = list(GAS_CO2 = 10000)
	products = list(/obj/item/stack/sheet/mineral/diamond = 1)

/datum/gas_recipe/crystallizer/plasma_sheet
	id = "plasma_sheet"
	name = "Arkusz plazmy"
	min_temp = 10
	max_temp = 20
	energy_release = 3500000
	requirements = list(GAS_PLASMA = 450)
	products = list(/obj/item/stack/sheet/mineral/plasma = 1)

/datum/gas_recipe/crystallizer/ammonia_crystal
	id = "ammonia_crystal"
	name = "Kryształ amoniaku"
	min_temp = 200
	max_temp = 240
	energy_release = 950000
	requirements = list(GAS_H2 = 50, GAS_N2 = 40)
	products = list(/obj/item/stack/ammonia_crystals = 2)

/datum/gas_recipe/crystallizer/fuel_pellet
	id = "fuel_basic"
	name = "Standardowy pellet paliwowy"
	energy_release = -6000000
	requirements = list(GAS_O2 = 50, GAS_PLASMA = 100)
	products = list(/obj/item/fuel_pellet = 1)

/datum/gas_recipe/crystallizer/fuel_pellet_advanced
	id = "fuel_advanced"
	name = "Zaawansowany pellet paliwowy"
	energy_release = -6000000
	requirements = list(GAS_TRITIUM = 100, GAS_H2 = 100)
	products = list(/obj/item/fuel_pellet/advanced = 1)

/datum/gas_recipe/crystallizer/fuel_pellet_exotic
	id = "fuel_exotic"
	name = "Egzotyczny pellet paliwowy"
	energy_release = -6000000
	requirements = list(GAS_HYPERNOB = 100, GAS_TRITIUM = 100)
	products = list(/obj/item/fuel_pellet/exotic = 1)

/datum/gas_recipe/crystallizer/shard
	id = "crystal_shard"
	name = "Odłamek supermaterii"
	min_temp = 10
	max_temp = 20
	energy_release = 3500000
	dangerous = TRUE
	requirements = list(GAS_HYPERNOB = 250, GAS_TRITIUM = 1000, GAS_BZ = 200, GAS_PLASMA = 5000, GAS_O2 = 4500)
	products = list(/obj/machinery/power/supermatter_crystal/shard = 1)

/// Kryształ amoniaku z tg (code/game/objects/items/stacks/ammonia_crystals.dm): mieli się na amoniak. Ikona z tg (stack_objects.dmi, CC-BY-SA 3.0).
/obj/item/stack/ammonia_crystals
	name = "kryształy amoniaku"
	desc = "Skrystalizowany amoniak. Dla kogoś cenny, ale raczej nie dla ciebie. Po zmieleniu daje amoniak."
	singular_name = "kryształ amoniaku"
	icon = 'aquila/icons/obj/ammonia_crystal.dmi'
	icon_state = "ammonia_crystal"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_amount = 50
	merge_type = /obj/item/stack/ammonia_crystals
	novariants = FALSE
	grind_results = list(/datum/reagent/ammonia = 10)

/// Odłamek wytworzony w krystalizatorze: cargo go nie kupuje (inaczej gaz zamieniałby się w kredyty)
/obj/machinery/power/supermatter_crystal/var/crystallized = FALSE

/datum/export/large/supermatter/applies_to(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	var/obj/machinery/power/supermatter_crystal/crystal = O
	if(istype(crystal) && crystal.crystallized)
		return FALSE
	return ..()
