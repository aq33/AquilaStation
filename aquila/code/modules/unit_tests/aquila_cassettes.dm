// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - kasety: dane i kopie, wbudowana kaseta, kaseta w jukeboxie (strony, wyjęcie), walkman w SSjukeboxes
/datum/unit_test/aquila_cassettes

/datum/unit_test/aquila_cassettes/Run()
	// Wbudowana kaseta z config/cassettes jest zatwierdzona
	var/datum/cassette/friday = SScassettes.cassettes["friday"]
	TEST_ASSERT(friday, "Built-in cassette config/cassettes/friday.json was not loaded")
	TEST_ASSERT_EQUAL(friday.status, CASSETTE_STATUS_APPROVED, "Built-in cassettes should be approved")
	TEST_ASSERT(length(friday.front.songs), "Built-in cassette has no songs on side A")

	// Kopia jest niezależna od oryginału
	var/datum/cassette/copy = friday.copy()
	TEST_ASSERT_EQUAL(copy.name, friday.name, "Copied cassette lost its name")
	TEST_ASSERT_EQUAL(length(copy.front.songs), length(friday.front.songs), "Copied cassette lost songs")
	copy.front.songs.Cut(1, 2)
	TEST_ASSERT(length(copy.front.songs) != length(friday.front.songs), "Editing a copy changed the original cassette")
	qdel(copy)

	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, floor)
	var/obj/item/cassette_tape/tape = allocate(/obj/item/cassette_tape, floor)
	tape.cassette_data.front.songs += new /datum/cassette_song("Raz", "https://www.youtube.com/watch?v=1", 60)
	tape.cassette_data.front.songs += new /datum/cassette_song("Dwa", "https://www.youtube.com/watch?v=2", 90)

	// Kaseta w jukeboxie zastępuje playlistę, strona B jest pusta, po wyjęciu playlista wraca
	var/obj/machinery/jukebox/jukebox = allocate(/obj/machinery/jukebox, floor)
	jukebox.verify = FALSE
	user.put_in_hands(tape)
	TEST_ASSERT(jukebox.insert_tape(tape, user), "Jukebox refused the cassette")
	TEST_ASSERT_EQUAL(jukebox.inserted_tape, tape, "Cassette is not inside the jukebox")
	TEST_ASSERT_EQUAL(length(jukebox.yt_tracks), 2, "Jukebox should play the songs from side A")
	var/list/first = jukebox.yt_tracks[1]
	TEST_ASSERT_EQUAL(first["title"], "Raz", "Wrong first track")
	jukebox.flip_tape(user)
	TEST_ASSERT_EQUAL(length(jukebox.yt_tracks), 0, "Side B is empty")
	jukebox.eject_tape(user)
	TEST_ASSERT(isnull(jukebox.inserted_tape), "Cassette is still in the jukebox")
	TEST_ASSERT_EQUAL(tape.loc, user, "Ejected cassette should go to the user's hands")
	TEST_ASSERT_EQUAL(length(jukebox.yt_tracks), 0, "Jukebox kept the cassette tracks after eject")

	// Walkman: słucha go tylko ten, kto ma go przy sobie
	tape.flipped = FALSE
	var/obj/item/walkman/walkman = allocate(/obj/item/walkman, floor)
	user.put_in_hands(walkman)
	walkman.inserted_tape = tape
	tape.forceMove(walkman)
	walkman.track_index = 1
	walkman.stream_url = "https://example.com/song.m4a"
	walkman.extra_data = list("title" = "Raz")
	walkman.track_started = world.time
	walkman.track_end = world.time + 60 SECONDS
	walkman.playing = TRUE
	walkman.start_listening(user)
	TEST_ASSERT_EQUAL(SSjukeboxes.walkman_listeners[user], walkman, "Walkman listener was not registered")
	TEST_ASSERT(walkman.can_play_for(user), "Walkman should play for the person holding it")
	TEST_ASSERT_EQUAL(walkman.current_song()?.name, "Raz", "Wrong current walkman song")
	user.dropItemToGround(walkman)
	TEST_ASSERT(!walkman.can_play_for(user), "Dropped walkman should not play for its former holder")
	walkman.stop_listening()
	TEST_ASSERT(isnull(SSjukeboxes.walkman_listeners[user]), "Walkman listener was not removed")

	// Kasety w recenzji nie da się przerabiać w decku
	var/obj/machinery/cassette_deck/deck = allocate(/obj/machinery/cassette_deck, floor)
	deck.tape = allocate(/obj/item/cassette_tape, deck)
	deck.tape.cassette_data.status = CASSETTE_STATUS_REVIEWING
	TEST_ASSERT(!deck.can_edit(user), "Deck should not edit a cassette under review")
	deck.tape.cassette_data.status = CASSETTE_STATUS_DENIED
	TEST_ASSERT(deck.can_edit(user), "Deck should edit a denied cassette")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
