/obj/item/clothing/suit/hooded/aquila/ghostcostume
	name = "straszliwy kostium ducha"
	desc = "Kostium straszliwego kostiumu ducha."
	icon_state = "ghostcostume"
	hoodtype = /obj/item/clothing/head/hooded/aquila/huge/ghostcosstumehood
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/aquila/ghostcostume/Initialize(mapload)
	. = ..()
	allowed = GLOB.civilian_storage_allowed

// Kosmobagiety - kurtka Komendanta, te same statystyki co kurtka peacekeepera
/obj/item/clothing/suit/ship/peacekeeper/jacket/police
	name = "kurtka Komendanta"
	desc = "Granatowa kurtka policyjna z insygniami Komendanta. Mimo ciężkiego opancerzenia nosi się ją niezwykle wygodnie."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "hosbluejacket"
	item_state = "hostrench"
