// AQUILA - basic mob cow (port of BeeStation/BeeStation-Hornet basic cow and udder component, decision D9)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Milking the basic cow through the whole attack chain fills the beaker from the udder component
/datum/unit_test/aquila_cow_milking_udder

/datum/unit_test/aquila_cow_milking_udder/Run()
	var/mob/living/carbon/human/farmer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/basic/cow/cow = allocate(/mob/living/basic/cow, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/component/udder/udder_component = cow.GetComponent(/datum/component/udder)
	TEST_ASSERT(udder_component, "The cow has no udder component")
	var/udder_before = udder_component.udder.reagents.total_volume
	TEST_ASSERT(udder_before > 0, "The cow starts with an empty udder")

	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	farmer.put_in_active_hand(beaker)
	beaker.melee_attack_chain(farmer, cow)
	TEST_ASSERT(beaker.reagents.has_reagent(/datum/reagent/consumable/milk), "Milking the cow put no milk in the beaker")
	TEST_ASSERT(udder_component.udder.reagents.total_volume < udder_before, "Milking the cow did not empty its udder")
	TEST_ASSERT_EQUAL(cow.health, cow.maxHealth, "Milking the cow also hit it")

	// A dead cow gives no milk
	var/milk_before = beaker.reagents.total_volume
	cow.death()
	beaker.melee_attack_chain(farmer, cow)
	TEST_ASSERT_EQUAL(beaker.reagents.total_volume, milk_before, "A dead cow was milked")

/// Feeding a cow wheat by hand can tame it, and a tamed cow can be ridden with our riding component
/datum/unit_test/aquila_cow_taming_riding

/datum/unit_test/aquila_cow_taming_riding/Run()
	var/mob/living/carbon/human/farmer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/basic/cow/cow = allocate(/mob/living/basic/cow, get_step(run_loc_floor_bottom_left, EAST))
	TEST_ASSERT(cow.ai_controller.blackboard[BB_BASIC_FOODS][/obj/item/food/grown/wheat], "The cow AI does not look for wheat")
	var/datum/component/tameable/tameable = cow.GetComponent(/datum/component/tameable)
	TEST_ASSERT(tameable, "The cow cannot be tamed")
	// Same path as feeding it until it trusts you
	tameable.on_tame(cow, farmer)
	TEST_ASSERT(farmer in cow.ai_controller.blackboard[BB_FRIENDS_LIST], "The tamed cow is not the farmer's friend")
	TEST_ASSERT(cow.GetComponent(/datum/component/riding), "The tamed cow cannot be ridden")
	TEST_ASSERT(cow.can_buckle, "The tamed cow cannot be buckled to")

/// The wisdom cow speaks Polish wisdoms from strings/wisdoms.txt and vanishes in smoke when petted
/datum/unit_test/aquila_wisdom_cow

/datum/unit_test/aquila_wisdom_cow/Run()
	TEST_ASSERT_EQUAL(length(GLOB.wisdoms), 430, "strings/wisdoms.txt was not read line by line")
	TEST_ASSERT("Czy jesteś żółwiem?" in GLOB.wisdoms, "The wisdoms are not the Polish translation")
	var/mob/living/basic/cow/wisdom/cow = allocate(/mob/living/basic/cow/wisdom, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_planning_subtree/random_speech/cow/wisdom/speech
	for(var/datum/ai_planning_subtree/subtree as anything in cow.ai_controller.planning_subtrees)
		if(istype(subtree, /datum/ai_planning_subtree/random_speech/cow/wisdom))
			speech = subtree
	TEST_ASSERT(speech, "The wisdom cow has no wisdom speech")
	TEST_ASSERT_EQUAL(length(speech.speak), 430, "The wisdom cow does not know all the wisdoms")
	TEST_ASSERT(!cow.GetComponent(/datum/component/tameable), "The wisdom cow can be tamed")
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	cow.attack_hand(listener, list())
	TEST_ASSERT(QDELETED(cow), "The wisdom cow did not vanish after sharing its wisdom")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
