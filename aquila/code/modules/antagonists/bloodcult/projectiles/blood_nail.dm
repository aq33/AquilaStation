//////////////////////////////
//                          //
//        BLOOD NAIL        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a cultist throws a blood dagger
//////////////////////////////

/obj/item/projectile/blooddagger
	name = "krwawy sztylet"
	icon = 'aquila/icons/bloodcult/projectiles_experimental.dmi'
	icon_state = "blood_dagger"
	damage = 5
	speed = 0.66
	extra_rotation = 45
	var/absorbed = 0
	var/stacks = 0

/obj/item/projectile/blooddagger/setAngle(new_angle)
	. = ..()
	cult_apply_rotation()

/obj/item/projectile/blooddagger/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	. = ..()
	if(!QDELETED(src))
		cult_apply_rotation()

/obj/item/projectile/blooddagger/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'aquila/sound/bloodcult/forge_over.ogg', 100, 1)
	if (!absorbed && !locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		if (color)
			S.color = color
			S.update_icon()
	..()


/obj/item/projectile/blooddagger/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (isliving(target))
		var/mob/living/M = target
		if (IS_CULTIST(M))
			var/mob/living/H = M
			if (!H.cult_no_blood())
				H.blood_volume += 5 + stacks * 5
				to_chat(H, span_notice("[firer ? "[src] od [firer]" : "[capitalize(src.name)]"] bezboleśnie wnika w twoje ciało, zasilając twoje naczynia świeżą krwią.") )
			else
				to_chat(H, span_notice("[firer ? "[src] od [firer]" : "[capitalize(src.name)]"] wnika w twoje ciało, ale nie masz naczyń, które mógłby zasilić.") )
			absorbed = 1
			playsound(H, 'aquila/sound/bloodcult/bloodyslice.ogg', 30, 1)
			return BULLET_ACT_BLOCK
		if (M.stat == DEAD)
			return BULLET_ACT_BLOCK

		if (!IS_CULTIST(M))
			density = FALSE
			invisibility = 101
			var/obj/effect/rooting_trap/bloodnail/nail = new (target.loc)
			nail.transform = transform
			if (color)
				nail.color = color
			else
				nail.color = COLOR_BLOOD
			if(isliving(target))
				nail.stick_to(target)
				var/mob/living/L = target
				L.take_overall_damage(damage, 0)
				to_chat(L, span_warning("[capitalize(src.name)] przebija twoje ciało i przygważdża cię w miejscu.") )
				to_chat(L, span_danger("Wyrwij się (resist) albo kliknij gwóźdź, żeby go wyciągnąć.") )
			else if(loc)
				var/turf/T = get_turf(src)
				nail.stick_to(T, get_dir(src, target))
			qdel(src)
			return
	qdel(src)


/obj/item/projectile/blooddagger/narsie_act()
	return
