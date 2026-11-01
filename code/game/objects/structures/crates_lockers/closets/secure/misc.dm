/obj/structure/closet/secure_closet/ertCom
	name = "szafka Dowódcy Zespołu Reagowania Kryzysowego"
	desc = "Szafka ze sprzętem dla Dowódcy Zespołu Reagowania Kryzysowego."
	req_access = list(ACCESS_CENT_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/ertCom/PopulateContents()
	..()
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/box/handcuffs(src)
	new /obj/item/aicard(src)
	new /obj/item/assembly/flash/handheld(src)
	if(prob(50))
		new /obj/item/ammo_box/magazine/m50(src)
		new /obj/item/ammo_box/magazine/m50(src)
		new /obj/item/gun/ballistic/automatic/pistol/deagle(src)
	else
		new /obj/item/ammo_box/a357(src)
		new /obj/item/ammo_box/a357(src)
		new /obj/item/gun/ballistic/revolver/mateba(src)

/obj/structure/closet/secure_closet/ertSec
	name = "szafka Operatora Kryzysowego Reagowania"
	desc = "Szafka ze sprzętem dla Operatora Kryzysowego Reagowania."
	req_access = list(ACCESS_CENT_SPECOPS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/ertSec/PopulateContents()
	..()
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/box/flashes(src)
	new /obj/item/storage/box/handcuffs(src)
	new /obj/item/shield/riot/tele(src)

/obj/structure/closet/secure_closet/ertMed
	name = "szafka Sanitariusza Kryzysowego Reagowania"
	desc = "Szafka ze sprzętem dla Sanitariusza Kryzysowego Reagowania."
	req_access = list(ACCESS_CENT_MEDICAL)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/ertMed/PopulateContents()
	..()
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/firstaid/brute(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /mob/living/simple_animal/bot/medbot(src)

/obj/structure/closet/secure_closet/ertEngi
	name = "szafka Inżyniera Kryzysowego Reagowania"
	desc = "Szafka ze sprzętem dla Inżyniera Kryzysowego Reagowania."
	req_access = list(ACCESS_CENT_STORAGE)
	icon_state = "ce"

/obj/structure/closet/secure_closet/ertEngi/PopulateContents()
	..()
	new /obj/item/stack/sheet/plasteel(src, 50)
	new /obj/item/stack/sheet/iron(src, 50)
	new /obj/item/stack/sheet/glass(src, 50)
	new /obj/item/stack/sheet/mineral/sandbags(src, 30)
	new /obj/item/clothing/shoes/magboots(src)
	new /obj/item/storage/box/smart_metal_foam(src)
	for(var/i in 1 to 3)
		new /obj/item/rcd_ammo/large(src)
