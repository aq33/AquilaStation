// AQUILA: port of tgstation code/modules/mob/living/basic/trooper/ (tg 926bf40c5a, last revision before behaviour trees) on the
// Bee AI core: Syndicate agents, Nanotrasen private security, Russians and pirates as basic mobs. Polish names, lines, loot,
// health, damage, ammo and sounds of our simple animals are kept.
// Changes against tg:
// - our pre-rendered sprites from icons/mob/simple_human.dmi stay (no apply_dynamic_human_appearance() here);
// - one `loot` list (with the corpse spawner) instead of tg's `loot` + `corpse`, as in our simple animals;
// - no ranged_mob_full_auto (a player holding the mouse button) and no maintain_distance: tg troopers do not keep their
//   distance either, the ranged attack behaviour stops `required_distance` tiles away;
// - tg's abductor agents and the "screaming" NT officer are not ported (new content); our NT officers that called for help
//   on sight (summon_backup in Aggro()) use the reinforcement calling controller, the Russian officer too ("V BOJ!!");
// - Syndicate civilians and the NSV13 boarders (/mob/living/simple_animal/hostile/nsv) are gone: the boarding interiors use
//   KNPC (aq33 decision 2026-11-11). The simple /mob/living/simple_animal/hostile/syndicate base stays only for the mecha
//   pilots and the away mission mobs (TheFactory).
/mob/living/basic/trooper
	icon = 'icons/mob/simple_human.dmi'
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	maxHealth = 100
	health = 100
	basic_mob_flags = DEL_ON_DEATH
	speed = 1 // basic mobs skip the simple animal +1 movespeed config: 2 (run) + 1 = the old 3 ds per tile
	melee_damage = 10
	attack_verb_continuous = "uderza"
	attack_sound = 'sound/weapons/punch1.ogg'
	melee_attack_cooldown = 1.2 SECONDS
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES // AQUILA: as our simple animals; maps switch it off with environment_smash = 0
	combat_mode = TRUE
	status_flags = CANPUSH
	unsuitable_atmos_damage = 15
	do_footstep = TRUE
	mobchatspan = "syndmob"
	ai_controller = /datum/ai_controller/basic_controller/trooper

	/// Loot this mob drops on death (with its corpse spawner)
	var/list/loot
	/// Range of the light the mob shines (helmet lamps of the space variants, energy swords)
	var/mob_light_range = 0

/mob/living/basic/trooper/Initialize(mapload)
	. = ..()
	if(LAZYLEN(loot))
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)
	if(mob_light_range)
		set_light(mob_light_range)
