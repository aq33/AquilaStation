
//////////////////////////////
//                          //
//   PERFORATING BLADE      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a filled soul blade performs a perforation
//////////////////////////////

/obj/item/projectile/soulbullet
	name = "ostrze dusz"
	icon = 'aquila/icons/bloodcult/cult_64x64.dmi'
	icon_state = "soulbullet"
	pixel_x = -16 * 1
	pixel_y = -10 * 1
	damage = 30//Only affects obj/turf. Mobs take a regular hit from the sword.
	mouse_opacity = 1
	extra_rotation = 45
	var/turf/secondary_target = null
	var/obj/item/melee/soulblade/blade = null
	var/mob/living/simple_animal/shade/shade = null
	var/redirected = 0
	var/leave_shadows = -1
	var/matrix/shadow_matrix = null

/obj/item/projectile/soulbullet/setAngle(new_angle)
	. = ..()
	cult_apply_rotation()

/obj/item/projectile/soulbullet/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	. = ..()
	if(!QDELETED(src))
		cult_apply_rotation()

/obj/item/projectile/soulbullet/Destroy()
	var/turf/T = get_turf(src)
	if (T)
		if (blade)
			blade.forceMove(T)
	blade = null
	shade = null
	..()

/obj/item/projectile/soulbullet/fire(angle, atom/direct_target)
	var/atom/target = get_turf(direct_target)
	var/target_angle = get_angle(starting, direct_target)

	if (!secondary_target)
		secondary_target = target
	if (!shade)
		icon_state = "soulbullet-empty"
	if (target != secondary_target)
		target_angle = round(get_angle(target, secondary_target))
		blade.dir = get_dir(target, secondary_target)
	else
		target_angle = round(get_angle(starting, target))
		blade.dir = get_dir(starting, target)
	shadow_matrix = turn(matrix(), target_angle+45)
	transform = shadow_matrix
	if (shade)
		icon_state = "soulbullet_spin"
		plane = HUD_PLANE
	else
		icon_state = "soulbullet-empty_spin"
	spawn(5)
		leave_shadows = 0
		if (shade)
			icon_state = "soulbullet"
		else
			icon_state = "soulbullet-empty"
	. = ..()


/obj/item/projectile/soulbullet/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/atom/A = target
	if (shade)
		if (ismob(A))
			var/mob/M = A
			if (!IS_CULTIST(M))
				A.attackby(blade, shade)
			else if (!M.get_active_held_item())//cultists and the blade's master can catch the blade on the fly
				blade.forceMove(loc)
				blade.attack_hand(M)
				to_chat(M, span_warning("Twoja ręka sama się porusza i chwyta [blade] w locie.") )
				blade = null
				qdel(src)
			else if (!M.get_inactive_held_item())
				blade.forceMove(loc)
				M.swap_hand() // guarrantees
				blade.attack_hand(M)
				to_chat(M, span_warning("Twoja ręka sama się porusza i chwyta [blade] w locie.") )
				M.swap_hand()
				blade = null
				qdel(src)
		else
			A.attackby(blade, shade)
	else
		if (ismob(A))
			var/mob/M = A
			if (!IS_CULTIST(M))
				A.hitby(blade)
			else if (!M.get_active_held_item())//cultists can catch the blade on the fly
				blade.forceMove(loc)
				blade.attack_hand(M)
				to_chat(M, span_warning("Twoja ręka sama się porusza i chwyta [blade] w locie.") )
				blade = null
				qdel(src)
			else if (!M.get_inactive_held_item())
				blade.forceMove(loc)
				M.swap_hand()
				blade.attack_hand(M)
				to_chat(M, span_warning("Twoja ręka sama się porusza i chwyta [blade] w locie.") )
				M.swap_hand()
				blade = null
				qdel(src)
		else
			A.hitby(blade)
	if(isliving(A))
		forceMove(get_step(loc, dir))
		if (!redirected)
			redirect()
	else
		..()


/obj/item/projectile/soulbullet/proc/redirect()
	redirected = 1
	speed = 0.66
	setAngle(rand(0, 360))

/obj/item/projectile/soulbullet/narsie_act()
	return

/obj/item/projectile/soulbullet/attackby(obj/item/I, mob/user)
	if (blade)
		return blade.attackby(I, user)

/obj/item/projectile/soulbullet/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if (blade)
		return blade.hitby(hitting_atom)

/obj/item/projectile/soulbullet/bullet_act(obj/item/projectile/P)
	. = ..()
	if (blade)
		return blade.bullet_act(P)
