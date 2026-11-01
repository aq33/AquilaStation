
//Boat

/obj/vehicle/ridden/lavaboat
	name = "łódź lawowa"
	desc = "Łódź do przeprawy przez lawę."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	can_buckle = TRUE
	legs_required = 0
	arms_required = 0

/obj/vehicle/ridden/lavaboat/Initialize(mapload)
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.keytype = /obj/item/oar
	D.allowed_turf_typecache = typecacheof(/turf/open/lava)

/obj/item/oar
	name = "wiosło"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "oar"
	item_state = "oar"
	lefthand_file = 'icons/mob/inhands/misc/lavaland_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/lavaland_righthand.dmi'
	desc = "Nie myl z tym, o które ciągle męczy cię dział naukowy."
	force = 12
	block_upgrade_walk = 1
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "Wiosło z kości goliata"
	result = /obj/item/oar
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 15
	category = CAT_PRIMAL

/datum/crafting_recipe/boat
	name = "Łódź ze skóry goliata"
	result = /obj/vehicle/ridden/lavaboat
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 50
	category = CAT_PRIMAL

//Dragon Boat


/obj/item/ship_in_a_bottle
	name = "statek w butelce"
	desc = "Malutki statek w butelce."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	to_chat(user, "Nie wiesz, jak wkładają statki do tych rzeczy, ale chyba wiesz, jak go stamtąd wyjąć.")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	new /obj/vehicle/ridden/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/ridden/lavaboat/dragon
	name = "tajemnicza łódź"
	desc = "Ta łódź płynie tam, dokąd zechcesz, bez potrzeby wiosłowania."
	icon_state = "dragon_boat"

/obj/vehicle/ridden/lavaboat/dragon/Initialize(mapload)
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 2), TEXT_SOUTH = list(1, 2), TEXT_EAST = list(1, 2), TEXT_WEST = list( 1, 2)))
	D.keytype = null
