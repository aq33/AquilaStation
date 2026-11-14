// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Ogłoszenie fali mięsoroidów miało dźwięk w miejscu tytułu: w gazecie i czacie tytułem było „announcer_meteors”
/datum/unit_test/aquila_meateor_announcement_title

/datum/unit_test/aquila_meateor_announcement_title/Run()
	var/datum/feed_channel/station_channel
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		if(channel.channel_name == "Ogłoszenia stacji")
			station_channel = channel
			break
	TEST_ASSERT(station_channel, "Brak kanału „Ogłoszenia stacji” w sieci newsów")
	var/old_count = length(station_channel.messages)
	var/datum/round_event/meteor_wave/meaty/event = new(FALSE)
	SSevents.running -= event
	event.announce(FALSE)
	qdel(event)
	TEST_ASSERT(length(station_channel.messages) == old_count + 1, "Ogłoszenie nie trafiło do kanału ogłoszeń")
	var/datum/feed_message/article = station_channel.messages[length(station_channel.messages)]
	TEST_ASSERT(findtext(article.body, "Alarm meteorytowy<br><br>") == 1, "Artykuł ogłoszenia zaczyna się od „[copytext(article.body, 1, 40)]” zamiast tytułu")

#undef TEST_ASSERT
