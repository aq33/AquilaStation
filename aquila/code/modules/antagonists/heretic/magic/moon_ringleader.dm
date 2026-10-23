/datum/action/cooldown/spell/aoe/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Potężne zaklęcie obszarowe, które przywołuje twoje kopie. \
			Zaatakowana kopia uszkadza mózg i poczytalność wszystkich w pobliżu oraz na chwilę ich ogłusza."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_ringleader"
	sound = 'aquila/sound/effects/moon_parade.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE_MOON
	invocation = "R'S 'E!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_radius = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader

/datum/action/cooldown/spell/aoe/moon_ringleader/cast(mob/living/caster)
	new moon_effect(get_turf(caster))
	// AQUILA - tg add_ally; u nas sojusz to wspólna frakcja z klonami
	caster.add_faction("ringleader([REF(caster)])")
	return ..()

/datum/action/cooldown/spell/aoe/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	var/list/o_range = orange(center, radius_override || aoe_radius) - list(owner, center)
	for(var/mob/living/carbon/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(issilicon(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		stuff += nearby_mob

	return stuff

/datum/action/cooldown/spell/aoe/moon_ringleader/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/caster)
	// AQUILA - tg basic illusion/shover; u nas wrogi simple_animal, który popycha cel
	var/mob/living/simple_animal/hostile/illusion/shover/shove_clone = new(pick(RANGE_TURFS(2, victim)))
	shove_clone.faction = list("ringleader([REF(caster)])")
	shove_clone.Copy_Parent(caster, 30 SECONDS, caster.health, 1, 0)
	shove_clone.GiveTarget(victim)
	RegisterSignal(shove_clone, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/// Used by Ringleaders Rise, illusions created by this spell will explode when they are interacted with
/datum/action/cooldown/spell/aoe/moon_ringleader/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER
	if(QDELETED(victim))
		return
	if(isliving(attacker))
		var/mob/living/living_attacker = attacker
		if(IS_HERETIC_OR_MONSTER(living_attacker)) // Heretics cant smack these guys to trigger their effects
			return
	playsound(victim, 'sound/items/party_horn.ogg', 30)
	// AQUILA - u nas nie ma konfetti, najbliżej jest brokat
	new /obj/effect/decal/cleanable/glitter(get_turf(victim))

	for(var/mob/living/mob in range(3, victim))
		if(mob == victim)
			continue
		if(IS_HERETIC_OR_MONSTER(mob))
			continue
		if(mob.can_block_magic(antimagic_flags))
			continue

		//If our moon heretic has their level 3 passive, we channel the amulet effect
		var/mob/living/simple_animal/hostile/illusion/fake_clone = victim
		var/mob/living/living_owner = fake_clone.parent_mob
		if(QDELETED(living_owner))
			continue
		var/datum/status_effect/heretic_passive/moon/our_passive = living_owner.has_status_effect(/datum/status_effect/heretic_passive/moon)
		// We channel the amulet before the "spell effects" so that people don't get converted after 1 clone goes off
		our_passive?.amulet?.channel_amulet(living_owner, mob)

		mob.AdjustStun(1 SECONDS)
		mob.AdjustKnockdown(1 SECONDS)
		mob.adjust_organ_loss(ORGAN_SLOT_BRAIN, 50, 150)
		mob.adjust_sanity(-50)

	qdel(victim)

/**
 * AQUILA - klon z Ringleaders Rise (tg: /mob/living/basic/illusion/shover).
 * Popycha cel zamiast go bić, a każdy atak na niego wysyła COMSIG_ATOM_WAS_ATTACKED
 * (zamiast elementu relay_attackers).
 */
/mob/living/simple_animal/hostile/illusion/shover
	attacktext = "popycha"
	attack_sound = 'sound/weapons/thudswoosh.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/illusion/shover/AttackingTarget()
	if(!isliving(target))
		return ..()
	var/mob/living/victim = target
	do_attack_animation(victim)
	playsound(victim, attack_sound, 50, TRUE, -1)
	var/turf/shove_to = get_step(victim, get_dir(src, victim))
	if(!shove_to || !victim.Move(shove_to, get_dir(src, victim)))
		victim.Knockdown(1 SECONDS)
	victim.visible_message(span_danger("[src] popycha [victim]!"), span_userdanger("[src] cię popycha!"))
	return TRUE

/mob/living/simple_animal/hostile/illusion/shover/proc/relay_attack(atom/attacker)
	if(QDELETED(src))
		return
	SEND_SIGNAL(src, COMSIG_ATOM_WAS_ATTACKED, attacker)

/mob/living/simple_animal/hostile/illusion/shover/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(I.force)
		relay_attack(user)

/mob/living/simple_animal/hostile/illusion/shover/attack_hand(mob/living/carbon/human/M, list/modifiers)
	. = ..()
	if(M.combat_mode)
		relay_attack(M)

/mob/living/simple_animal/hostile/illusion/shover/attack_paw(mob/living/carbon/monkey/user, list/modifiers)
	. = ..()
	relay_attack(user)

/mob/living/simple_animal/hostile/illusion/shover/attack_alien(mob/living/carbon/alien/humanoid/M, modifiers)
	. = ..()
	relay_attack(M)

/mob/living/simple_animal/hostile/illusion/shover/attack_animal(mob/living/simple_animal/M)
	. = ..()
	relay_attack(M)

/mob/living/simple_animal/hostile/illusion/shover/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	if(P.firer)
		relay_attack(P.firer)

/mob/living/simple_animal/hostile/illusion/shover/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	. = ..()
	if(isitem(AM) && throwingdatum?.thrower)
		var/obj/item/thrown_item = AM
		if(thrown_item.throwforce)
			relay_attack(throwingdatum.thrower)

/obj/effect/temp_visual/moon_ringleader
	icon = 'aquila/icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6

/obj/effect/temp_visual/moon_ringleader/ringleader/Initialize(mapload)
	. = ..()
	transform = transform.Scale(10)
