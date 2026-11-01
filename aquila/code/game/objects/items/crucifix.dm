// AQUILA - krucyfiks przeniesiony ze starego heretyka (code/modules/antagonists/heretic/items/crucifix.dm)
/obj/item/clothing/neck/crucifix
	name = "krucyfiks"
	desc = "Na wypadek, gdyby któraś z fałszywie oskarżonych przez ciebie osób naprawdę okazała się czarownicą. Chroni przed jej klątwami."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/obj/objects.dmi'
	icon_state = "crucifix"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/crucifix/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_NECK && istype(user))
		ADD_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/clothing/neck/crucifix/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/clothing/neck/crucifix/rosary
	name = "różaniec"
	desc = "Drewniany krzyżyk, który odpędza klątwy i uroki."
	resistance_flags = FLAMMABLE
	icon_state = "rosary"
