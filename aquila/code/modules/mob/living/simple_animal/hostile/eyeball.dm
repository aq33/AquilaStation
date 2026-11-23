// AQUILA: the eyeball was a subtype of the simple animal space carp (code/modules/mob/living/simple_animal/hostile/eyeballs.dm).
// The carp became basic mobs (decision D10 of raport/mobabilities_04_plan.md): the eyeball stays a simple animal on its own type
// with the carp vars it used to inherit (space proof, flying, gold core spawn, ghost possession); tg's basic eyeball (eye healing,
// crying, carrot taming) is not ported.
/mob/living/simple_animal/hostile/eyeball
	name = "gałka oczna"
	desc = "Dziwnie wyglądające stworzenie. Nie przestaje się gapić..."
	icon = 'icons/mob/carp.dmi'
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = ""
	gender = NEUTER
	mob_biotypes = list(MOB_ORGANIC)
	speak_chance = 0
	turns_per_move = 5
	response_help = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm = "uderza"
	emote_taunt = list("patrzy spode łba")
	taunt_chance = 25
	speed = 0
	maxHealth = 45
	health = 45
	spacewalk = TRUE
	speak_emote = list("woła telepatycznie")

	obj_damage = 60
	melee_damage = 20
	attacktext = "mruga do"
	attack_sound = 'sound/weapons/pierce.ogg'
	chat_color = "#B15FB9"
	mobchatspan = "researchdirector"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("spooky")
	movement_type = FLYING
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = TRUE
	playable = TRUE
	should_talk = FALSE

/mob/living/simple_animal/hostile/eyeball/Initialize(mapload)
	. = ..()
	find_candidates()

/mob/living/simple_animal/hostile/eyeball/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
