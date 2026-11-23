// AQ EDIT START - basic moby: agenci Syndykatu, wypruwacz i cywile przeszli na /mob/living/basic/trooper/syndicate
// (aquila/code/modules/mob/living/basic/trooper/syndicate.dm). Zostaje tylko baza simple dla pilotów mechów i mobów misji TheFactory.
// AQ EDIT END
/mob/living/simple_animal/hostile/syndicate
	name = "agent Syndykatu"
	desc = "Śmierć Nanotrasen."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	response_help = "szturcha"
	response_disarm = "popycha"
	response_harm = "uderza"
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 100
	health = 100
	melee_damage = 10
	attacktext = "uderza"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list(FACTION_SYNDICATE)
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 2
	do_footstep = TRUE
	mobchatspan = "syndmob"
