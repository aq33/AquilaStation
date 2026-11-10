// AQUILA - sprite'y z tg dla narzędzi i przedmiotów codziennych: stany w rękach, na pasku i wygląd pilota do drzwi

// Pilot do drzwi: własne stany z tg (door_remote_<dział>_<tryb> w icons/obj/device.dmi) zamiast gangtool-*,
// które dzielił z przedmiotami gangów. Wygląd zmienia się razem z trybem (otwieranie, rygle, dostęp awaryjny).
/obj/item/door_remote
	icon_state = "door_remote_civilian_open"
	/// Część nazwy stanu ikony; null = przedmiot ma własną grafikę i update_icon_state jej nie rusza
	var/remote_department = "civilian"

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/door_remote/update_icon_state()
	if(remote_department)
		icon_state = "door_remote_[remote_department]_[mode]"
	return ..()

/obj/item/door_remote/attack_self(mob/user)
	. = ..()
	update_icon()

/obj/item/door_remote/omni
	icon_state = "door_remote_omni_open"
	remote_department = "omni"

/obj/item/door_remote/captain
	icon_state = "door_remote_command_open"
	remote_department = "command"

/obj/item/door_remote/chief_engineer
	icon_state = "door_remote_engi_open"
	remote_department = "engi"

/obj/item/door_remote/research_director
	icon_state = "door_remote_sci_open"
	remote_department = "sci"

/obj/item/door_remote/head_of_security
	icon_state = "door_remote_security_open"
	remote_department = "security"

/obj/item/door_remote/quartermaster
	icon_state = "door_remote_cargo_open"
	remote_department = "cargo"

// Pilot ordynatora ma grafikę NFZ (aquila/code/modules/nfz/nfz.dm), zostaje bez zmian
/obj/item/door_remote/chief_medical_officer
	remote_department = null

/obj/item/door_remote/civillian
	icon_state = "door_remote_civilian_open"

/obj/item/door_remote/master_at_arms
	icon_state = "door_remote_security_open"
	remote_department = "security"

// Ręczny monitor załogi: w ręku i na pasku wspólny wygląd urządzenia elektronicznego jak w tg
/obj/item/sensor_device
	item_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

// Pinpointery na pasku (stany z tg w icons/mob/clothing/belt.dmi)
/obj/item/pinpointer
	worn_icon_state = "pinpointer"

/obj/item/pinpointer/crew
	worn_icon_state = "pinpointer_crew"

/obj/item/pinpointer/crew/contractor
	worn_icon_state = "pinpointer_black"

/obj/item/pinpointer/nuke/syndicate
	worn_icon_state = "pinpointer_black"

/obj/item/pinpointer/syndicate_cyborg
	worn_icon_state = "pinpointer_black"

/obj/item/pinpointer/shuttle
	worn_icon_state = "pinpointer_black"

// Szminka w ręku: zamknięta i otwarta jak w tg (stany lipstick i lipstickopen)
/obj/item/lipstick
	item_state = "lipstick"

/obj/item/lipstick/attack_self(mob/user)
	. = ..()
	item_state = open ? "lipstickopen" : "lipstick"
	user?.update_inv_hands()

// Wiertła górnicze mają w tg własne stany w ręku i na pasku (wcześniej używały stanów młota pneumatycznego)
/obj/item/pickaxe/drill
	item_state = "handdrill"
	worn_icon_state = "handdrill"

/obj/item/pickaxe/drill/diamonddrill
	item_state = "diamonddrill"
	worn_icon_state = "diamonddrill"

/obj/item/pickaxe/drill/cyborg/diamond
	item_state = "diamonddrill"
	worn_icon_state = "diamonddrill"
