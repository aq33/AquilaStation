/// AQUILA - what the crew sees of the ship signature system (sensor_signature.dm):
/// uncertain DRADIS contacts, "fire from an undetected source" contacts and the lock-on warning for player ships.

/// The position error of an uncertain contact drifts by at most this many tiles per step
#define SENSOR_OFFSET_STEP_TIME (2 SECONDS)
#define SENSOR_UNCERTAINTY_MIN 2
#define SENSOR_UNCERTAINTY_MAX 8
/// How long a hit from an undetected ship stays on DRADIS
#define HIT_GHOST_TIME (10 SECONDS)

/// Position error of target as seen by this ship. Kept per observing ship, not per console, and random-walked
/// instead of re-rolled, so neither reopening the window nor a second console lets you average the noise out.
/obj/structure/overmap/proc/get_sensor_offset(obj/structure/overmap/target, radius)
	var/list/offset = LAZYACCESS(sensor_offsets, target)
	if(!offset)
		var/start = round(radius)
		offset = list(rand(-start, start), rand(-start, start), world.time)
		LAZYSET(sensor_offsets, target, offset)
	else if(world.time >= offset[3] + SENSOR_OFFSET_STEP_TIME)
		offset[1] += rand(-1, 1)
		offset[2] += rand(-1, 1)
		offset[3] = world.time
	var/length = sqrt(offset[1] ** 2 + offset[2] ** 2)
	if(length > radius)
		offset[1] = round(offset[1] * radius / length, 1)
		offset[2] = round(offset[2] * radius / length, 1)
	return offset

/obj/machinery/computer/ship/dradis/ui_data(mob/user)
	. = ..()
	var/list/data = .
	data["sensor_signatures"] = GLOB.sensor_signature_enabled && linked
	if(!GLOB.sensor_signature_enabled || !linked)
		return
	// How far a typical AI ship (default max_tracking_range) picks us up, passively and while it pulses
	var/obj/structure/overmap/typical = /obj/structure/overmap
	var/typical_range = initial(typical.max_tracking_range)
	data["own_signature"] = round(linked.sensor_signature, 0.01)
	data["seen_from"] = round(clamp(typical_range * linked.sensor_signature, SENSOR_MIN_DETECTION, SENSOR_MAX_DETECTION))
	data["seen_from_pulse"] = round(clamp(typical_range * 2 * linked.sensor_signature, SENSOR_MIN_DETECTION, SENSOR_MAX_DETECTION))
	var/list/blips = data["ships"]
	for(var/list/blip as anything in blips)
		var/obj/structure/overmap/OM = locate(blip["id"])
		if(!istype(OM) || OM == linked || OM.faction == linked.faction || istype(OM, /obj/structure/overmap/asteroid) || (OM in linked.target_painted))
			continue
		var/dist = overmap_dist(linked, OM)
		if(dist <= max(sensor_range, OM.sensor_profile)) // Identified contacts are exact, same rule as the base proc
			continue
		var/radius = SENSOR_UNCERTAINTY_MIN + (SENSOR_UNCERTAINTY_MAX - SENSOR_UNCERTAINTY_MIN) * clamp(dist / OM.get_detection_range(linked), 0, 1)
		var/list/offset = linked.get_sensor_offset(OM, radius)
		blip["x"] += offset[1]
		blip["y"] += offset[2]
		blip["uncertainty"] = round(radius, 0.5)
	for(var/obj/structure/overmap/shooter as anything in linked.hit_ghosts?.Copy())
		var/list/ghost = linked.hit_ghosts[shooter]
		if(world.time > ghost[3] + HIT_GHOST_TIME)
			LAZYREMOVE(linked.hit_ghosts, shooter)
			continue
		if(!QDELETED(shooter) && shooter.is_sensor_visible(linked) >= SENSOR_VISIBILITY_FAINT)
			continue // Already a normal contact
		blips[++blips.len] = list("x" = ghost[1], "y" = ghost[2], "colour" = "#ff8800", "name" = "Źródło ostrzału", "opacity" = 0.8, "alignment" = "unaligned", "id" = "ghost_\ref[shooter]", "uncertainty" = SENSOR_UNCERTAINTY_MAX, "ghost" = TRUE)
	// Heard radar pulses (radar_emission.dm), unless the emitter is already a normal contact
	// The overmap wraps but the DRADIS view cannot scroll past its edges, so the UI repeats the emission sector on the far side
	data["map_width"] = world.maxx
	data["map_height"] = world.maxy
	var/list/shown = list()
	for(var/list/blip as anything in blips)
		if(blip["id"])
			shown[blip["id"]] = TRUE
	for(var/obj/structure/overmap/emitter as anything in linked.radar_emissions?.Copy())
		var/list/estimate = linked.get_emission_estimate(emitter)
		if(!estimate || shown["\ref[emitter]"])
			continue
		var/list/emission = linked.radar_emissions[emitter]
		var/fading = world.time > emission[1] + RADAR_VISIBILITY_PENALTY
		blips[++blips.len] = list(
			"x" = WRAP(linked.x + sin(estimate[1]) * estimate[2], 1, world.maxx + 1),
			"y" = WRAP(linked.y + cos(estimate[1]) * estimate[2], 1, world.maxy + 1),
			"colour" = "#e9a040",
			"name" = "NIEZNANY · emisja",
			"opacity" = fading ? 0.4 : 0.9,
			"alignment" = "unaligned",
			"id" = "emission_\ref[emitter]",
			"emission" = list("bearing" = round(estimate[1]), "distance" = round(estimate[2], 0.5), "width" = estimate[3], "spread" = round(estimate[4], 0.5)),
		)

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	var/obj/structure/overmap/shooter = P?.overmap_firer
	. = ..()
	if(!GLOB.sensor_signature_enabled || ai_controlled || QDELETED(src) || !istype(shooter) || shooter == src || QDELETED(shooter))
		return
	if(shooter.is_sensor_visible(src) >= SENSOR_VISIBILITY_FAINT)
		return
	LAZYSET(hit_ghosts, shooter, list(shooter.x, shooter.y, world.time))
	if(world.time < next_hit_ghost_warning)
		return
	next_hit_ghost_warning = world.time + HIT_GHOST_TIME
	var/message = "<span class='warning'>Ostrzał z niewykrytego źródła, namiar [round(overmap_angle(src, shooter))].</span>"
	if(dradis)
		dradis.visible_message(message)
	if(gunner)
		to_chat(gunner, message)
	if(pilot && pilot != gunner)
		to_chat(pilot, message)

/// The AI warns the ships it locks onto (ai-skynet.dm, add_enemy); a player lock now does too
/obj/structure/overmap/finish_lockon(obj/structure/overmap/target, obj/structure/overmap/data_link_origin)
	var/was_painted = istype(target) && LAZYFIND(target_painted, target)
	. = ..()
	if(!GLOB.sensor_signature_enabled || was_painted || data_link_origin || !istype(target) || target.ai_controlled)
		return
	if(!LAZYFIND(target_painted, target))
		return // The lock failed
	var/message = "<span class='warning'>NAMIAR OGNIOWY: [src] namierza nas z kierunku [round(overmap_angle(target, src))].</span>"
	if(target.tactical)
		target.tactical.relay_sound('nsv13/sound/effects/fighters/being_locked.ogg', message)
	else if(target.dradis)
		playsound(target.dradis, 'nsv13/sound/effects/fighters/being_locked.ogg', 100, FALSE)
		target.dradis.visible_message(message)
	if(target.pilot && !target.tactical)
		to_chat(target.pilot, message)

#undef SENSOR_OFFSET_STEP_TIME
#undef SENSOR_UNCERTAINTY_MIN
#undef SENSOR_UNCERTAINTY_MAX
#undef HIT_GHOST_TIME
