// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/cat/bread_cat_ai.dm (bee/master 0adf0fe9ae)
// No stove subtree: Bee does not register the stove interaction of cats (commented out in cat.dm).
/datum/ai_controller/basic_controller/cat/bread
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice,
		/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food,
		/datum/ai_planning_subtree/haul_food_to_young,
		/datum/ai_planning_subtree/random_speech/cats,
	)

/datum/ai_controller/basic_controller/cat/cake
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/decorate_donuts,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_mice,
		/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food,
		/datum/ai_planning_subtree/haul_food_to_young,
		/datum/ai_planning_subtree/random_speech/cats,
	)

/datum/ai_planning_subtree/find_and_hunt_target/decorate_donuts
	target_key = BB_DONUT_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/decorate_donuts
	finding_behavior = /datum/ai_behavior/find_hunt_target/decorate_donuts
	hunt_targets = list(/obj/item/food/donut)
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/decorate_donuts/valid_dinner(mob/living/source, obj/item/food/donut/target, radius)
	if(target.is_decorated) // AQUILA: Bee looked for decorated donuts only
		return FALSE
	return can_see(source, target, radius)

/datum/ai_behavior/hunt_target/decorate_donuts
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/decorate_donuts/target_caught(mob/living/hunter, atom/target)
	hunter.spin(spintime = 4, speed = 1)
