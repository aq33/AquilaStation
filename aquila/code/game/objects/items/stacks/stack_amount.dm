// AQUILA - liczba sztuk na stosie w ekwipunku (port z tgstation/tgstation, /obj/item/stack/update_name)
// Biała cyfra w rogu ikony, gdy stos jest w rękach, na postaci albo w plecaku. Na podłodze jej nie ma.

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	update_amount_maptext()

/obj/item/stack/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	update_amount_maptext()

/obj/item/stack/update_icon()
	. = ..()
	update_amount_maptext()

/obj/item/stack/use(used, transfer = FALSE, check = TRUE)
	. = ..()
	if(!QDELETED(src))
		update_amount_maptext()

/obj/item/stack/proc/update_amount_maptext()
	if(loc && (ismob(loc) || SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE)))
		maptext = MAPTEXT("<font color='white'>[get_amount()]</font>")
	else
		maptext = ""
