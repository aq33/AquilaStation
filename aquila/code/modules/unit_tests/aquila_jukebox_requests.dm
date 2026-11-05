// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - jukebox YouTube: Stop i odblokowanie po zawieszeniu unieważniają zapytanie do yt-dlp w toku,
/// a okno nie wywala się na numerze utworu spoza playlisty
/datum/unit_test/aquila_jukebox_requests

/datum/unit_test/aquila_jukebox_requests/Run()
	var/obj/machinery/jukebox/jukebox = allocate(/obj/machinery/jukebox, run_loc_floor_bottom_left)

	// Stop w trakcie zapytania
	var/request = jukebox.yt_set_busy(TRUE)
	TEST_ASSERT(jukebox.yt_request_valid(request), "A fresh request is not valid")
	jukebox.yt_stop()
	TEST_ASSERT(!jukebox.yt_busy, "Stop left the jukebox busy")
	TEST_ASSERT(!jukebox.yt_request_valid(request), "A request still counts after Stop")

	// Nowe zapytanie unieważnia stare
	var/old_request = jukebox.yt_set_busy(TRUE)
	var/new_request = jukebox.yt_set_busy(TRUE)
	TEST_ASSERT(!jukebox.yt_request_valid(old_request), "An older request still counts")
	TEST_ASSERT(jukebox.yt_request_valid(new_request), "The newest request is not valid")

	// Odblokowanie po zawieszeniu
	jukebox.yt_busy_since = world.time - 100 SECONDS
	jukebox.yt_check_stuck()
	TEST_ASSERT(!jukebox.yt_busy, "A stuck request did not unblock the jukebox")
	TEST_ASSERT(!jukebox.yt_request_valid(new_request), "A timed out request still counts")

	// Numer utworu spoza wczytanej playlisty (np. po wczytaniu krótszej) nie wywala okna
	jukebox.yt_tracks = list(list("id" = "a", "url" = "https://example.com/a", "title" = "A", "duration" = 60))
	jukebox.yt_index = 5
	jukebox.yt_active = TRUE
	TEST_ASSERT(jukebox.yt_ui(null), "The jukebox window did not render")
	jukebox.yt_active = FALSE

#undef TEST_ASSERT
