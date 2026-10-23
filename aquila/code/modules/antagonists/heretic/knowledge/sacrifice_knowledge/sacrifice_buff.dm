// A buff given to people sacrificed to help them survive.

/// Screen alert for the below status effect.
/atom/movable/screen/alert/status_effect/unholy_determination
	name = "Unholy Determination"
	desc = "Pojawiasz się w nieznanym pomieszczeniu. Ciemność zaczyna się zaciskać. Ogarnia cię panika. Nie ma czasu. Walcz albo zgiń!"
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "heretic_template"
	overlay_state = "wounded"

/// The buff given to people within the shadow realm to assist them in surviving.
/datum/status_effect/unholy_determination
	id = "unholy_determination"
	duration = 3 MINUTES // Given a default duration so no one gets to hold onto this buff forever by accident.
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/unholy_determination
	/// How much to heal every second
	var/heal_per_second = 0.25

/datum/status_effect/unholy_determination/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/unholy_determination/on_apply()
	owner.add_traits(list(TRAIT_COAGULATING, TRAIT_NOCRITDAMAGE, TRAIT_NOSOFTCRIT), TRAIT_STATUS_EFFECT(id))
	if(owner.get_blood_volume() < BLOOD_VOLUME_OKAY)
		owner.set_blood_volume(BLOOD_VOLUME_OKAY)
	return TRUE

/datum/status_effect/unholy_determination/on_remove()
	owner.remove_traits(list(TRAIT_COAGULATING, TRAIT_NOCRITDAMAGE, TRAIT_NOSOFTCRIT), TRAIT_STATUS_EFFECT(id))

/datum/status_effect/unholy_determination/tick(seconds_between_ticks)
	// The amount we heal of each damage type per tick. If we're missing legs we heal better because we can't dodge.
	var/healing_amount = (heal_per_second * seconds_between_ticks) + (heal_per_second * (2 - owner.get_num_legs()))

	// In softcrit you're, strong enough to stay up.
	if(owner.health <= owner.crit_threshold && owner.health >= HEALTH_THRESHOLD_FULLCRIT)
		if(prob(5))
			to_chat(owner, span_hypnophrase("Twoje ciało chce się poddać, ale walczysz dalej!"))
		healing_amount *= 2
	// ...But reach hardcrit and you're done. You now die faster.
	if (owner.health < HEALTH_THRESHOLD_FULLCRIT)
		if(prob(5))
			to_chat(owner, span_big(span_hypnophrase("Długo już nie wytrzymasz...")))
		healing_amount *= -0.5

	if(owner.health > owner.crit_threshold && prob(4))
		owner.set_jitter_if_lower(20 SECONDS)
		owner.set_dizzy_if_lower(10 SECONDS)
		// AQUILA - adjust_hallucinations_up_to(6 s, 48 s) na naszych tyknięciach Life (~2 s)
		owner.hallucination = min(owner.hallucination + 3, max(owner.hallucination, 24))

	if(prob(2))
		playsound(owner, pick(GLOB.creepy_ambience), 50, TRUE)

	adjust_all_damages(healing_amount, seconds_between_ticks)
	adjust_temperature(seconds_between_ticks)
	adjust_bleed_wounds(seconds_between_ticks)

/*
 * Heals up all the owner a bit, fire stacks and losebreath included.
 */
/datum/status_effect/unholy_determination/proc/adjust_all_damages(amount, seconds_between_ticks)

	owner.adjust_fire_stacks(-1)
	owner.losebreath = max(owner.losebreath - (0.5 * seconds_between_ticks), 0)

	owner.adjust_tox_loss(-amount, updating_health = FALSE, forced = TRUE)
	owner.adjust_oxy_loss(-amount, updating_health = FALSE)
	owner.adjust_brute_loss(-amount, updating_health = FALSE)
	owner.adjust_fire_loss(-amount, updating_health = FALSE)
	owner.updatehealth()

/*
 * Adjust the owner's temperature up or down to standard body temperatures.
 */
/datum/status_effect/unholy_determination/proc/adjust_temperature(seconds_between_ticks)
	// AQUILA - u nas jedna temperatura ciała (bez coretemperature z tg)
	var/target_temp = BODYTEMP_NORMAL
	if(owner.bodytemperature > target_temp)
		owner.adjust_bodytemperature(-50 * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_between_ticks, target_temp)
	else if(owner.bodytemperature < (target_temp + 1))
		owner.adjust_bodytemperature(50 * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_between_ticks, 0, target_temp)

/*
 * Slow and stop any blood loss the owner's experiencing.
 */
/datum/status_effect/unholy_determination/proc/adjust_bleed_wounds(seconds_between_ticks)
	if(!owner.get_blood_volume())
		return
	if(owner.get_blood_volume() < BLOOD_VOLUME_NORMAL)
		owner.adjust_blood_volume(2 * seconds_between_ticks, maximum = BLOOD_VOLUME_NORMAL)
	// AQUILA - zamiast coagulant_effect z tg zmniejszamy nasze krwawienie
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.cauterise_wounds(0.5 * seconds_between_ticks)

/// Torment the target with a frightening hand
/proc/fire_curse_hand(mob/living/carbon/victim, turf/forced_turf, range = 8, projectile_type = /obj/item/projectile/curse_hand/hel)
	var/grab_dir = turn(victim.dir, pick(-90, 90, 180, 180)) // Not in front, favour behind
	var/turf/spawn_turf = get_ranged_target_turf(victim, grab_dir, range)
	spawn_turf = forced_turf ? forced_turf : spawn_turf
	if (isnull(spawn_turf))
		return
	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, victim.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, TRUE, -1)
	var/obj/item/projectile/hand = new projectile_type(spawn_turf)
	hand.aim_projectile(victim, spawn_turf)
	if (QDELETED(hand)) // safety check if above fails - above has a stack trace if it does fail
		return
	hand.fire()
