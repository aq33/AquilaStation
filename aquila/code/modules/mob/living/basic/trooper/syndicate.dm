// AQUILA: port of tgstation code/modules/mob/living/basic/trooper/syndicate.dm (tg 926bf40c5a). Names, sprites, loot, health,
// ammo and sounds of our simple animals (code/modules/mob/living/simple_animal/hostile/syndicate.dm). The shield of the energy
// sword agents blocks shots as in tg (our simple animals had the chance variable, but nothing read it). Shooting cooldowns
// are tg's (pistols every second, bursts every 3 s; our simple animals fired every 3 s).

/// Syndicate troopers
/mob/living/basic/trooper/syndicate
	name = "agent Syndykatu"
	desc = "Śmierć Nanotrasen."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	faction = list(FACTION_SYNDICATE)
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)

/mob/living/basic/trooper/syndicate/space
	name = "komandos Syndykatu"
	icon_state = "syndicate_space"
	icon_living = "syndicate_space"
	maxHealth = 170
	health = 170
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_light_range = 4

/mob/living/basic/trooper/syndicate/space/stormtrooper
	name = "szturmowiec Syndykatu"
	icon_state = "syndicate_stormtrooper"
	icon_living = "syndicate_stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/basic/trooper/syndicate/melee //dude with a knife and no shields
	hardattacks = TRUE // nasty blocks (energy sword, chainsaw) do not hurt it, as our simple animal
	icon_state = "syndicate_knife"
	icon_living = "syndicate_knife"
	melee_damage = 15
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	sharpness = SHARP_EDGED
	status_flags = NONE
	loot = list(/obj/effect/gibspawner/human)
	/// Chance to block a projectile with the shield
	var/projectile_deflect_chance = 0

/mob/living/basic/trooper/syndicate/melee/bullet_act(obj/item/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(stat == CONSCIOUS && prob(projectile_deflect_chance))
		visible_message("<span class='danger'>[src] blokuje [hitting_projectile] tarczą!</span>")
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/basic/trooper/syndicate/melee/space
	name = "komandos Syndykatu"
	icon_state = "syndicate_space_knife"
	icon_living = "syndicate_space_knife"
	maxHealth = 170
	health = 170
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_light_range = 4

/mob/living/basic/trooper/syndicate/melee/space/stormtrooper
	name = "szturmowiec Syndykatu"
	icon_state = "syndicate_stormtrooper_knife"
	icon_living = "syndicate_stormtrooper_knife"
	maxHealth = 250
	health = 250

/mob/living/basic/trooper/syndicate/melee/sword
	icon_state = "syndicate_sword"
	icon_living = "syndicate_sword"
	melee_damage = 30
	armour_penetration = 35
	attack_sound = 'sound/weapons/blade1.ogg'
	projectile_deflect_chance = 50
	light_color = LIGHT_COLOR_RED
	mob_light_range = 2

/mob/living/basic/trooper/syndicate/melee/sword/space
	name = "komandos Syndykatu"
	icon_state = "syndicate_space_sword"
	icon_living = "syndicate_space_sword"
	maxHealth = 170
	health = 170
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_light_range = 4

/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper
	name = "szturmowiec Syndykatu"
	icon_state = "syndicate_stormtrooper_sword"
	icon_living = "syndicate_stormtrooper_sword"
	maxHealth = 250
	health = 250

///////////////Guns////////////

/mob/living/basic/trooper/syndicate/ranged
	icon_state = "syndicate_pistol"
	icon_living = "syndicate_pistol"
	loot = list(/obj/effect/gibspawner/human)
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	/// Type of bullet we use
	var/casingtype = /obj/item/ammo_casing/c10mm
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/weapons/gunshot.ogg'
	/// number of burst shots
	var/burst_shots
	/// Time between the shots of a burst
	var/burst_intervals = 0.2 SECONDS
	/// Time between taking shots
	var/ranged_cooldown = 1 SECONDS

/mob/living/basic/trooper/syndicate/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		casing_type = casingtype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
		burst_intervals = burst_intervals,\
	)

/mob/living/basic/trooper/syndicate/ranged/infiltrator //shuttle loan event
	projectilesound = 'sound/weapons/gunshot_silenced.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)

/mob/living/basic/trooper/syndicate/ranged/space
	name = "komandos Syndykatu"
	icon_state = "syndicate_space_pistol"
	icon_living = "syndicate_space_pistol"
	maxHealth = 170
	health = 170
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_light_range = 4

/mob/living/basic/trooper/syndicate/ranged/space/stormtrooper
	name = "szturmowiec Syndykatu"
	icon_state = "syndicate_stormtrooper_pistol"
	icon_living = "syndicate_stormtrooper_pistol"
	maxHealth = 250
	health = 250

/mob/living/basic/trooper/syndicate/ranged/smg
	icon_state = "syndicate_smg"
	icon_living = "syndicate_smg"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshot_smg.ogg'
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst
	burst_shots = 2
	ranged_cooldown = 3 SECONDS

///Spawns from an emagged orion trail machine set to kill the player.
/mob/living/basic/trooper/syndicate/ranged/smg/orion
	name = "ochrona portu kosmicznego"
	desc = "Elitarne korporacyjne siły ochrony wszystkich portów kosmicznych na Szlaku Oriona."
	faction = list("orion")
	loot = null

/mob/living/basic/trooper/syndicate/ranged/smg/pilot //caravan ambush ruin
	name = "pilot złomiarz Syndykatu"
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)

/mob/living/basic/trooper/syndicate/ranged/smg/space
	name = "komandos Syndykatu"
	icon_state = "syndicate_space_smg"
	icon_living = "syndicate_space_smg"
	maxHealth = 170
	health = 170
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_light_range = 4

/mob/living/basic/trooper/syndicate/ranged/smg/space/stormtrooper
	name = "szturmowiec Syndykatu"
	icon_state = "syndicate_stormtrooper_smg"
	icon_living = "syndicate_stormtrooper_smg"
	maxHealth = 250
	health = 250

/mob/living/basic/trooper/syndicate/ranged/shotgun
	icon_state = "syndicate_shotgun"
	icon_living = "syndicate_shotgun"
	casingtype = /obj/item/ammo_casing/shotgun/buckshot //buckshot (up to 72.5 brute) fired in a two-round burst
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/shotgunner
	burst_shots = 2
	burst_intervals = 0.6 SECONDS
	ranged_cooldown = 3 SECONDS

/mob/living/basic/trooper/syndicate/ranged/shotgun/space
	name = "komandos Syndykatu"
	icon_state = "syndicate_space_shotgun"
	icon_living = "syndicate_space_shotgun"
	maxHealth = 170
	health = 170
	speed = 1
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_light_range = 4

/mob/living/basic/trooper/syndicate/ranged/shotgun/space/stormtrooper
	name = "szturmowiec Syndykatu"
	icon_state = "syndicate_stormtrooper_shotgun"
	icon_living = "syndicate_stormtrooper_shotgun"
	maxHealth = 250
	health = 250

///////////////Misc////////////

/mob/living/basic/viscerator
	name = "wypruwacz"
	desc = "Mała maszyna z dwoma ostrzami, zdolna zadawać bardzo śmiertelne rany szarpane."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	combat_mode = TRUE
	mob_biotypes = list(MOB_ROBOTIC)
	basic_mob_flags = DEL_ON_DEATH
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 700
	unsuitable_cold_damage = 0
	health = 25
	maxHealth = 25
	melee_damage = 15
	sharpness = SHARP_EDGED
	obj_damage = 0
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list(FACTION_SYNDICATE)
	mob_size = MOB_SIZE_TINY
	limb_destroyer = TRUE
	speak_emote = list("stwierdza")
	bubble_icon = "syndibot"
	gold_core_spawnable = HOSTILE_SPAWN
	death_message = "zostaje roztrzaskany na kawałki!"
	ai_controller = /datum/ai_controller/basic_controller/trooper/viscerator

/mob/living/basic/viscerator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/swarming)
