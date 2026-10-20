// Interkom z SS220 (ss220club/Paradise-SS220, grafiki CC BY-SA 3.0): 4 kierunki, dir = strona ściany, jak u nas w directional.
// Egzemplarze z ręcznym przesunięciem na mapie dostają kierunek z przesunięcia.
/obj/item/radio/intercom
	icon = 'aquila/icons/ss220/intercom.dmi'

/obj/item/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src)
	if(wall_dir)
		setDir(wall_dir)
