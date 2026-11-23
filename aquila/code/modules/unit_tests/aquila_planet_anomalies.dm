// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - planety: anomalie planetarne z Shiptesta nie wygasają, stoją w miejscu, działają na człowieka obok
/// i dają się zneutralizować sygnałem z kodem rdzenia, który zostaje na ziemi; spawnery stawiają anomalię
/datum/unit_test/planet_shiptest_anomalies

/datum/unit_test/planet_shiptest_anomalies/Run()
	var/list/anomaly_types = list(
		/obj/effect/anomaly/grav/high/planetary,
		/obj/effect/anomaly/grav/high/big/planetary,
		/obj/effect/anomaly/bluespace/big/planetary,
		/obj/effect/anomaly/flux/big/planetary,
		/obj/effect/anomaly/pyro/big/planetary,
		/obj/effect/anomaly/heartbeat/planetary,
		/obj/effect/anomaly/sparkler/planetary,
		/obj/effect/anomaly/tvstatic/planetary,
		/obj/effect/anomaly/tvstatic/blackbox,
		/obj/effect/anomaly/veins/planetary,
		/obj/effect/anomaly/veins/helltree,
		/obj/effect/anomaly/phantom/planetary,
		/obj/effect/anomaly/melter/planetary,
		/obj/effect/anomaly/transfusion/planetary,
		/obj/effect/anomaly/chronograph/planetary,
	)
	var/turf/center = run_loc_floor_bottom_left
	var/turf/beside = get_step(center, EAST)
	for(var/anomaly_type in anomaly_types)
		var/obj/effect/anomaly/anomaly = new anomaly_type(center)
		TEST_ASSERT(anomaly.immortal, "[anomaly_type] isn't immortal")
		TEST_ASSERT(!anomaly.countdown, "[anomaly_type] has a countdown")
		TEST_ASSERT(icon_exists(anomaly.icon, anomaly.icon_state), "[anomaly_type] has no sprite [anomaly.icon_state]")
		TEST_ASSERT(icon_exists(anomaly.aSignal.icon, anomaly.aSignal.icon_state), "[anomaly.aSignal.type] has no sprite [anomaly.aSignal.icon_state]")
		var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, beside)
		for(var/i in 1 to 5)
			if("pulse_cooldown" in anomaly.vars)
				anomaly.vars["pulse_cooldown"] = 0
			if("pulse_secondary_cooldown" in anomaly.vars)
				anomaly.vars["pulse_secondary_cooldown"] = 0
			anomaly.anomalyEffect(2)
			TEST_ASSERT(anomaly.loc == center, "[anomaly_type] moved")
		// Fontanna i widmowa przy dotknięciu sypią wnętrznościami, a te w pokoju testowym bez grawitacji wpadają
		// w błąd komponentu dryfu z core, więc tych dwóch test nie dotyka
		if(!istype(anomaly, /obj/effect/anomaly/veins) && !istype(anomaly, /obj/effect/anomaly/phantom))
			anomaly.Bumped(victim)
		TEST_ASSERT(!QDELETED(anomaly), "[anomaly_type] deleted itself while working")
		TEST_ASSERT(anomaly.loc == center, "[anomaly_type] moved after being touched")
		// Neutralizacja: sygnał z kodem rdzenia
		var/obj/item/assembly/signaler/anomaly/core = anomaly.aSignal
		var/datum/signal/signal = new(list("code" = core.code))
		core.receive_signal(signal)
		TEST_ASSERT(QDELETED(anomaly), "[anomaly_type] wasn't neutralized by its core's signal")
		TEST_ASSERT(core.loc == center, "[anomaly_type] didn't drop its core")
		qdel(core)
		qdel(victim)
		for(var/atom/movable/leftover as anything in center.contents + beside.contents)
			// Śmieci po działaniu (wnętrzności, iskry, dłonie) i ciało wyplute przez szum
			if((isobj(leftover) && !istype(leftover, /obj/effect/landmark)) || (ishuman(leftover) && leftover != victim))
				qdel(leftover)

	// Działanie: transfuzyjna i fontanna zabierają krew, chronograf przyspiesza
	var/mob/living/carbon/human/donor = allocate(/mob/living/carbon/human, beside)
	var/obj/effect/anomaly/transfusion/planetary/transfusion = new(center)
	var/blood_before = donor.blood_volume
	transfusion.blood_music()
	TEST_ASSERT(donor.blood_volume < blood_before, "The transfusion anomaly didn't take blood from a healthy human")
	qdel(transfusion)
	donor.blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/effect/anomaly/veins/planetary/veins = new(center)
	veins.drain_blood()
	TEST_ASSERT(donor.blood_volume < BLOOD_VOLUME_NORMAL, "The fountain anomaly didn't drain blood")
	qdel(veins)
	var/obj/effect/anomaly/chronograph/planetary/chronograph = new(center)
	chronograph.anomalyEffect(2)
	TEST_ASSERT(donor.has_status_effect(/datum/status_effect/accelerando), "The chronograph didn't speed up a human next to it")
	qdel(chronograph)
	donor.remove_status_effect(/datum/status_effect/accelerando)

	// Spawnery stawiają anomalię
	for(var/spawner_type in subtypesof(/obj/effect/spawner/lootdrop/planetary_anomaly))
		new spawner_type(center)
		var/obj/effect/anomaly/spawned = locate() in center
		TEST_ASSERT(spawned, "[spawner_type] spawned no anomaly")
		for(var/obj/effect/anomaly/anomaly in center)
			qdel(anomaly)
		for(var/mob/living/carbon/human/stored in center)
			if(stored != donor)
				qdel(stored)

#undef TEST_ASSERT
