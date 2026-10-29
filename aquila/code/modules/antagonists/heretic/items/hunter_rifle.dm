/// The max range we can zoom in on people from.
#define MAX_LIONHUNTER_RANGE 30

// The Lionhunter, a gun for heretics
// The ammo it uses takes time to "charge" before firing,
// releasing a homing, very damaging projectile
// AQUILA - zamiast komponentu lunety z tg nasze przybliżenie broni (zoomable)
/obj/item/gun/ballistic/rifle/lionhunter
	name = "\improper karabin Łowcy Lwów"
	desc = "Antycznie wyglądający karabin, nieskazitelny, choć ewidentnie bardzo stary."
	icon = 'aquila/icons/obj/weapons/guns/lionhunter.dmi'
	icon_state = "lionhunter"
	item_state = "lionhunter"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/lionhunter_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/lionhunter_righthand.dmi'
	worn_icon = 'aquila/icons/mob/lionhunter_back.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/lionhunter
	fire_sound = 'aquila/sound/items/weapons/gun/sniper/shot.ogg'
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 5
	pixel_x = -8
	base_pixel_x = -8

/obj/item/ammo_box/magazine/internal/boltaction/lionhunter
	name = "wewnętrzny magazynek karabinu Łowcy Lwów"
	ammo_type = /obj/item/ammo_casing/strilka310/lionhunter
	caliber = CALIBER_STRILKA310
	max_ammo = 3

/obj/item/ammo_casing/strilka310
	name = "łuska .310 Strilka"
	desc = "Łuska .310 Strilka. Słowo „łuska” to lekkie naciągnięcie - to po prostu bryłka czerwonego prochu."
	icon = 'aquila/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "310-casing"
	caliber = CALIBER_STRILKA310
	projectile_type = /obj/item/projectile/bullet/strilka310

/obj/item/ammo_casing/strilka310/lionhunter
	projectile_type = /obj/item/projectile/bullet/strilka310/lionhunter
	/// Whether we're currently aiming this casing at something
	var/currently_aiming = FALSE
	/// How many seconds it takes to aim per tile of distance between the target
	var/seconds_per_distance = 0.2 SECONDS
	/// The minimum distance required to gain a damage bonus from aiming
	var/min_distance = 4

/obj/item/ammo_casing/strilka310/lionhunter/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, spread_mult = 1, atom/fired_from)
	if(!BB)
		return
	if(!check_fire(target, user))
		return

	return ..()

/// Checks if we can successfully fire our projectile.
/obj/item/ammo_casing/strilka310/lionhunter/proc/check_fire(atom/target, mob/living/user)
	// In case someone puts this in turrets or something wacky, just fire like normal
	if(!iscarbon(user) || !istype(loc, /obj/item/gun/ballistic/rifle/lionhunter))
		return TRUE

	if(currently_aiming)
		user.balloon_alert(user, "już celujesz!")
		return FALSE

	var/distance = get_dist(user, target)
	if(target.z != user.z || distance > MAX_LIONHUNTER_RANGE)
		return FALSE

	var/fire_time = min(distance * seconds_per_distance, 10 SECONDS)

	if(distance <= min_distance || !isliving(target))
		return TRUE

	user.balloon_alert(user, "celujesz...")
	user.playsound_local(get_turf(user), 'sound/weapons/chunkyrack.ogg', 100, TRUE)

	var/image/reticle = image(
		icon = 'icons/mob/actions/actions_items.dmi',
		icon_state = "sniper_zoom",
		layer = ABOVE_MOB_LAYER,
		loc = target,
	)
	reticle.alpha = 0

	var/list/mob/viewers = viewers(target)
	// The shooter might be out of view, but they should be included
	viewers |= user

	for(var/mob/viewer as anything in viewers)
		viewer.client?.images |= reticle

	// Animate the fade in
	animate(reticle, fire_time * 0.5, alpha = 255, transform = turn(reticle.transform, 180))
	animate(reticle, fire_time * 0.5, transform = turn(reticle.transform, 180))

	currently_aiming = TRUE
	// AQUILA - cel nie jest celem do_after, bo nasz do_after przerywa, gdy cel się ruszy
	. = do_after(user, fire_time, extra_checks = CALLBACK(src, PROC_REF(check_fire_callback), target, user))
	currently_aiming = FALSE

	animate(reticle, 0.5 SECONDS, alpha = 0)
	for(var/mob/viewer as anything in viewers)
		viewer.client?.images -= reticle

	if(!.)
		user.balloon_alert(user, "przerwano!")

	return .

/// Callback for the do_after within the check_fire proc to see if something will prevent us from firing while aiming
/obj/item/ammo_casing/strilka310/lionhunter/proc/check_fire_callback(mob/living/target, mob/living/user)
	if(QDELETED(target) || !isturf(target.loc) || target.z != user.z || get_dist(user, target) > MAX_LIONHUNTER_RANGE)
		return FALSE

	return TRUE

/obj/item/ammo_casing/strilka310/lionhunter/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	if(!BB)
		return

	var/distance = get_dist(user, target)
	// If we're close range, or the target's not a living, OR for some reason a non-carbon is firing the gun
	// The projectile is dry-fired, and gains no buffs
	// BUT, if we're at a decent range and the target's a living mob,
	// the projectile's been channel fired. It has full effects and homes in.
	if(distance > min_distance && isliving(target) && iscarbon(user))
		BB.stamina *= 2
		BB.knockdown = 0.5 SECONDS
		BB.stutter = 3
		BB.projectile_phasing = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

		BB.homing = TRUE
		BB.homing_turn_speed = 150
		BB.set_homing_target(target)

	return ..()

/obj/item/projectile/bullet/strilka310
	name = "pocisk .310 Strilka"
	damage = 60
	armour_penetration = 10

/obj/item/projectile/bullet/strilka310/lionhunter
	name = "łowiecki pocisk .310"
	// These stats are only applied if the weapon is fired fully aimed
	// If fired without aiming or at someone too close, it will do much less
	damage = 30
	stamina = 30
	projectile_phasing = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS
	///The mob that is currently inside the bullet
	var/mob/stored_mob

/obj/item/projectile/bullet/strilka310/lionhunter/fire(angle, atom/direct_target)
	. = ..()
	if(QDELETED(src) || !isliving(firer) || !isliving(original))
		return
	var/mob/living/living_firer = firer
	if(IS_HERETIC(living_firer))
		living_firer.forceMove(src)
		stored_mob = living_firer

/obj/item/projectile/bullet/strilka310/lionhunter/Exited(atom/movable/gone, direction)
	if(gone == stored_mob)
		stored_mob = null
	return ..()

/obj/item/projectile/bullet/strilka310/lionhunter/on_range()
	stored_mob?.forceMove(loc)
	return ..()

/obj/item/projectile/bullet/strilka310/lionhunter/on_hit(atom/target, blocked, pierce_hit)
	stored_mob?.forceMove(loc) //Pretty important to get our mob out of the bullet
	. = ..()
	if(!isliving(target))
		return BULLET_ACT_HIT
	var/mob/living/victim = target
	var/mob/firing_mob = firer
	if(IS_HERETIC_OR_MONSTER(victim) || !IS_HERETIC(firing_mob))
		return BULLET_ACT_HIT

	SEND_SIGNAL(firer, COMSIG_LIONHUNTER_ON_HIT, victim)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/strilka310/lionhunter/Destroy()
	if(stored_mob)
		stack_trace("Lionhunter bullet qdel'd with its firer still inside!")
		stored_mob.forceMove(get_turf(src))
		stored_mob = null
	return ..()

// Extra ammunition can be made with a heretic ritual.
/obj/item/ammo_box/strilka310/lionhunter
	name = "łódka (.310 łowiecki)"
	desc = "Łódka z tajemniczą, nietypową amunicją. Nie pasuje do zwykłych karabinów."
	icon = 'aquila/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "lionhunter_strip"
	ammo_type = /obj/item/ammo_casing/strilka310/lionhunter
	caliber = CALIBER_STRILKA310
	max_ammo = 3
	multiple_sprites = 1
	w_class = WEIGHT_CLASS_TINY

/obj/effect/temp_visual/bullet_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2

#undef MAX_LIONHUNTER_RANGE
