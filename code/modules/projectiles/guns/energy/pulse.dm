/obj/item/gun/energy/pulse
	name = "karabin pulsacyjny"
	desc = "Wytrzymały, wszechstronny karabin energetyczny z trzema trybami. Ulubiona broń żołnierzy z pierwszej linii."
	icon_state = "pulse"
	item_state = null
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	modifystate = TRUE
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	cell_type = "/obj/item/stock_parts/cell/pulse"
	fire_rate = 3
	automatic = 1

/obj/item/gun/energy/pulse/prize
	pin = /obj/item/firing_pin

/obj/item/gun/energy/pulse/prize/Initialize(mapload)
	. = ..()
	GLOB.poi_list += src
	var/turf/T = get_turf(src)

	message_admins("Nagroda w postaci karabinu pulsacyjnego pojawiła się w [ADMIN_VERBOSEJMP(T)]")
	log_game("A pulse rifle prize has been created at [AREACOORD(T)]")

	notify_ghosts("Ktoś wygrał karabin pulsacyjny w nagrodę!", source = src, action = NOTIFY_ORBIT, header = "Nagroda: karabin pulsacyjny")

/obj/item/gun/energy/pulse/prize/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/item/gun/energy/pulse/loyalpin
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/energy/pulse/carbine
	name = "karabinek pulsacyjny"
	desc = "Kompaktowa odmiana karabinu pulsacyjnego: słabsza siła ognia, ale łatwiej ją schować."
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	icon_state = "pulse_carbine"
	item_state = null
	cell_type = "/obj/item/stock_parts/cell/pulse/carbine"
	can_flashlight = TRUE
	flight_x_offset = 18
	flight_y_offset = 12

/obj/item/gun/energy/pulse/carbine/loyalpin
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/energy/pulse/carbine/cyborg
	name = "karabinek pulsacyjny"
	desc = "Kompaktowa wersja popularnego karabinka pulsacyjnego dla cyborgów."
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	icon_state = "pulse_carbine"
	item_state = null
	cell_type = "/obj/item/stock_parts/cell/pulse/carbine"
	can_flashlight = TRUE
	flight_x_offset = 18
	flight_y_offset = 12


/obj/item/gun/energy/pulse/pistol
	name = "pistolet pulsacyjny"
	desc = "Karabin pulsacyjny zamknięty w łatwym do ukrycia pistolecie o małej pojemności."
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	icon_state = "pulse_pistol"
	item_state = "gun"
	cell_type = "/obj/item/stock_parts/cell/pulse/pistol"
	automatic = 0
	fire_rate = 1.5
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/energy/pulse/pistol/loyalpin
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/energy/pulse/destroyer
	name = "niszczyciel pulsacyjny"
	desc = "Wytrzymały karabin energetyczny stworzony do czystego niszczenia."
	cell_type = "/obj/item/stock_parts/cell/infinite"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse)

/obj/item/gun/energy/pulse/destroyer/attack_self(mob/living/user)
	to_chat(user, "<span class='danger'>[src.name] ma trzy tryby i wszystkie to ZNISZCZ.</span>")

/obj/item/gun/energy/pulse/pistol/m1911
	name = "\improper M1911-P"
	desc = "Kompaktowy rdzeń pulsacyjny w klasycznej ramie pistoletu dla oficerów Nanotrasen. Nie liczy się rozmiar broni, tylko rozmiar dziury, którą robi w ludziach."
	icon_state = "m1911"
	item_state = "gun"
	cell_type = "/obj/item/stock_parts/cell/infinite"
