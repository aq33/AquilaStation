/obj/item/ship_weapon/parts //Base item
	name = "elektronika broni"
	desc = "Ten sprzęt to wytwór twojej wyobraźni. Daj znać koderom, jak go zdobyłeś!"
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/**
 * Firing electronics - used in construction of <s>new</s> old munitions machinery
 */
/obj/item/ship_weapon/parts/firing_electronics
	name = "elektronika spustowa"
	desc = "Układ spustowy dużej broni."
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"

/obj/item/ship_weapon/parts/firing_electronics/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

//Almost all of the ship weapon parts are supposed to be destroyed a LOT, this is the only one where that is not the case.
/obj/item/ship_weapon/parts/firing_electronics/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()


/**
 * Railgun loading tray
 */
/obj/item/ship_weapon/parts/loading_tray
	name = "podajnik"
	desc = "Podajnik do dużej broni."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_tray"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/loading_tray/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/**
 * Railgun rail
 */
/obj/item/ship_weapon/parts/railgun_rail
	name = "szyna działa szynowego"
	desc = "Magnetyczna szyna do działa szynowego."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "railgun_rail"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/railgun_rail/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/**
 * MAC Barrel
 */
/obj/item/ship_weapon/parts/mac_barrel
	name = "lufa MAC"
	desc = "Lufa do działa MAC."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "mac_barrel"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'

/obj/item/ship_weapon/parts/mac_barrel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ship_weapon/parts/broadside_casing
	name = "łuska pocisku burtowego"
	desc = "Pusta łuska do działa burtowego. Załaduj ją do pakowarki pocisków!"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "broadside_casing"

/obj/item/ship_weapon/parts/broadside_load
	name = "ładunek pocisku burtowego"
	desc = "Luźny ładunek do pocisku burtowego. Załaduj go do pakowarki pocisków!"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "broadside_load"

/obj/item/ship_weapon/parts/broadside_load/uranium
	name = "ładunek pocisku burtowego ze zubożonego uranu"
	desc = "Luźny ładunek do pocisku burtowego. Załaduj go do pakowarki pocisków! Ten jest <i>wyjątkowo</i> ciężki."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "broadside_load_uranium"
