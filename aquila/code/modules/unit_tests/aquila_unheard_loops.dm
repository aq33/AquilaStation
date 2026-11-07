// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/datum/looping_sound/aquila_unheard_test
	mid_sounds = list('sound/machines/click.ogg' = 1)
	mid_length = 5
	var/plays = 0
	var/stops = 0

/datum/looping_sound/aquila_unheard_test/play(soundfile)
	plays++

/datum/looping_sound/aquila_unheard_test/stop(null_parent)
	stops++
	return ..()

/// AQUILA - pętla dźwiękowa nie gra bez słuchacza w zasięgu, gra przy słuchaczu, a max_loops dalej ją kończy
/datum/unit_test/aquila_unheard_loops
	var/test_z
	var/list/saved_clients
	var/list/saved_dead

/datum/unit_test/aquila_unheard_loops/Run()
	var/turf/source_turf = run_loc_floor_bottom_left
	test_z = source_turf.z
	// Na czas testu nikt nie słucha na tym z-levelu, niezależnie od tego, kto jest na serwerze
	saved_clients = SSmobs.clients_by_zlevel[test_z]
	saved_dead = SSmobs.dead_players_by_zlevel[test_z]
	SSmobs.clients_by_zlevel[test_z] = list()
	SSmobs.dead_players_by_zlevel[test_z] = list()

	var/obj/item/source = allocate(/obj/item/toy/crayon/red, source_turf)
	var/datum/looping_sound/aquila_unheard_test/loop = new(source)

	loop.sound_loop(world.time)
	TEST_ASSERT_EQUAL(loop.plays, 0, "Pętla zagrała, choć w zasięgu nie ma nikogo")

	loop.skip_unheard = FALSE
	loop.sound_loop(world.time)
	TEST_ASSERT_EQUAL(loop.plays, 1, "Pętla z skip_unheard = FALSE nie zagrała bez słuchacza")
	loop.skip_unheard = TRUE

	var/turf/near_turf = locate(source_turf.x + 2, source_turf.y, test_z)
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human, near_turf)
	SSmobs.clients_by_zlevel[test_z] += listener
	loop.sound_loop(world.time)
	TEST_ASSERT_EQUAL(loop.plays, 2, "Pętla nie zagrała przy słuchaczu 2 kratki dalej")

	SSmobs.clients_by_zlevel[test_z] -= listener
	SSmobs.dead_players_by_zlevel[test_z] += listener
	loop.sound_loop(world.time)
	TEST_ASSERT_EQUAL(loop.plays, 3, "Pętla nie zagrała przy martwym graczu 2 kratki dalej")
	SSmobs.dead_players_by_zlevel[test_z] -= listener

	var/far_x = source_turf.x + SOUND_RANGE + 5
	if(far_x > world.maxx)
		far_x = source_turf.x - SOUND_RANGE - 5
	var/turf/far_turf = locate(far_x, source_turf.y, test_z)
	TEST_ASSERT(far_turf, "Brak kafelka poza zasięgiem dźwięku")
	listener.forceMove(far_turf)
	SSmobs.clients_by_zlevel[test_z] += listener
	loop.sound_loop(world.time)
	TEST_ASSERT_EQUAL(loop.plays, 3, "Pętla zagrała do słuchacza poza zasięgiem")

	// Pętla z limitem powtórzeń kończy się także wtedy, gdy nikt jej nie słyszy
	SSmobs.clients_by_zlevel[test_z] -= listener
	loop.max_loops = 1
	loop.sound_loop(world.time - loop.mid_length * 2)
	TEST_ASSERT_EQUAL(loop.stops, 1, "Pętla po max_loops nie zatrzymała się bez słuchacza")
	TEST_ASSERT_EQUAL(loop.plays, 3, "Pętla po max_loops zagrała")

	qdel(loop)

/datum/unit_test/aquila_unheard_loops/Destroy()
	if(test_z)
		SSmobs.clients_by_zlevel[test_z] = saved_clients
		SSmobs.dead_players_by_zlevel[test_z] = saved_dead
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
