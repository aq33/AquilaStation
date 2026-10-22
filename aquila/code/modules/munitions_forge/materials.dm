// AQUILA - kuźnia amunicji: wspólna tabela materiałów.
// Z tej tabeli korzysta też kuźnia railguna (gęstość, twardość, przewodnictwo).
// Żelazo to poziom zwykłej amunicji z cargo, każdy droższy materiał to wymiana jednej cechy na drugą.

GLOBAL_LIST_INIT(munition_materials, init_munition_materials())

/proc/init_munition_materials()
	. = list()
	for(var/path in subtypesof(/datum/munition_material) - typesof(/datum/munition_material/alloy))
		var/datum/munition_material/M = new path
		.[M.material_type] = M

/proc/get_munition_material(material_type)
	return GLOB.munition_materials[material_type]

/// Kuźnia railguna wybiera materiał po nazwie ("Iron", "Silver"...).
/proc/get_munition_material_by_railgun_name(railgun_name)
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		if(M.railgun_name == railgun_name)
			return M

/datum/munition_material
	/// Nazwa w nazwach wyrobów, np. "uran"
	var/name = "nic"
	/// Klucz w silosie
	var/datum/material/material_type
	/// Nazwa materiału w kuźni railguna
	var/railgun_name
	/// Gęstość (g/cm3, przeskalowana) — masa pocisku
	var/density = 14
	/// Twardość (Mohs) — przebicie
	var/hardness = 4
	/// Przewodnictwo — tylko railgun
	var/conductivity = 1
	/// Mnożnik obrażeń
	var/damage_mult = 1
	/// Dodatek do armour_penetration
	var/armour_pen_add = 0
	/// Mnożnik prędkości pocisku (większy = szybszy)
	var/speed_mult = 1
	/// Mnożnik wytrzymałości pocisku (odporność na PDC i flak)
	var/integrity_mult = 1
	/// Koszt względem żelaza
	var/sheets_mult = 1
	/// Kolor wyrobu, null = bez barwienia
	var/color_tint
	/// Krótki opis do examine (to, czego nie mówią liczby i cechy)
	var/special_desc
	/// Ścieżki cech, z których powstaje lista traits
	var/list/trait_types
	/// Cechy: typ -> /datum/munition_trait
	var/list/traits

/datum/munition_material/New()
	. = ..()
	traits = list()
	for(var/path in trait_types)
		traits[path] = new path

/// Składniki w silosie: typ materiału -> udział (czysty materiał to on sam w całości)
/datum/munition_material/proc/get_components()
	. = list()
	.[material_type] = 1

/// Ile jednostek każdego składnika potrzeba na odlew (amount to ilość przed mnożnikiem materiału)
/datum/munition_material/proc/get_cost(amount)
	. = list()
	var/list/components = get_components()
	for(var/mat in components)
		.[mat] = round(amount * sheets_mult * components[mat])

/datum/munition_material/iron
	name = "żelazo"
	material_type = /datum/material/iron
	railgun_name = "Iron"
	density = 14
	hardness = 4
	conductivity = 1

/datum/munition_material/copper
	name = "miedź"
	material_type = /datum/material/copper
	railgun_name = "Copper"
	density = 18
	hardness = 5
	conductivity = 5.9
	damage_mult = 1.05
	armour_pen_add = 5
	color_tint = "#d9864a"
	trait_types = list(/datum/munition_trait/conductive)

/datum/munition_material/titanium
	name = "tytan"
	material_type = /datum/material/titanium
	railgun_name = "Titanium"
	density = 9
	hardness = 6
	conductivity = 0.24
	damage_mult = 0.95
	armour_pen_add = 10
	speed_mult = 1.1
	integrity_mult = 1.3
	sheets_mult = 1.5
	color_tint = "#b9c6d6"
	special_desc = "Pocisk trudno zestrzelić obroną punktową."

/datum/munition_material/silver
	name = "srebro"
	material_type = /datum/material/silver
	railgun_name = "Silver"
	density = 22
	hardness = 2.5
	conductivity = 6.3
	damage_mult = 1.05
	armour_pen_add = -5
	speed_mult = 0.95
	sheets_mult = 1.5
	color_tint = "#e6e6f0"
	trait_types = list(/datum/munition_trait/holy, /datum/munition_trait/conductive)

/datum/munition_material/gold
	name = "złoto"
	material_type = /datum/material/gold
	railgun_name = "Gold"
	density = 40
	hardness = 2.5
	conductivity = 4.1
	damage_mult = 1.2
	armour_pen_add = -10
	speed_mult = 0.85
	sheets_mult = 2
	color_tint = "#f2c94c"

/datum/munition_material/uranium
	name = "uran"
	material_type = /datum/material/uranium
	railgun_name = "Uranium"
	density = 38
	hardness = 6
	conductivity = 0.36
	damage_mult = 1.2
	armour_pen_add = 15
	speed_mult = 0.9
	integrity_mult = 1.1
	sheets_mult = 2
	color_tint = "#6fdc5a"
	trait_types = list(/datum/munition_trait/radioactive)

/datum/munition_material/plasma
	name = "plazma"
	material_type = /datum/material/plasma
	railgun_name = "Plasma"
	density = 10
	hardness = 3
	conductivity = 2
	damage_mult = 0.9
	armour_pen_add = -5
	integrity_mult = 0.9
	sheets_mult = 1.5
	color_tint = "#c15bd6"
	trait_types = list(/datum/munition_trait/incendiary)

/datum/munition_material/diamond
	name = "diament"
	material_type = /datum/material/diamond
	railgun_name = "Diamond"
	density = 7
	hardness = 10
	conductivity = 0.001
	damage_mult = 0.9
	armour_pen_add = 30
	speed_mult = 1.1
	integrity_mult = 1.2
	sheets_mult = 3
	color_tint = "#9fe8f2"
	special_desc = "Najlepsze przebicie pancerza."

/datum/munition_material/bluespace
	name = "bluespace"
	material_type = /datum/material/bluespace
	railgun_name = "Bluespace"
	density = 4
	hardness = NUM_E
	conductivity = 8
	damage_mult = 0.85
	speed_mult = 1.35
	sheets_mult = 3
	color_tint = "#4f7cff"
	special_desc = "Najszybszy pocisk."

/datum/munition_material/bananium
	name = "bananium"
	material_type = /datum/material/bananium
	railgun_name = "Bananium"
	density = 25
	hardness = 1
	conductivity = 1
	damage_mult = 0.7
	armour_pen_add = -20
	sheets_mult = 2
	color_tint = "#ffe94a"
	trait_types = list(/datum/munition_trait/honk)

// ---------------------------------------------------------------- stopy

/// Stopy powstają w piecu łukowym z dwóch materiałów po połowie. Jeden datum na parę, trzymany w GLOB.
GLOBAL_LIST_EMPTY(munition_alloys)

/// Udział cech składnika w stopie
#define MUNITION_ALLOY_TRAIT_POWER 0.6

/proc/get_munition_alloy(datum/munition_material/first, datum/munition_material/second)
	if(!first || !second || first == second || istype(first, /datum/munition_material/alloy) || istype(second, /datum/munition_material/alloy))
		return null
	// kolejność jak w tabeli, żeby uran+tytan i tytan+uran to był ten sam stop
	var/list/order = list()
	for(var/key in GLOB.munition_materials)
		order += GLOB.munition_materials[key]
	if(order.Find(first) > order.Find(second))
		var/datum/munition_material/swap = first
		first = second
		second = swap
	var/key = "[first.material_type]+[second.material_type]"
	if(!GLOB.munition_alloys[key])
		GLOB.munition_alloys[key] = new /datum/munition_material/alloy(first, second)
	return GLOB.munition_alloys[key]

/datum/munition_material/alloy
	name = "stop"
	var/datum/munition_material/first
	var/datum/munition_material/second

/datum/munition_material/alloy/New(datum/munition_material/first, datum/munition_material/second)
	. = ..()
	src.first = first
	src.second = second
	name = "[first.name]-[second.name]"
	material_type = first.material_type
	density = (first.density + second.density) / 2
	hardness = (first.hardness + second.hardness) / 2
	conductivity = (first.conductivity + second.conductivity) / 2
	damage_mult = round((first.damage_mult + second.damage_mult) / 2, 0.01)
	armour_pen_add = round((first.armour_pen_add + second.armour_pen_add) / 2)
	speed_mult = round((first.speed_mult + second.speed_mult) / 2, 0.01)
	integrity_mult = round((first.integrity_mult + second.integrity_mult) / 2, 0.01)
	sheets_mult = (first.sheets_mult + second.sheets_mult) / 2
	if(first.color_tint || second.color_tint)
		color_tint = BlendRGB(first.color_tint || "#9a9a9a", second.color_tint || "#9a9a9a", 0.5)
	var/list/descs = list()
	for(var/datum/munition_material/M as anything in list(first, second))
		if(M.special_desc)
			descs += M.special_desc
	if(length(descs))
		special_desc = "Po połowie: [jointext(descs, " ")]"
	traits = list()
	merge_munition_traits(traits, first.traits, MUNITION_ALLOY_TRAIT_POWER)
	merge_munition_traits(traits, second.traits, MUNITION_ALLOY_TRAIT_POWER)

/datum/munition_material/alloy/get_components()
	. = list()
	.[first.material_type] = 0.5
	.[second.material_type] = 0.5

/// Każdy składnik liczy się ze swoim mnożnikiem kosztu
/datum/munition_material/alloy/get_cost(amount)
	. = list()
	for(var/datum/munition_material/M as anything in list(first, second))
		.[M.material_type] = round(amount * M.sheets_mult * 0.5)

#undef MUNITION_ALLOY_TRAIT_POWER

/// Linie do analizatora: liczby i cechy materiału
/datum/munition_material/proc/stat_lines()
	. = list("obrażenia ×[damage_mult]", "przebicie [armour_pen_add >= 0 ? "+" : ""][armour_pen_add]", "prędkość ×[speed_mult]", "wytrzymałość ×[integrity_mult]", "koszt ×[sheets_mult]")
	. = list(jointext(., ", "))
	if(special_desc)
		. += special_desc
	for(var/key in traits)
		var/datum/munition_trait/T = traits[key]
		. += "[capitalize(T.name)]: [T.describe()]"
