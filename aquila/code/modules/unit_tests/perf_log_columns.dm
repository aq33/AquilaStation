// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Every perf CSV row has as many fields as the header
/datum/unit_test/perf_log_columns

/datum/unit_test/perf_log_columns/Run()
	// fire() divides by the ticks since its last run
	for(var/i in 1 to 2)
		sleep(world.tick_lag)
		SStime_track.fire()
	var/list/lines = splittext(trim(file2text(GLOB.perf_log)), "\n")
	// The log can hold earlier runs with the same file name, check this round's header
	var/header_line = 0
	for(var/i in length(lines) to 1 step -1)
		if(findtext(lines[i], "time,", 1, 6))
			header_line = i
			break
	TEST_ASSERT(header_line, "The perf log has no header")
	TEST_ASSERT(length(lines) - header_line >= 2, "The perf log has [length(lines) - header_line] rows after two fire() calls")
	var/header_fields = length(splittext(lines[header_line], ","))
	for(var/i in header_line + 1 to length(lines))
		var/row_fields = length(splittext(lines[i], ","))
		TEST_ASSERT(row_fields == header_fields, "Perf log row [i - header_line] has [row_fields] fields, the header has [header_fields]")

#undef TEST_ASSERT
