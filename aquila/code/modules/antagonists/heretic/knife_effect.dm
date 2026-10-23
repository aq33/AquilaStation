// "Floating ghost blade" effect for blade heretics
/obj/effect/floating_blade
	name = "knife"
	icon = 'aquila/icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	layer = LOW_MOB_LAYER
	/// The color the knife glows around it.
	var/glow_color = "#ececff"

/obj/effect/floating_blade/Initialize(mapload)
	. = ..()
	// AQUILA - tg: element movetype_handler + TRAIT_MOVE_FLYING; u nas typ ruchu ustawiamy wprost
	setMovetype(movement_type | FLYING)
	add_filter("dio_knife", 2, list("type" = "outline", "color" = glow_color, "size" = 1))

/obj/effect/floating_blade/haunted
	icon = 'aquila/icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
