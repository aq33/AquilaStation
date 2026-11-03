// AQUILA - Smoke test komory testowej: każdy zestaw dostaje podstawowe interakcje i kilka sekund procesowania.
// Długi (kilka minut), więc nie chodzi w CI. Lokalnie: dm.exe -DCBT -DUNIT_TESTS -DTEST_CHAMBER_SMOKE nsv13.dme
// Wynik per zestaw w [GLOB.log_directory]/test_chamber_smoke.csv, runtime'y jak zwykle w tests.log.
// Żeby puścić tylko ten test, dopisz tymczasowo TEST_FOCUS(/datum/unit_test/test_chamber_smoke) (CI blokuje TEST_FOCUS w commitach).
// Skok cpu przy pojedynczym zestawie zwykle oznacza twarde usunięcie śmieci z wcześniejszych zestawów, sprawdź qdel.log.
#ifdef TEST_CHAMBER_SMOKE

/// Ile czekamy po interakcjach, żeby procesy, timery i rzucone przedmioty zdążyły zadziałać
#define SMOKE_SETTLE_TIME (3 SECONDS)

/datum/unit_test/test_chamber_smoke
	priority = TEST_DEFAULT

/datum/unit_test/test_chamber_smoke/Run()
	var/datum/test_chamber/chamber = get_test_chamber()
	if(!chamber)
		return Fail("Test chamber failed to load")

	var/csv = "[GLOB.log_directory]/test_chamber_smoke.csv"
	text2file("kit;pr;runtimes;hard_dels;spawn_ms;cpu_avg;cpu_max;objects", csv)
	var/list/failed_kits = list()

	for(var/name in test_chamber_kits())
		var/datum/test_chamber_kit/kit = test_chamber_kits()[name]
		if(!chamber.reset())
			Fail("Chamber failed to reset before [name]")
			break
		var/runtimes_before = GLOB.total_runtimes
		var/hard_dels_before = SSgarbage.totaldels
		var/start = REALTIMEOFDAY

		var/list/before = chamber_movables(chamber)
		chamber.spawn_kit(kit, null)
		var/list/spawned = chamber_movables(chamber) - before

		// Jedna małpa na cios; każdy przedmiot dostaje własnego człowieka, bo interakcje biegną równolegle
		var/mob/living/carbon/monkey/target = new(get_step(chamber.arrival, EAST))
		var/mob/living/carbon/human/actor = new(chamber.arrival)
		for(var/atom/movable/AM as anything in spawned)
			if(QDELETED(AM))
				continue
			if(isitem(AM))
				INVOKE_ASYNC(src, PROC_REF(exercise_item), new /mob/living/carbon/human(chamber.arrival), target, AM)
			else if(isliving(AM))
				var/mob/living/L = AM
				if(!L.key)
					INVOKE_ASYNC(L, TYPE_PROC_REF(/atom, attack_hand), actor)
			else if(isobj(AM))
				INVOKE_ASYNC(AM, TYPE_PROC_REF(/atom, attack_hand), actor)
			CHECK_TICK
		var/spawn_ms = (REALTIMEOFDAY - start) * 100

		// Próbki world.cpu w czasie procesowania zestawu
		var/cpu_sum = 0
		var/cpu_max = 0
		var/samples = 0
		var/settle_until = world.time + SMOKE_SETTLE_TIME
		while(world.time < settle_until)
			sleep(world.tick_lag)
			cpu_sum += world.cpu
			cpu_max = max(cpu_max, world.cpu)
			samples++

		var/runtimes = GLOB.total_runtimes - runtimes_before
		if(runtimes)
			failed_kits += "[name] ([runtimes])"
		text2file("[name];[kit.pr];[runtimes];[SSgarbage.totaldels - hard_dels_before];[round(spawn_ms)];[round(cpu_sum / max(samples, 1), 0.1)];[round(cpu_max, 0.1)];[length(spawned)]", csv)

	chamber.reset()
	if(length(failed_kits))
		Fail("Kits with runtimes: [english_list(failed_kits)]")

/// Wszystkie obiekty w komorze (obiekt wielokratkowy liczy się raz)
/datum/unit_test/test_chamber_smoke/proc/chamber_movables(datum/test_chamber/chamber)
	. = list()
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		for(var/atom/movable/AM as anything in T)
			.[AM] = TRUE

/// Przedmiot w rękę, użycie, cios w małpę, rzut
/datum/unit_test/test_chamber_smoke/proc/exercise_item(mob/living/carbon/human/actor, mob/living/target, obj/item/I)
	if(QDELETED(I) || QDELETED(actor) || I.anchored || !isturf(I.loc))
		return
	if(!actor.put_in_active_hand(I))
		return
	I.attack_self(actor)
	if(!QDELETED(I) && !QDELETED(actor) && I.loc == actor && !QDELETED(target))
		I.melee_attack_chain(actor, target)
	if(!QDELETED(I) && !QDELETED(actor) && I.loc == actor)
		actor.dropItemToGround(I)
		var/turf/throw_target = get_ranged_target_turf(actor, WEST, 3)
		if(throw_target && isturf(I.loc))
			I.throw_at(throw_target, 3, 1, actor)

#undef SMOKE_SETTLE_TIME

#endif
