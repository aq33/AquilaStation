
/obj/item/gps
	name = "system globalnego pozycjonowania"
	desc = "Pomaga zagubionym kosmonautom odnaleźć drogę między planetami od 2016 roku."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	obj_flags = UNIQUE_RENAME
	var/gpstag

/obj/item/gps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps/item, gpstag)

/obj/item/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "System pozycjonowania pomocny przy ratowaniu uwięzionych lub rannych górników. Noszenie go przy sobie podczas wydobycia może uratować ci życie."

/obj/item/gps/mining/exploration
	gpstag = "EXP0"
	desc = "System pozycjonowania do namierzania ważnych nadajników z dużej odległości."

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "Wewnętrzny system pozycjonowania cyborga górniczego. Służy jako nadajnik do odzyskiwania uszkodzonych cyborgów albo jako narzędzie współpracy ekip górniczych."

/obj/item/gps/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "System pozycjonowania pomocny przy ratowaniu uwięzionych lub rannych górników. Noszenie go przy sobie podczas wydobycia może uratować ci życie."

/obj/item/gps/visible_debug
	name = "widoczny GPS"
	gpstag = "ADMIN"
	desc = "Ten adminowski GPS zostawia widoczne współrzędne \
		na każdym polu, przez które przejdzie (do debugowania). Szczególnie przydatny \
		do oznaczania obszaru wokół krawędzi przejść."
	var/list/turf/tagged

/obj/item/gps/visible_debug/Initialize(mapload)
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = MAPTEXT("[T.x],[T.y],[T.get_virtual_z_level()]")
		tagged |= T

/obj/item/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()
