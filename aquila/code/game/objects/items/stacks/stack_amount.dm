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
	var/new_maptext = ""
	if(loc && (ismob(loc) || SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE)))
		new_maptext = MAPTEXT("<font color='white'>[get_amount()]</font>")
	// Stos na taśmociągu rusza się co tick: bez porównania każdy krok podmieniałby wygląd
	if(maptext != new_maptext)
		maptext = new_maptext

// Zwykły widok schowka czyści maptext przedmiotów przy każdym odświeżeniu. W trybie grupowania (display_numerical_stacking)
// liczba na ikonie to liczba zgrupowanych przedmiotów, więc tam jej nie ruszamy. Siatka ma to w swoim orient2hud()
/datum/component/storage/orient2hud()
	. = ..()
	if(display_numerical_stacking)
		return
	var/atom/real_location = real_location()
	for(var/obj/item/stack/stack in real_location)
		stack.update_amount_maptext()
