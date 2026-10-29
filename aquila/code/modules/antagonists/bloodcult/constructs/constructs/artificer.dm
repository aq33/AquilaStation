// AQUILA - Rzemieślnik kultu „Cult 4”. Bazowy typ jest nasz (code/modules/mob/living/simple_animal/constructs.dm),
// tu typ do limitów kultu i doskonały rzemieślnik z vg: leczy konstrukty promieniem, stawia struktury i hexy.

/mob/living/simple_animal/hostile/construct/builder
	construct_type = "Artificer"

/mob/living/simple_animal/hostile/construct/builder/perfect
	icon_state = "artificer2"
	icon_living = "artificer2"
	icon_dead = "artificer2"
	icon = 'aquila/icons/bloodcult/mob.dmi'
	see_in_dark = 7
	new_glow = TRUE
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
		/datum/action/cooldown/spell/pointed/conjure/struct,
		/datum/action/cooldown/spell/pointed/conjure/door,
		/datum/action/cooldown/spell/pointed/conjure/pylon,
		/datum/action/cooldown/spell/pointed/conjure/hex,
	)
	var/mob/living/simple_animal/hostile/construct/heal_target = null
	var/obj/effect/overlay/artificerray/ray = null
	var/heal_range = 2
	var/list/minions = list()
	var/list/satellites = list()

/mob/living/simple_animal/hostile/construct/builder/perfect/Destroy()
	end_ray()
	for(var/mob/living/simple_animal/hostile/hex/H as anything in minions)
		H.master = null
	minions = null
	QDEL_LIST(satellites)
	return ..()

/// Niewidzialne punkty za plecami rzemieślnika, za którymi idą hexy w trybie eskorty
/obj/abstract/satellite
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	icon = 'aquila/icons/bloodcult/effects.dmi'
	icon_state = null

/mob/living/simple_animal/hostile/construct/builder/perfect/proc/update_satellites()
	var/turf/T = get_turf(src)
	if(!T)
		return
	while(length(satellites) < 3)
		var/obj/abstract/satellite/S = new(T)
		satellites.Add(S)
	var/obj/abstract/satellite/satellite_A = satellites[1]
	var/obj/abstract/satellite/satellite_B = satellites[2]
	var/obj/abstract/satellite/satellite_C = satellites[3]
	satellite_A.forceMove(get_step(T, turn(dir, 180)) || T)//behind
	satellite_B.forceMove(get_step(T, turn(dir, 135)) || T)//behind on one side
	satellite_C.forceMove(get_step(T, turn(dir, 225)) || T)//behind on the other side

/mob/living/simple_animal/hostile/construct/builder/perfect/Life(seconds, times_fired)
	. = ..()
	if(. && heal_target)
		heal_target.adjustHealth(-round(heal_target.maxHealth / 10))
		anim(target = heal_target, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "const_heal", plane = ABOVE_LIGHTING_PLANE)
		move_ray()
	update_satellites()

/mob/living/simple_animal/hostile/construct/builder/perfect/Move(atom/newloc, direct, glide_size_override)
	. = ..()
	if(ray)
		move_ray()
	update_satellites()

/mob/living/simple_animal/hostile/construct/builder/perfect/forceMove(atom/destination)
	. = ..()
	if(ray)
		move_ray()
	update_satellites()

/mob/living/simple_animal/hostile/construct/builder/perfect/proc/start_ray(mob/living/simple_animal/hostile/construct/target)
	if(!istype(target))
		return
	if(src in target.healers)
		to_chat(src, span_warning("Już leczysz [target]."))
		return
	if(ray)
		end_ray()
	target.healers.Add(src)
	heal_target = target
	ray = new(loc)
	to_chat(src, span_notice("Leczysz teraz [target]."))
	move_ray()

/mob/living/simple_animal/hostile/construct/builder/perfect/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(isconstruct(attack_target))
		var/mob/living/simple_animal/hostile/construct/C = attack_target
		if(C.health < C.maxHealth)
			start_ray(C)

/mob/living/simple_animal/hostile/construct/builder/perfect/proc/move_ray()
	if(heal_target && ray && heal_target.health < heal_target.maxHealth && get_dist(heal_target, src) <= heal_range && isturf(loc) && isturf(heal_target.loc))
		ray.forceMove(loc)
		var/disty = heal_target.y - src.y
		var/distx = heal_target.x - src.x
		var/newangle
		if(!disty)
			if(distx >= 0)
				newangle = 90
			else
				newangle = 270
		else
			newangle = arctan(distx/disty)
			if(disty < 0)
				newangle += 180
			else if(distx < 0)
				newangle += 360
		var/matrix/M = matrix()
		if(ray.oldloc_source && ray.oldloc_target && get_dist(src, ray.oldloc_source) <= 1 && get_dist(heal_target, ray.oldloc_target) <= 1)
			animate(ray, transform = turn(M.Scale(1, sqrt(distx*distx+disty*disty)), newangle), time = 1)
		else
			ray.transform = turn(M.Scale(1, sqrt(distx*distx+disty*disty)), newangle)
		ray.oldloc_source = src.loc
		ray.oldloc_target = heal_target.loc
	else
		end_ray()

/mob/living/simple_animal/hostile/construct/builder/perfect/proc/end_ray()
	if(heal_target)
		heal_target.healers?.Remove(src)
		heal_target = null
	if(ray)
		QDEL_NULL(ray)

/obj/effect/overlay/artificerray
	name = "promień"
	icon = 'aquila/icons/bloodcult/96x96.dmi'
	icon_state = "artificer_ray"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -29
	var/turf/oldloc_source = null
	var/turf/oldloc_target = null

/obj/effect/overlay/artificerray/narsie_act()
	return

/obj/effect/overlay/artificerray/ex_act()
	return

/obj/effect/overlay/artificerray/emp_act()
	return

/obj/effect/overlay/artificerray/blob_act()
	return

/obj/effect/overlay/artificerray/singularity_act()
	return
