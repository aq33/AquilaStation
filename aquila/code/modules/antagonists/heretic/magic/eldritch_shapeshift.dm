// Given to heretic monsters.
/datum/action/cooldown/spell/shapeshift/eldritch
	name = "Shapechange"
	desc = "Zaklęcie, które pozwala przybrać postać innego stworzenia i zyskać jego zdolności. \
		Po dokonaniu wyboru nie możesz go już zmienić."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"

	school = SCHOOL_FORBIDDEN
	invocation = "SH'PE."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	// AQUILA - u nas te zwierzęta i boty to simple_animal
	possible_shapes = list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/bot/secbot,
	)
