// AQUILA - sprzęt miejsca zbrodni dla detektywa.

/datum/outfit/job/detective
	l_pocket = /obj/item/toy/crayon/white/chalk

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/storage/box/csi_markers(src)
	new /obj/item/barrier_tape_roll(src)
	new /obj/item/holosign_creator/detective(src)
	new /obj/item/toy/crayon/white/chalk(src)
	new /obj/item/aq_uv_light(src) // lampa UV (uv_light.dm)
	new /obj/item/clothing/glasses/hud/security/sunglasses/aq_investigation(src) // okulary śledcze (eye_tracking.dm)
	new /obj/item/pinpointer/aq_bloodtrak(src) // BloodTrak (bloodtrak.dm)
