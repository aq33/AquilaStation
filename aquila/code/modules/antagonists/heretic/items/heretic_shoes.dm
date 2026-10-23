/obj/item/clothing/shoes/greaves_of_the_prophet
	name = "joint-snap sabatons"
	desc = "Sabatony z chropowatego, zużytego żelaza. Stoją pewniej niż ziemia, po której stąpają. Pokrywa je cienka warstwa rdzy - a jednak jej widok przynosi dziwną ulgę."
	icon_state = "hereticgreaves"
	item_state = "hereticgreaves"
	worn_icon = 'aquila/icons/mob/clothing/feet_greaves.dmi'
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF
	// AQUILA - u nas odporność na poślizgi daje flaga NOSLIP i cecha TRAIT_NOSLIPALL
	clothing_flags = NOSLIP

/obj/item/clothing/shoes/greaves_of_the_prophet/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_FEET)
		ADD_TRAIT(user, TRAIT_NOSLIPALL, CLOTHING_TRAIT)

/obj/item/clothing/shoes/greaves_of_the_prophet/dropped(mob/user)
	REMOVE_TRAIT(user, TRAIT_NOSLIPALL, CLOTHING_TRAIT)
	return ..()
