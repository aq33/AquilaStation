/datum/action/cooldown/spell/pointed/projectile/star_blast
	name = "Star Blast"
	desc = "Wystrzeliwuje niepowstrzymany dysk kosmicznej energii, który rozsiewa gwiezdny znak. \
			Ponowne rzucenie przenosi cię do dysku, a pola kosmiczne powstają wokół dysku i wokół ciebie, wciągając pobliskich pogan."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_blast"

	sound = 'aquila/sound/effects/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 SECONDS // Cooldown is tied to teleportation, not firing

	invocation = "R'T'T' ST'R!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "Przygotowujesz gwiezdny wybuch!"
	deactive_msg = "Przestajesz kręcić kosmiczną energię w dłoni... na razie."
	cast_range = 12
	projectile_type = /obj/item/projectile/magic/star_ball
	/// Weakref to the projectile we fire, so that we can recast our ability to teleport to its location
	var/datum/weakref/projectile_weakref
	/// Weakref to our summoner, only relevant if we are a stargazer. Prevents us from harming our master
	var/datum/weakref/summoner

/datum/action/cooldown/spell/pointed/projectile/star_blast/ready_projectile(obj/item/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	projectile_weakref = WEAKREF(to_fire)
	to_fire.AddElement(cosmic_trail_based_on_passive(user), /obj/effect/forcefield/cosmic_field/fast)
	RegisterSignal(to_fire, COMSIG_PARENT_QDELETING, PROC_REF(on_ball_deleted))

/// AQUILA - zamiast obramówki z tg: przycisk świeci na zielono, póki dysk leci i można do niego skoczyć
/datum/action/cooldown/spell/pointed/projectile/star_blast/is_action_active()
	return ..() || !!projectile_weakref?.resolve()

/datum/action/cooldown/spell/pointed/projectile/star_blast/proc/on_ball_deleted(datum/source)
	SIGNAL_HANDLER
	projectile_weakref = null
	UpdateButtonIcon()

/datum/action/cooldown/spell/pointed/projectile/star_blast/set_click_ability(mob/on_who)
	var/obj/item/projectile/magic/star_ball/active_ball = projectile_weakref?.resolve()
	if(!active_ball)
		return ..()

	pull_victims()
	do_teleport(owner, get_turf(active_ball), no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	pull_victims() // Yes, this is intentional, we want to pull mobs from the place we were, and the place we've teleported to
	QDEL_NULL(active_ball)
	projectile_weakref = null
	// Cooldown of the ability itself is only 1 second after shooting, it's 25 seconds after we teleport to our ball
	StartCooldown(25 SECONDS)
	return FALSE

/datum/action/cooldown/spell/pointed/projectile/star_blast/proc/pull_victims()
	new /obj/effect/temp_visual/circle_wave/star_blast(get_turf(owner))
	for(var/turf/spawn_turf in range(1, get_turf(owner)))
		if(spawn_turf.density)
			continue
		create_cosmic_field(spawn_turf, owner, /obj/effect/forcefield/cosmic_field/star_blast)
	var/mob/living/our_summoner = summoner?.resolve()
	for(var/mob/living/nearby_mob in view(2, owner))
		if(nearby_mob == owner || nearby_mob == our_summoner)
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue
		for(var/i in 1 to 3)
			nearby_mob.forceMove(get_step_towards(nearby_mob, owner))
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)

/obj/item/projectile/magic/star_ball
	name = "star ball"
	icon = 'aquila/icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "star_ball"
	damage = 0
	nodamage = TRUE
	speed = 5 // tg: 0.2 pola na tyknięcie, u nas czas na pole
	range = 25
	knockdown = 4 SECONDS
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSBLOB | PASSMOB | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSFLAPS | PASSDOORS | PASSVEHICLE | PASSITEM | PASSWINDOW
	projectile_piercing = PASSMOB | PASSVEHICLE
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 3

/obj/item/projectile/magic/star_ball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/cast_on = firer
	for(var/mob/living/nearby_mob in range(star_mark_range, target))
		if(cast_on == nearby_mob || (istype(cast_on) && cast_on.buckled == nearby_mob))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)

/obj/item/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'aquila/sound/effects/magic/cosmic_energy.ogg', 50, FALSE)
	return ..()
