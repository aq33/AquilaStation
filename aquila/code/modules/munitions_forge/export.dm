// AQUILA - kuźnia amunicji: eksport kutej amunicji (na wzór smithed_part/get_cost z Monkestation).
// Cena idzie od wartości zużytych surowców, a nie od stałej kwoty, żeby kuźnia nie stała się drukarką kredytów
// z żelaza: klasa I to połowa wartości surowców, klasa V 90% plus mała premia za robotę.

/datum/export/forged_munition
	unit_name = "wyrób z kuźni amunicji"
	k_elasticity = 0
	// Pudełka sprzedają się przez swoje naboje: eksport idzie od środka i kasuje niesprzedane naboje,
	// zanim dojdzie do pudełka, więc wycena samego pudełka na promie zawsze dawała 0 kr
	export_types = list(/obj/item/ammo_casing, /obj/item/ship_weapon/ammunition, /obj/item/ship_weapon/parts/missile/warhead)

/datum/export/forged_munition/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	if(istype(O, /obj/item/ammo_casing))
		return forged_casing_value(O) // bez zaokrąglenia: nabój bywa wart ułamek kredytu, sumę zaokrągla total_printout
	return forged_munition_value(O)

/datum/export/forged_munition/total_printout(datum/export_report/ex, notes = TRUE)
	if(ex.total_value[src])
		ex.total_value[src] = round(ex.total_value[src])
	return ..()

/// Ile kredytów za jeden wyrób; 0 = to nie jest wyrób z kuźni
/proc/forged_munition_value(obj/O)
	if(istype(O, /obj/item/ammo_casing))
		return round(forged_casing_value(O))
	var/body_type = GLOB.munition_products[O.type]
	if(!body_type)
		return 0
	if(istype(O, /obj/item/ammo_box))
		// Pudełko jest warte tyle, ile wykutych nabojów ma teraz w środku: każdy nabój to ułamek pełnego pudełka.
		// Inaczej rozłożenie nabojów do pustych pudełek mnożyło cenę.
		var/obj/item/ammo_box/box = O
		var/box_value = 0
		for(var/obj/item/ammo_casing/casing in box.stored_ammo)
			box_value += forged_casing_value(casing)
		return round(box_value)
	var/datum/component/forged_munition/forged = O.GetComponent(/datum/component/forged_munition)
	if(!forged)
		return 0
	return round(forged_product_value(forged, body_type))

/// Ile wart jest wykuty nabój w pudełku z kuźni: ułamek ceny pełnego pudełka (bez zaokrąglenia).
/// Luzem albo w pudełku, którego kuźnia nie robi, nabój nic nie jest wart.
/proc/forged_casing_value(obj/item/ammo_casing/casing)
	var/obj/item/ammo_box/box = casing.loc
	if(!istype(box) || !(casing in box.stored_ammo))
		return 0
	var/body_type = GLOB.munition_products[box.type]
	if(!body_type)
		return 0
	var/datum/component/forged_munition/round_forged = casing.GetComponent(/datum/component/forged_munition)
	if(!round_forged)
		return 0
	return forged_product_value(round_forged, body_type) / max(box.max_ammo, 1)

/// Wartość jednego pełnego wyrobu o właściwościach forged, odlanego z korpusu body_type (bez zaokrąglenia)
/proc/forged_product_value(datum/component/forged_munition/forged, body_type)
	var/obj/item/munition_part/body/body = body_type
	// Partia z jednego korpusu (np. 6 pocisków Gaussa) dzieli koszt surowców i premię
	var/batch = initial(body.product_count)
	var/amount = initial(body.material_amount) * forged.quality.material_mult / batch
	if(forged.galvanized)
		amount *= 0.5
	var/raw_value = 0
	var/list/cost = forged.material.get_cost(amount)
	for(var/mat in cost)
		raw_value += munition_sheet_value(mat) * cost[mat] / MINERAL_MATERIAL_AMOUNT
	var/value = raw_value * (0.5 + 0.1 * forged.quality.level)
	if(!forged.galvanized)
		value += 10 * (forged.quality.level + 1) / batch
	return value

/// Cena arkusza materiału w eksporcie cargo (najniższa, bo np. plastytan też ma material_id tytanu)
/proc/munition_sheet_value(material_type)
	. = 0
	for(var/datum/export/material/E in GLOB.exports_list)
		if(E.material_id == material_type && (!. || E.init_cost < .))
			. = E.init_cost
