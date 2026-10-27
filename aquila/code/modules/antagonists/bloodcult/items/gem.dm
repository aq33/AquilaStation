/obj/item/soulstone/gem
	name = "klejnot dusz"
	desc = "Świeżo oszlifowany kamień, który zdaje się chwytać dusze tak samo jak odłamki Kamienia Dusz. Ten jednak oszlifowano do perfekcji."
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state = "soulstone"
	perfect = TRUE

/obj/item/soulstone/gem/update_icon_state()
	. = ..()
	var/mob/living/simple_animal/shade/shade = locate(/mob/living/simple_animal/shade) in contents
	if(shade)
		icon_state = "soulstone2"
	else
		icon_state = "soulstone"
