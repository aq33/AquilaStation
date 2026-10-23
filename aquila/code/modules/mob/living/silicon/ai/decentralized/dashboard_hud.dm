/atom/movable/screen/ai/dashboard
	name = "Panel przetwarzania"
	icon = 'aquila/icons/mob/ai_servers_ui.dmi'
	icon_state = "dashboard"

/atom/movable/screen/ai/dashboard/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	if(!istype(AI) || !AI.dashboard)
		return
	AI.dashboard.ui_interact(AI)

/datum/hud/ai/New(mob/owner)
	. = ..()
	var/atom/movable/screen/using = new /atom/movable/screen/ai/dashboard()
	using.screen_loc = "SOUTH:6,WEST+16"
	using.hud = src
	static_inventory += using

/mob/living/silicon/ai/verb/open_ai_dashboard()
	set category = "AI Commands"
	set name = "Panel przetwarzania"
	if(incapacitated() || !dashboard)
		return
	dashboard.ui_interact(src)
