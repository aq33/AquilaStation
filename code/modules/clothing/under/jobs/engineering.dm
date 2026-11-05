//Contains: Engineering department jumpsuits
/obj/item/clothing/under/rank/engineering/chief_engineer
	desc = "Odblaskowy kombinezon dla inżynierów na tyle szalonych, by dosłużyć się stanowiska głównego inżyniera. Ma słabą osłonę przed promieniowaniem."
	name = "kombinezon głównego inżyniera"
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi' //NSV13
	worn_icon = 'nsv13/icons/mob/uniform.dmi' //NSV13
	icon_state = "legacy_chiefengineer" //NSV13
	item_state = "gy_suit"	//TODO replace it
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 80, "acid" = 40, "stamina" = 0, "bleed" = 10)
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/atmospheric_technician
	desc = "Kombinezon noszony przez techników atmosferyki."
	name = "kombinezon technika atmosferyki"
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi' //NSV13
	worn_icon = 'nsv13/icons/mob/uniform.dmi' //NSV13
	icon_state = "legacy_atmos" //NSV13
	item_state = "atmos_suit"
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/engineer
	desc = "Pomarańczowy odblaskowy kombinezon noszony przez inżynierów. Ma słabą osłonę przed promieniowaniem."
	name = "kombinezon inżyniera"
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi' //NSV13
	worn_icon = 'nsv13/icons/mob/uniform.dmi' //NSV13
	icon_state = "legacy_engine" //NSV13
	item_state = "engi_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 60, "acid" = 20, "stamina" = 0, "bleed" = 10)
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/engineer/hazard
	name = "ostrzegawczy kombinezon inżyniera"
	desc = "Dobrze widoczny kombinezon z materiałów odpornych na ciepło i promieniowanie."
	icon = 'icons/obj/clothing/uniforms.dmi' //NSV13
	worn_icon = 'icons/mob/uniform.dmi' //NSV13
	icon_state = "hazard"
	item_state = "suit-orange"
	alt_covers_chest = TRUE

