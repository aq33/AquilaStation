// AQUILA - basic farm animals from BeeStation/BeeStation-Hornet#14771 (goat, chicken, chick, turkey, rabbit) and our sheep
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// A female goat and a sheep are milked through the udder component and give their own milk; a male goat has no udder
/datum/unit_test/aquila_goat_sheep_udder

/datum/unit_test/aquila_goat_sheep_udder/Run()
	var/mob/living/carbon/human/farmer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/basic/goat/goat = allocate(/mob/living/basic/goat, get_step(run_loc_floor_bottom_left, EAST))
	goat.gender = FEMALE
	goat.add_udder()
	var/obj/item/reagent_containers/glass/beaker/goat_beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	farmer.put_in_active_hand(goat_beaker)
	goat_beaker.melee_attack_chain(farmer, goat)
	TEST_ASSERT(goat_beaker.reagents.has_reagent(/datum/reagent/consumable/milk/goat), "Milking the goat gave no goat milk")
	TEST_ASSERT(!goat_beaker.reagents.has_reagent(/datum/reagent/consumable/milk), "The goat gave cow milk")
	TEST_ASSERT_EQUAL(goat.health, goat.maxHealth, "Milking the goat also hit it")
	farmer.dropItemToGround(goat_beaker)

	var/mob/living/basic/goat/billy = allocate(/mob/living/basic/goat, get_step(run_loc_floor_bottom_left, NORTH))
	if(billy.gender != MALE)
		qdel(billy.GetComponent(/datum/component/udder))
		billy.gender = MALE
		billy.add_udder()
	TEST_ASSERT(!billy.GetComponent(/datum/component/udder), "A male goat has an udder")

	var/mob/living/basic/sheep/sheep = allocate(/mob/living/basic/sheep, get_step(run_loc_floor_bottom_left, NORTHEAST))
	var/obj/item/reagent_containers/glass/beaker/sheep_beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	farmer.put_in_active_hand(sheep_beaker)
	sheep_beaker.melee_attack_chain(farmer, sheep)
	TEST_ASSERT(sheep_beaker.reagents.has_reagent(/datum/reagent/consumable/milk/sheep), "Milking the sheep gave no sheep milk")

	// Shearing leaves wool and a sheared sheep
	var/turf/sheep_turf = get_turf(sheep)
	var/list/before = sheep_turf.contents.Copy()
	sheep.shear()
	allocated += (sheep_turf.contents - before)
	TEST_ASSERT(sheep.shaved, "The sheep was not sheared")
	TEST_ASSERT(locate(/obj/item/stack/sheet/cotton/wool) in sheep_turf, "Shearing the sheep left no wool")

/// A goat eats a space vine in its way and attacks someone who hit it
/datum/unit_test/aquila_goat_eats_vines

/datum/unit_test/aquila_goat_eats_vines/Run()
	var/mob/living/basic/goat/goat = allocate(/mob/living/basic/goat, run_loc_floor_bottom_left)
	TEST_ASSERT(goat.ai_controller.blackboard[BB_BASIC_FOODS][/obj/structure/spacevine], "The goat AI does not look for space vines")
	var/obj/structure/glowshroom/shroom = allocate(/obj/structure/glowshroom, get_step(run_loc_floor_bottom_left, EAST))
	// Through the AI: find_food picks the glowshroom and the melee attack bites it (it stood next to it forever before)
	run_ai_until_deleted(goat, shroom)
	TEST_ASSERT(QDELETED(shroom), "The goat AI did not eat the glowshroom next to it")

	// The snake AI eats a dead mouse lying next to it the same way
	var/mob/living/basic/snake/snake = allocate(/mob/living/basic/snake, get_step(run_loc_floor_bottom_left, NORTH))
	var/obj/item/food/deadmouse/snack = allocate(/obj/item/food/deadmouse, get_step(snake, NORTH))
	run_ai_until_deleted(snake, snack)
	TEST_ASSERT(QDELETED(snack), "The snake AI did not eat the dead mouse next to it")

/// Plans and runs the AI of the eater (off without clients) until the food is gone or 10 s pass
/datum/unit_test/aquila_goat_eats_vines/proc/run_ai_until_deleted(mob/living/basic/eater, atom/food)
	var/datum/ai_controller/controller = eater.ai_controller
	for(var/i in 1 to 100)
		controller.SelectBehaviors(1)
		for(var/datum/ai_behavior/behavior as anything in controller.current_behaviors)
			controller.ProcessBehavior(1, behavior)
		if(QDELETED(food))
			return
		sleep(1)

/// Fed chickens lay eggs, fertile eggs hatch into chicks, chicks grow into chickens, and max_chickens caps all of it
/datum/unit_test/aquila_chicken_cycle
	/// max_chickens before the test, put back in Destroy() also when an assertion fails halfway
	var/old_cap

/datum/unit_test/aquila_chicken_cycle/Run()
	old_cap = CONFIG_GET(number/max_chickens)
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/carbon/human/farmer = allocate(/mob/living/carbon/human, floor)
	var/mob/living/basic/chicken/hen = allocate(/mob/living/basic/chicken, get_step(floor, EAST))
	var/datum/component/egg_layer/layer = hen.GetComponent(/datum/component/egg_layer)
	TEST_ASSERT(layer, "The chicken does not lay eggs")

	// Feeding by hand adds eggs, up to the limit
	var/obj/item/food/grown/wheat/wheat = allocate(/obj/item/food/grown/wheat)
	farmer.put_in_active_hand(wheat)
	wheat.melee_attack_chain(farmer, hen)
	TEST_ASSERT(QDELETED(wheat), "The chicken did not eat the wheat")
	TEST_ASSERT(layer.eggs_left >= 1 && layer.eggs_left <= layer.max_eggs_held, "Feeding gave [layer.eggs_left] eggs")
	TEST_ASSERT_EQUAL(hen.health, hen.maxHealth, "Feeding the chicken also hit it")

	// A full flock lays only eggs that never hatch
	CONFIG_SET(number/max_chickens, GLOB.total_chickens)
	for(var/i in 1 to 20)
		var/obj/item/egg = layer.lay_egg()
		allocated += egg
		TEST_ASSERT(!egg.GetComponent(/datum/component/fertile_egg), "A chicken laid a fertile egg over the max_chickens cap")

	// Under the cap some eggs are fertile (25% each)
	CONFIG_SET(number/max_chickens, GLOB.total_chickens + 10)
	var/obj/item/fertile_egg
	for(var/i in 1 to 40)
		var/obj/item/egg = layer.lay_egg()
		allocated += egg
		if(egg.GetComponent(/datum/component/fertile_egg))
			fertile_egg = egg
			break
	TEST_ASSERT(fertile_egg, "No fertile egg in 40 eggs laid under the cap")

	// The cap is checked again when the egg hatches
	var/datum/component/fertile_egg/embryo = fertile_egg.GetComponent(/datum/component/fertile_egg)
	CONFIG_SET(number/max_chickens, GLOB.total_chickens)
	embryo.hatch()
	TEST_ASSERT(!QDELETED(fertile_egg), "An egg hatched over the max_chickens cap")
	TEST_ASSERT(!fertile_egg.GetComponent(/datum/component/fertile_egg), "An egg over the cap stayed fertile")

	var/obj/item/second_egg = new /obj/item/food/egg(get_step(floor, NORTH))
	allocated += second_egg
	hen.egg_laid(second_egg)
	CONFIG_SET(number/max_chickens, GLOB.total_chickens + 10)
	var/chickens_before = GLOB.total_chickens
	var/datum/component/fertile_egg/second_embryo = second_egg.GetComponent(/datum/component/fertile_egg)
	var/tries = 0
	while(!second_embryo && tries < 40)
		tries++
		qdel(second_egg)
		second_egg = new /obj/item/food/egg(get_step(floor, NORTH))
		allocated += second_egg
		hen.egg_laid(second_egg)
		second_embryo = second_egg.GetComponent(/datum/component/fertile_egg)
	TEST_ASSERT(second_embryo, "Could not get a fertile egg")
	var/mob/living/basic/chick/chick = second_embryo.hatch()
	TEST_ASSERT(istype(chick), "The fertile egg did not hatch into a chick")
	allocated += chick
	TEST_ASSERT_EQUAL(GLOB.total_chickens, chickens_before + 1, "The chick is not counted with the chickens")

	// The chick grows into a chicken
	var/datum/component/growth_and_differentiation/growth = chick.GetComponent(/datum/component/growth_and_differentiation)
	TEST_ASSERT(growth, "The chick cannot grow up")
	var/mob/living/basic/chicken/grown = growth.grow(TRUE)
	TEST_ASSERT(istype(grown), "The chick did not grow into a chicken")
	allocated += grown
	TEST_ASSERT_EQUAL(grown.loc, chick.loc, "The chicken did not appear where the chick was")
	qdel(chick)
	TEST_ASSERT_EQUAL(GLOB.total_chickens, chickens_before + 1, "Growing up changed the chicken count")

	// Dead chickens do not count
	grown.death()
	TEST_ASSERT_EQUAL(GLOB.total_chickens, chickens_before, "A dead chicken still counts")

/datum/unit_test/aquila_chicken_cycle/Destroy()
	if(!isnull(old_cap))
		CONFIG_SET(number/max_chickens, old_cap)
	return ..()

/// The gutlunch uses the udder component: eating gibs fills it, a beaker milks it
/datum/unit_test/aquila_gutlunch_udder

/datum/unit_test/aquila_gutlunch_udder/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/guthen = allocate(/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen, floor)
	var/datum/component/udder/udder_component = guthen.GetComponent(/datum/component/udder)
	TEST_ASSERT(udder_component, "The gutlunch has no udder component")
	TEST_ASSERT_EQUAL(udder_component.udder.reagents.total_volume, 0, "The gutlunch udder does not start empty")
	for(var/i in 1 to 20)
		var/obj/effect/decal/cleanable/blood/gibs/gibs = new(get_step(floor, EAST))
		guthen.target = gibs
		guthen.AttackingTarget()
		TEST_ASSERT(QDELETED(gibs), "The gutlunch did not eat the gibs")
		if(udder_component.udder.reagents.total_volume)
			break
	TEST_ASSERT(udder_component.udder.reagents.total_volume > 0, "Eating gibs did not fill the gutlunch udder")

	var/mob/living/carbon/human/farmer = allocate(/mob/living/carbon/human, get_step(floor, NORTH))
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	farmer.put_in_active_hand(beaker)
	beaker.melee_attack_chain(farmer, guthen)
	TEST_ASSERT(beaker.reagents.total_volume > 0, "Milking the gutlunch gave nothing")
	TEST_ASSERT_EQUAL(guthen.health, guthen.maxHealth, "Milking the gutlunch also hit it")

/// The mapped mascots and holodeck animals keep what the maps gave them through var edits before
/datum/unit_test/aquila_basic_farm_mapped

/datum/unit_test/aquila_basic_farm_mapped/Run()
	var/mob/living/basic/turkey/tom/tom = allocate(/mob/living/basic/turkey/tom, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(tom.maxHealth, 200, "Tom lost his health")
	TEST_ASSERT_EQUAL(tom.unsuitable_atmos_damage, 0, "Tom is hurt by space air")
	var/mob/living/basic/chick/permanent/holo_chick = allocate(/mob/living/basic/chick/permanent, get_step(run_loc_floor_bottom_left, EAST))
	TEST_ASSERT(!holo_chick.GetComponent(/datum/component/growth_and_differentiation), "A permanent chick grows up")
	var/mob/living/basic/rabbit/easter/easter = allocate(/mob/living/basic/rabbit/easter, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/component/egg_layer/rabbit_layer = easter.GetComponent(/datum/component/egg_layer)
	TEST_ASSERT(rabbit_layer, "The Easter rabbit lays no eggs")
	var/obj/item/suprise_egg/prize = rabbit_layer.lay_egg()
	allocated += prize
	TEST_ASSERT(istype(prize, /obj/item/suprise_egg/loaded), "The Easter rabbit laid [prize?.type] instead of a surprise egg")
	TEST_ASSERT(prize.icon == 'icons/obj/food/egg.dmi', "The surprise egg has no egg icon")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
