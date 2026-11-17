// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - woda na planetach: człowiek w głębokiej wodzie jest zanurzony, płynie, męczy się, po wyczerpaniu tonie,
/// a na brzegu przestaje; głęboka woda nie nadaje się do lądowania, płytka tak
/datum/unit_test/planet_water_swimming

/datum/unit_test/planet_water_swimming/Run()
	var/turf/shore = run_loc_floor_bottom_left
	var/turf/old_deep_type = get_step(shore, EAST)
	var/old_type_one = old_deep_type.type
	var/turf/open/water/planet/deep_one = old_deep_type.ChangeTurf(/turf/open/water/planet/beach/deep)
	var/turf/second = get_step(deep_one, EAST)
	var/old_type_two = second.type
	var/turf/open/water/planet/deep_two = second.ChangeTurf(/turf/open/water/planet/beach/deep)
	var/turf/third = get_step(deep_two, EAST)
	var/old_type_three = third.type
	var/turf/open/water/planet/shallow = third.ChangeTurf(/turf/open/water/planet/beach)

	TEST_ASSERT(is_planet_hazard_turf(deep_one), "Deep water is safe to land on")
	TEST_ASSERT(!is_planet_hazard_turf(shallow), "Shallow water counts as a landing hazard")

	var/mob/living/carbon/human/swimmer = allocate(/mob/living/carbon/human, shore)
	swimmer.forceMove(deep_one)
	TEST_ASSERT(HAS_TRAIT(swimmer, TRAIT_IMMERSED), "A human in deep water isn't immersed")
	TEST_ASSERT(swimmer.has_status_effect(/datum/status_effect/swimming), "A human in deep water isn't swimming")

	// Każdy krok w głębokiej wodzie może męczyć (30%): 40 kroków to praktycznie pewne zmęczenie
	for(var/i in 1 to 40)
		swimmer.forceMove(i % 2 ? deep_two : deep_one)
	TEST_ASSERT(swimmer.getStaminaLoss() > 0, "Swimming in deep water doesn't cost stamina")
	TEST_ASSERT(HAS_TRAIT(swimmer, TRAIT_IMMERSED), "Moving between deep water turfs lost the immersion")

	// Stojący człowiek nie tonie, wyczerpany (leżący) tak
	var/datum/status_effect/swimming/swimming = swimmer.has_status_effect(/datum/status_effect/swimming)
	TEST_ASSERT(!swimming.is_drowning(), "A standing human drowns in deep water")
	swimmer.Paralyze(20 SECONDS)
	TEST_ASSERT(swimming.is_drowning(), "An exhausted (lying) human doesn't drown in deep water")
	var/oxy_before = swimmer.getOxyLoss()
	swimming.drown()
	TEST_ASSERT(swimmer.getOxyLoss() > oxy_before, "Drowning doesn't deal oxygen damage")
	swimmer.SetParalyzed(0)

	// Wyjście na brzeg kończy pływanie i zanurzenie
	swimmer.forceMove(shore)
	TEST_ASSERT(!HAS_TRAIT(swimmer, TRAIT_IMMERSED), "A human on the shore is still immersed")
	TEST_ASSERT(!swimmer.has_status_effect(/datum/status_effect/swimming), "A human on the shore is still swimming")

	// Płytka woda zanurza, ale nie każe pływać
	swimmer.forceMove(shallow)
	TEST_ASSERT(HAS_TRAIT(swimmer, TRAIT_IMMERSED), "A human in shallow water isn't immersed")
	TEST_ASSERT(!swimmer.has_status_effect(/datum/status_effect/swimming), "A human in shallow water swims")
	swimmer.forceMove(shore)

	deep_one.ChangeTurf(old_type_one)
	deep_two.ChangeTurf(old_type_two)
	shallow.ChangeTurf(old_type_three)

/// AQUILA - wędkarstwo: zarzucenie wędki w łowisko zaczyna łowienie, wygrana minigra daje rybę do ręki i zjada
/// przynętę, a w lawie łowi tylko wędka z żyłką odporną na żar
/datum/unit_test/planet_water_fishing

/datum/unit_test/planet_water_fishing/Run()
	var/turf/shore = run_loc_floor_bottom_left
	var/turf/water_turf = get_step(shore, EAST)
	var/old_type = water_turf.type
	var/turf/open/water/planet/water = water_turf.ChangeTurf(/turf/open/water/planet/beach)

	var/mob/living/carbon/human/fisher = allocate(/mob/living/carbon/human, shore)
	var/obj/item/fishing_rod/rod = allocate(/obj/item/fishing_rod)
	fisher.put_in_active_hand(rod)
	var/obj/item/food/fishing_worm/worm = allocate(/obj/item/food/fishing_worm)
	rod.attackby(worm, fisher)
	TEST_ASSERT(rod.bait == worm, "A worm can't be put on the hook")

	TEST_ASSERT(rod.cast_line(water, fisher), "Casting into beach water doesn't start fishing")
	TEST_ASSERT(HAS_TRAIT(fisher, TRAIT_GONE_FISHING), "The fisher isn't fishing after casting")
	var/datum/fishing_challenge/challenge = GLOB.fishing_challenges_by_user[fisher]
	TEST_ASSERT(challenge, "Casting didn't create a fishing challenge")
	rod.cast_line(water, fisher)
	TEST_ASSERT(GLOB.fishing_challenges_by_user[fisher] == challenge, "A second cast started another challenge")

	// Minigra wymaga klienta: wynik wymuszony jak po wygranej (branie złapane, ryba wyholowana)
	challenge.reward_path = /datum/aquarium_behaviour/fish/planet/perch
	challenge.phase = 3 // MINIGAME_PHASE
	challenge.complete(TRUE)
	TEST_ASSERT(!HAS_TRAIT(fisher, TRAIT_GONE_FISHING), "The fisher is still fishing after the catch")
	var/obj/item/fish/caught = locate() in fisher.held_items
	TEST_ASSERT(caught, "The won minigame didn't put a fish in the fisher's hands")
	TEST_ASSERT_EQUAL(caught.name, "okoń", "The caught fish isn't the rolled species")
	TEST_ASSERT(!rod.bait, "The bait wasn't eaten after the minigame")

	// Pusty zarzut nic nie daje, losowanie z tabeli zwraca zdobycz albo FISHING_DUD
	var/datum/fish_source/beach = GLOB.preset_fish_sources[FISHING_SPOT_PRESET_BEACH]
	TEST_ASSERT(isnull(beach.dispense_reward(FISHING_DUD, fisher)), "A dud gave something")
	for(var/i in 1 to 20)
		var/reward = beach.roll_reward(rod, fisher)
		TEST_ASSERT(reward == FISHING_DUD || ispath(reward), "The beach source rolled [reward]")
	var/difficulty = beach.calculate_difficulty(/datum/aquarium_behaviour/fish/planet/stingray, rod, fisher)
	TEST_ASSERT(difficulty >= FISHING_MINIMUM_DIFFICULTY && difficulty <= 100, "Fishing difficulty [difficulty] is out of range")

	// Lawa tylko wędką odporną na żar
	var/datum/fish_source/lava = GLOB.preset_fish_sources[FISHING_SPOT_PRESET_LAVA]
	TEST_ASSERT(lava.can_fish(rod, fisher), "A plain rod can fish in lava")
	var/obj/item/fishing_rod/tech/tech_rod = allocate(/obj/item/fishing_rod/tech)
	TEST_ASSERT(isnull(lava.can_fish(tech_rod, fisher)), "The heat resistant rod can't fish in lava")

	// Ryba kroi się nożem na filety
	var/obj/item/kitchen/knife/knife = allocate(/obj/item/kitchen/knife)
	fisher.drop_all_held_items()
	caught.forceMove(shore)
	fisher.put_in_active_hand(knife)
	knife.toolspeed = 0.01
	caught.tool_act(fisher, knife, TOOL_KNIFE)
	TEST_ASSERT(QDELETED(caught), "Cutting a fish with a knife didn't turn it into fillets")
	TEST_ASSERT(locate(/obj/item/food/fishmeat) in shore, "Cutting a fish didn't leave fish fillets")

	for(var/obj/item/food/fishmeat/fillet in shore)
		qdel(fillet)
	water.ChangeTurf(old_type)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
