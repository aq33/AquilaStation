// AQUILA - baza mobów heretyka z tg (tam basic mob), u nas wrogi simple_animal.
// Moby są dla graczy (przywoływane z duchów), więc AI wyłączone; każdy ma combat mode.
/mob/living/simple_animal/hostile/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "Koszmar spoza tego świata, przywołany przez kiepski kod."
	icon = 'aquila/icons/mob/nonhuman-player/eldritch_mobs.dmi'
	faction = list(FACTION_HERETIC)
	del_on_death = TRUE
	gender = NEUTER
	mob_biotypes = list()

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	unsuitable_atmos_damage = 0
	status_flags = CANPUSH
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	speed = 0

	attack_sound = 'sound/weapons/punch1.ogg'
	response_help = "zastanawia się, czy na pewno dotknąć"
	response_disarm = "wymachuje na"
	response_harm = "rozdziera"
	attacktext = "rozdziera"
	deathmessage = "zapada się w sobie."

	combat_mode = TRUE
	combat_mode_indicator = TRUE
	AIStatus = AI_OFF
	can_have_ai = FALSE
	wander = FALSE
	speak_emote = list("wrzeszczy")
	gold_core_spawnable = NO_SPAWN
	loot = list(/obj/effect/gibspawner/generic)

/mob/living/simple_animal/hostile/heretic_summon/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_HERETIC_SUMMON, INNATE_TRAIT)

// AQUILA - wspólny punkt na efekty po trafieniu wręcz (tg: melee_attack / elementy na ataku)
// Gracz atakuje przez resolve_unarmed_attack, AI przez AttackingTarget.
/mob/living/simple_animal/hostile/heretic_summon/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	if(attack_target.attack_animal(src, modifiers) && isliving(attack_target))
		on_melee_hit(attack_target)

/mob/living/simple_animal/hostile/heretic_summon/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		on_melee_hit(target)

/// Wołane po udanym trafieniu wręcz żywego celu
/mob/living/simple_animal/hostile/heretic_summon/proc/on_melee_hit(mob/living/victim)
	return
