// AQUILA - kuźnia amunicji: wspólna tabela materiałów.
// Z tej tabeli korzysta też kuźnia railguna (gęstość, twardość, przewodnictwo).
// Żelazo to poziom zwykłej amunicji z cargo, każdy droższy materiał to wymiana jednej cechy na drugą.
// Liczby (obrażenia, przebicie, prędkość) bierze rdzeń korpusu, efekt specjalny (cechy) i odporność bierze powłoka.

GLOBAL_LIST_INIT(munition_materials, init_munition_materials())

/proc/init_munition_materials()
	. = list()
	for(var/path in subtypesof(/datum/munition_material) - typesof(/datum/munition_material/layered))
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
	trait_types = list(/datum/munition_trait/emp/weak)

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
	trait_types = list(/datum/munition_trait/hardened)

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
	trait_types = list(/datum/munition_trait/holy, /datum/munition_trait/emp)

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
	trait_types = list(/datum/munition_trait/shrapnel)

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
	trait_types = list(/datum/munition_trait/armor_strip)

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
	trait_types = list(/datum/munition_trait/shield_bypass)

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

// ---------------------------------------------------------------- powłoka i rdzeń

/// Korpus z dwóch materiałów, jak pocisk z kuźni railguna: powłoka (ćwierć odlewu) daje efekt specjalny i odporność
/// na obronę punktową, rdzeń (trzy czwarte) daje obrażenia, przebicie i prędkość. Jeden datum na parę, trzymany w GLOB.
GLOBAL_LIST_EMPTY(munition_layered)

/// Udział powłoki w odlewie
#define MUNITION_COATING_SHARE 0.25

/// Korpus z rdzeniem i powłoką; ta sama para albo brak powłoki to czysty materiał rdzenia
/proc/get_munition_layered(datum/munition_material/coating, datum/munition_material/core)
	if(!core || istype(core, /datum/munition_material/layered))
		return null
	if(!coating || coating == core)
		return core
	if(istype(coating, /datum/munition_material/layered))
		return null
	var/key = "[coating.material_type]+[core.material_type]"
	if(!GLOB.munition_layered[key])
		GLOB.munition_layered[key] = new /datum/munition_material/layered(coating, core)
	return GLOB.munition_layered[key]

/datum/munition_material/layered
	name = "rdzeń w powłoce"
	var/datum/munition_material/coating
	var/datum/munition_material/core

/datum/munition_material/layered/New(datum/munition_material/coating, datum/munition_material/core)
	. = ..()
	src.coating = coating
	src.core = core
	name = "[core.name] w powłoce: [coating.name]"
	material_type = core.material_type
	railgun_name = null
	density = coating.density * MUNITION_COATING_SHARE + core.density * (1 - MUNITION_COATING_SHARE)
	hardness = coating.hardness * MUNITION_COATING_SHARE + core.hardness * (1 - MUNITION_COATING_SHARE)
	conductivity = coating.conductivity * MUNITION_COATING_SHARE + core.conductivity * (1 - MUNITION_COATING_SHARE)
	damage_mult = core.damage_mult
	armour_pen_add = core.armour_pen_add
	speed_mult = core.speed_mult
	integrity_mult = coating.integrity_mult
	sheets_mult = coating.sheets_mult * MUNITION_COATING_SHARE + core.sheets_mult * (1 - MUNITION_COATING_SHARE)
	color_tint = coating.color_tint
	special_desc = core.special_desc
	traits = list()
	merge_munition_traits(traits, coating.traits)

/datum/munition_material/layered/get_components()
	. = list()
	.[coating.material_type] = MUNITION_COATING_SHARE
	.[core.material_type] = 1 - MUNITION_COATING_SHARE

/// Każdy składnik liczy się ze swoim mnożnikiem kosztu
/datum/munition_material/layered/get_cost(amount)
	. = list()
	.[coating.material_type] = round(amount * coating.sheets_mult * MUNITION_COATING_SHARE)
	.[core.material_type] = round(amount * core.sheets_mult * (1 - MUNITION_COATING_SHARE))

/// Linie do analizatora: liczby i cechy materiału
/datum/munition_material/proc/stat_lines()
	. = list("obrażenia ×[damage_mult]", "przebicie [armour_pen_add >= 0 ? "+" : ""][armour_pen_add]", "prędkość ×[speed_mult]", "wytrzymałość ×[integrity_mult]", "koszt ×[sheets_mult]")
	. = list(jointext(., ", "))
	if(special_desc)
		. += special_desc
	for(var/key in traits)
		var/datum/munition_trait/T = traits[key]
		. += "[capitalize(T.name)]: [T.describe()]"
