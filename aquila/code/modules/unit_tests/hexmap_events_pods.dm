// AQUILA - testy eventów z kafli mapy hex: kapsuła ratunkowa, kapsuła z łupem, rój dronów, wiadomości gospodarcze, wybuch zsypu, zatkane ubikacje
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Toilet clog clogs the given number of toilets; the flood variant also overflows them and again on every flood tick
/datum/unit_test/aquila_hex_pods_toilet_clog

/datum/unit_test/aquila_hex_pods_toilet_clog/Run()
	var/turf/open/T1 = run_loc_floor_bottom_left
	var/turf/open/T2 = get_step(T1, EAST)
	var/turf/open/T3 = get_step(T2, EAST)
	for(var/turf/open/T in list(T1, T2, T3))
		aquila_liquids_cleanup(T)
	var/obj/structure/toilet/toilet1 = allocate(/obj/structure/toilet, T1)
	var/obj/structure/toilet/toilet2 = allocate(/obj/structure/toilet, T2)
	var/obj/structure/toilet/toilet3 = allocate(/obj/structure/toilet, T3)

	var/datum/round_event/aquila_hex_toilet_clog/clog = new(FALSE)
	TEST_ASSERT_EQUAL(clog.clog_toilets(list(toilet1, toilet2), 5), 2, "Clogging asked for more toilets than given did not clog both")
	TEST_ASSERT(toilet1.clogged && toilet2.clogged, "Toilet clog did not clog the toilets")
	TEST_ASSERT(QDELETED(T1.liquids) && QDELETED(T2.liquids), "A plain clog overflowed the toilets by itself")
	TEST_ASSERT_EQUAL(clog.clog_toilets(list(toilet1, toilet2), 1), 0, "Already clogged toilets were clogged again")
	clog.kill()

	var/datum/round_event/aquila_hex_toilet_clog/flood/flood = new(FALSE)
	TEST_ASSERT_EQUAL(flood.clog_toilets(list(toilet3), 1), 1, "Toilet flood did not clog the toilet")
	TEST_ASSERT(toilet3.clogged, "Toilet flood left the toilet unclogged")
	TEST_ASSERT(!QDELETED(T3.liquids), "Toilet flood did not overflow the toilet")
	aquila_liquids_cleanup(T3)
	flood.overflow_clogged()
	TEST_ASSERT(!QDELETED(T3.liquids), "A flood tick did not overflow the clogged toilet again")
	aquila_liquids_cleanup(T3)
	toilet3.clogged = FALSE // plunged
	flood.overflow_clogged()
	TEST_ASSERT(QDELETED(T3.liquids), "A plunged toilet still overflowed")
	TEST_ASSERT(!length(flood.clogged_toilets), "The flood still tracks a plunged toilet")
	flood.kill()
	for(var/turf/open/T in list(T1, T2, T3))
		aquila_liquids_cleanup(T)

/// The weakened disposal pipe bursts at the end of the event and spews trash; a pipe replaced in time does not
/datum/unit_test/aquila_hex_pods_disposals_explosion
	var/turf/test_turf
	var/turf_type

/datum/unit_test/aquila_hex_pods_disposals_explosion/Destroy()
	if(test_turf)
		for(var/obj/item/I in range(12, test_turf))
			if(istype(I, /obj/item/trash) || istype(I, /obj/item/stack/tile))
				qdel(I)
		for(var/obj/structure/disposalpipe/pipe in test_turf)
			qdel(pipe)
		if(test_turf.type != turf_type)
			test_turf.ChangeTurf(turf_type)
	test_turf = null
	return ..()

/datum/unit_test/aquila_hex_pods_disposals_explosion/Run()
	test_turf = run_loc_floor_bottom_left
	turf_type = test_turf.type
	var/obj/structure/disposalpipe/segment/pipe = new(test_turf)
	pipe.dpdir = NORTH | SOUTH

	var/datum/round_event/aquila_hex_disposals_explosion/event = new(FALSE)
	event.weaken_pipe(pipe)
	TEST_ASSERT(pipe.obj_integrity <= pipe.max_integrity * 0.35, "The pipe was not weakened ([pipe.obj_integrity]/[pipe.max_integrity])")
	TEST_ASSERT(event.pipe_weakened(), "The weakened pipe is not seen as weak")
	event.end()
	event.kill()
	TEST_ASSERT(QDELETED(pipe), "The weakened pipe did not burst")
	TEST_ASSERT(locate(/obj/structure/disposalpipe/broken) in test_turf, "The burst pipe left no broken pipe")
	var/trash_count = 0
	for(var/obj/item/trash/trash in range(12, test_turf))
		trash_count++
	TEST_ASSERT(trash_count >= 5, "The burst pipe spewed [trash_count] pieces of trash, expected at least 5")

	// Cut out with a welder before the end: the event stops and nothing bursts
	for(var/obj/structure/disposalpipe/broken/broken in test_turf)
		qdel(broken)
	var/obj/structure/disposalpipe/segment/replaced_pipe = new(test_turf)
	var/datum/round_event/aquila_hex_disposals_explosion/second_event = new(FALSE)
	second_event.weaken_pipe(replaced_pipe)
	qdel(replaced_pipe)
	TEST_ASSERT(isnull(second_event.bursting_pipe), "The event kept the pipe that was removed")
	TEST_ASSERT(!(second_event in SSevents.running), "The event kept running after its pipe was removed")

/// Economic news changes one trader's prices, also for goods restocked during the event, and puts them back
/datum/unit_test/aquila_hex_pods_economic_news

/datum/unit_test/aquila_hex_pods_economic_news/Run()
	var/datum/trader/trader = new
	var/datum/trader_item/item = new
	item.price = 1000
	trader.stonks += item

	var/datum/round_event/aquila_hex_economic_news/event = new(FALSE)
	event.affected_trader = trader
	event.price_multiplier = 1.5
	event.news_type = "pirates"
	event.apply_price_change()
	TEST_ASSERT_EQUAL(item.price, 1500, "The trader's price did not rise")
	var/datum/trader_item/restocked = new
	restocked.price = 200
	trader.stonks += restocked
	event.apply_price_change()
	TEST_ASSERT_EQUAL(restocked.price, 300, "A restocked item did not get the price change")
	TEST_ASSERT_EQUAL(item.price, 1500, "The price changed twice")
	TEST_ASSERT(findtext(event.article_body(), "wzrosły"), "The article does not say the prices rose")
	event.end()
	TEST_ASSERT_EQUAL(item.price, 1000, "The price was not restored")
	TEST_ASSERT_EQUAL(restocked.price, 200, "The restocked item's price was not restored")

	// An admin killing the event early must not leave the prices changed
	event.price_multiplier = 0.5
	event.apply_price_change()
	TEST_ASSERT_EQUAL(item.price, 500, "The trader's price did not drop")
	event.kill()
	TEST_ASSERT_EQUAL(item.price, 1000, "Killing the event did not restore the price")

	trader.stonks.Cut()
	qdel(item)
	qdel(restocked)
	qdel(trader)

/// The loot pod carries loot and 2-4 guards of the chosen side, and drops them where it lands
/datum/unit_test/aquila_hex_pods_loot_pod
	var/turf/test_turf

/datum/unit_test/aquila_hex_pods_loot_pod/Destroy()
	if(test_turf)
		for(var/atom/movable/AM in test_turf)
			if(isliving(AM) || isitem(AM))
				qdel(AM)
	test_turf = null
	return ..()

/datum/unit_test/aquila_hex_pods_loot_pod/Run()
	test_turf = run_loc_floor_bottom_left
	var/datum/round_event/aquila_hex_loot_pod/event = new(FALSE)
	event.syndicate_guards = TRUE
	var/obj/structure/closet/supplypod/pod = allocate(/obj/structure/closet/supplypod, test_turf)
	event.fill_pod(pod)
	event.kill()
	var/guards = 0
	var/loot = 0
	for(var/atom/movable/AM in pod)
		if(istype(AM, /mob/living/basic/trooper/syndicate))
			guards++
		else if(isliving(AM))
			return Fail("The Syndicate loot pod carries a [AM.type]")
		else if(isitem(AM))
			loot++
	TEST_ASSERT(guards >= 2 && guards <= 4, "The loot pod carries [guards] guards, expected 2-4")
	TEST_ASSERT(loot >= 4, "The loot pod carries only [loot] items")
	pod.open_pod(pod)
	TEST_ASSERT(!length(pod.contents), "The landed pod kept its contents")
	var/landed_guards = 0
	for(var/mob/living/basic/trooper/syndicate/guard in test_turf)
		landed_guards++
	TEST_ASSERT_EQUAL(landed_guards, guards, "The guards did not come out of the pod")

/// Castaways get their outfit, the burglar the burglary tools
/datum/unit_test/aquila_hex_pods_rescue_pod

/datum/unit_test/aquila_hex_pods_rescue_pod/Run()
	var/datum/round_event/aquila_hex_rescue_pod/event = new(FALSE)
	event.kill()
	var/mob/living/carbon/human/castaway = event.make_castaway(run_loc_floor_bottom_left, FALSE)
	allocated += castaway
	TEST_ASSERT(istype(castaway.wear_suit, /obj/item/clothing/suit/space/fragile), "The castaway has no emergency space suit")
	TEST_ASSERT(isnull(castaway.ckey), "The castaway body got a player without a poll")
	var/mob/living/carbon/human/burglar = event.make_castaway(run_loc_floor_bottom_left, TRUE)
	allocated += burglar
	TEST_ASSERT(istype(burglar.wear_mask, /obj/item/clothing/mask/balaclava), "The burglar has no balaclava")
	TEST_ASSERT(locate(/obj/item/crowbar) in burglar.back, "The burglar has no crowbar in the backpack")

/// Drones of the swarm fly in space, and the swarm takes its drones away when it leaves
/datum/unit_test/aquila_hex_pods_rogue_drone_swarm

/datum/unit_test/aquila_hex_pods_rogue_drone_swarm/Run()
	var/datum/round_event/aquila_hex_rogue_drone_swarm/event = new(FALSE)
	var/mob/living/basic/hivebot/range/aquila_hex_rogue_drone/drone = event.spawn_drone(run_loc_floor_bottom_left)
	TEST_ASSERT(drone.spacewalk, "The rogue drone cannot move in space")
	qdel(drone)
	TEST_ASSERT(!length(event.drones), "A destroyed drone stayed on the swarm's list")
	var/mob/living/basic/hivebot/range/aquila_hex_rogue_drone/second_drone = event.spawn_drone(run_loc_floor_bottom_left)
	event.end()
	event.kill()
	TEST_ASSERT(QDELETED(second_drone), "The drone stayed after the swarm left")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
