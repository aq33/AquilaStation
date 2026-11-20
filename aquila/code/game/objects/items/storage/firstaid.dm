// AQUILA: zestaw do leczenia robotów z nsv13/ wkłada 8 przedmiotów, do tego nanopasta (AquilaMed 5), a apteczka ma 7 miejsc
/obj/item/storage/firstaid/robot/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 9

/obj/item/storage/firstaid/robot/PopulateContents()
	. = ..()
	if(!empty)
		new /obj/item/stack/medical/nanopaste(src)
