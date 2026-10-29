// AQUILA - Upiór kultu „Cult 4”. Bazowy typ jest nasz (code/modules/mob/living/simple_animal/constructs.dm),
// tu typ do limitów kultu i doskonały upiór z vg (ścieżki krwi zamiast runy teleportu).

/mob/living/simple_animal/hostile/construct/wraith
	construct_type = "Wraith"

/mob/living/simple_animal/hostile/construct/wraith/perfect
	icon = 'aquila/icons/bloodcult/mob.dmi'
	icon_state = "wraith2"
	icon_living = "wraith2"
	icon_dead = "wraith2"
	new_glow = TRUE
	see_in_dark = 7
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift,
		/datum/action/cooldown/spell/pointed/conjure/path_entrance,
		/datum/action/cooldown/spell/pointed/conjure/path_exit,
	)
