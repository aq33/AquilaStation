// AQUILA - kuźnia amunicji: wspólna tabela materiałów.
// Z tej tabeli korzysta też kuźnia railguna (gęstość, twardość, przewodnictwo).
// Żelazo to poziom zwykłej amunicji z cargo, każdy droższy materiał to wymiana jednej cechy na drugą.

GLOBAL_LIST_INIT(munition_materials, init_munition_materials())

/proc/init_munition_materials()
	. = list()
	for(var/path in subtypesof(/datum/munition_material))
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
	/// Krótki opis efektu specjalnego do examine
	var/special_desc

/// Efekt przy trafieniu w moba lub obiekt (broń ręczna).
/datum/munition_material/proc/on_hit(obj/item/projectile/P, atom/target)
	return

/// Efekt przy trafieniu w statek na overmapie.
/datum/munition_material/proc/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target)
	return

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
	special_desc = "Dodatkowo rani kultystów i wampiry, wzmacnia ładunek EMP."

/datum/munition_material/silver/on_hit(obj/item/projectile/P, atom/target)
	if(!isliving(target))
		return
	var/mob/living/L = target
	if(IS_CULTIST(L) || IS_VAMPIRE(L))
		L.apply_damage(P.damage * 0.5, BRUTE, P.def_zone)
		to_chat(L, "<span class='userdanger'>Srebro pali cię od środka!</span>")

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
	special_desc = "Napromieniowuje trafionych."

/datum/munition_material/uranium/on_hit(obj/item/projectile/P, atom/target)
	if(isliving(target))
		var/mob/living/L = target
		L.apply_effect(30, EFFECT_IRRADIATE)

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
	special_desc = "Podpala cel."

/datum/munition_material/plasma/on_hit(obj/item/projectile/P, atom/target)
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_fire_stacks(1)
		L.IgniteMob()

/datum/munition_material/plasma/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target)
	if(target.ai_controlled || istype(target, /obj/structure/overmap/small_craft))
		target.hullburn += 5
		target.hullburn_power = max(target.hullburn_power, 4)

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
	special_desc = "HONK."

/datum/munition_material/bananium/on_hit(obj/item/projectile/P, atom/target)
	playsound(get_turf(target), 'sound/items/bikehorn.ogg', 50, TRUE)
	if(isliving(target) && prob(25))
		var/mob/living/L = target
		L.Knockdown(1 SECONDS)

/datum/munition_material/bananium/on_overmap_hit(obj/item/projectile/P, obj/structure/overmap/target)
	playsound(target, 'sound/items/bikehorn.ogg', 100, TRUE)
