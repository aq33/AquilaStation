// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - dźwięk przestrzenny: ściana i zamknięte drzwi wygłuszają, otwarte nie; za ścianą stłumiona kopia, ciszej
/// i mniej ścieżki suchej; panorama łagodniejsza; pogłos z kształtu pomieszczenia
/datum/unit_test/aquila_sound_occlusion

/datum/unit_test/aquila_sound_occlusion/Run()
	var/turf/source_turf = run_loc_floor_bottom_left
	var/turf/middle_turf = locate(source_turf.x + 1, source_turf.y, source_turf.z)
	var/turf/listener_turf = locate(source_turf.x + 2, source_turf.y, source_turf.z)
	TEST_ASSERT(listener_turf.x <= run_loc_floor_top_right.x, "Test room is too narrow")

	// Pusta podłoga nie wygłusza
	TEST_ASSERT_EQUAL(get_sound_occlusion(source_turf, listener_turf), 0, "Open floor should not occlude")

	// Zamknięte drzwi wygłuszają, otwarte nie
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, middle_turf)
	door.density = TRUE
	TEST_ASSERT_EQUAL(get_sound_occlusion(source_turf, listener_turf), door.sound_dampening, "Closed door should occlude by its sound_dampening")
	door.density = FALSE
	TEST_ASSERT_EQUAL(get_sound_occlusion(source_turf, listener_turf), 0, "Open door should not occlude")
	qdel(door)

	// Ściana (fałszywa, żeby nie przebudowywać kafelka) wygłusza; po przekątnej linia też ją trafia
	var/obj/structure/falsewall/wall = allocate(/obj/structure/falsewall, middle_turf)
	TEST_ASSERT_EQUAL(get_sound_occlusion(source_turf, listener_turf), wall.sound_dampening, "A wall should occlude")
	TEST_ASSERT_EQUAL(get_sound_occlusion(listener_turf, source_turf), wall.sound_dampening, "Occlusion should not depend on the direction")
	var/turf/diagonal_turf = locate(source_turf.x + 2, source_turf.y + 1, source_turf.z)
	if(diagonal_turf && diagonal_turf.y <= run_loc_floor_top_right.y)
		TEST_ASSERT_EQUAL(get_sound_occlusion(source_turf, diagonal_turf), wall.sound_dampening, "The line to (2, 1) should cross the wall")
	qdel(wall)

	// Za ścianą: stłumiona kopia, ciszej i mniej ścieżki suchej
	var/sound/S = sound('sound/effects/bang.ogg')
	S.volume = 100
	var/original = apply_sound_occlusion(S, 0.45)
	TEST_ASSERT_EQUAL("[original]", "sound/effects/bang.ogg", "Should return the original file to restore")
	TEST_ASSERT_EQUAL("[S.file]", "[GLOB.muffled_sounds["sound/effects/bang.ogg"]]", "Should switch to the muffled copy")
	TEST_ASSERT(S.volume < 100 && S.volume > 50, "One wall should make it quieter, not silent (got [S.volume])")
	TEST_ASSERT(S.echo[1] < 0, "One wall should lower the direct path")
	// Ten sam /sound idzie do kolejnego słuchacza bez przeszkód
	S.file = original
	S.volume = 100
	TEST_ASSERT(isnull(apply_sound_occlusion(S, 0)), "Nothing in the way should not switch the file")
	TEST_ASSERT_EQUAL(S.volume, 100, "Nothing in the way should keep the volume")
	TEST_ASSERT_EQUAL(S.echo[1], 0, "The direct path should be restored for the next listener")
	// Szyba ścisza, ale nie podmienia pliku
	TEST_ASSERT(isnull(apply_sound_occlusion(S, 0.15)), "A plain window should not muffle the file")

	// Panorama bez klienta (stała pozycja): dźwięk z boku ma wysokość, więc nie gra w jednym uchu
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human, listener_turf)
	var/sound/positioned = sound('sound/effects/bang.ogg')
	listener.apply_sound_position(positioned, source_turf, listener_turf, null, 1, 0)
	TEST_ASSERT_EQUAL(positioned.x, -2, "Source two tiles to the left")
	TEST_ASSERT(positioned.y > 1, "A sound from the side should be lifted to soften the pan (y = [positioned.y])")
	TEST_ASSERT(isnull(positioned:atom), "Without a client the sound should not be tracked")

	// Pogłos z kształtu pomieszczenia
	TEST_ASSERT_EQUAL(classify_sound_environment(12, 0, 0), SOUND_AREA_SMALL_ENCLOSED, "Small hard room")
	TEST_ASSERT_EQUAL(classify_sound_environment(12, 0, 0.9), SOUND_AREA_SMALL_SOFTFLOOR, "Small carpeted room")
	TEST_ASSERT_EQUAL(classify_sound_environment(90, 0.9, 0), SOUND_ENVIRONMENT_HALLWAY, "Corridor")
	TEST_ASSERT_EQUAL(classify_sound_environment(600, 0.1, 0), SOUND_AREA_LARGE_ENCLOSED, "Large hall")
	TEST_ASSERT_EQUAL(classify_sound_environment(120, 0.2, 0), SOUND_AREA_STANDARD_STATION, "Medium room keeps the station reverb")
	TEST_ASSERT_EQUAL(classify_sound_environment(120, 0.2, 0.6), SOUND_AREA_MEDIUM_SOFTFLOOR, "Medium carpeted room")

	// Z daleka: stłumiona kopia bez ściany po drodze
	var/sound/far = sound('sound/effects/bang.ogg')
	far.volume = 100
	TEST_ASSERT(!isnull(apply_sound_occlusion(far, 0, 12)), "A sound from 12 tiles should use the muffled copy")
	TEST_ASSERT_EQUAL(far.volume, 100, "Distance alone should not change the volume (playsound_local does the falloff)")

	// Szczelny hełm: wszystko przytłumione
	var/obj/item/clothing/head/helmet/space/helmet = allocate(/obj/item/clothing/head/helmet/space)
	listener.equip_to_slot_or_del(helmet, ITEM_SLOT_HEAD)
	TEST_ASSERT(listener.has_sealed_helmet(), "A space helmet should count as sealed")
	var/sound/inside = sound('sound/effects/bang.ogg')
	inside.volume = 100
	TEST_ASSERT(!isnull(apply_sound_occlusion(inside, 0, 1, listener)), "A sealed helmet should muffle even a close sound")
	TEST_ASSERT(inside.volume < 100, "A sealed helmet should make it a bit quieter")
	qdel(helmet)

	// Dookoła ściany przez otwarte drzwi: ściana na prostej, drzwi kafelek wyżej
	var/turf/door_turf = locate(source_turf.x + 1, source_turf.y + 1, source_turf.z)
	if(door_turf && door_turf.y <= run_loc_floor_top_right.y)
		var/obj/structure/falsewall/blocking = allocate(/obj/structure/falsewall, middle_turf)
		var/obj/machinery/door/airlock/side_door = allocate(/obj/machinery/door/airlock, door_turf)
		side_door.density = FALSE
		GLOB.sound_path_cache = null
		var/list/heard = sound_heard_through(source_turf, listener, 80, SOUND_RANGE, source_turf)
		TEST_ASSERT(heard[1] < 0.3, "A loud sound should go around the wall through the open door (got [heard[1]])")
		TEST_ASSERT(isturf(heard[2]) && heard[2] != source_turf, "The sound should come from the side of the door")
		var/through_door = heard[1]
		// Zamknięte drzwi: zostaje tylko dłuższa droga dookoła pokoju testowego albo sama ściana
		side_door.density = TRUE
		GLOB.sound_path_cache = null
		heard = sound_heard_through(source_turf, listener, 80, SOUND_RANGE, source_turf)
		TEST_ASSERT(heard[1] > through_door, "A closed door should muffle more than an open one ([heard[1]] vs [through_door])")
		TEST_ASSERT(heard[1] <= blocking.sound_dampening, "A way around should never muffle more than the wall")
		heard = sound_heard_through(source_turf, listener, 10, SOUND_RANGE, source_turf)
		TEST_ASSERT_EQUAL(heard[1], blocking.sound_dampening, "A quiet sound should not look for a way around")
		qdel(side_door)
		qdel(blocking)

	// Szum otoczenia: słychać najbliższe źródło, jeden szum na rodzaj, za ścianą ciszej
	var/obj/machinery/aquila_test_hum/hum = allocate(/obj/machinery/aquila_test_hum, source_turf)
	var/obj/machinery/aquila_test_hum/second_hum = allocate(/obj/machinery/aquila_test_hum, middle_turf)
	var/list/picked = SSambient_emitters.select_for(listener_turf)
	TEST_ASSERT(second_hum in picked, "The closest hum should be picked")
	TEST_ASSERT(!(hum in picked), "Two hums of the same kind should play as one")
	qdel(second_hum)
	picked = SSambient_emitters.select_for(listener_turf)
	var/open_volume = picked[hum]
	TEST_ASSERT(open_volume > 0, "A hum two tiles away should be heard")
	var/obj/structure/falsewall/hum_wall = allocate(/obj/structure/falsewall, middle_turf)
	picked = SSambient_emitters.select_for(listener_turf)
	TEST_ASSERT(picked[hum] < open_volume, "A hum behind a wall should be quieter")
	qdel(hum_wall)
	qdel(hum)
	TEST_ASSERT(!length(SSambient_emitters.select_for(listener_turf)), "A deleted machine should stop humming")

/// Maszyna, która zawsze szumi (do testu)
/obj/machinery/aquila_test_hum
	ambient_hum = 'aquila/sound/ambience/emitters/vent.ogg'
	ambient_hum_range = 5
	use_power = NO_POWER_USE

/obj/machinery/aquila_test_hum/ambient_hum_active()
	return TRUE

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
