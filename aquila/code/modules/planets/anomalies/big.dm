// AQUILA - silna i duże anomalie planetarne: port z Shiptesta (code/game/objects/effects/anomalies/anomalies_gravity.dm,
// anomalies_bluespace.dm, anomalies_flux.dm, anomalies_pyroclastic.dm, podtypy /high, /big i ich /planetary,
// licencja AGPLv3). Duża anomalia to zwykła anomalia naszego typu (rdzeń i działanie z core), półtora albo dwa razy
// większa, nieśmiertelna i silniejsza. Rdzeń ma typ zwykłej anomalii (core_anomaly_type), więc działa jak jej rdzeń.
// Różnice względem Shiptesta:
// - silna anomalia grawitacyjna to nasza /obj/effect/anomaly/grav/high (pole grawitacji o losowej sile 0-3 w zasięgu
//   7 zamiast stałej 2 w zasięgu 5), a duża to jej podtyp; bazowe działanie grawitacji jest nasze (Shiptest dokłada
//   15 obrażeń co puls);
// - duża piroklastyczna nie zamienia gruntu w lawę: w Shiptest ten kod nigdy się nie wykonywał (anomalyEffect nic nie
//   zwraca, więc warunek zawsze przerywał), zostaje grzanie i podpalanie w zasięgu;
// - duża bluespace teleportuje w zasięgu 4 na 12 pól i wstrzykuje płynny bluespace co puls oraz przy dotknięciu
//   (u nas zwykła teleportuje tylko sąsiadów na 4 pola);
// - duża strumienia razi wyładowaniem (tesla_zap) co sekundę i mocniej porusza prądem przy dotknięciu.

/obj/effect/anomaly/grav/high/planetary
	name = "silna anomalia grawitacyjna"
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/grav

/// Ogromna anomalia grawitacyjna: półtora raza większa, przesuwa nawet ciężkie rzeczy
/obj/effect/anomaly/grav/high/big
	name = "ogromna anomalia grawitacyjna"
	immortal = TRUE
	move_force = MOVE_FORCE_OVERPOWERING
	core_anomaly_type = /obj/effect/anomaly/grav

/obj/effect/anomaly/grav/high/big/Initialize(mapload, new_lifespan)
	. = ..()
	transform *= 1.5

/obj/effect/anomaly/grav/high/big/planetary
	immobile = TRUE

/// Ogromna anomalia bluespace
/obj/effect/anomaly/bluespace/big
	name = "ogromna anomalia bluespace"
	immortal = TRUE
	core_anomaly_type = /obj/effect/anomaly/bluespace
	/// Zasięg, z którego teleportuje, i odległość teleportu
	var/effectrange = 4
	var/teleport_distance = 12
	/// Ile płynnego bluespace wstrzykuje
	var/reagent_amount = 20
	var/pulse_delay = 15 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/anomaly/bluespace/big/Initialize(mapload, new_lifespan)
	. = ..()
	transform *= 1.5
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/bluespace/big/anomalyEffect(delta_time)
	..()
	for(var/mob/living/victim in range(effectrange, src))
		do_teleport(victim, locate(victim.x, victim.y, victim.z), teleport_distance, channel = TELEPORT_CHANNEL_BLUESPACE)
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	for(var/mob/living/carbon/victim in range(effectrange, src))
		victim.reagents?.add_reagent(/datum/reagent/bluespace, reagent_amount)

/obj/effect/anomaly/bluespace/big/Bumped(atom/movable/AM)
	if(iscarbon(AM))
		var/mob/living/carbon/victim = AM
		victim.reagents?.add_reagent(/datum/reagent/bluespace, reagent_amount)
	return ..()

/obj/effect/anomaly/bluespace/big/planetary
	immobile = TRUE

/// Ogromna anomalia strumienia
/obj/effect/anomaly/flux/big
	name = "ogromna anomalia strumienia"
	immortal = TRUE
	shockdamage = 30
	core_anomaly_type = /obj/effect/anomaly/flux
	/// Wyładowania co pulse_delay: zasięg i moc
	var/zap_range = 2
	var/zap_power = 3000
	var/pulse_delay = 1 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/anomaly/flux/big/Initialize(mapload, new_lifespan, drops_core = TRUE, explosive = ANOMALY_FLUX_EXPLOSIVE)
	. = ..()
	transform *= 1.5

/obj/effect/anomaly/flux/big/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	tesla_zap(src, zap_range, zap_power, TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE)

/obj/effect/anomaly/flux/big/Bumped(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		new /obj/effect/particle_effect/sparks(loc)
		tesla_zap(src, zap_range, zap_power, TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE)

/obj/effect/anomaly/flux/big/planetary
	immobile = TRUE

/// Ogromna anomalia piroklastyczna: dwa razy większa, grzeje wszystkich w zasięgu i podpala bliższych
/obj/effect/anomaly/pyro/big
	name = "ogromna anomalia piroklastyczna"
	immortal = TRUE
	fire_power = 60
	core_anomaly_type = /obj/effect/anomaly/pyro
	var/effectrange = 6
	var/pulse_delay = 2 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/anomaly/pyro/big/Initialize(mapload, new_lifespan)
	. = ..()
	transform *= 2

/obj/effect/anomaly/pyro/big/anomalyEffect(delta_time)
	..()
	for(var/mob/living/carbon/nearby in range(effectrange, src))
		nearby.adjust_bodytemperature(20)
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	for(var/mob/living/carbon/nearby in range(effectrange / 2, src))
		nearby.adjust_fire_stacks(3)
		nearby.IgniteMob()

/obj/effect/anomaly/pyro/big/planetary
	immobile = TRUE
