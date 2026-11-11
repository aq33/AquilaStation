// AQ EDIT - basic moby: the spaceman is a basic mob (aquila\code\modules\mob\living\basic\space_fauna\spaceman.dm)

/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace //this should be in a different file
	name = "\improper prywatny ochroniarz Nanotrasen"
	desc = "Funkcjonariusz prywatnych sił ochrony Nanotrasen."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "nanotrasen"
	icon_living = "nanotrasen"
	icon_dead = null
	icon_gib = "syndicate_gib"
	turns_per_move = 5
	response_help = "szturcha"
	response_disarm = "popycha"
	response_harm = "uderza"
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	vision_range = 3
	maxHealth = 100
	health = 100
	melee_damage = 12
	attacktext = "uderza"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("nanotrasenprivate")
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	status_flags = CANPUSH
	search_objects = 1

/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace/Aggro()
	..()
	summon_backup(15)
	say("Trwa 411, potrzebne wsparcie!")

/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace/ranged
	icon_state = "nanotrasenrangedsmg"
	icon_living = "nanotrasenrangedsmg"
	vision_range = 9
	rapid = 3
	ranged = 1
	retreat_distance = 3
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gunshot_smg.ogg'
	loot = list(/obj/item/gun/ballistic/automatic/wt550,
				/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
