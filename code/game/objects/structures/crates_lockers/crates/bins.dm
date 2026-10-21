/obj/structure/closet/crate/bin
	desc = "A trash bin, place your trash here for the janitor to collect."
	name = "trash bin"
	icon_state = "trashbin" //AQUILA EDIT - Bee#10136 trash bin
	open_sound = 'sound/effects/bin_open.ogg'
	close_sound = 'sound/effects/bin_close.ogg'
	anchored = TRUE
	horizontal = FALSE
	delivery_icon = null

/obj/structure/closet/crate/bin/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/closet/crate/bin/update_icon()
	..()
	if(contents.len == 0)
		add_overlay("trashbin_empty")
	else if(contents.len >= storage_capacity)
		add_overlay("trashbin_full")
	else
		add_overlay("trashbin_some")

/obj/structure/closet/crate/bin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/T = W
		to_chat(user, "<span class='notice'>Napełniasz worek.</span>")
		for(var/obj/item/O in src)
			SEND_SIGNAL(T, COMSIG_TRY_STORAGE_INSERT, O, user, TRUE)
		T.update_icon()
		do_animate()
		return TRUE
	else
		return ..()

/obj/structure/closet/crate/bin/proc/do_animate()
	playsound(loc, open_sound, 15, 1, -3)
	addtimer(CALLBACK(src, PROC_REF(close)), 13)
