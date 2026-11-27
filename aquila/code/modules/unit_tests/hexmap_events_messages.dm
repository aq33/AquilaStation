// AQUILA - testy eventów z kafli mapy hex, etap E1 (wiadomości, komunikaty i drobne prezenty): pule terenów, artykuły
// w kanale informacyjnym, spam na PDA i faksach, prezent z Centrali, ankieta, premia, aktualizacja komputerów, nowe prawo, burza Ianów
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Every E1 event is in the pool of its own terrain only; the empty space ones still spawn as plain ship events
/datum/unit_test/aquila_hex_messages_pools

/datum/unit_test/aquila_hex_messages_pools/Run()
	var/list/allowed_terrains = list(
		/datum/round_event_control/aquila_hex_trivial_news = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_mundane_news = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_news_report = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_pda_spam = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_fax_spam = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_cargo_gifts = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_centcom_questionnaire = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_money_bonus = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_computer_update = HEX_TERRAIN_ION,
		/datum/round_event_control/aquila_hex_new_space_law = HEX_TERRAIN_ION,
		/datum/round_event_control/aquila_hex_ian_storm = HEX_TERRAIN_WORMHOLE,
	)
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/path in allowed_terrains)
		var/datum/round_event_control/control = hex_event_control(path)
		TEST_ASSERT(control, "No event control of [path]")
		var/terrain_id = allowed_terrains[path]
		TEST_ASSERT(path in hex_terrain(terrain_id).events, "[control.name] is not in the pool of [terrain_id]")
		for(var/id in GLOB.hex_terrains)
			if(id != terrain_id)
				TEST_ASSERT(!(path in hex_terrain(id).events), "[control.name] is also in the pool of [id]")
		if(terrain_id == HEX_TERRAIN_EMPTY)
			TEST_ASSERT(!hex_tile_environment_events()[path], "[control.name] of empty space is dropped from the ship events")
			if(GLOB.hexmap?.built)
				TEST_ASSERT(hex_random_event_allowed(control), "SSevents cannot roll [control.name] with the hex map built")
		else
			TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")

/// The three news events each post an article to the galactic news channel; a sector story comes out once per round
/datum/unit_test/aquila_hex_messages_news

/datum/unit_test/aquila_hex_messages_news/Run()
	var/channel_name = aquila_hex_news_channel()
	TEST_ASSERT(channel_name, "The galactic news channel was not created")
	var/datum/feed_channel/channel
	for(var/datum/feed_channel/FC as anything in GLOB.news_network.network_channels)
		if(FC.channel_name == channel_name)
			channel = FC
	TEST_ASSERT(channel, "The galactic news channel is not on the news network")
	for(var/event_type in list(/datum/round_event/aquila_hex_news/trivial, /datum/round_event/aquila_hex_news/mundane, /datum/round_event/aquila_hex_news/report))
		var/before = length(channel.messages)
		var/datum/round_event/aquila_hex_news/news = new event_type(FALSE)
		news.kill()
		news.start()
		TEST_ASSERT_EQUAL(length(channel.messages), before + 1, "[event_type] did not post one article")
		var/datum/feed_message/article = channel.messages[length(channel.messages)]
		TEST_ASSERT(length(article.body) > 40, "[event_type] posted an empty article")
		qdel(news)

	var/datum/round_event_control/aquila_hex_news_report/report_control = hex_event_control(/datum/round_event_control/aquila_hex_news_report)
	var/list/saved_used = report_control.used_stories.Copy()
	report_control.used_stories.Cut()
	var/datum/round_event/aquila_hex_news/report/report = new(FALSE)
	report.kill()
	report.control = report_control
	var/list/seen = list()
	for(var/i in 1 to length(aquila_hex_sector_stories()))
		var/list/story = report.make_article()
		TEST_ASSERT(story, "Sector news ran out of stories after [i - 1]")
		TEST_ASSERT(!(story[1] in seen), "The sector story \"[story[1]]\" came out twice")
		seen += story[1]
	TEST_ASSERT(isnull(report.make_article()), "Sector news gave a story after all were used")
	TEST_ASSERT(!report_control.canSpawnEvent(100), "Sector news can still spawn with no stories left")
	report_control.used_stories = saved_used
	qdel(report)

/// PDA spam reaches a tablet's messenger as an automated message
/datum/unit_test/aquila_hex_messages_pda_spam

/datum/unit_test/aquila_hex_messages_pda_spam/Run()
	var/obj/item/modular_computer/tablet/pda/pda = allocate(/obj/item/modular_computer/tablet/pda, run_loc_floor_bottom_left)
	pda.saved_identification = "Jan Testowy"
	pda.saved_job = "Asystent"
	var/datum/round_event/aquila_hex_pda_spam/spam = new(FALSE)
	spam.kill()
	var/datum/computer_file/program/messenger/messenger = spam.tablet_messenger(pda)
	TEST_ASSERT(messenger, "The PDA has no messenger")
	var/before = length(messenger.messages)
	var/datum/signal/subspace/messaging/tablet_msg/signal = spam.make_signal(pda)
	TEST_ASSERT(signal, "No spam signal for the PDA")
	TEST_ASSERT(signal.data["automated"], "The spam is not an automated message")
	signal.logged = signal // as if a message server logged it
	signal.broadcast()
	TEST_ASSERT_EQUAL(length(messenger.messages), before + 1, "The spam did not reach the messenger")
	var/list/message = messenger.messages[length(messenger.messages)]
	TEST_ASSERT(length(message["contents"]), "The spam message is empty")
	messenger.sending_and_receiving = FALSE
	TEST_ASSERT(!(pda in spam.spam_targets()), "A PDA with the messenger off is a spam target")
	qdel(spam)

/// Fax spam prints the flyer on a fax
/datum/unit_test/aquila_hex_messages_fax_spam

/datum/unit_test/aquila_hex_messages_fax_spam/Run()
	var/obj/machinery/fax/fax = allocate(/obj/machinery/fax, run_loc_floor_bottom_left)
	var/datum/round_event/aquila_hex_fax_spam/spam = new(FALSE)
	spam.kill()
	TEST_ASSERT(length(spam.flyer) == 2, "Fax spam has no flyer")
	var/obj/item/paper/flyer = spam.send_flyer(fax, "Nieznany nadawca")
	TEST_ASSERT(flyer, "The fax did not get the flyer")
	TEST_ASSERT_EQUAL(flyer.name, spam.flyer[1], "The flyer has the wrong name")
	TEST_ASSERT(length(flyer.raw_text_inputs), "The flyer is blank")
	var/list/last = fax.fax_history[length(fax.fax_history)]
	TEST_ASSERT_EQUAL(last["history_type"], "Receive", "The fax did not receive the flyer")
	qdel(flyer)
	qdel(spam)

/// The gift for a department is a set of unlocked crates from our cargo packs
/datum/unit_test/aquila_hex_messages_cargo_gifts

/datum/unit_test/aquila_hex_messages_cargo_gifts/Run()
	var/datum/round_event/aquila_hex_cargo_gifts/gift = new(FALSE)
	gift.kill()
	for(var/department in gift.gift_variants())
		gift.gift_department = department
		var/list/crates = gift.make_gift_crates()
		TEST_ASSERT_EQUAL(length(crates), length(gift.gift_variants()[department]), "The gift for [department] is missing crates")
		for(var/obj/structure/closet/crate/crate in crates)
			TEST_ASSERT(!crate.locked, "A gift crate for [department] is locked")
			TEST_ASSERT(length(crate.contents), "A gift crate for [department] is empty")
		QDEL_LIST(crates)
	qdel(gift)

/// The questionnaire pays the cargo budget only for a complete, signed form faxed to Central Command in time
/datum/unit_test/aquila_hex_messages_questionnaire

/datum/unit_test/aquila_hex_messages_questionnaire/Run()
	var/obj/machinery/fax/fax = allocate(/obj/machinery/fax, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/sender = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/bank_account/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
	TEST_ASSERT(cargo, "No cargo budget")
	var/datum/round_event/aquila_hex_centcom_questionnaire/survey = new(FALSE)
	survey.kill()
	survey.home_fax_ref = WEAKREF(fax)
	survey.deadline = world.time + 10 MINUTES
	var/obj/item/paper/aquila_hex_questionnaire/form = survey.make_form()
	TEST_ASSERT(length(form.raw_text_inputs), "The questionnaire is blank")
	form.add_field_input(0, "7")
	form.add_field_input(1, "Karp zjadł kanapkę kapitana.")
	var/balance = cargo.account_balance
	var/replies = length(fax.fax_history)
	TEST_ASSERT(!survey.receive_answer(form), "An unsigned questionnaire was accepted")
	TEST_ASSERT_EQUAL(cargo.account_balance, balance, "An unsigned questionnaire paid the budget")
	TEST_ASSERT(length(fax.fax_history) > replies, "No reply fax for an incomplete questionnaire")
	form.add_field_input(2, "%sign", signature_name = "Jan Testowy")
	TEST_ASSERT(form.questionnaire_complete(), "A filled, signed questionnaire is not complete")
	fax.send_to_additional_faxes(form, sender, "Centrala", "#34c924")
	TEST_ASSERT(survey.answered, "Faxing the form to Central Command did not answer the questionnaire")
	TEST_ASSERT_EQUAL(cargo.account_balance, balance + survey.reward, "The questionnaire did not pay the cargo budget")
	TEST_ASSERT(!survey.receive_answer(form), "The questionnaire paid twice")
	TEST_ASSERT_EQUAL(cargo.account_balance, balance + survey.reward, "The questionnaire paid twice")
	cargo.adjust_money(-survey.reward)
	qdel(form)
	qdel(survey)

/// The money bonus pays the rolled amount to the right budget
/datum/unit_test/aquila_hex_messages_money_bonus

/datum/unit_test/aquila_hex_messages_money_bonus/Run()
	var/datum/round_event/aquila_hex_money_bonus/bonus = new(FALSE)
	bonus.kill()
	for(var/tier in list("refund", "grant", "priority"))
		bonus.roll_bonus(tier)
		TEST_ASSERT(bonus.amount > 0, "The [tier] bonus is empty")
		if(tier == "grant")
			TEST_ASSERT(bonus.account_id != ACCOUNT_CAR, "The grant goes to the cargo budget")
		else
			TEST_ASSERT_EQUAL(bonus.account_id, ACCOUNT_CAR, "The [tier] bonus does not go to the cargo budget")
		var/datum/bank_account/account = SSeconomy.get_dep_account(bonus.account_id)
		TEST_ASSERT(account, "No [bonus.account_id] account")
		var/balance = account.account_balance
		bonus.start()
		TEST_ASSERT_EQUAL(account.account_balance, balance + bonus.amount, "The [tier] bonus was not paid")
		account.adjust_money(-bonus.amount)
	qdel(bonus)

/// An updating console and tablet show the progress instead of their screen until the update ends
/datum/unit_test/aquila_hex_messages_computer_update

/datum/unit_test/aquila_hex_messages_computer_update/Run()
	var/obj/machinery/computer/station_alert/console = allocate(/obj/machinery/computer/station_alert, run_loc_floor_bottom_left)
	var/obj/item/modular_computer/tablet/pda/pda = allocate(/obj/item/modular_computer/tablet/pda, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!console.aquila_update_blocks(user), "A console blocks without an update")
	var/datum/round_event/aquila_hex_computer_update/update = new(FALSE)
	update.kill()
	TEST_ASSERT(update.start_update(console, 60 SECONDS), "The console did not start the update")
	TEST_ASSERT(update.start_update(pda, 60 SECONDS), "The PDA did not start the update")
	TEST_ASSERT_EQUAL(update.updated, 2, "The update count is wrong")
	TEST_ASSERT(console.aquila_update_blocks(user), "An updating console does not block")
	TEST_ASSERT(pda.aquila_update_blocks(user), "An updating PDA does not block")
	TEST_ASSERT(findtext(aquila_update_screen(world.time - 30 SECONDS, world.time + 30 SECONDS), "50%"), "Half way through the update does not show 50%")
	console.aquila_update_until = world.time
	pda.aquila_update_until = world.time
	TEST_ASSERT(!console.aquila_update_blocks(user), "The console still blocks after the update")
	TEST_ASSERT(!pda.aquila_update_blocks(user), "The PDA still blocks after the update")
	qdel(update)

/// The new space law announces one of the 25 bans
/datum/unit_test/aquila_hex_messages_new_space_law

/datum/unit_test/aquila_hex_messages_new_space_law/Run()
	TEST_ASSERT_EQUAL(length(aquila_hex_space_law_bans()), 25, "The space law ban list has the wrong length")
	var/datum/round_event/aquila_hex_new_space_law/law = new(FALSE)
	law.kill()
	TEST_ASSERT(law.new_law in aquila_hex_space_law_bans(), "No ban was picked")
	TEST_ASSERT(findtext(law.law_text(), law.new_law), "The announcement does not name the ban")
	qdel(law)

/// The Ian storm puts a corgi named Ian <letter> next to a crew member
/datum/unit_test/aquila_hex_messages_ian_storm

/datum/unit_test/aquila_hex_messages_ian_storm/Run()
	var/turf/center = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z)
	var/datum/round_event/aquila_hex_ian_storm/storm = new(FALSE)
	storm.kill()
	var/mob/living/basic/pet/dog/corgi/ian = storm.place_ian(center)
	TEST_ASSERT(ian, "The Ian storm placed no corgi next to a free floor")
	allocated += ian
	TEST_ASSERT(findtext(ian.name, "Ian ") == 1, "The corgi is named [ian.name], not Ian <letter>")
	TEST_ASSERT(get_dist(ian, center) <= 1, "The corgi landed [get_dist(ian, center)] tiles away")
	TEST_ASSERT_EQUAL(storm.ians, 1, "The Ian count is wrong")
	TEST_ASSERT(isnull(storm.place_ian(null)), "A corgi was placed without a turf")
	qdel(storm)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
