/*
Slimecrossing Mobs
	Mobs and effects added by the slimecrossing system.
	Collected here for clarity.
*/

//Slime transformation power - Burning Black
/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform
	name = "Przemiana w szlama"
	desc = "Zmień się z człowieka w szlama albo z powrotem!"
	action_icon_state = "transformslime"
	cooldown_min = 0
	charge_max = 0
	invocation_type = "none"
	shapeshift_type = /mob/living/simple_animal/slime/transformedslime
	convert_damage = TRUE
	convert_damage_type = CLONE
	var/remove_on_restore = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform/Restore(mob/living/M)
	if(remove_on_restore)
		if(M.mind)
			M.mind.RemoveSpell(src)
	..()

//Transformed slime - Burning Black
/mob/living/simple_animal/slime/transformedslime

/mob/living/simple_animal/slime/transformedslime/Reproduce() //Just in case.
	to_chat(src, "<span class='warning'>Nie mogę się rozmnażać...</span>")
	return

//Slime corgi - Chilling Pink
/mob/living/simple_animal/pet/dog/corgi/puppy/slime
	name = "\improper szlamowy szczeniak corgi"
	real_name = "szlamowy szczeniak corgi"
	desc = "Nieznośnie uroczy różowy szlamowy szczeniak corgi."
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	nofur = TRUE
	gold_core_spawnable = NO_SPAWN
	speak_emote = list("bulgocze", "bąbelkuje", "szczeka")
	emote_hear = list("bąbelkuje!", "chlupie.", "plaska!")
	emote_see = list("rozchlapuje maź dookoła.", "pada płasko.", "trzęsie się!")
