/mob/living/simple_animal/hostile/retaliate/spaceman
	name = "kosmonauta"
	desc = "Co to, do diabła, jest..?"
	icon_state = "old"
	icon_living = "old"
	icon_dead = "old_dead"
	icon_gib = "clown_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	gender = MALE
	turns_per_move = 5
	response_help = "szturcha"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm = "uderza"
	combat_mode = TRUE
	maxHealth = 100
	health = 100
	speed = 0
	melee_damage = 10
	attacktext = "uderza"
	attack_sound = 'sound/weapons/punch1.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = FALSE

	do_footstep = TRUE

// AQ EDIT - basic moby: pokojowi ochroniarze Nanotrasen to /mob/living/basic/trooper/nanotrasen/peaceful (aquila/code/modules/mob/living/basic/trooper/nanotrasen.dm)
