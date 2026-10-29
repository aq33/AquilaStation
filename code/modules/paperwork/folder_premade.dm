/obj/item/folder/blue
	desc = "Niebieska teczka."
	icon_state = "folder_blue"
	bg_color = "#355e9f"

/obj/item/folder/red
	desc = "Czerwona teczka."
	icon_state = "folder_red"
	bg_color = "#b5002e"

/obj/item/folder/yellow
	desc = "Żółta teczka."
	icon_state = "folder_yellow"
	bg_color = "#b88f3d"

/obj/item/folder/white
	desc = "Biała teczka."
	icon_state = "folder_white"
	bg_color = "#d9d9d9"

/obj/item/folder/documents
	name = "teczka – „ŚCIŚLE TAJNE”"
	desc = "Teczka z pieczęcią „Ściśle tajne – własność korporacji Nanotrasen. Nieuprawnione rozpowszechnianie karane jest śmiercią”."

/obj/item/folder/documents/Initialize(mapload)
	. = ..()
	new /obj/item/documents/nanotrasen(src)
	update_icon()

/obj/item/folder/syndicate
	icon_state = "folder_syndie"
	bg_color = "#3f3f3f"
	name = "teczka – „ŚCIŚLE TAJNE”"
	desc = "Teczka z pieczęcią „Ściśle tajne – własność Syndykatu”."

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/red(src)
	update_icon()

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/blue(src)
	update_icon()

/obj/item/folder/syndicate/mining/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_icon()
