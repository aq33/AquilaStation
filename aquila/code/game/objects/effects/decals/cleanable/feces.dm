/obj/effect/decal/cleanable/feces
	name = "odchody"
	desc = "Brązowe, śmierdzące i śliskie. Równie dobrze mogłoby to być danie kucharza."
	icon = 'aquila/icons/effects/feces.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_POOP
	bloodiness = BLOOD_AMOUNT_PER_DECAL

/obj/effect/decal/cleanable/feces/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddComponent(/datum/component/slippery, BLOOD_SLIPPERY_KNOCKDOWN, NO_SLIP_WHEN_WALKING)
