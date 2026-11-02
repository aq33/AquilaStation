/obj/effect/abstract/ripple
	name = "zmarszczka nadprzestrzeni"
	desc = "Coś nadlatuje przez nadprzestrzeń, widać zakłócenia \
		obrazu. Lepiej nie stać na nich, \
		kiedy to, co przebija się tunelem, dotrze na miejsce."
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo"
	anchored = TRUE
	density = FALSE
	layer = RIPPLE_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON
	alpha = 0

/obj/effect/abstract/ripple/Initialize(mapload, time_left)
	. = ..()
	animate(src, alpha=255, time=time_left)
	addtimer(CALLBACK(src, PROC_REF(stop_animation)), 8, TIMER_CLIENT_TIME)

/obj/effect/abstract/ripple/proc/stop_animation()
	icon_state = "medi_holo_no_anim"
