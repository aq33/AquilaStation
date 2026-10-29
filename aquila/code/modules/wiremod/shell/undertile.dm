/obj/item/undertile_circuit
	name = "circuit panel"
	desc = "Panel na układ scalony. Aby działał, trzeba go zamontować pod płytką podłogi."
	icon = 'aquila/icons/obj/wiremod/circuits.dmi'
	item_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	icon_state = "undertile"
	custom_materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 2.5, /datum/material/glass = (MINERAL_MATERIAL_AMOUNT / 2))

/obj/item/undertile_circuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_SMALL, SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT)

// U nas nie ma elementu undertile. Turf woła hide() na obiektach z level = 1, gdy kładzie się lub zdejmuje płytkę:
// pod płytką panel jest przykręcony (obudowa wymaga zakotwiczenia) i niewidoczny poza t-rayem.
/obj/item/undertile_circuit
	level = 1

/obj/item/undertile_circuit/hide(intact)
	var/covered = intact && isturf(loc)
	setAnchored(covered)
	invisibility = covered ? INVISIBILITY_OBSERVER : initial(invisibility)
	if(covered)
		ADD_TRAIT(src, TRAIT_T_RAY_VISIBLE, REF(src))
	else
		REMOVE_TRAIT(src, TRAIT_T_RAY_VISIBLE, REF(src))
