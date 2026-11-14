// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Kanał gazety, do którego priority_announce wrzuca ogłoszenia
/proc/aquila_test_station_news_channel()
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		if(channel.channel_name == "Ogłoszenia stacji")
			return channel

/// Ogłoszenie fali mięsoroidów miało dźwięk w miejscu tytułu: w gazecie i czacie tytułem było „announcer_meteors”
/datum/unit_test/aquila_meateor_announcement_title

/datum/unit_test/aquila_meateor_announcement_title/Run()
	var/datum/feed_channel/station_channel = aquila_test_station_news_channel()
	TEST_ASSERT(station_channel, "Brak kanału „Ogłoszenia stacji” w sieci newsów")
	var/old_count = length(station_channel.messages)
	var/datum/round_event/meteor_wave/meaty/event = new(FALSE)
	SSevents.running -= event
	event.announce(FALSE)
	qdel(event)
	TEST_ASSERT(length(station_channel.messages) == old_count + 1, "Ogłoszenie nie trafiło do kanału ogłoszeń")
	var/datum/feed_message/article = station_channel.messages[length(station_channel.messages)]
	TEST_ASSERT(findtext(article.body, "Alarm meteorytowy<br><br>") == 1, "Artykuł ogłoszenia zaczyna się od „[copytext(article.body, 1, 40)]” zamiast tytułu")

/// Zastępczy prom ewakuacyjny: game_end() królowej sprawdza tylko tryb i woła request()
/datum/aquila_test_emergency_stub
	var/mode = SHUTTLE_IDLE
	var/requested = FALSE

/datum/aquila_test_emergency_stub/proc/request(obj/machinery/computer/communications/call_from, set_coefficient)
	requested = TRUE

/// Ogłoszenie inwazji ksenomorfów miało dźwięk w miejscu tytułu: tytułem artykułu była ścieżka pliku
/datum/unit_test/aquila_queen_announcement_title

/datum/unit_test/aquila_queen_announcement_title/Run()
	var/datum/feed_channel/station_channel = aquila_test_station_news_channel()
	TEST_ASSERT(station_channel, "Brak kanału „Ogłoszenia stacji” w sieci newsów")
	var/mob/living/carbon/alien/humanoid/royal/queen/queen = allocate(/mob/living/carbon/alien/humanoid/royal/queen)
	if(!is_station_level(queen.z))
		// game_end() sprawdza tylko poziom Z, więc wystarczy dowolny turf stacji
		var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
		TEST_ASSERT(length(station_levels), "Mapa testowa nie ma poziomu stacji")
		queen.forceMove(locate(1, 1, station_levels[1]))
	TEST_ASSERT(is_station_level(queen.z), "Królowa nie stoi na poziomie stacji, game_end() nic nie ogłosi")
	var/old_emergency = SSshuttle.emergency
	var/old_no_recall = SSshuttle.emergencyNoRecall
	var/datum/aquila_test_emergency_stub/stub = new
	var/old_count = length(station_channel.messages)
	SSshuttle.emergency = stub
	queen.game_end()
	SSshuttle.emergency = old_emergency
	SSshuttle.emergencyNoRecall = old_no_recall
	TEST_ASSERT(stub.requested, "game_end() nie wezwał promu")
	TEST_ASSERT(length(station_channel.messages) == old_count + 1, "Ogłoszenie nie trafiło do kanału ogłoszeń")
	var/datum/feed_message/article = station_channel.messages[length(station_channel.messages)]
	TEST_ASSERT(findtext(article.body, "Wykryto inwazję ksenomorfów") == 1, "Artykuł ogłoszenia zaczyna się od „[copytext(article.body, 1, 40)]” zamiast treści")

/// Każde nagranie eventu jest w domyślnym announcerze, a announcer bez nagrań eventów (stażysta) gra swój alert
/datum/unit_test/aquila_event_announcement_sounds

/datum/unit_test/aquila_event_announcement_sounds/Run()
	var/datum/centcom_announcer/default/default_announcer = new
	for(var/name in GLOB.aquila_event_announcement_sounds)
		var/clip = default_announcer.event_sounds[ANNOUNCER_EVENT(name)]
		TEST_ASSERT(isfile(clip), "Domyślny announcer nie ma nagrania [name]")
	var/old_announcer = SSstation.announcer
	var/datum/centcom_announcer/intern/intern = new
	SSstation.announcer = default_announcer
	var/default_sound = aquila_event_announcement_sound(ANNOUNCER_EVENT("anomaly_grav"))
	SSstation.announcer = intern
	var/intern_sound = aquila_event_announcement_sound(ANNOUNCER_EVENT("anomaly_grav"))
	SSstation.announcer = old_announcer
	TEST_ASSERT(default_sound == ANNOUNCER_EVENT("anomaly_grav"), "Domyślny announcer nie zostawił klucza nagrania eventu")
	TEST_ASSERT(intern_sound in intern.alert_sounds, "Stażysta zamiast swojego alertu dostał [intern_sound]")
	TEST_ASSERT(aquila_event_announcement_sound(ANNOUNCER_METEORS) == ANNOUNCER_METEORS, "Zwykły klucz announcera został podmieniony")

#undef TEST_ASSERT
