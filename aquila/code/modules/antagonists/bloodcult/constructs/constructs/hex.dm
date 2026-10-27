// AQUILA - Hex: mniejszy konstrukt przywoływany przez doskonałego rzemieślnika (vg, draft Monke #3867).
// AI na naszym simple_animal/hostile (FindTarget/PickTarget/MoveToTarget/Goto). Draft opierał się na „stance”
// ze starego tg, u nas hex jest „bezczynny”, gdy nie ma celu (target == null).
/mob/living/simple_animal/hostile/hex
	name = "\improper Hex"
	real_name = "Hex"
	desc = "Mniejszy konstrukt, stworzony przez Rzemieślnika."
	stop_automated_movement_when_pulled = 1
	movement_type = FLYING
	icon = 'aquila/icons/bloodcult/mob.dmi'
	icon_state = "hex"
	icon_living = "hex"
	icon_dead = "hex"
	mob_biotypes = list(MOB_INORGANIC)
	speak_chance = 0
	turns_per_move = 8
	maxHealth = 50
	health = 50
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	projectilesound = 'aquila/sound/bloodcult/forge.ogg'
	projectiletype = /obj/item/projectile/bloodslash
	move_to_delay = 1
	melee_damage = 15
	attacktext = "tnie"
	attack_sound = 'aquila/sound/bloodcult/vg/weapons/rapidslice.ogg'
	speed = 5
	faction = list("cult")
	spacewalk = TRUE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	del_on_death = TRUE
	var/mob/living/simple_animal/hostile/construct/builder/perfect/master = null
	var/no_master = TRUE
	var/glow_color = "#FFFFFF"

	var/image/master_glow = null
	var/image/harm_glow = null

	var/mode = HEX_MODE_ROAMING
	var/passive = FALSE
	var/turf/guard_spot = null
	/*
	HEX_MODE_ROAMING 	: Usual mob roaming behaviour.
	HEX_MODE_GUARD 		: Stands in place. If it spots an enemy, will chase it, then attempt to return to the spot where they were placed.
	HEX_MODE_ESCORT		: Follows the Artificer that summoned them around if they're close enough, otherwise stays idle. Shoots at enemies but doesn't chase them.
	*/

/mob/living/simple_animal/hostile/hex/Initialize(mapload)
	. = ..()
	setupglow(glow_color)
	update_harmglow()
	animate(src, pixel_y = 4, time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 2, time = 10, loop = -1, easing = SINE_EASING)
	toggle_ai(AI_ON)

/mob/living/simple_animal/hostile/hex/Destroy()
	master_glow = null
	harm_glow = null
	guard_spot = null
	if(master)
		master.minions?.Remove(src)
		if(IS_CULTIST(master))
			master.DisplayUI("Cultist Right Panel")
	master = null
	return ..()

/mob/living/simple_animal/hostile/hex/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/hex/update_overlays()
	. = ..()
	var/damage = maxHealth - health
	var/icon/damageicon
	if(damage > (2*maxHealth/3))
		damageicon = icon(icon, "wraith2_damage_high")//fits well enough
	else if(damage > (maxHealth/3))
		damageicon = icon(icon, "wraith2_damage_low")
	if(damageicon)
		damageicon.Blend(glow_color, ICON_ADD)
		var/image/damage_overlay = image(icon = damageicon)
		damage_overlay.plane = ABOVE_LIGHTING_PLANE
		. += damage_overlay
	if(master_glow)
		. += master_glow
	if(harm_glow)
		. += harm_glow

/mob/living/simple_animal/hostile/hex/proc/setupglow(_glowcolor = "#FFFFFF")
	glow_color = _glowcolor
	var/icon/glowicon = icon(icon, "glow-[icon_state]")
	glowicon.Blend(_glowcolor, ICON_ADD)
	master_glow = image(icon = glowicon)
	master_glow.plane = ABOVE_LIGHTING_PLANE
	update_icon()

/mob/living/simple_animal/hostile/hex/proc/update_harmglow()
	harm_glow = image(icon, src, "[passive ? "glow-hex-passive" : "glow-hex-harm"]")
	harm_glow.plane = ABOVE_LIGHTING_PLANE
	update_icon()

/mob/living/simple_animal/hostile/hex/Life(seconds, times_fired)
	if(mode != HEX_MODE_ROAMING)
		stop_automated_movement = 1
	. = ..()
	if(!.)
		return
	if(!no_master)
		if(QDELETED(master) || master.stat == DEAD)
			adjustBruteLoss(20)//we shortly die out after our master's demise
			mode = HEX_MODE_ROAMING
			master = null
	switch(mode)
		if(HEX_MODE_GUARD)
			if(!target)
				if(!guard_spot)
					guard_spot = get_turf(src)
				else
					var/turf/T = get_turf(src)
					if(T != guard_spot)
						if((T.z == guard_spot.z) && (get_dist(T, guard_spot) < 50))
							Goto(guard_spot, move_to_delay, 0)
						else
							guard_spot = get_turf(src)
					else
						setDir(turn(dir, -90))
		if(HEX_MODE_ESCORT)
			escort_routine()
		else
			guard_spot = null

/mob/living/simple_animal/hostile/hex/proc/escort_routine()
	guard_spot = null
	if(!master || !length(master.satellites))
		return
	var/escorts = 0
	var/spot = 0
	for(var/mob/living/simple_animal/hostile/hex/H in master.minions)
		if(H.mode == HEX_MODE_ESCORT)
			escorts++
		if(H == src)
			spot = escorts
	var/obj/abstract/satellite/follow
	if(escorts == 1)
		follow = master.satellites[1]//trailing behind
	else
		follow = master.satellites[clamp(spot + 1, 1, length(master.satellites))]//trailing on each sides
	Goto(follow, move_to_delay, 0)
	if(!target && (loc == get_turf(follow)))
		setDir(master.dir)

/mob/living/simple_animal/hostile/hex/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/item/projectile/bloodslash))//stop hitting yourself ffs!
		return TRUE
	if((mode == HEX_MODE_ESCORT) && (istype(mover, /mob/living/simple_animal/hostile/hex) || (mover == master)))//Escort mode is janky otherwise
		return TRUE

/mob/living/simple_animal/hostile/hex/Move(atom/newloc, direct, glide_size_override)
	. = ..()
	if(target)
		setDir(get_dir(src, target))

/mob/living/simple_animal/hostile/hex/forceMove(atom/destination)
	. = ..()
	if(target)
		setDir(get_dir(src, target))

/mob/living/simple_animal/hostile/hex/death(gibbed)
	visible_message(span_warning("[src] rozpada się w stertę odłamków."))
	return ..(TRUE)

/mob/living/simple_animal/hostile/hex/PickTarget(list/Targets)
	if(passive)
		return
	for(var/mob/M in Targets)
		if(IS_CULTIST(M))
			Targets -= M
			continue
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(istype(C.handcuffed, /obj/item/restraints/handcuffs/cult)) //hex don't attack prisoners
				Targets -= M
				continue
		if(locate(/obj/effect/stun_indicator) in M)//or people that got stun paper'd
			Targets -= M
			continue
		if(locate(/obj/effect/cult_ritual/conversion) in M.loc)//or people that stand on top of an active conversion rune
			Targets -= M
	return ..()

/mob/living/simple_animal/hostile/hex/MoveToTarget(list/possible_targets)
	if(mode != HEX_MODE_ESCORT)
		return ..()
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return FALSE
	if(isturf(loc) && (target in possible_targets))
		setDir(get_dir(src, target))
		if(get_dist(src, target) >= 2 && ranged_cooldown <= world.time)
			OpenFire(target)
		if(target.Adjacent(src))
			AttackingTarget()
		return TRUE
	LoseTarget()
	return FALSE

/mob/living/simple_animal/hostile/hex/narsie_act()
	return

/mob/living/simple_animal/hostile/hex/CanAttack(atom/the_target)
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(IS_CULTIST(L) || isconstruct(L) || istype(L, /mob/living/simple_animal/hostile/hex))
			return FALSE
		if("cult" in L.faction)
			return FALSE
	return ..()
