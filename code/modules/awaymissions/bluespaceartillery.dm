

/obj/machinery/artillerycontrol
	var/reload = 120
	var/reload_cooldown = 120
	var/explosiondev = 3
	var/explosionmed = 6
	var/explosionlight = 12
	name = "bluespace artillery control"
	icon_state = "control_boxp1"
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	density = TRUE

/obj/machinery/artillerycontrol/process(delta_time)
	if(reload < reload_cooldown)
		reload += delta_time

/obj/structure/artilleryplaceholder
	name = "artillery"
	icon = 'icons/obj/machines/artillery.dmi'
	anchored = TRUE
	density = TRUE

/obj/structure/artilleryplaceholder/decorative
	density = FALSE

/obj/machinery/artillerycontrol/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtilleryControl", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/artillerycontrol/ui_data(mob/user)
	var/list/data = list()
	data["reload"] = round(reload)
	data["reload_cooldown"] = reload_cooldown
	return data

/obj/machinery/artillerycontrol/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "fire")
		return
	var/A = tgui_input_list(usr, "Obszar do ostrzału", "Otwórz ogień", GLOB.teleportlocs)
	if(!A)
		return
	var/area/thearea = GLOB.teleportlocs[A]
	if(!thearea)
		return
	if(usr.stat || usr.restrained())
		return
	if(reload < reload_cooldown)
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		priority_announce("Wykryto ostrzał artylerii bluespace. Przygotować się na uderzenie.", sound = SSstation.announcer.get_rand_alert_sound())
		message_admins("[ADMIN_LOOKUPFLW(usr)] has launched an artillery strike.")
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			L+=T
		var/loc = pick(L)
		explosion(loc,explosiondev,explosionmed,explosionlight)
		reload = 0
	return TRUE
