/**********************Mining Equipment Vendor Items**************************/
//misc stuff you can buy from the vendor that has special code but doesn't really need its own file

/**********************Facehugger toy**********************/
/obj/item/clothing/mask/facehugger/toy
	item_state = "facehugger_inactive"
	desc = "Zabawka, którą górnicy robią sobie psikusy, wkładając ją innym do łóżek. Po przyczepieniu się do czegoś potrzebuje chwili na naładowanie."
	throwforce = 0
	real = 0
	sterile = 1
	tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/Die()
	return
