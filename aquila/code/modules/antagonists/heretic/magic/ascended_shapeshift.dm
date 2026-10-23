// Given to ascended knock heretics, is a form of shapeshift that can turn into all 4 common heretic summons, and is not limited to 1 selection.
/datum/action/cooldown/spell/shapeshift/eldritch/ascension
	name = "Ascended Shapechange"
	desc = "Zaklęcie, które pozwala przybrać postać innej istoty z Mansusa i zyskać jej zdolności. \
		Wybór możesz zmienić w dowolnej chwili, a gdy twoja forma zginie, ty przeżyjesz."
	cooldown_time = 20 SECONDS
	convert_damage = FALSE
	die_with_shapeshifted_form = FALSE
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "lock_ascension"
	possible_shapes = list(
		/mob/living/simple_animal/hostile/heretic_summon/ash_spirit,
		/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ascended,
		/mob/living/simple_animal/hostile/heretic_summon/rust_walker,
		/mob/living/simple_animal/hostile/heretic_summon/stalker,
	)

/datum/action/cooldown/spell/shapeshift/eldritch/ascension/do_shapeshift(mob/living/caster)
	. = ..()
	if(!.)
		return
	//buff our forms so this ascension ability isnt shit
	playsound(caster, 'sound/magic/demon_consume.ogg', 50, TRUE)
	var/mob/living/monster = .
	// AQUILA - bez seethrough_mob (u nas brak); tg daje losowe obrażenia między upper/2 a max(lower*2, 40),
	// u nas jedna wartość melee_damage, więc bierzemy średnią z tego zakresu
	monster.maxHealth *= 1.5
	monster.health = monster.maxHealth
	monster.melee_damage = round((max(monster.melee_damage * 2, 40) + monster.melee_damage / 2) / 2)
	monster.transform *= 1.5
	// AQUILA - zamiast elementu wall_tearer: niszczenie ścian (także wzmocnionych) atakiem simple_animal
	if(isanimal(monster))
		var/mob/living/simple_animal/animal_monster = monster
		animal_monster.environment_smash |= ENVIRONMENT_SMASH_STRUCTURES | ENVIRONMENT_SMASH_WALLS | ENVIRONMENT_SMASH_RWALLS

/datum/action/cooldown/spell/shapeshift/eldritch/ascension/do_unshapeshift(mob/living/caster)
	. = ..()
	shapeshift_type = null //pick another loser
