// AQUILA: port of tgstation code/modules/mob/living/basic/trooper/pirate.dm (tg 926bf40c5a). Names, sprites and loot of our
// simple animals (code/modules/mob/living/simple_animal/hostile/pirate.dm); from tg the plundering melee attacks (credits from
// the ID card of a hit victim, dropped as a holochip on death). The space pirates keep our space gear without a loot change.

/// Pirate trooper subtype
/mob/living/basic/trooper/pirate
	name = "pirat"
	desc = "Robi, co chce, bo pirat jest wolny."
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "pirate_dead"
	response_help_continuous = "popycha"
	speak_emote = list("arrrczy")
	faction = list("pirate")
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate, /obj/item/melee/transforming/energy/sword/pirate)
	/// The amount of money to steal with a melee attack
	var/plunder_credits = 25

/mob/living/basic/trooper/pirate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plundering_attacks, plunder_amount = plunder_credits)

/mob/living/basic/trooper/pirate/melee
	name = "pirat zabijaka"
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "piratemelee_dead"
	melee_damage = 30
	armour_penetration = 35
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/blade1.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	sharpness = SHARP_EDGED
	light_color = LIGHT_COLOR_RED
	mob_light_range = 2
	plunder_credits = 50 //they hit hard so they steal more

/mob/living/basic/trooper/pirate/melee/space
	name = "kosmiczny pirat zabijaka"
	icon_state = "piratespace"
	icon_living = "piratespace"
	icon_dead = "piratespace_dead"
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0

/mob/living/basic/trooper/pirate/ranged
	name = "pirat strzelec"
	icon_state = "pirateranged"
	icon_living = "pirateranged"
	icon_dead = "pirateranged_dead"
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate/ranged, /obj/item/gun/energy/laser)
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	/// Type of bullet we use
	var/projectiletype = /obj/item/projectile/beam/laser
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/weapons/laser.ogg'
	/// number of burst shots
	var/burst_shots = 2
	/// Time between the shots of a burst
	var/burst_intervals = 0.6 SECONDS
	/// Time between taking shots
	var/ranged_cooldown = 6 SECONDS

/mob/living/basic/trooper/pirate/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = projectiletype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
		burst_intervals = burst_intervals,\
	)

/mob/living/basic/trooper/pirate/ranged/space
	name = "kosmiczny pirat strzelec"
	icon_state = "piratespaceranged"
	icon_living = "piratespaceranged"
	icon_dead = "piratespaceranged_dead"
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
