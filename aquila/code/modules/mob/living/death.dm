/mob/living/death(gibbed)
	var/was_dead_before = stat == DEAD
	. = ..()
	if(!was_dead_before && client && mind?.current)
		// After death() is done: a mob deleted on death (swarmer, gib, dust) has already handed the client to its ghost
		addtimer(CALLBACK(GLOB.death_info, TYPE_PROC_REF(/datum/death_info, show_to), client), 1)

GLOBAL_DATUM_INIT(death_info, /datum/death_info, new)

/// One shared datum behind every "Nie żyjesz" window, the window only shows static text
/datum/death_info

///Okienko z informacją, że gracz umarł i jak może wrócić do gry (tgui DeathInfo.tsx), na mobie, którym klient jest teraz
/datum/death_info/proc/show_to(client/player)
	if(player?.mob)
		ui_interact(player.mob)

/datum/death_info/ui_state(mob/user)
	return GLOB.always_state

/datum/death_info/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DeathInfo")
		ui.open()

/datum/death_info/ui_static_data(mob/user)
	return list(
		"norespawn" = CONFIG_GET(flag/norespawn),
	)
