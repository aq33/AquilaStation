// AQUILA: port of tgstation code/modules/mob/living/basic/trooper/nanotrasen.dm (tg 926bf40c5a). Names, lines, loot, ammo and
// sounds of our simple animals (code/modules/mob/living/simple_animal/hostile/nanotrasen.dm and the peaceful officers from
// retaliate/spaceman.dm). Our hostile officers called for backup when they spotted someone, so they use the reinforcement
// calling controllers (tg: only the "screaming" variant) and keep their random lines. Our faction "nanotrasenprivate" stays
// (tg: ROLE_DEATHSQUAD).

/// Nanotrasen Private Security forces
/mob/living/basic/trooper/nanotrasen
	name = "\improper prywatny ochroniarz Nanotrasen"
	desc = "Funkcjonariusz prywatnych sił ochrony Nanotrasen. Raczej nie cieszy się na twój widok."
	icon_state = "nanotrasen"
	icon_living = "nanotrasen"
	icon_gib = "syndicate_gib"
	melee_damage = 12
	faction = list("nanotrasenprivate")
	mobchatspan = "unknown"
	loot = list(/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
	ai_controller = /datum/ai_controller/basic_controller/trooper/calls_reinforcements/nanotrasen

/mob/living/basic/trooper/nanotrasen/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck = null)
	return -10 // Respect our troops

/// Lines of the hostile officers
/datum/ai_planning_subtree/random_speech/nanotrasen
	speech_chance = 3
	speak = list("Przestań się stawiać!", "JA JESTEM PRAWEM!", "Poczuj gniew złotego bełtu!", "Przestań łamać prawo, dupku!")

/datum/ai_controller/basic_controller/trooper/calls_reinforcements/nanotrasen
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/attack_obstacle_in_path/trooper,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target/reinforce,
		/datum/ai_planning_subtree/random_speech/nanotrasen,
	)

/datum/ai_controller/basic_controller/trooper/ranged/calls_reinforcements/nanotrasen
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target/reinforce,
		/datum/ai_planning_subtree/random_speech/nanotrasen,
	)

/datum/ai_controller/basic_controller/trooper/ranged/burst/calls_reinforcements/nanotrasen
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trooper_burst,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target/reinforce,
		/datum/ai_planning_subtree/random_speech/nanotrasen,
	)

/mob/living/basic/trooper/nanotrasen/ranged
	icon_state = "nanotrasenranged"
	icon_living = "nanotrasenranged"
	loot = list(/obj/item/gun/ballistic/automatic/pistol/m1911, /obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/calls_reinforcements/nanotrasen
	/// Type of bullet we use
	var/casingtype = /obj/item/ammo_casing/c45
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/weapons/gunshot.ogg'
	/// number of burst shots
	var/burst_shots
	/// Time between taking shots
	var/ranged_cooldown = 1 SECONDS

/mob/living/basic/trooper/nanotrasen/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		casing_type = casingtype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
	)

/mob/living/basic/trooper/nanotrasen/ranged/smg
	icon_state = "nanotrasenrangedsmg"
	icon_living = "nanotrasenrangedsmg"
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst/calls_reinforcements/nanotrasen
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gunshot_smg.ogg'
	loot = list(/obj/item/gun/ballistic/automatic/wt550, /obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
	burst_shots = 3
	ranged_cooldown = 3 SECONDS

/// Officer of the maintenance trap (trickyspawner/shitsec): no gear to loot
/mob/living/basic/trooper/nanotrasen/hugbox
	loot = list(/obj/effect/gibspawner/human)//no gamer gear, sorry!
	mobchatspan = "headofsecurity"

/// A more peaceful variant that will only attack when attacked, or when another Nanotrasen officer calls for help.
/mob/living/basic/trooper/nanotrasen/peaceful
	desc = "Funkcjonariusz prywatnych sił ochrony Nanotrasen."
	ai_controller = /datum/ai_controller/basic_controller/trooper/peaceful

/mob/living/basic/trooper/nanotrasen/peaceful/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(ai_retaliate_behaviour)))

/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful
	desc = "Funkcjonariusz prywatnych sił ochrony Nanotrasen."
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst/peaceful

/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(ai_retaliate_behaviour)))

/// Tells the officers around that someone attacked us
/mob/living/basic/trooper/nanotrasen/proc/ai_retaliate_behaviour(mob/living/attacker)
	if (!istype(attacker))
		return
	for (var/mob/living/basic/trooper/nanotrasen/potential_trooper in oview(src, 7))
		potential_trooper.ai_controller?.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)
