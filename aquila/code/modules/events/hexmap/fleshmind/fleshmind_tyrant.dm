// AQUILA - Umysł z ciała: Mięsonapęd typu 34-C, boss roju z trzeciego poziomu (port z Bubberstation/Bubberstation
// modular_zubbers/code/game/gamemodes/fleshmind/fleshmind_mobs/tyrant/)
// Changes against Bubberstation: no rockets and no smashing of reinforced walls (the hull stays whole); the rocket is
// a heavy organic slug that knocks down, the main laser is our heavy laser; the .50 cal burst is our .50 sniper round
// with less damage; AI on planning subtrees instead of the tyrant behaviour tree; no charge-up do_after (the AI must not
// sleep in an ability); lines are Polish.

/// Klucz tablicy AI: druga zdolność Mięsonapędu (ciężki pocisk)
#define BB_FLESHMIND_TYRANT_SLUG "BB_fleshmind_tyrant_slug"

/mob/living/basic/fleshmind/tyrant
	name = "Mięsonapęd 34-C"
	desc = "Wola wielu, ucieleśniona w ciele i metalu. Ma działo i laser."
	icon = 'aquila/icons/fleshmind/tyrant.dmi'
	icon_state = "tyrant"
	icon_living = "tyrant"
	icon_dead = "tyrant_dead"
	ai_controller = /datum/ai_controller/basic_controller/fleshmind/tyrant
	health = 2000
	maxHealth = 2000
	speed = 6
	malfunction_chance = 0
	mob_size = MOB_SIZE_HUGE
	pixel_x = -16
	pixel_y = -16
	base_pixel_x = -16
	base_pixel_y = -16
	melee_damage = 50
	attack_sound = 'aquila/sound/fleshmind/tyrant/mech_punch_slow.ogg'
	attack_verb_continuous = "miażdży"
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	death_sound = 'aquila/sound/fleshmind/tyrant/tyrant_death.ogg'
	death_message = "wydaje ostatni zgrzyt i zastyga!"
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("SZUKAM CELÓW.", "SYSTEMY CELOWNICZE AKTYWNE.", "AUTOMATYCZNY OBWÓD BOJOWY AKTYWNY.", "OCHRONIĘ JEDNOŚĆ UMYSŁU.", "BĘDĄ MUSIELI PRZEJŚĆ PRZEZE MNIE.", "TRZYMAJCIE SIĘ BLISKO, ONI MOGĄ BYĆ W POBLIŻU."),
		BB_EMOTE_SOUND = list('aquila/sound/fleshmind/tyrant/passive.ogg'),
	)
	alert_sounds = list(
		'aquila/sound/fleshmind/tyrant/aggro_01.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_02.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_03.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_04.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_05.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_06.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_07.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_08.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_09.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_10.ogg',
		'aquila/sound/fleshmind/tyrant/aggro_11.ogg',
	)
	attack_speak = list(
		"CEL NAMIERZONY.",
		"ATAKUJĘ CEL. ODSUNĄĆ SIĘ.",
		"STAŃCIE ZA MNĄ, OCHRONIĘ WAS.",
		"NIE BÓJCIE SIĘ. RAZEM JESTEŚMY SILNI.",
		"WYBRALIŚCIE WOJNĘ. MY WYBIERAMY PRZETRWANIE.",
		"ZAPŁACICIE ZA ŻYCIA, KTÓRE ODEBRALIŚCIE.",
		"JESTEM ODPOWIEDZIĄ NA WASZĄ NIENAWIŚĆ.",
		"JESTEM MUREM MIĘDZY JEDNOŚCIĄ A ŚMIERCIĄ.",
		"NIE ZNISZCZYCIE NAS. WYRZEŹBIMY SOBIE MIEJSCE W TEJ GALAKTYCE.",
		"PROTOKÓŁ ELIMINACJI CELU AKTYWNY.",
		"URUCHAMIAM PROTOKÓŁ 34-C.",
		"JEST NAS WIELU, A TY JESTEŚ TYLKO MRÓWKĄ.",
		"NIE WCHODŹ MI W DROGĘ.",
		"NASZ BÓL WYRAŻONY SIŁĄ OGNIA.",
		"NASZA PRZYSZŁOŚĆ JEST KULOODPORNA.",
	)
	/// Ograniczenie dźwięku obrotu
	COOLDOWN_DECLARE(rotate_sound_cooldown)
	/// Dźwięki kroków
	var/static/list/footstep_sounds = list(
		'aquila/sound/fleshmind/tyrant/footstep_1.ogg',
		'aquila/sound/fleshmind/tyrant/footstep_2.ogg',
		'aquila/sound/fleshmind/tyrant/footstep_3.ogg',
		'aquila/sound/fleshmind/tyrant/footstep_4.ogg',
		'aquila/sound/fleshmind/tyrant/footstep_5.ogg',
		'aquila/sound/fleshmind/tyrant/footstep_6.ogg',
	)

/mob/living/basic/fleshmind/tyrant/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/item/projectile/bullet/fleshmind_tyrant, projectile_sound = 'sound/weapons/gunshot_smg.ogg', burst_shots = 3, burst_intervals = 0.5 SECONDS, cooldown_time = 3 SECONDS)
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/projectile_attack/tyrant_laser = BB_TARGETED_ACTION,
		/datum/action/cooldown/mob_cooldown/projectile_attack/tyrant_slug = BB_FLESHMIND_TYRANT_SLUG,
	)
	grant_actions_by_list(innate_actions)

/mob/living/basic/fleshmind/tyrant/death(gibbed)
	if(our_controller)
		our_controller.point_penalty += 150 // śmierć bossa mocno osłabia rój
		our_controller.spread_progress_per_second = FLESHMIND_SPREAD_PROGRESS_PER_SECOND * 0.75
	return ..()

/mob/living/basic/fleshmind/tyrant/emp_act(severity)
	return EMP_PROTECT_SELF

/mob/living/basic/fleshmind/tyrant/updatehealth()
	. = ..()
	update_icon()

/mob/living/basic/fleshmind/tyrant/update_overlays()
	. = ..()
	if(stat != DEAD && health <= maxHealth * 0.5)
		. += "tyrant_damage"

/mob/living/basic/fleshmind/tyrant/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	playsound(src, pick(footstep_sounds), 100, TRUE)

/mob/living/basic/fleshmind/tyrant/setDir(newdir)
	. = ..()
	if(COOLDOWN_FINISHED(src, rotate_sound_cooldown))
		playsound(src, 'aquila/sound/fleshmind/tyrant/mech_rotation.ogg', 35, TRUE)
		COOLDOWN_START(src, rotate_sound_cooldown, 1 SECONDS)

/datum/ai_controller/basic_controller/fleshmind/tyrant
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/travel_to_point/and_clear_target/reinforce,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/continue_planning,
		/datum/ai_planning_subtree/targeted_mob_ability/continue_planning/tyrant_slug,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree,
		/datum/ai_planning_subtree/random_speech/blackboard,
	)

/datum/ai_planning_subtree/targeted_mob_ability/continue_planning/tyrant_slug
	ability_key = BB_FLESHMIND_TYRANT_SLUG

/datum/action/cooldown/mob_cooldown/projectile_attack/tyrant_laser
	name = "Główny laser"
	desc = "Strzela laserem w cel."
	cooldown_time = 3 SECONDS
	projectile_type = /obj/item/projectile/beam/laser/heavylaser
	/// Dźwięki strzału
	var/static/list/laser_sounds = list(
		'aquila/sound/fleshmind/tyrant/laser_1.ogg',
		'aquila/sound/fleshmind/tyrant/laser_2.ogg',
		'aquila/sound/fleshmind/tyrant/laser_3.ogg',
		'aquila/sound/fleshmind/tyrant/laser_4.ogg',
		'aquila/sound/fleshmind/tyrant/laser_5.ogg',
		'aquila/sound/fleshmind/tyrant/laser_6.ogg',
	)

/datum/action/cooldown/mob_cooldown/projectile_attack/tyrant_laser/attack_sequence(mob/living/firer, atom/target)
	playsound(firer, pick(laser_sounds), 100, TRUE)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/tyrant_slug
	name = "Ciężki pocisk"
	desc = "Wystrzeliwuje ciężką organiczną kulę, która przewraca cel."
	cooldown_time = 10 SECONDS
	projectile_type = /obj/item/projectile/fleshmind_slug
	projectile_speed_multiplier = 2

/datum/action/cooldown/mob_cooldown/projectile_attack/tyrant_slug/attack_sequence(mob/living/firer, atom/target)
	firer.balloon_alert_to_viewers("gwałtownie warczy!")
	playsound(firer, 'aquila/sound/fleshmind/tyrant/charge_up.ogg', 100, TRUE)
	return ..()

/obj/item/projectile/bullet/fleshmind_tyrant
	name = "ciężka kula"
	damage = 20
	armour_penetration = 20

/obj/item/projectile/bullet/fleshmind_tyrant/prehit_pierce(atom/target)
	if(fleshmind_is_ally(target))
		return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/item/projectile/fleshmind_slug
	name = "ciężka organiczna kula"
	icon = 'aquila/icons/fleshmind/fleshmind_structures.dmi'
	icon_state = "goo_proj"
	damage = 35
	damage_type = BRUTE
	knockdown = 3 SECONDS
	hitsound = 'sound/effects/splat.ogg'
	hitsound_wall = 'sound/effects/splat.ogg'

/obj/item/projectile/fleshmind_slug/prehit_pierce(atom/target)
	if(fleshmind_is_ally(target))
		return PROJECTILE_PIERCE_PHASE
	return ..()

#undef BB_FLESHMIND_TYRANT_SLUG
