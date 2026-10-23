// AQUILA - kuźnia amunicji: eksport kutej amunicji (na wzór smithed_part/get_cost z Monkestation).
// Cena idzie od wartości zużytych surowców, a nie od stałej kwoty, żeby kuźnia nie stała się drukarką kredytów
// z żelaza: klasa I to połowa wartości surowców, klasa V 90% plus mała premia za robotę.

/datum/export/forged_munition
	unit_name = "wyrób z kuźni amunicji"
	k_elasticity = 0
	export_types = list(/obj/item/ammo_box, /obj/item/ship_weapon/ammunition, /obj/item/ship_weapon/parts/missile/warhead)

/datum/export/forged_munition/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	return forged_munition_value(O)

/// Ile kredytów za jeden wyrób; 0 = to nie jest wyrób z kuźni
/proc/forged_munition_value(obj/O)
	var/datum/component/forged_munition/forged = get_forged_munition(O)
	var/body_type = GLOB.munition_products[O.type]
	if(!forged || !body_type)
		return 0
	var/obj/item/munition_part/body/body = body_type
	var/amount = initial(body.material_amount) * forged.quality.material_mult
	if(forged.galvanized)
		amount *= 0.5
	var/raw_value = 0
	var/list/cost = forged.material.get_cost(amount)
	for(var/mat in cost)
		raw_value += munition_sheet_value(mat) * cost[mat] / MINERAL_MATERIAL_AMOUNT
	var/value = raw_value * (0.5 + 0.1 * forged.quality.level)
	if(!forged.galvanized)
		value += 10 * (forged.quality.level + 1)
	return round(value)

/// Cena arkusza materiału w eksporcie cargo (najniższa, bo np. plastytan też ma material_id tytanu)
/proc/munition_sheet_value(material_type)
	. = 0
	for(var/datum/export/material/E in GLOB.exports_list)
		if(E.material_id == material_type && (!. || E.init_cost < .))
			. = E.init_cost
