// AQUILA - Smoke test komory testowej: każdy zestaw dostaje podstawowe interakcje i kilka sekund procesowania.
// Długi (kilka minut), więc nie chodzi w CI. Lokalnie: dm.exe -DCBT -DUNIT_TESTS -DTEST_CHAMBER_SMOKE nsv13.dme
// Wynik per zestaw w [GLOB.log_directory]/test_chamber_smoke.csv, runtime'y jak zwykle w tests.log.
// Żeby puścić tylko ten test, dopisz tymczasowo TEST_FOCUS(/datum/unit_test/test_chamber_smoke) (CI blokuje TEST_FOCUS w commitach).
// Skok cpu przy pojedynczym zestawie zwykle oznacza twarde usunięcie śmieci z wcześniejszych zestawów, sprawdź qdel.log.
#ifdef TEST_CHAMBER_SMOKE

/// Ile czekamy po interakcjach, żeby procesy, timery i rzucone przedmioty zdążyły zadziałać
#define SMOKE_SETTLE_TIME (3 SECONDS)
/// Ile najwyżej czekamy dodatkowo na interakcje, które same śpią (do_after, sleep w attack_self)
#define SMOKE_PENDING_TIMEOUT (15 SECONDS)

/datum/unit_test/test_chamber_smoke
	priority = TEST_DEFAULT
	/// Nazwa zestawu -> ile jego interakcji jeszcze nie wróciło; osobno, bo spóźniona interakcja zestawu nie może zdjąć licznika następnego
	var/list/pending = list()

/datum/unit_test/test_chamber_smoke/Run()
	var/datum/test_chamber/chamber = get_test_chamber()
	if(!chamber)
		return Fail("Test chamber failed to load")

	var/csv = "[GLOB.log_directory]/test_chamber_smoke.csv"
	fdel(csv)
	text2file("kit;pr;runtimes;hard_dels;spawn_ms;cpu_avg;cpu_max;objects;unfinished", csv)
	var/list/failed_kits = list()

	// Sprzątanie poprzedniej rundy testów nie liczy się do pierwszego zestawu
	if(!chamber.reset())
		return Fail("Chamber failed to reset before the first kit")

	for(var/name in test_chamber_kits())
		var/datum/test_chamber_kit/kit = test_chamber_kits()[name]
		var/runtimes_before = GLOB.total_runtimes
		var/hard_dels_before = SSgarbage.totaldels
		var/start = REALTIMEOFDAY
		pending[name] = 0

		// Część zestawów (zdrajca, darkspawn) robi setup() tylko dla człowieka z umysłem
		var/mob/living/carbon/human/kit_user = new(chamber.arrival)
		kit_user.mind_initialize()
		var/list/before = chamber_movables(chamber)
		chamber.spawn_kit(kit, kit_user)
		var/list/spawned = chamber_movables(chamber) - before

		// Jedna małpa na cios; każdy przedmiot dostaje własnego człowieka, bo interakcje biegną równolegle
		var/mob/living/carbon/monkey/target = new(get_step(chamber.arrival, EAST))
		var/mob/living/carbon/human/actor = new(chamber.arrival)
		for(var/atom/movable/AM as anything in spawned)
			if(QDELETED(AM))
				continue
			if(isitem(AM))
				INVOKE_ASYNC(src, PROC_REF(exercise_item), name, new /mob/living/carbon/human(chamber.arrival), target, AM)
			else if(isliving(AM))
				var/mob/living/L = AM
				if(!L.key)
					INVOKE_ASYNC(src, PROC_REF(exercise_hand), name, actor, L)
			else if(isobj(AM))
				INVOKE_ASYNC(src, PROC_REF(exercise_hand), name, actor, AM)
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
		// Interakcje, które śpią dłużej, kończą się tutaj, a nie w trakcie następnego zestawu
		var/pending_until = world.time + SMOKE_PENDING_TIMEOUT
		while(pending[name] > 0 && world.time < pending_until)
			sleep(world.tick_lag)
		// Nie Fail: interakcja może po prostu długo czekać (do_after bez klienta), a jej runtime i tak trafi do tests.log
		var/unfinished = pending[name]

		// Reset po zestawie liczy się do niego: runtime'y z Destroy() i usunięcia zostają przy właściwym zestawie
		if(!chamber.reset())
			Fail("Chamber failed to reset after [name]")
			break

		var/runtimes = GLOB.total_runtimes - runtimes_before
		if(runtimes)
			failed_kits += "[name] ([runtimes])"
		text2file("[name];[kit.pr];[runtimes];[SSgarbage.totaldels - hard_dels_before];[round(spawn_ms)];[round(cpu_sum / max(samples, 1), 0.1)];[round(cpu_max, 0.1)];[length(spawned)];[unfinished]", csv)

	if(length(failed_kits))
		Fail("Kits with runtimes: [english_list(failed_kits)]")

/// Klik ręką w maszynę lub moba; licznik pending wraca też po runtime'ie
/datum/unit_test/test_chamber_smoke/proc/exercise_hand(kit_name, mob/living/carbon/human/actor, atom/A)
	pending[kit_name]++
	try
		if(!QDELETED(A) && !QDELETED(actor))
			A.attack_hand(actor)
	catch(var/exception/e)
		pending[kit_name]--
		throw e
	pending[kit_name]--

/// Wszystkie obiekty w komorze (obiekt wielokratkowy liczy się raz)
/datum/unit_test/test_chamber_smoke/proc/chamber_movables(datum/test_chamber/chamber)
	. = list()
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		for(var/atom/movable/AM as anything in T)
			.[AM] = TRUE

/// Przedmiot w rękę, użycie, cios w małpę, rzut; licznik pending wraca też po runtime'ie
/datum/unit_test/test_chamber_smoke/proc/exercise_item(kit_name, mob/living/carbon/human/actor, mob/living/target, obj/item/I)
	pending[kit_name]++
	try
		use_item(actor, target, I)
	catch(var/exception/e)
		pending[kit_name]--
		throw e
	pending[kit_name]--

/datum/unit_test/test_chamber_smoke/proc/use_item(mob/living/carbon/human/actor, mob/living/target, obj/item/I)
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
#undef SMOKE_PENDING_TIMEOUT

#endif
