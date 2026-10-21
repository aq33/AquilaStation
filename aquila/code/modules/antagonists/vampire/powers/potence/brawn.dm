/datum/action/vampire/targeted/brawn
	name = "Krzepa"
	desc = "Zrywaj więzy, rozwalaj szafki i drzwi albo zadawaj straszliwe obrażenia gołymi rękami."
	button_icon_state = "power_strength"
	power_explanation = "Użyj tej mocy, żeby zadać potworny cios. Uderzenie cyborga razi go EMP i zadaje duże obrażenia.\n\
		Na poziomie 3 możesz wyłamywać szafki i zrywać więzy.\n\
		Na poziomie 4 możesz wyważać śluzy.\n\
		Wyższe rangi zwiększają obrażenia od ciosu."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 50
	sol_multiplier = 5
	cooldown_time = 9 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "Wybierz cel."
	level_current = 1

	/// Only changed by the '/brawn/brash' subtype; acts as a general purpose damage multipler.
	var/damage_coefficient = 1.25
	/// Boolean indicating whether or not this version of '/brawn' is in the '/brash' subtype and should
	/// bypass typical ability level restrictions. (There is probably a better way to do this.)
	var/brujah = FALSE

/datum/action/vampire/targeted/brawn/two
	level_current = 2

/datum/action/vampire/targeted/brawn/three
	level_current = 3

/datum/action/vampire/targeted/brawn/four
	level_current = 4

/datum/action/vampire/targeted/brawn/activate_power()
	// Did we break out of our handcuffs?
	if(break_restraints())
		power_activated_sucessfully()
		return
	// Did we knock a grabber down? We can only do this while not also breaking restraints if strong enough.
	if(level_current >= 3 && escape_puller())
		power_activated_sucessfully()
		return
	// Did neither, now we can PUNCH.
	. = ..()

// Look at 'biodegrade.dm' for reference
/datum/action/vampire/targeted/brawn/proc/break_restraints()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner

	var/used = FALSE

	// Lockers
	if(istype(human_owner.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = human_owner.loc
		closet.bust_open()
		closet.visible_message(
			span_warning("[human_owner] rozwala od środka: [closet]!"),
			span_warning("Rozwalasz od środka: [closet]!")
		)
		to_chat(human_owner, span_warning("Wyłamujesz na oścież: [closet]!"))
		used = TRUE

	// Cuffs
	if(human_owner.handcuffed || human_owner.legcuffed)
		human_owner.uncuff()
		human_owner.visible_message(
			span_warning("[human_owner] zrzuca więzy, jakby to było nic!"),
			span_warning("Zrywasz więzy!")
		)
		used = TRUE

	// Straightjackets
	if(human_owner.wear_suit?.breakouttime)
		var/obj/item/clothing/suit/straightjacket = human_owner.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(straightjacket && human_owner.wear_suit == straightjacket)
			qdel(straightjacket)
		human_owner.visible_message(
			span_warning("[human_owner] rozrywa na sobie [straightjacket]!"),
			span_warning("Rozrywasz na sobie [straightjacket]!")
		)
		used = TRUE

	if(used)
		playsound(get_turf(human_owner), 'sound/effects/grillehit.ogg', 80, 1, -1)

	if(used)
		check_witnesses()
	return used

/datum/action/vampire/targeted/brawn/proc/escape_puller()
	if(!owner.pulledby)
		return FALSE

	var/mob/pulled_mob = owner.pulledby
	var/pull_power = pulled_mob.grab_state
	playsound(get_turf(pulled_mob), 'sound/effects/woodhit.ogg', 75, 1, -1)

	// Knock Down (if Living)
	if(isliving(pulled_mob))
		var/mob/living/hit_target = pulled_mob
		hit_target.Knockdown(pull_power * 10 + 20)

	// Knock Back (before Knockdown, which probably cancels pull)
	var/send_dir = get_dir(owner, pulled_mob)
	var/turf/turf_thrown_at = get_ranged_target_turf(pulled_mob, send_dir, pull_power)
	owner.newtonian_move(send_dir) // Bounce back in 0 G
	pulled_mob.throw_at(turf_thrown_at, pull_power, TRUE, owner, FALSE) // Throw distance based on grab state! Harder grabs punished more aggressively.

	log_combat(owner, pulled_mob, "used [src.name] power")
	owner.visible_message(
		span_warning("[owner] wyrywa się z chwytu, a [pulled_mob] leci w tył!"),
		span_warning("Strząsasz z siebie chwyt, a [pulled_mob] leci w tył!")
	)
	owner.pulledby = null // It's already done, but JUST IN CASE.

	check_witnesses()
	return TRUE

/datum/action/vampire/targeted/brawn/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/carbon_owner = owner

	// Living Targets
	if(isliving(target_atom))
		var/mob/living/living_target = target_atom

		// Strength of the attack
		// AQUILA - u nas cios zależy od gatunku, nie od rąk (w Bee: suma bazowych obrażeń obu rąk)
		var/base_arm_damage = (carbon_owner.dna?.species?.punchdamage || 7) * 2
		var/hit_strength = base_arm_damage * damage_coefficient + 2
		var/powerlevel = min(5, 1 + level_current)

		if(rand(5 + powerlevel) >= 5)
			living_target.visible_message(
				span_danger("[carbon_owner] zadaje brutalny cios i [living_target] odlatuje!"), \
				span_userdanger("[carbon_owner] zadaje ci potworny cios, aż odlatujesz!"),
			)
			living_target.Knockdown(min(5, rand(10, 10 * powerlevel)))

		// Attack!
		owner.balloon_alert(owner, "uderzasz: [living_target]!")
		playsound(get_turf(living_target), 'sound/weapons/punch4.ogg', 60, 1, -1)
		check_witnesses(living_target)
		carbon_owner.do_attack_animation(living_target, ATTACK_EFFECT_SMASH)

		var/obj/item/bodypart/affecting = living_target.get_bodypart(ran_zone(living_target.get_combat_bodyzone()))
		living_target.apply_damage(hit_strength, BRUTE, affecting)

		// Knockback
		var/send_dir = get_dir(owner, living_target)
		var/turf/turf_thrown_at = get_ranged_target_turf(living_target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		living_target.throw_at(turf_thrown_at, powerlevel, TRUE, owner)

		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(living_target))
			living_target.emp_act(EMP_HEAVY)
	// Lockers
	else if(istype(target_atom, /obj/structure/closet))
		var/obj/structure/closet/target_closet = target_atom

		playsound(get_turf(carbon_owner), 'sound/machines/airlock_alien_prying.ogg', 40, TRUE, -1)
		carbon_owner.balloon_alert(carbon_owner, "szykujesz się do wyłamania...")
		if(!vampire_do_after(carbon_owner, 2.5 SECONDS, target_closet))
			carbon_owner.balloon_alert(carbon_owner, "przerwano!")
			return FALSE
		target_closet.visible_message(span_danger("[carbon_owner] wyłamuje uderzeniem: [target_closet]!"))

		target_closet.bust_open()
		playsound(get_turf(carbon_owner), 'sound/effects/grillehit.ogg', 80, TRUE, -1)
		check_witnesses()
	// Airlocks
	else if(istype(target_atom, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/target_airlock = target_atom

		playsound(get_turf(carbon_owner), 'sound/machines/airlock_alien_prying.ogg', 40, TRUE, -1)
		check_witnesses()
		owner.balloon_alert(owner, "szykujesz się do wyważenia...")
		if(!vampire_do_after(carbon_owner, 2.5 SECONDS, target_airlock))
			carbon_owner.balloon_alert(carbon_owner, "przerwano!")
			return FALSE

		if(target_airlock.Adjacent(carbon_owner))
			target_airlock.visible_message(span_danger("[carbon_owner] wyważa uderzeniem: [target_airlock]!"))

			// Adjust cost and cooldown if Brujah
			if(brujah)
				if(target_airlock.locked)
					vitaecost = 100
					cooldown_time = 10 SECONDS
				else
					vitaecost = 75
					cooldown_time = 6 SECONDS
			else // If not Brujah then just make the vampire wait a second...
				carbon_owner.Stun(1 SECONDS)

			carbon_owner.Stun(1 SECONDS)
			carbon_owner.do_attack_animation(target_airlock, ATTACK_EFFECT_SMASH)
			playsound(get_turf(target_airlock), 'sound/effects/bang.ogg', 30, 1, -1)
			if(brujah && level_current >= 3 && target_airlock.locked)
				target_airlock.unbolt()
			target_airlock.open(2) // open(2) is like a crowbar or jaws of life.

/datum/action/vampire/targeted/brawn/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Brujah has their own checks
	if(brujah)
		return TRUE

	if(isliving(target_atom))
		return TRUE

	if(istype(target_atom, /obj/machinery/door/airlock))
		if(level_current < 4)
			owner.balloon_alert(owner, "wymagany poziom 4!")
			return FALSE

		return TRUE

	if(istype(target_atom, /obj/structure/closet))
		if(level_current < 3)
			owner.balloon_alert(owner, "wymagany poziom 3!")
			return FALSE

		var/obj/structure/closet/target_closet = target_atom
		if(target_closet.welded || target_closet.locked)
			return TRUE

	return FALSE
