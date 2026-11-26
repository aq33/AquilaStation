/// AQUILA - szafka kontroli uszkodzeń przy grodziach („Damage Control Coordination”, Alpha 3 z roadmapy NSV): sprzęt,
/// którym załoga łata wyłomy i gasi pożary, zanim dojdą ekipy inżynierii. Stoi w korytarzach przy drzwiach pożarowych.
/obj/structure/closet/damage_control
	name = "szafka kontroli uszkodzeń"
	desc = "Szafka przy grodzi z gaśnicami, nadmuchiwanymi ścianami do łatania wyłomów, uszczelniaczem i taśmą."
	icon_door = "yellow"
	anchored = TRUE

/obj/structure/closet/damage_control/PopulateContents()
	..()
	new /obj/item/extinguisher(src)
	new /obj/item/extinguisher/advanced/hull_repair_juice(src)
	for(var/i in 1 to 3)
		new /obj/item/inflatable(src)
	new /obj/item/sealant(src)
	new /obj/item/stack/sticky_tape(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
