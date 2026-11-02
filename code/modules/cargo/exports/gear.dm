/datum/export/gear

/datum/export/gear/sec_helmet
	cost = 100
	unit_name = "hełm ochrony"
	export_types = list(/obj/item/clothing/head/helmet/sec)

/datum/export/gear/sec_armor
	cost = 100
	unit_name = "kamizelka kuloodporna"
	export_types = list(/obj/item/clothing/suit/armor/vest)

/datum/export/gear/riot_shield
	cost = 100
	unit_name = "tarcza prewencyjna"
	export_types = list(/obj/item/shield/riot)


/datum/export/gear/mask/breath
	cost = 2
	unit_name = "maska oddechowa"
	export_types = list(/obj/item/clothing/mask/breath)

/datum/export/gear/mask/gas
	cost = 10
	unit_name = "maska gazowa"
	export_types = list(/obj/item/clothing/mask/gas)
	include_subtypes = FALSE


/datum/export/gear/space/helmet
	cost = 75
	unit_name = "hełm kosmiczny"
	export_types = list(/obj/item/clothing/head/helmet/space, /obj/item/clothing/head/helmet/space/eva, /obj/item/clothing/head/helmet/space/nasavoid)
	include_subtypes = FALSE

/datum/export/gear/space/suit
	cost = 150
	unit_name = "skafander kosmiczny"
	export_types = list(/obj/item/clothing/suit/space, /obj/item/clothing/suit/space/eva, /obj/item/clothing/suit/space/nasavoid)
	include_subtypes = FALSE


/datum/export/gear/space/syndiehelmet
	cost = 150
	unit_name = "hełm kosmiczny Syndykatu"
	export_types = list(/obj/item/clothing/head/helmet/space/syndicate)

/datum/export/gear/space/syndiesuit
	cost = 300
	unit_name = "skafander kosmiczny Syndykatu"
	export_types = list(/obj/item/clothing/suit/space/syndicate)


/datum/export/gear/radhelmet
	cost = 50
	unit_name = "kaptur przeciwradiacyjny"
	export_types = list(/obj/item/clothing/head/radiation)

/datum/export/gear/radsuit
	cost = 100
	unit_name = "kombinezon przeciwradiacyjny"
	export_types = list(/obj/item/clothing/suit/radiation)

/datum/export/gear/biohood
	cost = 50
	unit_name = "kaptur biologiczny"
	export_types = list(/obj/item/clothing/head/bio_hood)

/datum/export/gear/biosuit
	cost = 100
	unit_name = "kombinezon biologiczny"
	export_types = list(/obj/item/clothing/suit/bio_suit)

/datum/export/gear/bombhelmet
	cost = 50
	unit_name = "kaptur saperski"
	export_types = list(/obj/item/clothing/head/bomb_hood)

/datum/export/gear/bombsuit
	cost = 100
	unit_name = "kombinezon saperski"
	export_types = list(/obj/item/clothing/suit/bomb_suit)

/datum/export/gear/goldpda
	cost = 500
	unit_name = "eleganckie PDA"
	export_types = list(/obj/item/modular_computer/tablet/pda/vip)

/datum/export/gear/envirosuitvip
	cost = 4500
	unit_name = "designerski kombinezon ochronny"
	export_types = list(/obj/item/clothing/under/plasmaman/gold, /obj/item/clothing/head/helmet/space/plasmaman/gold)
