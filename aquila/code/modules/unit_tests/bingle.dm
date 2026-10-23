// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - bingle: punkty Dołu, wymiar, odrzucanie istot, wzrost i zwrot zawartości
/datum/unit_test/bingle

/datum/unit_test/bingle/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)

	var/datum/weighted_ghost_midround/midround = new
	TEST_ASSERT(/datum/round_event_control/bingle in midround.heavy_events(), "Bingle is not in the heavy weighted pool")
	qdel(midround)

	var/obj/structure/bingle_hole/hole = allocate(/obj/structure/bingle_hole, left)
	var/mob/living/simple_animal/hostile/bingle/bingle = allocate(/mob/living/simple_animal/hostile/bingle, right, hole)
	TEST_ASSERT_EQUAL(bingle.linked_pit, hole, "Bingle is not linked to its pit")

	// Przedmiot to 1 punkt, stos tyle, ile ma sztuk
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, right)
	crayon.forceMove(left)
	TEST_ASSERT_EQUAL(hole.item_value_consumed, 1, "Item was not worth 1 point")
	var/obj/item/stack/sheet/iron/iron = allocate(/obj/item/stack/sheet/iron, right)
	iron.amount = 7
	iron.forceMove(left)
	TEST_ASSERT_EQUAL(hole.item_value_consumed, 8, "Stack was not worth its amount")

	// Połknięte rzeczy trafiają do wymiaru
	hole.finish_swallow(crayon)
	TEST_ASSERT(GLOB.bingle_pit_reservation, "Bingle pit dimension was not created")
	TEST_ASSERT(istype(get_area(crayon), /area/centcom/bingle_pit), "Swallowed item is not in the bingle pit")
	var/turf/open/pit_floor = get_turf(crayon)
	TEST_ASSERT(pit_floor.air?.return_pressure() > 50, "Bingle pit has no air")

	// Bingle i istoty przed progiem nie wpadają
	bingle.forceMove(left)
	TEST_ASSERT_EQUAL(hole.item_value_consumed, 8, "Bingle fell into its own pit")
	bingle.forceMove(right)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, right)
	victim.forceMove(left)
	TEST_ASSERT_EQUAL(hole.item_value_consumed, 8, "Pit accepted a creature too early")
	TEST_ASSERT(!hole.falling[victim], "Creature is falling below the threshold")

	// Od 100 punktów Dół rośnie i przyjmuje istoty
	hole.item_value_consumed = BINGLE_PIT_LIVING_THRESHOLD
	hole.last_bingle_spawn_value = hole.item_value_consumed // bez ankiety duchów w teście
	hole.process(2)
	TEST_ASSERT_EQUAL(hole.current_pit_size, 2, "Pit did not grow at 100 points")
	TEST_ASSERT_EQUAL(length(hole.pit_overlays), 4, "2x2 pit has the wrong amount of overlays")
	var/mob/living/carbon/human/second_victim = allocate(/mob/living/carbon/human, get_step(right, EAST))
	// W pokoju testowym nie ma grawitacji, a stojący unoszą się nad Dołem, więc wrzucamy zwłoki
	second_victim.death()
	second_victim.forceMove(left)
	TEST_ASSERT_EQUAL(hole.item_value_consumed, BINGLE_PIT_LIVING_THRESHOLD + 10, "Creature was not worth 10 points")
	victim = second_victim
	hole.finish_swallow(victim)
	TEST_ASSERT(istype(get_area(victim), /area/centcom/bingle_pit), "Swallowed creature is not in the bingle pit")

	// Pancerz od 500 punktów (bez wzrostu, bo od 4x4 Dół zjadłby ściany pokoju testowego)
	hole.current_pit_size = BINGLE_PIT_MAX_SIZE
	hole.item_value_consumed = BINGLE_PIT_ARMOR_THRESHOLD
	hole.last_bingle_spawn_value = hole.item_value_consumed
	hole.process(2)
	TEST_ASSERT(bingle.evolved, "Bingle did not evolve at 500 points")
	TEST_ASSERT_EQUAL(bingle.maxHealth, 200, "Evolved bingle has the wrong health")

	// Zniszczony Dół oddaje zawartość (bingla odpinamy, żeby test nie puszczał losowego dymu)
	bingle.set_linked_pit(null)
	qdel(hole)
	// Zwrot idzie asynchronicznie z CHECK_TICK, więc czekamy, aż obie rzeczy wrócą
	for(var/i in 1 to 100)
		if(crayon.z == left.z && victim.z == left.z)
			break
		sleep(1)
	TEST_ASSERT(get_dist(crayon, left) <= 6 && crayon.z == left.z, "Destroyed pit did not eject its contents")
	TEST_ASSERT(get_dist(victim, left) <= 6 && victim.z == left.z, "Destroyed pit did not eject the creature")

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Bingle test caused runtimes")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
