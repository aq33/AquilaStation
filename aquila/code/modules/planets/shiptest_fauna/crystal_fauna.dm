// AQUILA: rare crystal fauna of Shiptest's lava planets (AGPLv3) as subtypes of our basic mining mobs:
// - kryształowy goliat: Shiptest goliath/beast/ancient/crystal (mining_mobs/goliath.dm),
// - zapomniany obserwator: Shiptest basilisk/watcher/forgotten (mining_mobs/basilisk.dm),
// - zniekształcony legion: Shiptest hivelord/legion/crystal and its skull (mining_mobs/hivelord.dm).
// Sprites (CC BY-SA 3.0): Shiptest icons/mob/lavaland/lavaland_monsters.dmi and icons/obj/projectiles.dmi copied to
// aquila/icons/planets/fauna/lava_fauna.dmi, icons/mob/lavaland/watcher.dmi to watcher_forgotten.dmi, the crystal spire of
// icons/effects/32x64.dmi to crystal_spire.dmi.
// Changes against Shiptest:
// - no strange crystals in the butcher results and no crystal heart from the legion (we have neither item; the disfigured
//   legion drops the normal regenerative core);
// - the crystal spires are our goliath tentacles with the crystal sprite (they stun, Shiptest's legcuff); the crystal
//   goliath's main tentacle attack raises crystal spires and fires shards, its tentacle burst and tentacle line (tg
//   abilities of our goliath) keep the normal tentacles;
// - the crystal goliath churns spires around itself as our pradawny goliat does (only while its AI is active), not as the
//   Shiptest ancient goliath's Life().

/// Chance per Life() and per nearby turf that the crystal goliath raises a spire there
#define CRYSTAL_GOLIATH_CHURN_PROB 10

/// Once a goliath, now a mass of crystals: raises crystal spires around it and sprays crystal shards
/mob/living/basic/mining/goliath/crystal
	name = "kryształowy goliat"
	desc = "Niegdyś goliat, teraz odrażająca masa poskręcanego ciała i kryształów, które wyrastają z całego jego rozkładającego się cielska."
	icon = 'aquila/icons/planets/fauna/lava_fauna.dmi'
	icon_state = "crystal_goliath"
	icon_living = "crystal_goliath"
	icon_dead = "crystal_goliath_dead"
	tentacle_warning_state = "crystal_goliath2"
	throw_blocked_message = "nie przebija zwapniałej skóry"
	maxHealth = 180
	health = 180
	speed = 8
	tameable = FALSE
	crusher_drop_chance = 30
	butcher_results = list(/obj/item/food/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/ore/silver = 10)
	guaranteed_butcher_results = list()
	/// Is a spiral of shards being fired
	var/spiral_attack_inprogress = FALSE
	/// Don't re-check nearby turfs for this long
	COOLDOWN_DECLARE(retarget_turfs_cooldown)
	/// List of places we might raise a spire, if we're alive
	var/list/spire_target_turfs

/mob/living/basic/mining/goliath/crystal/Initialize(mapload)
	. = ..()
	// The crystal version of the main tentacle attack
	QDEL_NULL(tentacles)
	tentacles = new /datum/action/cooldown/mob_cooldown/goliath_tentacles/crystal(src)
	tentacles.Grant(src)
	ai_controller.set_blackboard_key(BB_GOLIATH_TENTACLES, tentacles)

/mob/living/basic/mining/goliath/crystal/Life(seconds, times_fired)
	. = ..()
	if (stat == DEAD || !isturf(loc) || ai_controller?.ai_status != AI_STATUS_ON)
		return
	if (!LAZYLEN(spire_target_turfs) || COOLDOWN_FINISHED(src, retarget_turfs_cooldown))
		cache_nearby_turfs()
	for (var/turf/target_turf as anything in spire_target_turfs)
		if (is_blocked_turf(target_turf, exclude_mobs = TRUE))
			spire_target_turfs -= target_turf
			continue
		if (prob(CRYSTAL_GOLIATH_CHURN_PROB))
			new /obj/effect/temp_visual/goliath_tentacle/crystal(target_turf, src)

/mob/living/basic/mining/goliath/crystal/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if (loc == OldLoc || stat == DEAD || !isturf(loc))
		return
	LAZYCLEARLIST(spire_target_turfs)

/// Store nearby turfs in our list so we can pop them out later
/mob/living/basic/mining/goliath/crystal/proc/cache_nearby_turfs()
	COOLDOWN_START(src, retarget_turfs_cooldown, 5 SECONDS)
	LAZYCLEARLIST(spire_target_turfs)
	for (var/turf/open/floor in orange(4, loc))
		LAZYADD(spire_target_turfs, floor)

/// Shake and warn, then spray shards at the target a second later
/mob/living/basic/mining/goliath/crystal/proc/convulse(atom/target)
	if (stat == DEAD)
		return
	Shake(2, 2, 1 SECONDS)
	visible_message(span_warning("[src] gwałtownie się wstrząsa! Odsuń się!"))
	playsound(loc, 'sound/effects/magic.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(release_shards), target), 1 SECONDS)

/// Three shards at the target, or now and then a spiral of shards all around
/mob/living/basic/mining/goliath/crystal/proc/release_shards(atom/target)
	if (QDELETED(src) || stat == DEAD || !isturf(loc))
		return
	if (prob(20) && !spiral_attack_inprogress)
		visible_message(span_warning("[src] rozpyla kryształowe odłamki dookoła siebie!"))
		playsound(loc, 'sound/magic/charge.ogg', 100, TRUE)
		spiral_attack_inprogress = TRUE
		for (var/i in 0 to 9)
			addtimer(CALLBACK(src, PROC_REF(shoot_projectile), i * (180 / NUM_E)), i * 3)
		addtimer(VARSET_CALLBACK(src, spiral_attack_inprogress, FALSE), 3 SECONDS)
		return
	visible_message(span_warning("[src] wyrzuca z siebie materię, rozsiewając kryształowe odłamki!"))
	playsound(loc, 'sound/effects/bamf.ogg', 100, TRUE)
	var/angle = (QDELETED(target) || get_turf(target) == get_turf(src)) ? dir2angle(dir) : get_angle(src, target)
	shoot_projectile(angle + 10)
	shoot_projectile(angle)
	shoot_projectile(angle - 10)

/// Fire one shard at the angle
/mob/living/basic/mining/goliath/crystal/proc/shoot_projectile(angle)
	if (QDELETED(src) || stat == DEAD || !isturf(loc))
		return
	fire_crystal_shard(get_turf(src), angle, src)

/// Fires a crystal shard from the turf at the angle; the shooter (can be null) is not hit by it
/proc/fire_crystal_shard(turf/start_turf, angle, atom/movable/shooter)
	var/obj/item/projectile/goliath_crystal/shard = new(start_turf)
	shard.preparePixelProjectile(get_step(start_turf, pick(GLOB.alldirs)), start_turf)
	shard.firer = shooter
	shard.fire(angle)

/// The crystal goliath's main attack: crystal spires instead of tentacles, and a spray of shards after it
/datum/action/cooldown/mob_cooldown/goliath_tentacles/crystal
	name = "Kryształowe iglice"
	desc = "Wypuszcza spod ziemi kryształowe iglice w wybranym miejscu, a potem rozsiewa kryształowe odłamki."
	icon_icon = 'aquila/icons/planets/fauna/lava_fauna.dmi'
	button_icon_state = "crystal_shard"

/datum/action/cooldown/mob_cooldown/goliath_tentacles/crystal/Activate(atom/target)
	var/turf/target_turf = get_turf(target)
	new /obj/effect/temp_visual/goliath_tentacle/crystal/original(target_turf, owner)
	if (isliving(target))
		owner.visible_message(span_warning("[owner] wypuszcza kryształowe iglice pod [target]!"))
	var/mob/living/basic/mining/goliath/crystal/crystal_owner = owner
	if (istype(crystal_owner))
		crystal_owner.convulse(target)
	StartCooldown()
	return TRUE

/// A crystal spire: a goliath tentacle that looks like a crystal
/obj/effect/temp_visual/goliath_tentacle/crystal
	name = "kryształowa iglica"
	icon = 'aquila/icons/planets/fauna/crystal_spire.dmi'
	icon_state = "crystal_growth"

/obj/effect/temp_visual/goliath_tentacle/crystal/tripanim()
	. = ..()
	icon_state = "crystal"

/obj/effect/temp_visual/goliath_tentacle/crystal/retract()
	. = ..()
	icon_state = "crystal_reduction"

/// Raises three more spires around it, on any of the eight sides
/obj/effect/temp_visual/goliath_tentacle/crystal/original

/obj/effect/temp_visual/goliath_tentacle/crystal/original/Initialize(mapload, new_spawner)
	. = ..()
	if (QDELETED(src))
		return
	var/list/directions = GLOB.alldirs.Copy()
	for (var/i in 1 to 3)
		var/turf/spawn_turf = get_step(src, pick_n_take(directions))
		if (spawn_turf)
			new /obj/effect/temp_visual/goliath_tentacle/crystal(spawn_turf, spawner)

/// Shard of the crystal goliath and of the disfigured legion's skulls: raises a crystal spire where it hits
/obj/item/projectile/goliath_crystal
	name = "kryształowy odłamek"
	icon = 'aquila/icons/planets/fauna/lava_fauna.dmi'
	icon_state = "crystal_shard"
	damage = 25
	damage_type = BRUTE
	speed = 3
	range = 14

/obj/item/projectile/goliath_crystal/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	var/turf/turf_hit = get_turf(target)
	if (turf_hit)
		new /obj/effect/temp_visual/goliath_tentacle/crystal(turf_hit, isliving(firer) ? firer : null)

/obj/item/projectile/goliath_crystal/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if (istype(target, /mob/living/basic/mining) || istype(target, /mob/living/simple_animal/hostile/asteroid))
		return FALSE
	return ..()

/// A watcher deformed by a crystal growth: tougher, faster and shooting all the time
/mob/living/basic/mining/watcher/forgotten
	name = "zapomniany obserwator"
	desc = "Na tym obserwatorze wyrosła nowotworowa kryształowa narośl, która na zawsze go oszpeciła i wykrzywiła w tę pokręconą postać."
	icon = 'aquila/icons/planets/fauna/watcher_forgotten.dmi'
	icon_state = "forgotten"
	icon_living = "forgotten"
	icon_dead = "forgotten_dead"
	maxHealth = 250
	health = 250
	melee_damage = 25
	speed = 2
	ranged_cooldown = 1 SECONDS
	projectile_type = /obj/item/projectile/temp/basilisk/forgotten
	crusher_drop_chance = 30

/// Colder frost blast that also makes you shake
/obj/item/projectile/temp/basilisk/forgotten
	damage = 5
	nodamage = FALSE
	temperature = 30

/obj/item/projectile/temp/basilisk/forgotten/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (isliving(target))
		var/mob/living/living_target = target
		living_target.set_jitter_if_lower(10 SECONDS)

/// A legion that went over to the crystals: its skulls burst into crystal shards
/mob/living/basic/mining/legion/crystal
	name = "zniekształcony legion"
	desc = "Zniekształcony, powykręcany i zepsuty. Kiedyś był częścią legionu, teraz służy innej, plugawej i pokrętnej sprawie."
	icon = 'aquila/icons/planets/fauna/lava_fauna.dmi'
	icon_state = "disfigured_legion"
	icon_living = "disfigured_legion"
	icon_dead = "disfigured_legion"
	brood_type = /mob/living/basic/mining/legion_brood/crystal

/// Skull of the disfigured legion
/mob/living/basic/mining/legion_brood/crystal
	name = "zniekształcony legion"
	desc = "Jeden z nikogo."
	icon = 'aquila/icons/planets/fauna/lava_fauna.dmi'
	icon_state = "disfigured_legion_head"
	icon_living = "disfigured_legion_head"
	icon_dead = "disfigured_legion_head"
	speed = 3

/mob/living/basic/mining/legion_brood/crystal/death(gibbed)
	var/turf/death_turf = get_turf(src)
	if (death_turf && stat != DEAD)
		// the legion that launched us fires them (the skull is deleted on death), as Shiptest's `source`
		var/mob/living/shooter = created_by?.resolve()
		for (var/i in 0 to 5)
			fire_crystal_shard(death_turf, i * (360 / 5), QDELETED(shooter) ? null : shooter)
	return ..()

#undef CRYSTAL_GOLIATH_CHURN_PROB
