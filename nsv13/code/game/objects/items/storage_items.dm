/*
This file contains various storage items in this order:

	ammo boxes
	normal boxes
	syndie kit boxes
	first aid/medikits
	reagent containers

*/

//Ammo Boxes

/obj/item/storage/toolbox/ammo/shotgun
	name = "pudełko z amunicją (śrut 12ga)"
	desc = "Zawiera kilka nabojów śrutowych."

/obj/item/storage/toolbox/ammo/shotgun/PopulateContents()
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)
	new /obj/item/ammo_casing/shotgun/buckshot(src)

/obj/item/storage/toolbox/ammo/shotgun/beanbag
	name = "pudełko z amunicją (beanbag 12ga)"
	desc = "Zawiera kilka pocisków typu beanbag."

/obj/item/storage/toolbox/ammo/shotgun/beanbag/PopulateContents()
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)

//Regular Boxes

/obj/item/storage/box/cookie
	name = "pudełko ciastek"
	desc = "Zawiera kilka ciastek dla grzecznych pacjentów."

/obj/item/storage/box/cookie/PopulateContents()
	new /obj/item/food/cookie( src )
	new /obj/item/food/cookie( src )
	new /obj/item/food/cookie( src )
	new /obj/item/food/cookie/oatmeal( src )
	new /obj/item/food/cookie/oatmeal( src )
	new /obj/item/food/cookie/sugar/spookyskull( src )
	new /obj/item/food/cookie/sugar/spookyskull( src )

/obj/item/storage/box/beakers/large_mix/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/beaker/large( src )
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/glass/beaker( src )

/obj/item/storage/box/suitbox/maid
	name = "pudełko kompresyjne ze strojami pokojówki"
	desc = "Zawiera najnowocześniejszy strój pokojówki."

/obj/item/storage/box/suitbox/maid/PopulateContents()
	new /obj/item/clothing/head/maidheadband(src)
	new /obj/item/clothing/neck/maid(src)
	new /obj/item/clothing/gloves/maid(src)
	new /obj/item/clothing/under/costume/maid(src)

/obj/item/storage/box/radiokey/mun
	name = "pudełko kluczy radiowych działu amunicji"
	desc = "Dają dostęp do radia działu amunicji i zaopatrzenia."
	radio_key = /obj/item/encryptionkey/munitions_tech

/obj/item/storage/box/radiokey/pilot
	name = "pudełko kluczy radiowych pilotów"
	desc = "Dają dostęp do radia Kontroli Lotów i działu amunicji."
	radio_key = /obj/item/encryptionkey/pilot

/obj/item/storage/box/squad_lanyards
	name = "zapasowe smycze drużyn"
	desc = "Pudełko pełne smyczy do przydzielania personelu do drużyn. Przemaluj je w konsoli zarządzania drużynami i rozdaj."
	icon = 'nsv13/icons/obj/storage.dmi'
	illustration = "lanyard"

/obj/item/storage/box/squad_lanyards/PopulateContents()
	generate_items_inside(list(/obj/item/clothing/neck/squad = 10),src)

//Syndie Kit Boxes

/obj/item/storage/box/syndie_kit/maid
	name = "awaryjny zestaw pokojówki"

/obj/item/storage/box/syndie_kit/maid/PopulateContents()
	new /obj/item/clothing/head/maidheadband/syndicate(src)
	new /obj/item/clothing/under/syndicate/maid(src)
	new /obj/item/clothing/gloves/combat/maid(src)
	new /obj/item/clothing/accessory/maidapron/syndicate(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/soap/syndie(src)
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/mop/sharp(src)

/obj/item/storage/box/syndie_kit/plushie
	name = "\improper zestaw „zrób to sam”: pluszobomba"

/obj/item/storage/box/syndie_kit/plushie/PopulateContents()
	new /obj/item/toy/plush/lfighter/synlfighter(src)
	new /obj/item/kitchen/knife/combat/survival(src)
	new /obj/item/grenade/syndieminibomb(src)
	new /obj/item/screwdriver(src)

//First aid kits

/obj/item/storage/firstaid/robot
	name = "zestaw do leczenia robotów"
	desc = "Służy do leczenia ran i dolegliwości robotycznych form życia."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "firstaid-robot"
	item_state = "firstaid-robot"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/medical_righthand.dmi'
	skin_type = MEDBOT_SKIN_ROBOT

/obj/item/storage/firstaid/robot/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-robot","firstaid-robotalt")

/obj/item/storage/firstaid/robot/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/weldingtool = 1,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/reagent_containers/hypospray/medipen/system_cleaner = 2,
		/obj/item/reagent_containers/glass/bottle/radioactive_disinfectant = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

//Reagent containers

/obj/item/reagent_containers/glass/bottle/solder
	name = "butelka lutu"
	label_name = "solder"
	desc = "Mała butelka. Zawiera płynny lut. Przydaje się do naprawy uszkodzeń syntetycznego mózgu."
	list_reagents = list(/datum/reagent/medicine/liquid_solder = 30)

/obj/item/reagent_containers/glass/bottle/radioactive_disinfectant
	name = "butelka środka odkażającego z promieniowania"
	label_name = "odkażacz radiacyjny"
	desc = "Mała butelka. Zawiera środek odkażający z promieniowania. Przydaje się do usuwania napromieniowania z syntetyków."
	list_reagents = list(/datum/reagent/medicine/radioactive_disinfectant = 30)

/obj/item/reagent_containers/glass/bottle/system_cleaner
	name = "butelka czyściciela systemu"
	label_name = "czyściciel systemu"
	desc = "Mała butelka. Zawiera czyściciel systemu. Przydaje się do usuwania toksycznych chemikaliów i toksyn z syntetyków."
	list_reagents = list(/datum/reagent/medicine/system_cleaner = 30)

/obj/item/reagent_containers/hypospray/medipen/system_cleaner
	name = "medipen z czyścicielem systemu"
	icon = 'nsv13/icons/obj/nsv13_syringe.dmi'
	icon_state = "syscleanpen"
	item_state = "syscleanpen"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "Autoinjektor z czyścicielem systemu, służący do szybkiego usuwania toksyn z syntetyków."
	list_reagents = list(/datum/reagent/medicine/system_cleaner = 10)
