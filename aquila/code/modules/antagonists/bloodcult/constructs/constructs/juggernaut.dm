// AQUILA - Juggernaut kultu „Cult 4”. Bazowy typ jest nasz (code/modules/mob/living/simple_animal/constructs.dm),
// tu typ do limitów kultu i doskonały juggernaut z vg (szarża Jugger-Dash).

/mob/living/simple_animal/hostile/construct/armored
	construct_type = "Juggernaut"

/mob/living/simple_animal/hostile/construct/armored/perfect
	icon = 'aquila/icons/bloodcult/mob.dmi'
	icon_state = "juggernaut2"
	icon_living = "juggernaut2"
	icon_dead = "juggernaut2"
	new_glow = TRUE
	see_in_dark = 7
	construct_spells = list(
		/obj/effect/proc_holder/spell/targeted/forcewall/cult,
		/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/juggernaut,
		/datum/action/cooldown/spell/juggerdash,
	)
	var/dash_dir = null
	var/turf/crashing = null

/mob/living/simple_animal/hostile/construct/armored/perfect/Bump(atom/obstacle)
	// Rzut kończy się w ..() (finalize), więc sprawdzamy go przed wywołaniem rodzica
	var/was_throwing = !QDELETED(throwing)
	. = ..()
	if(!was_throwing || QDELETED(obstacle))
		return
	var/breakthrough = FALSE
	if(istype(obstacle, /obj/structure/window))
		var/obj/structure/window/W = obstacle
		W.take_damage(1000)
		breakthrough = TRUE

	else if(istype(obstacle, /obj/structure/grille))
		var/obj/structure/grille/G = obstacle
		G.take_damage(G.max_integrity * 0.25)
		breakthrough = TRUE

	else if(istype(obstacle, /obj/structure/table))
		qdel(obstacle)
		breakthrough = TRUE

	else if(istype(obstacle, /obj/structure/rack))
		new /obj/item/rack_parts(obstacle.loc)
		qdel(obstacle)
		breakthrough = TRUE

	else if(istype(obstacle, /turf/closed/wall))
		var/turf/closed/wall/W = obstacle
		if(W.hardness <= 60)
			playsound(W, 'aquila/sound/bloodcult/vg/weapons/heavysmash.ogg', 75, 1)
			W.dismantle_wall(1)
			breakthrough = TRUE
		else
			crashing = null

	else if(istype(obstacle, /obj/structure/reagent_dispensers))
		qdel(obstacle)

	else if(isliving(obstacle))
		var/mob/living/L = obstacle
		L.take_overall_damage(5, 0)
		if(L.buckled)
			L.buckled.unbuckle_mob(L)
		if(!(L.status_flags & CANKNOCKDOWN) || issilicon(L))
			//can't be knocked down? you'll still take the damage.
			crashing = null
		else
			L.Stun(2 SECONDS)
			L.Knockdown(2 SECONDS)
			playsound(src, 'aquila/sound/bloodcult/vg/weapons/heavysmash.ogg', 50, 0, 0)
			breakthrough = TRUE
	else
		crashing = null

	if(breakthrough)
		addtimer(CALLBACK(src, PROC_REF(continue_dash)), 1)

/mob/living/simple_animal/hostile/construct/armored/perfect/proc/continue_dash()
	if(QDELETED(src) || stat == DEAD)
		return
	if(!crashing || isspaceturf(crashing))
		crashing = get_distant_turf(get_turf(src), dash_dir || dir, 2)
	throw_at(crashing, 50, throw_speed, src)

/datum/action/cooldown/spell/juggerdash
	name = "Szarża juggernauta"
	desc = "Szarżujesz w linii prostej, przewracając wszystko na swojej drodze, nawet niektóre ściany."
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon_state = "const_juggdash"
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"
	var/range = 4

	cooldown_time = 40 SECONDS
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/juggerdash/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/hostile/construct/armored/perfect/jugg = owner
	if(!istype(jugg))
		return
	playsound(jugg, 'aquila/sound/bloodcult/vg/effects/juggerdash.ogg', 100, 1)
	jugg.crashing = null
	jugg.dash_dir = jugg.dir
	var/turf/landing = get_distant_turf(get_turf(jugg), jugg.dir, range)
	jugg.throw_at(landing, range, 2, jugg)
