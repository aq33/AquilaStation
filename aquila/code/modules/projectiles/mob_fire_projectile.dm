// AQUILA: /atom/proc/fire_projectile() of BeeStation/BeeStation-Hornet code/modules/projectiles/projectile.dm (bee/master) on
// /mob/living only: NSV13 overmap ships (/obj/structure/overmap, an /atom) have their own fire_projectile() with other arguments.
// Bee writes ignored atoms as weakrefs into a ready list; our `impacted` is a lazy list keyed by the atom itself.

/**
 * Fires a projectile of `projectile_type` from this mob at `target`, like the old simple animal Shoot().
 * `firer` overrides who shot it (default: this mob), `ignore_targets` are atoms the projectile flies through.
 * Returns the projectile.
 */
/mob/living/proc/fire_projectile(projectile_type, atom/target, sound, firer, list/ignore_targets)
	if(!isnull(sound))
		playsound(src, sound, vol = 100, vary = TRUE)

	var/turf/startloc = get_turf(src)
	var/turf/targloc = get_turf(target)
	if(!startloc || !targloc)
		return
	var/obj/item/projectile/bullet = new projectile_type(startloc)
	bullet.starting = startloc
	for(var/atom/thing as anything in ignore_targets)
		LAZYSET(bullet.impacted, thing, TRUE)
	bullet.firer = firer || src
	bullet.fired_from = src
	bullet.yo = targloc.y - startloc.y
	bullet.xo = targloc.x - startloc.x
	bullet.original = target
	bullet.preparePixelProjectile(target, src)
	bullet.fire()
	return bullet
