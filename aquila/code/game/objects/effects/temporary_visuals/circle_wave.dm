/// Rozchodzący się pierścień (tg: /obj/effect/temp_visual/circle_wave). Kolor można podać przy tworzeniu.
/obj/effect/temp_visual/circle_wave
	icon = 'aquila/icons/effects/voidwalker_wave.dmi'
	icon_state = "circle_wave"
	pixel_x = -16
	pixel_y = -16
	duration = 0.5 SECONDS
	var/max_alpha = 255
	///How far the effect would scale in size
	var/amount_to_scale = 2

/obj/effect/temp_visual/circle_wave/Initialize(mapload, new_color)
	transform = matrix().Scale(0.1)
	animate(src, transform = matrix().Scale(amount_to_scale), time = duration, flags = ANIMATION_PARALLEL)
	animate(src, alpha = max_alpha, time = duration * 0.6, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = duration * 0.4)
	apply_wibbly_filters(src)
	if(!color)
		color = new_color || COLOR_LIME
	return ..()
