/// AQUILA - szafka kontroli uszkodzeń (aquila/code/modules/overmap/damage_control/dc_locker.dm): gaśnice, łatki,
/// uszczelniacz i taśma do łatania wyłomów, zanim dojdą ekipy inżynierii.
/datum/unit_test/aquila_damage_control

/datum/unit_test/aquila_damage_control/Run()
	var/obj/structure/closet/damage_control/locker = allocate(/obj/structure/closet/damage_control)
	var/inflatables = 0
	for(var/obj/item/inflatable/patch in locker)
		inflatables++
	if(!(locate(/obj/item/extinguisher) in locker) || inflatables < 3 || !(locate(/obj/item/sealant) in locker) || !(locate(/obj/item/stack/sticky_tape) in locker))
		return Fail("Szafka kontroli uszkodzeń nie ma gaśnicy, trzech łatek, uszczelniacza i taśmy")
