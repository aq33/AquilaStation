// Port BeeStation/BeeStation-Hornet#14750 (code/game/objects/effects/sprint_dust.dm).
// Ikona z goon/icons/obj/effects.dmi z Bee (Goonstation, CC BY-NC-SA 3.0), u nas w aquila/icons/effects/sprint_dust.dmi.

/obj/effect/sprint_dust
	icon = 'aquila/icons/effects/sprint_dust.dmi'
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/sprint_dust/proc/appear(state, dir, turf/T, duration)
	if(!T)
		return
	if(state == "sprint_cloud")
		src.dir = SOUTH
	else
		src.dir = dir
	abstract_move(T)
	flick(state, src)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, moveToNullspace)), duration, TIMER_UNIQUE | TIMER_OVERRIDE)
