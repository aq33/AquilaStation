// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the jukebox only hands YouTube/SoundCloud links to the server-side yt-dlp (no requests to 127.0.0.1 or the internal network)
/datum/unit_test/aquila_jukebox_url_whitelist

/datum/unit_test/aquila_jukebox_url_whitelist/Run()
	var/list/allowed = list(
		"https://www.youtube.com/playlist?list=PL3QLD4mbUqkmQytxtaEQY8ShmFBBzTreg",
		"https://youtube.com/watch?v=dQw4w9WgXcQ",
		"https://music.youtube.com/watch?v=dQw4w9WgXcQ",
		"https://youtu.be/dQw4w9WgXcQ",
		"http://M.YouTube.com/watch?v=x",
		"https://soundcloud.com/artist/track",
		"https://on.soundcloud.com/abc",
		"https://api-v2.soundcloud.com/tracks/123",
		"https://soundcloud.com"
	)
	for(var/url in allowed)
		TEST_ASSERT(aquila_jukebox_url_allowed(url), "Jukebox rejected an allowed link: [url]")

	var/list/rejected = list(
		"http://127.0.0.1:8080/admin",
		"http://localhost/",
		"http://10.0.0.1/",
		"https://youtube.com@127.0.0.1/",
		"https://youtube.com.evil.example/",
		"https://evilyoutube.com/",
		"https://.youtube.com/",
		"file:///etc/passwd",
		"youtube.com/watch?v=x",
		""
	)
	for(var/url in rejected)
		TEST_ASSERT(!aquila_jukebox_url_allowed(url), "Jukebox accepted a forbidden link: [url]")

	// cmd /c expands %VAR% even inside quotes - on Windows no % may reach the command line
	if(world.system_type == MS_WINDOWS)
		var/scrubbed = shell_url_scrub("https://youtube.com/watch?v=a-b_c%PATH%&x=%CD%")
		TEST_ASSERT(!findtext(scrubbed, "%"), "shell_url_scrub let a % through: [scrubbed]")
		TEST_ASSERT(findtext(scrubbed, "v=a-b_c"), "shell_url_scrub broke a YouTube video id: [scrubbed]")

/// AQUILA - a negative transfer used to reverse the direction and create money (newscaster bounty with a negative value)
/datum/unit_test/aquila_negative_transfer

/datum/unit_test/aquila_negative_transfer/Run()
	var/datum/job/assistant = SSjob.GetJob(JOB_NAME_ASSISTANT)
	var/datum/bank_account/payer = allocate(/datum/bank_account, "Test Payer", assistant)
	var/datum/bank_account/receiver = allocate(/datum/bank_account, "Test Receiver", assistant)
	payer.account_balance = 100
	receiver.account_balance = 100

	TEST_ASSERT(!receiver.transfer_money(payer, -50), "A negative transfer was accepted")
	TEST_ASSERT_EQUAL(payer.account_balance, 100, "A negative transfer changed the payer's balance")
	TEST_ASSERT_EQUAL(receiver.account_balance, 100, "A negative transfer changed the receiver's balance")

	TEST_ASSERT(receiver.transfer_money(payer, 0), "A zero transfer (e.g. a 0 cr paycheck) is no longer accepted")
	TEST_ASSERT(receiver.transfer_money(payer, 30), "A normal transfer failed")
	TEST_ASSERT_EQUAL(payer.account_balance, 70, "The payer's balance after a normal transfer")
	TEST_ASSERT_EQUAL(receiver.account_balance, 130, "The receiver's balance after a normal transfer")

/// AQUILA - paying a fine with a holochip takes only what is owed (the rest stays on the chip) and a paid fine takes nothing
/datum/unit_test/aquila_warrant_holochip_change

/datum/unit_test/aquila_warrant_holochip_change/Run()
	var/obj/machinery/computer/warrant/console = allocate(/obj/machinery/computer/warrant)
	var/mob/living/carbon/human/payer = allocate(/mob/living/carbon/human)
	var/obj/item/holochip/chip = allocate(/obj/item/holochip, null, 150)
	payer.put_in_hands(chip)
	TEST_ASSERT(payer.is_holding(chip), "The payer could not pick up the holochip")

	var/datum/data/record/record = new
	record.fields["id"] = "aquila_test_warrant"
	record.fields["name"] = "Test Payer"
	var/datum/data/crime/fine = GLOB.data_core.createCrimeEntry("Test", "Test", "Test", "00:00", 100)
	record.fields["citation"] = list(fine)
	GLOB.data_core.security += record
	var/list/params = list("crew_ref" = "aquila_test_warrant", "fine_ref" = "[fine.dataId]")

	console.pay_fine_holochip(payer, params)
	var/paid_first = fine.paid
	var/chip_left = QDELETED(chip) ? 0 : chip.credits
	console.pay_fine_holochip(payer, params)
	var/paid_second = fine.paid
	var/chip_left_second = QDELETED(chip) ? 0 : chip.credits

	GLOB.data_core.security -= record
	qdel(record)

	TEST_ASSERT_EQUAL(paid_first, 100, "A 150 cr holochip did not pay exactly the 100 cr fine")
	TEST_ASSERT_EQUAL(chip_left, 50, "The change did not stay on the holochip")
	TEST_ASSERT_EQUAL(paid_second, 100, "An already paid fine took more money")
	TEST_ASSERT_EQUAL(chip_left_second, 50, "Paying an already paid fine used up the holochip")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
