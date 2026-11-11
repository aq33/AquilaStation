// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/basic_defense.dm (bee/master 0adf0fe9ae)
// Messages follow our simple animals (animal_defense.dm): one third-person verb, "cię" for the mob itself, Polish lines
// reused from there. Unarmed damage comes from the species (`punchdamage`), as for simple animals.

/mob/living/basic/attack_hand(mob/living/carbon/human/user, list/modifiers)
	// so that martial arts don't double dip
	if(..())
		return TRUE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(user.move_force < move_resist)
			return
		user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		var/shove_dir = get_dir(user, src)
		if(!Move(get_step(src, shove_dir), shove_dir))
			log_combat(user, src, "shoved (failing to move it)", user)
			visible_message(span_danger("[user] [response_disarm_continuous] [src]!"), \
							span_userdanger("[user] [response_disarm_continuous] cię!"), null, COMBAT_MESSAGE_RANGE)
			return TRUE
		log_combat(user, src, "shoved", user)
		visible_message(span_danger("[user] [response_disarm_continuous] [src] i odpycha [p_them()]!"), \
						span_userdanger("[user] cię odpycha!"), null, COMBAT_MESSAGE_RANGE)
		return TRUE

	if(!user.combat_mode)
		if(stat == DEAD)
			return
		visible_message(span_notice("[user] [response_help_continuous] [src]."), \
						span_notice("[user] [response_help_continuous] cię."))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		SEND_SIGNAL(user, COMSIG_LIVING_PET_ANIMAL, src)
	else
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_notice("Nie chcesz zrobić krzywdy [src]!"))
			return
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		visible_message(span_danger("[user] [response_harm_continuous] [src]!"),\
						span_userdanger("[user] [response_harm_continuous] cię!"), null, COMBAT_MESSAGE_RANGE)
		playsound(loc, attacked_sound, 25, TRUE, -1)
		var/damage = ishuman(user) ? user.dna.species.punchdamage : 1
		attack_threshold_check(damage)
		log_combat(user, src, "attacked", user)
		updatehealth()
		return TRUE

/mob/living/basic/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(!user.combat_mode)
		return FALSE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("Nie chcesz zrobić krzywdy [src]!"))
		return FALSE
	..(user, TRUE)
	playsound(loc, "punch", 25, TRUE, -1)
	visible_message(span_danger("[user] uderza [src]!"), \
		span_userdanger("[user] uderza cię!"), null, COMBAT_MESSAGE_RANGE)
	apply_damage(15, BRUTE)
	return TRUE

/mob/living/basic/attack_paw(mob/living/carbon/monkey/user, list/modifiers)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			var/damage = rand(1, 3)
			attack_threshold_check(damage)
			return TRUE
	if (!user.combat_mode)
		if (health > 0)
			visible_message(span_notice("[user.name] [response_help_continuous] [src]."), \
							span_notice("[user.name] [response_help_continuous] cię."))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

/mob/living/basic/attack_alien(mob/living/carbon/alien/humanoid/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user] [response_disarm_continuous] [name]!"), \
			span_userdanger("[user] [response_disarm_continuous] cię!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(user, src, "disarmed", user)
		return

	visible_message(span_danger("[user] tnie [src]!"), \
		span_userdanger("[user] tnie cię!"), null, COMBAT_MESSAGE_RANGE)
	playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
	attack_threshold_check(rand(15, 30))
	log_combat(user, src, "attacked", user)

/mob/living/basic/attack_larva(mob/living/carbon/alien/larva/attacking_larva)
	. = ..()
	if(. && stat != DEAD) //successful larva bite
		var/damage = rand(5, 10)
		. = attack_threshold_check(damage)
		if(.)
			attacking_larva.amount_grown = min(attacking_larva.amount_grown + damage, attacking_larva.max_grown)

/mob/living/basic/attack_animal(mob/living/simple_animal/user)
	. = ..()
	if(.)
		return attack_threshold_check(user.melee_damage, user.melee_damage_type)

/mob/living/basic/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = 20
		if(M.is_adult)
			damage = 30
		if(M.transformeffects & SLIME_EFFECT_RED)
			damage *= 1.1
		return attack_threshold_check(damage)

/mob/living/basic/attack_drone(mob/living/simple_animal/drone/attacking_drone)
	if(attacking_drone.combat_mode) //No kicking dogs even as a rogue drone. Use a weapon.
		return
	return ..()

/mob/living/basic/attack_drone_secondary(mob/living/simple_animal/drone/attacking_drone)
	if(attacking_drone.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/basic/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = "melee", actuallydamage = TRUE)
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(temp_damage >= 0 && temp_damage <= force_threshold)
		visible_message(span_warning("[src] wygląda na nietkniętego."))
		return FALSE
	else
		if(actuallydamage)
			apply_damage(damage, damagetype, null, getarmor(null, armorcheck))
		return TRUE

/mob/living/basic/bullet_act(obj/item/projectile/Proj, def_zone, piercing_hit = FALSE)
	// AQUILA: Bee skips the signal here (its relay_attackers listens elsewhere); ours relays shots through it (odwet, żółw)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, Proj, def_zone)
	apply_damage(Proj.damage, Proj.damage_type)
	Proj.on_hit(src, 0, piercing_hit)
	return BULLET_ACT_HIT

/mob/living/basic/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if(QDELETED(src))
		return
	var/bomb_armor = getarmor(null, "bomb")
	switch(severity)
		if (EXPLODE_DEVASTATE)
			if(prob(bomb_armor))
				apply_damage(500, BRUTE)
			else
				gib()

		if (EXPLODE_HEAVY)
			var/bloss = 60
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			apply_damage(bloss, BRUTE)

		if (EXPLODE_LIGHT)
			var/bloss = 30
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			apply_damage(bloss, BRUTE)

/mob/living/basic/blob_act(obj/structure/blob/attacking_blob)
	apply_damage(20, BRUTE)

/mob/living/basic/do_attack_animation(atom/attacked_atom, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage)
		if(attack_vis_effect && !iswallturf(attacked_atom)) // override the standard visual effect.
			visual_effect_icon = attack_vis_effect
		else if(melee_damage < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()

/mob/living/basic/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(CONSCIOUS)
	med_hud_set_status()

/mob/living/basic/updatehealth()
	..()
	health = clamp(health, 0, maxHealth)
	update_health_hud()

/mob/living/basic/update_health_hud()
	if(!hud_used)
		return
	var/severity = 5 - clamp(FLOOR((health / maxHealth) * 5, 1), 0, 5)
	if(severity > 0)
		overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")

/mob/living/basic/emp_act(severity)
	. = ..()
	if(MOB_ROBOTIC in mob_biotypes)
		emp_reaction(severity)

/mob/living/basic/proc/emp_reaction(severity)
	switch(severity)
		if(EMP_LIGHT)
			visible_message(span_danger("[src] gwałtownie się trzęsie, a jego części się luzują!"))
			apply_damage(maxHealth * 0.6)
			Shake(5, 5, 1 SECONDS)
		if(EMP_HEAVY)
			visible_message(span_danger("[src] nagle rozpada się na kawałki!"))
			apply_damage(maxHealth)
