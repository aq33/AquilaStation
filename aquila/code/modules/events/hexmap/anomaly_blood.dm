// AQUILA - Anomalia krwi: strzela odłamkami, od których się krwawi, i przeskakuje na leżących, żeby wysysać z nich krew; przy zapadnięciu się rani wszystkich w pobliżu (port z BeeStation code/modules/events/anomaly_blood.dm + code/game/objects/effects/anomalies/anomaly_bleed.dm)
// Bee fires its shrapnel through the pellet cloud component, which in our code only works for casings, grenades and mines,
// so the anomaly fires 3-6 bleeding shards in random directions itself. Bee's detonation teleports the anomaly next to
// every crew member in turn with sleep() calls while it is being deleted; here it bursts once where it stands and makes
// every carbon within 3 tiles bleed. Bee's sprite is not in our icons, so it is the vortex state in red.

/datum/round_event_control/aquila_hex_anomaly_blood
	name = "Anomalia krwi"
	typepath = /datum/round_event/aquila_hex_anomaly/blood
	weight = 10
	min_players = 15
	max_occurrences = 2

/datum/round_event/aquila_hex_anomaly/blood
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/aquila_hex_blood
	announce_kind = "blood"

/obj/effect/anomaly/aquila_hex_blood
	name = "anomalia krwi"
	desc = "Wirujący skrzep czerwonej mgły. Pachnie żelazem."
	icon_state = "bhole3"
	color = "#b00000"
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	density = TRUE
	/// Wysysa właśnie krew i stoi w miejscu
	var/sucking = FALSE

/obj/effect/anomaly/aquila_hex_blood/anomalyEffect(delta_time)
	if(sucking)
		return
	..()
	if(DT_PROB(20, delta_time))
		fire_shards(rand(3, 6))
	if(DT_PROB(10, delta_time))
		for(var/mob/living/carbon/bleed_target in view(6, src))
			if(!bleed_target.resting || bleed_target.stat == DEAD)
				continue
			if(do_teleport(src, get_turf(bleed_target), channel = TELEPORT_CHANNEL_BLUESPACE))
				bleed_target.Stun(3 SECONDS)
				suck_blood()
			break

/// Strzela odłamkami w losowych kierunkach. Zwraca liczbę wystrzelonych.
/obj/effect/anomaly/aquila_hex_blood/proc/fire_shards(amount)
	var/turf/start = get_turf(src)
	if(!start)
		return 0
	for(var/i in 1 to amount)
		var/obj/item/projectile/bullet/shrapnel/aquila_hex_bleed/shard = new(start)
		shard.firer = src
		shard.fire(rand(0, 359))
	playsound(start, 'sound/effects/bang.ogg', 50, TRUE)
	return amount

/// Wysysa krew z leżących na jej kaflu, co pół sekundy, póki ktoś tam leży
/obj/effect/anomaly/aquila_hex_blood/proc/suck_blood()
	if(QDELETED(src))
		return
	sucking = FALSE
	for(var/mob/living/carbon/bleed_target in loc)
		if(bleed_target.stat == DEAD)
			continue
		bleed_target.add_bleeding(BLEED_SURFACE)
		bleed_target.emote("scream")
		sucking = TRUE
	if(sucking)
		new /obj/effect/temp_visual/cult/sparks(loc)
		addtimer(CALLBACK(src, PROC_REF(suck_blood)), 0.5 SECONDS)

/obj/effect/anomaly/aquila_hex_blood/detonate()
	STOP_PROCESSING(SSobj, src)
	fire_shards(8)
	for(var/mob/living/carbon/bleed_target in range(3, src))
		if(bleed_target.stat != DEAD)
			bleed_target.add_bleeding(BLEED_CUT)

/obj/item/projectile/bullet/shrapnel/aquila_hex_bleed
	name = "odłamek skrzepłej krwi"
	damage = 4
	bleed_force = BLEED_DEEP_WOUND
	dismemberment = 0
