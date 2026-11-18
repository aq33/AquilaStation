// AQUILA - rework amunicji: pociski artylerii i łuski burtowe robi kuźnia zamiast protolathe, a cargo sprzedaje je
// w trzech typach (AP, HE, APHE). Budowa burtówek zostaje: łuski z kuźni idą do pakowarki razem z ładunkami i prochem,
// a pakowarka przenosi na gotowe pociski materiał, klasę i typ każdej łuski.

// ---------------------------------------------------------------- protolathe

// Te projekty przeszły do pieca łukowego (parts.dm, required_node tych samych węzłów)
/datum/techweb_node/advanced_ballistics/New()
	. = ..()
	design_ids -= list("naval_shell", "broadside_casing", "broadside_load", "plasma_core")

/datum/techweb_node/macro_ballistics/New()
	. = ..()
	design_ids -= list("naval_shell_ap", "broadside_load_uranium")

// ---------------------------------------------------------------- fabryczne pociski z cargo

/// Żelazny pocisk danego typu, bez klasy i bez kary klasy I
/proc/aq_apply_factory_munition(atom/movable/product, filler_type)
	apply_forged_munition(product, get_munition_material(/datum/material/iron), get_munition_quality(/datum/munition_quality), get_munition_filler(filler_type), factory = TRUE)

/obj/item/ship_weapon/ammunition/naval_artillery/factory
	/// Typ pocisku (/datum/munition_filler)
	var/factory_type = /datum/munition_filler/aphe

/obj/item/ship_weapon/ammunition/naval_artillery/factory/Initialize(mapload)
	. = ..()
	aq_apply_factory_munition(src, factory_type)

/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap
	factory_type = /datum/munition_filler/ap

/obj/item/ship_weapon/ammunition/naval_artillery/factory/he
	factory_type = /datum/munition_filler/he

/obj/item/ship_weapon/parts/broadside_casing/factory
	var/factory_type = /datum/munition_filler/aphe

/obj/item/ship_weapon/parts/broadside_casing/factory/Initialize(mapload)
	. = ..()
	aq_apply_factory_munition(src, factory_type)

/obj/item/ship_weapon/parts/broadside_casing/factory/ap
	factory_type = /datum/munition_filler/ap

/obj/item/ship_weapon/parts/broadside_casing/factory/he
	factory_type = /datum/munition_filler/he

/datum/supply_pack/munitions/railgun
	name = "Pociski artylerii okrętowej APHE (x10)"
	desc = "Pociski artylerii okrętowej typu APHE: pośrodku między przebiciem a obrażeniami. Przed strzałem trzeba je uzbroić. OSTRZEŻENIE: SILNIE WYBUCHOWE."
	contains = list(/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory)

/datum/supply_pack/munitions/railgun/ap
	name = "Pociski artylerii okrętowej AP (x10)"
	desc = "Przeciwpancerne pociski artylerii okrętowej na ciężko opancerzone okręty. Przed strzałem trzeba je uzbroić. OSTRZEŻENIE: SILNIE WYBUCHOWE."
	contains = list(/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap)

/datum/supply_pack/munitions/railgun/he
	name = "Pociski artylerii okrętowej HE (x10)"
	desc = "Odłamkowo-burzące pociski artylerii okrętowej na myśliwce i lekko opancerzone okręty. Przed strzałem trzeba je uzbroić. OSTRZEŻENIE: SILNIE WYBUCHOWE."
	contains = list(/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he,
					/obj/item/ship_weapon/ammunition/naval_artillery/factory/he)

/datum/supply_pack/munitions/broadside_casings
	name = "Puste łuski pocisków burtowych APHE"
	desc = "15 pustych łusek APHE do pocisków burtowych."
	contains = list(/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory)

/datum/supply_pack/munitions/broadside_casings/ap
	name = "Puste łuski pocisków burtowych AP"
	desc = "15 pustych łusek AP do pocisków burtowych."
	contains = list(/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap,
					/obj/item/ship_weapon/parts/broadside_casing/factory/ap)

/datum/supply_pack/munitions/broadside_casings/he
	name = "Puste łuski pocisków burtowych HE"
	desc = "15 pustych łusek HE do pocisków burtowych."
	contains = list(/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he,
					/obj/item/ship_weapon/parts/broadside_casing/factory/he)

/datum/supply_pack/munitions/broadside_pack
	contains = list(/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_load,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/ship_weapon/parts/broadside_casing/factory,
					/obj/item/powder_bag)

// ---------------------------------------------------------------- pakowarka burtówek

/obj/machinery/broadside_shell_packer
	/// Właściwości kuźni kolejnych łusek na stole (FALSE = zwykła łuska), w kolejności wkładania
	var/list/aq_casing_munitions

/// Wołane z load() tuż przed usunięciem łuski
/obj/machinery/broadside_shell_packer/proc/aq_store_casing_munition(obj/item/casing)
	var/datum/component/forged_munition/F = casing.GetComponent(/datum/component/forged_munition)
	LAZYADD(aq_casing_munitions, F ? list(list(F.material, F.quality, F.filler, F.galvanized, F.factory)) : FALSE)

/// Wołane z pack() dla każdego nowego pocisku
/obj/machinery/broadside_shell_packer/proc/aq_apply_casing_munition(obj/item/shell, index)
	if(!shell || index > LAZYLEN(aq_casing_munitions))
		return
	var/list/entry = aq_casing_munitions[index]
	if(!islist(entry))
		return
	apply_forged_munition(shell, entry[1], entry[2], entry[3], entry[4], entry[5])

/obj/machinery/broadside_shell_packer/reset()
	. = ..()
	aq_casing_munitions = null
