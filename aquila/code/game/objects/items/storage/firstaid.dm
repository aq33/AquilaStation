// AQUILA: zestaw do leczenia robotów z nsv13/ wkłada 8 przedmiotów, a apteczka ma 7 miejsc
/obj/item/storage/firstaid/robot/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8
