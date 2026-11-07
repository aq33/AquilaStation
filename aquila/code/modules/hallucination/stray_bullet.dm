// AQUILA - zabłąkany pocisk na naszych pociskach-halucynacjach z code/modules/projectiles/projectile/special/hallucination.dm
// (Bee definiuje własne na /obj/projectile, którego nie mamy). Logika startu jak w Bee.

/// Shoots a random, fake projectile to the hallucinator
/datum/hallucination/stray_bullet
	random_hallucination_weight = 7
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

/datum/hallucination/stray_bullet/start()
	if(!iscarbon(hallucinator))
		return FALSE
	var/list/turf/starting_locations = list()

	var/used_view = hallucinator.client?.view || world.view
	for(var/turf/open/open_out_of_view in view(getexpandedview(used_view, 2, 2), hallucinator) - view(used_view, hallucinator))
		starting_locations += open_out_of_view

	if(!length(starting_locations))
		return FALSE

	var/turf/start = pick(starting_locations)
	var/proj_type = pick(subtypesof(/obj/item/projectile/hallucination))
	feedback_details += "Type: [proj_type], Source: ([start.x], [start.y], [start.z])"

	var/obj/item/projectile/hallucination/fake_projectile = new proj_type(start)
	hallucinator.playsound_local(start, fake_projectile.hal_fire_sound, 60, TRUE)
	fake_projectile.hal_target = hallucinator
	fake_projectile.preparePixelProjectile(hallucinator, start)
	fake_projectile.fire()

	QDEL_IN(src, 1 SECONDS)
	return TRUE
