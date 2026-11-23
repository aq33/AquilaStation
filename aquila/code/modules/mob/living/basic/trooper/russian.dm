// AQUILA: port of tgstation code/modules/mob/living/basic/trooper/russian.dm (tg 926bf40c5a). Our simple animal variants stay
// (code/modules/mob/living/simple_animal/hostile/russian.dm: Mosin rifleman, shotgun trooper and the officer with a burst
// who calls for backup with "V BOJ!!"), with their names, loot and ammo. Punching, not tg's kitchen knife; no Spinwarder language.

/// Russian trooper subtype
/mob/living/basic/trooper/russian
	name = "Rosjanin"
	desc = "Za Ojczyznę!"
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	melee_damage = 15
	faction = list("russian")
	loot = list(/obj/effect/mob_spawn/human/corpse/russian, /obj/item/kitchen/knife)

/mob/living/basic/trooper/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged, /obj/item/gun/ballistic/revolver/nagant)
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	/// Type of bullet we use
	var/casingtype = /obj/item/ammo_casing/n762
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/weapons/gunshot.ogg'
	/// number of burst shots
	var/burst_shots
	/// Time between taking shots
	var/ranged_cooldown = 1 SECONDS

/mob/living/basic/trooper/russian/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		casing_type = casingtype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
	)

/mob/living/basic/trooper/russian/ranged/mosin
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged, /obj/item/gun/ballistic/rifle/boltaction)
	casingtype = /obj/item/ammo_casing/a762
	ranged_cooldown = 3 SECONDS

/mob/living/basic/trooper/russian/ranged/trooper
	icon_state = "russianrangedelite"
	icon_living = "russianrangedelite"
	maxHealth = 150
	health = 150
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged/trooper, /obj/item/gun/ballistic/shotgun/lethal)
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/shotgunner
	ranged_cooldown = 3 SECONDS

/mob/living/basic/trooper/russian/ranged/officer
	name = "rosyjski oficer"
	icon_state = "russianofficer"
	icon_living = "russianofficer"
	maxHealth = 65
	health = 65
	casingtype = /obj/item/ammo_casing/c9mm
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged/officer, /obj/item/gun/ballistic/automatic/pistol/APS)
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst/calls_reinforcements/russian
	burst_shots = 3
	ranged_cooldown = 3 SECONDS

/datum/ai_controller/basic_controller/trooper/ranged/burst/calls_reinforcements/russian
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "V BOJ!!",
	)
