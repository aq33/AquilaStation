//Ship piloting console, most of the code is already in ship.dm
/obj/machinery/computer/ship/helm
	name = "konsola sterowania lotem Seegson model HLM"
	desc = "Skomputeryzowany pakiet pilotażowy, który pozwala ustawić prędkość, położenie, kurs statku i nie tylko!"
	icon_screen = "helm"
	position = OVERMAP_USER_ROLE_PILOT
	circuit = /obj/item/circuitboard/computer/ship/helm

/obj/machinery/computer/ship/helm/syndicate
	req_one_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/ship/helm/Destroy()
	if(linked && linked.helm == src)
		linked.helm = null
	return ..()

/obj/machinery/computer/ship/helm/set_position(obj/structure/overmap/OM)
	OM.helm = src
	return

/**
	Allows boarding pilots to toggle autopilot! This is locked to boarding ships for obvious reasons...
*/

/obj/machinery/computer/ship/helm/multitool_act(mob/living/user, obj/item/I)
	if(!linked)
		linked = get_overmap()
	if(linked && allowed(user) && linked.role <= NORMAL_OVERMAP && initial(linked.ai_controlled))
		linked.ai_controlled = !linked.ai_controlled
		playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
		to_chat(user, "<span class='warning'>Autopilot [linked.ai_controlled ? "włączony" : "wyłączony"].</span>")
	..()
	return TRUE

// Helm and tactical in one console, useful for debugging
// This console should not be made available for the player ship, looking at you mappers
/obj/machinery/computer/ship/helm/allinone
	name = "statek debugowy"
	desc = "Nie powinieneś tego widzieć."
	color = "red"

/obj/machinery/computer/ship/helm/allinone/ui_interact(mob/user)
	. = ..()
	if(!linked.gunner && isliving(user))
		linked.gunner = user
