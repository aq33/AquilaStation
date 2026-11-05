// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - on Linux the INVOKE_YOUTUBEDL from config.txt (.\yt-dlp.exe) becomes a command that can run there
/datum/unit_test/aquila_linux_ytdl

/datum/unit_test/aquila_linux_ytdl/Run()
	// Not qdel'd: Destroy() would take the real entry out of the config
	var/datum/config_entry/string/invoke_youtubedl/entry = new
	TEST_ASSERT(entry.ValidateAndSet(".\\yt-dlp.exe --no-check-certificate"), "INVOKE_YOUTUBEDL was rejected")
	if(world.system_type == UNIX)
		TEST_ASSERT(!findtext(entry.config_entry_value, ".exe"), "Linux still gets a Windows yt-dlp: [entry.config_entry_value]")
		TEST_ASSERT(findtext(entry.config_entry_value, "yt-dlp --no-check-certificate"), "The yt-dlp options were lost: [entry.config_entry_value]")
	else
		TEST_ASSERT_EQUAL(entry.config_entry_value, ".\\yt-dlp.exe --no-check-certificate", "Windows INVOKE_YOUTUBEDL was changed")

	// Any other command is left alone
	TEST_ASSERT(entry.ValidateAndSet("youtube-dl"), "INVOKE_YOUTUBEDL was rejected")
	TEST_ASSERT_EQUAL(entry.config_entry_value, "youtube-dl", "A non yt-dlp.exe command was changed")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
