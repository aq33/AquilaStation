// Interkom z SS220 (ss220club/Paradise-SS220, grafiki CC BY-SA 3.0): 4 kierunki, dir = strona ściany, jak u nas w directional.
// Kierunek i przesunięcie bierze z przesunięcia na mapie paradise_wall_place() w przesuniecia.dm.
/obj/item/radio/intercom
	icon = 'aquila/icons/ss220/intercom.dmi'

// Nakładki SS220 zamiast intercom-mic/intercom-bc
/obj/item/radio/intercom/update_icon()
	. = ..()
	cut_overlays()
	if(listening)
		add_overlay("intercom_s")
	if(broadcasting)
		add_overlay("intercom_m")
