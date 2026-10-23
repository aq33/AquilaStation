/**
 * A funny little rolling guy who is great at scouting.
 * It can see through walls, jaunt, and create a psychic network to report its findings.
 * It can blind people to make a getaway, but also get stronger if it attacks the same target consecutively.
 */
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	name = "\improper Raw Prophet"
	real_name = "Raw Prophet"
	desc = "Obrzydlistwo zszyte z kilku odciętych rąk i jednego spuchniętego, osieroconego oka."
	icon_state = "raw_prophet"
	icon_living = "raw_prophet"
	status_flags = CANPUSH
	// AQUILA - tg: 5-10 obrażeń, u nas jedna wartość; rośnie przy kolejnych ciosach w ten sam cel
	melee_damage = 8
	maxHealth = 65
	health = 65
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	mob_biotypes = list(MOB_ORGANIC)
	loot = list(/obj/effect/gibspawner/human, /obj/item/bodypart/l_arm, /obj/item/organ/eyes)
	/// List of innate abilities we have to add.
	var/static/list/innate_abilities = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/long,
		/datum/action/cooldown/spell/list_target/telepathy/eldritch,
		/datum/action/innate/expand_sight,
	)
	// AQUILA - tg: komponent focused_attacker. Każdy kolejny cios w ten sam cel jest mocniejszy.
	/// Ile obrażeń dochodzi za każdy kolejny cios w ten sam cel
	var/focus_gain_per_attack = 5
	/// Najwyższy dodatek do obrażeń
	var/focus_maximum_gain = 25
	/// Ostatnio atakowany cel
	var/datum/weakref/focus_last_target

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/Initialize(mapload)
	. = ..()
	var/on_link_message = "Czujesz, jak coś nowego wkracza w sferę twojego umysłu... \
		Słyszysz szepty dalekich ludzi, wrzaski grozy i powitalny pomruk Mansus Link istoty [src]."
	var/on_unlink_message = "Twój umysł się rozpada, gdy Mansus Link istoty [src] go opuszcza."
	AddComponent( \
		/datum/component/mind_linker/active_linking, \
		network_name = "Mansus Link", \
		chat_color = "#568b00", \
		post_unlink_callback = CALLBACK(src, PROC_REF(after_unlink)), \
		speech_action_background_icon_state = "bg_ecult", \
		speech_action_overlay_state = "bg_ecult", \
		linker_action_path = /datum/action/cooldown/spell/pointed/manse_link, \
		link_message = on_link_message, \
		unlink_message = on_unlink_message, \
	)

	grant_actions_by_list(get_innate_abilities())

/// Returns a list of abilities that we should add.
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/proc/get_innate_abilities()
	var/list/returnable_list = innate_abilities.Copy()
	returnable_list += /datum/action/cooldown/spell/pointed/blind/eldritch
	return returnable_list

/*
 * Callback for the mind_linker component.
 * Stuns people who are ejected from the network.
 */
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/proc/after_unlink(mob/living/unlinked_mob)
	if(QDELETED(unlinked_mob) || unlinked_mob.stat == DEAD)
		return

	INVOKE_ASYNC(unlinked_mob, TYPE_PROC_REF(/mob, emote), "scream")
	unlinked_mob.AdjustParalyzed(0.5 SECONDS) //micro stun

// AQUILA - tg: element wheel, prorok toczy się, gdy idzie
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(Forced || incapacitated() || !(mobility_flags & MOBILITY_STAND))
		return
	var/rotation_degree = (360 / 3)
	if(Dir & SOUTHWEST)
		rotation_degree *= -1
	var/matrix/to_turn = turn(transform, rotation_degree)
	animate(src, transform = to_turn, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL)

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/AttackingTarget()
	SpinAnimation(speed = 5, loops = 1)
	if(target == src)
		return
	update_focus(target)
	return ..()

/// tg: focused_attacker - liczy kolejne ciosy w ten sam cel
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/proc/update_focus(atom/attacked)
	if(isnull(attacked) || isturf(attacked))
		return
	if(focus_last_target?.resolve() == attacked)
		if(melee_damage - initial(melee_damage) >= focus_maximum_gain)
			return
		melee_damage += focus_gain_per_attack
		return
	melee_damage = initial(melee_damage)
	focus_last_target = WEAKREF(attacked)

/// Variant raw prophet used by eldritch transformation with more base attack power
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ascended
	melee_damage = 18

/// NPC variant with a less bullshit ability
// AQUILA - u nas bez AI z tg: zwykłe AI wrogiego moba, bez zaklęcia oślepienia (AI i tak go nie użyje)
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ruins
	AIStatus = AI_ON
	can_have_ai = TRUE
	wander = TRUE

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ruins/get_innate_abilities()
	return innate_abilities.Copy()
