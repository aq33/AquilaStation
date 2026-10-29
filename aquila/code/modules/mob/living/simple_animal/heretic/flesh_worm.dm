/// Armsy starts to look a bit funky if he's shorter than this
#define MINIMUM_ARMSY_LENGTH 2

// What if we took a linked list... But made it a mob?
/// The "Terror of the Night" / Armsy, a large worm made of multiple bodyparts that occupies multiple tiles
// AQUILA - w tg łańcuch robią komponenty mob_chain, leash, blood_walk, amputating_limbs i element wall_smasher.
// U nas to zwykły simple_animal, więc ta sama logika siedzi w samym mobie.
/mob/living/simple_animal/hostile/heretic_summon/armsy
	name = "Lord of the Night"
	real_name = "Master of Decay"
	desc = "Obrzydlistwo z dziesiątek odciętych, zniekształconych kończyn, które czepiają się siebie nawzajem."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	base_icon_state = "armsy"
	maxHealth = 400
	health = 400
	// AQUILA - tg: 30-50 obrażeń
	melee_damage = 40
	obj_damage = 200
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = list(MOB_ORGANIC)
	///Previous segment in the chain, we hold onto this purely to keep track of how long we currently are and to attach new growth to the back
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/back
	/// AQUILA - segment przed nami (tg: front w komponencie mob_chain)
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/front
	///How many arms do we have to eat to expand?
	var/stacks_to_grow = 5
	///Currently eaten arms
	var/current_stacks = 0
	/// AQUILA - tg: amputating_limbs, szansa na wyrwanie ręki przy ciosie
	var/snip_chance = 10

/*
 * Arguments
 * * spawn_bodyparts - whether we spawn additional armsy bodies until we reach length.
 * * worm_length - the length of the worm we're creating. Below 2 doesn't work very well.
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 6)
	. = ..()
	if(spawn_bodyparts)
		build_tail(worm_length)

/mob/living/simple_animal/hostile/heretic_summon/armsy/Destroy()
	if(front)
		var/mob/living/simple_animal/hostile/heretic_summon/armsy/old_front = front
		front = null
		old_front.register_behind(null)
	if(back)
		var/mob/living/simple_animal/hostile/heretic_summon/armsy/old_back = back
		back = null
		old_back.front = null
		qdel(old_back) // chain destruction baby
	return ..()

// We are a vessel of otherworldly destruction, we bring our gravity with us
/mob/living/simple_animal/hostile/heretic_summon/armsy/has_gravity(turf/gravity_turf)
	return TRUE

/mob/living/simple_animal/hostile/heretic_summon/armsy/can_be_pulled(user, grab_state, force)
	return FALSE // The component does this but not on the head. We don't want the head to be pulled either.

/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/build_tail(worm_length)
	worm_length = max(worm_length, MINIMUM_ARMSY_LENGTH)
	// Sets the hp of the head to be exactly the (length * hp), so the head is de facto the hardest to destroy.
	maxHealth = worm_length * maxHealth
	health = maxHealth

	var/datum/action/cooldown/worm_contract/shrink = new(src)
	shrink.Grant(src)

	var/mob/living/simple_animal/hostile/heretic_summon/armsy/prev = src
	for(var/i in 1 to worm_length)
		prev = new_segment(behind = prev)
	update_segment_icon()

/// Grows a new segment behind the passed mob
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/new_segment(mob/living/simple_animal/hostile/heretic_summon/armsy/behind)
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/segment = new type(behind.drop_location(), FALSE)
	ADD_TRAIT(segment, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT)
	segment.front = behind
	behind.register_behind(segment)
	segment.update_segment_icon()
	return segment

/// Record that we got another guy on our ass
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/register_behind(mob/living/simple_animal/hostile/heretic_summon/armsy/tail)
	back = tail
	update_segment_icon()

/// tg: mob_chain - wygląd zależny od miejsca w łańcuchu
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/update_segment_icon()
	var/current_icon_state = base_icon_state
	if(isnull(front))
		current_icon_state = "[current_icon_state]_start"
	else if(isnull(back))
		current_icon_state = "[current_icon_state]_end"
	else
		current_icon_state = "[current_icon_state]_mid"
	icon_state = current_icon_state
	icon_living = current_icon_state

/// tg: mob_chain - ogon idzie za nami, a jak zostanie w tyle, dociągamy go (tg: leash)
/mob/living/simple_animal/hostile/heretic_summon/armsy/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	spread_blood()
	if(isnull(back) || QDELETED(back) || !isturf(OldLoc) || back.loc == OldLoc)
		return
	if(!back.Move(OldLoc))
		back.forceMove(OldLoc)

/// tg: blood_walk - zostawiamy za sobą ślady krwi
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/spread_blood()
	var/turf/our_turf = get_turf(src)
	if(!isopenturf(our_turf) || isgroundlessturf(our_turf))
		return
	var/obj/effect/decal/cleanable/blood/tracks/existing = locate() in our_turf
	if(existing)
		existing.setDir(dir)
		return
	var/obj/effect/decal/cleanable/blood/tracks/new_tracks = new(our_turf)
	new_tracks.setDir(dir)

/// Ściąga cały ogon na nasze pole
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/contract_next_chain_into_single_tile()
	if(isnull(back))
		return
	back.forceMove(loc)
	back.contract_next_chain_into_single_tile()

// tg: mob_chain - obrażenia (i leczenie) idą na koniec ogona
/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(back && !forced)
		return back.adjustBruteLoss(amount, updating_health, forced)
	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(back && !forced)
		return back.adjustFireLoss(amount, updating_health, forced)
	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(back && !forced)
		return back.adjustToxLoss(amount, updating_health, forced)
	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	if(back && !forced)
		return back.adjustOxyLoss(amount, updating_health, forced)
	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustStaminaLoss(amount, updating_health, forced = FALSE)
	if(back && !forced)
		back.adjustStaminaLoss(amount, updating_health, forced)
	return ..()

// tg: mob_chain - jak umieramy, umiera też wszystko za nami
/mob/living/simple_animal/hostile/heretic_summon/armsy/death(gibbed)
	if(back && !QDELETED(back) && back.stat != DEAD)
		back.death(gibbed)
	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/AttackingTarget()
	if(istype(target, /obj/item/bodypart/l_arm) || istype(target, /obj/item/bodypart/r_arm))
		visible_message(span_warning("[src] pożera [target]!"))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		qdel(target)
		on_arm_eaten()
		return
	if(target == back || target == front)
		return
	// tg: mob_chain - ogon atakuje razem z głową
	if(back && !QDELETED(target))
		INVOKE_ASYNC(back, PROC_REF(chain_attack), target)
	if(try_amputate(target))
		return
	return ..()

/// Segment za głową atakuje ten sam cel, jeśli go sięga
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/chain_attack(atom/attacked)
	if(QDELETED(attacked) || stat == DEAD)
		return
	if(!Adjacent(attacked))
		if(back)
			back.chain_attack(attacked)
		return
	GiveTarget(attacked)
	AttackingTarget()

/// tg: amputating_limbs - czasem zamiast zwykłego ciosu wyrywamy rękę
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/try_amputate(atom/victim)
	if(!iscarbon(victim) || HAS_TRAIT(victim, TRAIT_NODISMEMBER) || !prob(snip_chance))
		return FALSE
	var/mob/living/carbon/limbed_victim = victim
	var/list/valid_targets = list()
	for(var/obj/item/bodypart/possible_target as anything in limbed_victim.bodyparts)
		if(!(possible_target.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)))
			continue
		if(!possible_target.dismemberable)
			continue
		valid_targets += possible_target
	if(!length(valid_targets))
		return FALSE
	var/obj/item/bodypart/to_remove = pick(valid_targets)
	do_attack_animation(limbed_victim)
	limbed_victim.visible_message(
		span_danger("[src] wyrywa [limbed_victim] kończynę!"),
		span_userdanger("[src] wyrywa ci kończynę!"),
	)
	to_remove.dismember()
	return TRUE

/*
 * Handle healing our chain.
 * Eating arms off the ground heals us, and if we eat enough arms while above a certain health threshold we get longer!
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/on_arm_eaten()
	if(!isnull(back))
		back.on_arm_eaten()
		return

	adjust_brute_loss(-maxHealth * 0.5, FALSE)
	adjust_fire_loss(-maxHealth * 0.5, FALSE)

	if(health < maxHealth * 0.8)
		return

	current_stacks++
	if(current_stacks < stacks_to_grow)
		return

	visible_message(span_boldwarning("[src] napina się i rośnie!"))
	current_stacks = 0
	new_segment(behind = src)

/*
 * Recursively get the length of our chain.
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/get_length()
	. = 1
	if(isnull(back))
		return
	. += back.get_length()

/**
 * Shrink the chain of mobs into one tile.
 */
// AQUILA - w tg część komponentu mob_chain
/datum/action/cooldown/worm_contract
	name = "Skurcz"
	desc = "Ściąga całe twoje ciało na jedno pole."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "worm_contract"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/worm_contract/Trigger()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/worm = owner
	if(!istype(worm))
		return FALSE
	worm.contract_next_chain_into_single_tile()
	StartCooldown()
	return TRUE

#undef MINIMUM_ARMSY_LENGTH
