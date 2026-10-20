/*
	Export datum, so we can sell artifacts for dosh
*/

/datum/export/artifact
	unit_name = "xenoartifact"
	export_types = list(/obj/item/xenoartifact)

/datum/export/artifact/get_cost(obj/item/O, allowed_categories = NONE)
	cost = O.item_price
	return ..()

/datum/export/artifact/applies_to(obj/O, allowed_categories = NONE)
	. = ..()
	if(.)
		return
	//aquila: dowolny przedmiot z komponentem artefaktu (perły), ale z tymi samymi warunkami co bazowe applies_to
	if(!O.GetComponent(/datum/component/xenoartifact))
		return FALSE
	if((allowed_categories & export_category) != export_category)
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE
