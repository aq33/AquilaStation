
/obj/effect/rooting_trap/bloodnail
	name = "krwawy gwóźdź"
	desc = "Spiczasty czerwony gwóźdź, który zdaje się przebijać nie to, na czym spoczywa, lecz samą tkankę rzeczywistości."
	icon_state = "bloodnail"
	icon = 'aquila/icons/bloodcult/effects.dmi'

/obj/effect/rooting_trap/bloodnail/New()
	..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/effect/rooting_trap/bloodnail/stick_to(atom/A, side = null)
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)
	var/turf/T = get_turf(A)
	. = ..()
	if (.)
		visible_message(span_warning("[capitalize(src.name)] przybija [A] do [T].") )
