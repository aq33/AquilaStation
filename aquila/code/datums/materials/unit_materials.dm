// AQUILA - wspólny odczyt materiałów do odzysku (poprawki przeglądu aq33/AquilaStation#613).
// Po BeeStation/BeeStation-Hornet#10135 `custom_materials` stosu to suma całego stosu, a `mats_per_unit` to jedna sztuka.
// Wszystko, co odzyskuje materiał (kontener materiałów, analizator, silos, eksport, rozbiórka mebli i ścian), czyta
// materiały przez get_unit_materials(), żeby nie liczyć stosu raz na sztukę i raz w całości.

/**
 * Materiały, które oddaje jedna sztuka atomu (stos: jeden arkusz; reszta: cały atom).
 * Materiały z przemiany metalgenem dają tylko wygląd i efekty, więc nic się z nich nie odzyskuje (null).
 * Zwracana lista bywa współdzielona (FindOrCreateMaterialCombo): nie zmieniaj jej.
 */
/atom/proc/get_unit_materials()
	if(HAS_TRAIT(src, TRAIT_MATERIALS_TRANSMUTED))
		return null
	return custom_materials

/obj/item/stack/get_unit_materials()
	if(HAS_TRAIT(src, TRAIT_MATERIALS_TRANSMUTED))
		return null
	return mats_per_unit

/// Przenosi materiały na atom, który zastępuje ten (podniesione i postawione krzesło), razem ze znacznikiem metalgenu
/atom/proc/transfer_materials_to(atom/target)
	if(!length(custom_materials))
		return
	if(HAS_TRAIT(src, TRAIT_MATERIALS_TRANSMUTED))
		ADD_TRAIT(target, TRAIT_MATERIALS_TRANSMUTED, METALGEN_TRAIT)
	target.set_custom_materials(custom_materials)

/**
 * Wysypuje arkusze materiałów atomu do odzysku (meble, ściany i podłogi z materiału).
 * Pomija materiały bez arkusza (kamień z gorgium) i resztki mniejsze od arkusza.
 */
/atom/proc/drop_material_sheets(atom/location)
	var/list/materials = get_unit_materials()
	for(var/datum/material/material as anything in materials)
		if(!material.sheet_type)
			continue
		var/sheets = FLOOR(materials[material] / MINERAL_MATERIAL_AMOUNT, 1)
		if(sheets >= 1)
			new material.sheet_type(location, sheets)

/// Łączy stos z innymi stosami na tym samym polu, jak w Initialize(). Dla stosów tworzonych bez łączenia, którym materiał
/// nadaje się dopiero po utworzeniu (inaczej nowa złota płytka wpada do stosu żelaznych, zanim dostanie złoto).
/obj/item/stack/proc/merge_with_loc()
	for(var/obj/item/stack/other in loc)
		if(merge_check(other))
			merge(other)
			if(QDELETED(src))
				return
