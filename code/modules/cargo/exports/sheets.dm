/datum/export/stack
	message = "ark."

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.amount
	return 0

// Hides

/datum/export/stack/skin/monkey
	cost = 50
	message = "szt. – skóra małpy"
	export_types = list(/obj/item/stack/sheet/animalhide/monkey)

/datum/export/stack/skin/human
	cost = 100
	export_category = EXPORT_CONTRABAND
	message = "szt. – ludzka skóra"
	export_types = list(/obj/item/stack/sheet/animalhide/human)

/datum/export/stack/skin/goliath_hide
	cost = 200
	message = "szt. – skóra goliata"
	export_types = list(/obj/item/stack/sheet/animalhide/goliath_hide)

/datum/export/stack/skin/cat
	cost = 150
	export_category = EXPORT_CONTRABAND
	message = "szt. – skóra kota"
	export_types = list(/obj/item/stack/sheet/animalhide/cat)

/datum/export/stack/skin/corgi
	cost = 200
	export_category = EXPORT_CONTRABAND
	message = "szt. – skóra corgi"
	export_types = list(/obj/item/stack/sheet/animalhide/corgi)

/datum/export/stack/skin/lizard
	cost = 150
	message = "szt. – skóra jaszczura"
	export_types = list(/obj/item/stack/sheet/animalhide/lizard)

/datum/export/stack/skin/gondola
	cost = 5000
	message = "szt. – skóra gondoli"
	export_types = list(/obj/item/stack/sheet/animalhide/gondola)

/datum/export/stack/skin/xeno
	cost = 500
	message = "szt. – skóra obcego"
	export_types = list(/obj/item/stack/sheet/animalhide/xeno)

// Common materials.
// For base materials, see materials.dm

/datum/export/stack/plasteel
	cost = 155 // 2000u of plasma + 2000u of iron.
	message = "ark. plastali"
	export_types = list(/obj/item/stack/sheet/plasteel)

// 1 glass + 0.5 iron, cost is rounded up.
/datum/export/stack/rglass
	cost = 8
	message = "ark. szkła zbrojonego"
	export_types = list(/obj/item/stack/sheet/rglass)

/datum/export/stack/bscrystal
	cost = 300
	message = "szt. – kryształ bluespace"
	export_types = list(/obj/item/stack/ore/bluespace_crystal)

/datum/export/stack/wood
	cost = 30
	message = "szt. – deska"
	export_types = list(/obj/item/stack/sheet/mineral/wood)

/datum/export/stack/cardboard
	cost = 2
	message = "ark. tektury"
	export_types = list(/obj/item/stack/sheet/cardboard)

/datum/export/stack/sandstone
	cost = 1
	message = "bl. piaskowca"
	export_types = list(/obj/item/stack/sheet/mineral/sandstone)

/datum/export/stack/cable
	cost = 0.2
	message = "odc. kabla"
	export_types = list(/obj/item/stack/cable_coil)

// Weird Stuff

/datum/export/stack/abductor
	cost = 1000
	message = "ark. stopu obcych"
	export_types = list(/obj/item/stack/sheet/mineral/abductor)

/datum/export/stack/adamantine
	cost = 500
	message = "szt. – sztabka adamantytu"
	export_types = list(/obj/item/stack/sheet/mineral/adamantine)

