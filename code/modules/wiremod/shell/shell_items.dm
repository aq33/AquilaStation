/**
 * # Shell Item
 *
 * Printed out by protolathes. Screwdriver to complete the shell.
 */
/obj/item/shell
	name = "obudowa"
	desc = "Obudowa, którą można dokończyć śrubokrętem."
	icon = 'icons/obj/wiremod.dmi'
	var/shell_to_spawn
	var/screw_delay = 3 SECONDS

/obj/item/shell/screwdriver_act(mob/living/user, obj/item/tool)
	user.visible_message("<span class='notice'>[user] zaczyna kończyć [src].</span>", "<span class='notice'>Zaczynasz kończyć [src].</span>")
	tool.play_tool_sound(src)
	if(!do_after(user, screw_delay, target = src))
		return
	user.visible_message("<span class='notice'>[user] kończy [src].</span>", "<span class='notice'>Kończysz [src].</span>")

	var/turf/drop_loc = drop_location()

	qdel(src)
	if(drop_loc)
		new shell_to_spawn(drop_loc)

	return TRUE

/obj/item/shell/bot
	name = "obudowa bota"
	icon_state = "setup_medium_box-open"
	shell_to_spawn = /obj/structure/bot

/obj/item/shell/money_bot
	name = "obudowa bota pieniężnego"
	icon_state = "setup_large-open"
	shell_to_spawn = /obj/structure/money_bot

/obj/item/shell/drone
	name = "obudowa drona"
	icon_state = "setup_medium_med-open"
	shell_to_spawn = /mob/living/circuit_drone

/obj/item/shell/server
	name = "obudowa serwera"
	icon_state = "setup_stationary-open"
	shell_to_spawn = /obj/structure/server
	screw_delay = 10 SECONDS

/obj/item/shell/airlock
	name = "obudowa śluzy z układem"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	shell_to_spawn = /obj/machinery/door/airlock/shell
	screw_delay = 10 SECONDS
