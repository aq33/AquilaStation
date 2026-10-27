//////////////////////////////
//                          //
//        BLOOD SLASH       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a cultist swings a soul blade that has at least 5 blood in it.
//////////////////////////////

/obj/item/projectile/bloodslash
	name = "krwawe cięcie"
	icon = 'aquila/icons/bloodcult/projectiles_experimental.dmi'
	icon_state = "bloodslash"
	damage = 15
	speed = 0.4
	extra_rotation = 45
	damage_type = BURN

/obj/item/projectile/bloodslash/setAngle(new_angle)
	. = ..()
	cult_apply_rotation()

/obj/item/projectile/bloodslash/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	. = ..()
	if(!QDELETED(src))
		cult_apply_rotation()

/obj/item/projectile/bloodslash/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'aquila/sound/bloodcult/forge_over.ogg', 100, 1)
	if (!locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		new /obj/effect/decal/cleanable/blood/splatter(T)//splash (AQUILA: u nas plama nie ma licznika count)
	..()

/obj/item/projectile/bloodslash/Bump(atom/A)
	if (isliving(A))
		forceMove(A.loc)
		var/mob/living/M = A
		if (!IS_CULTIST(M))
			..()
	qdel(src)

/obj/item/projectile/bloodslash/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (isliving(target))
		var/mob/living/M = target
		if (IS_CULTIST(M))
			return BULLET_ACT_BLOCK
		if (M.stat == DEAD)
			return BULLET_ACT_BLOCK
		to_chat(M, span_warning("Czujesz palący żar w swoim wnętrzu!") )

/obj/item/projectile/bloodslash/narsie_act()
	return
