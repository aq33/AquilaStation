// AQUILA - basic lizard, crab, butterfly, snake and turtle from BeeStation/BeeStation-Hornet#14771
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// A snake bite injects its venom, its gland can be milked, and the rod of Asclepius snake bites with medicine
/datum/unit_test/aquila_snake_venom

/datum/unit_test/aquila_snake_venom/Run()
	var/mob/living/basic/snake/snake = allocate(/mob/living/basic/snake, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	snake.melee_attack(victim, ignore_cooldown = TRUE)
	TEST_ASSERT(victim.reagents.has_reagent(/datum/reagent/toxin/venom), "The snake bite injected no venom")
	TEST_ASSERT(snake.ai_controller.blackboard[BB_BASIC_FOODS][/mob/living/basic/mouse], "The snake does not hunt mice")
	TEST_ASSERT(snake.playable, "Ghosts cannot take a snake over")

	var/datum/component/udder/gland = snake.GetComponent(/datum/component/udder)
	TEST_ASSERT(istype(gland?.udder, /obj/item/udder/venom), "The snake has no venom gland")
	gland.udder.reagents.add_reagent(gland.udder.reagent_produced_typepath, 10)
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	victim.put_in_active_hand(beaker)
	beaker.melee_attack_chain(victim, snake)
	TEST_ASSERT(beaker.reagents.has_reagent(/datum/reagent/toxin/venom), "Milking the snake gave no venom")

	var/mob/living/basic/snake/healer = allocate(/mob/living/basic/snake, get_step(run_loc_floor_bottom_left, NORTH), /datum/reagent/medicine/bicaridine)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTHEAST))
	healer.melee_attack(patient, ignore_cooldown = TRUE)
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/medicine/bicaridine), "The Asclepius snake did not bite with its medicine")

/// A lizard swallows a cockroach it bites; a crab walks sideways; a butterfly flies only while alive
/datum/unit_test/aquila_lizard_crab_butterfly

/datum/unit_test/aquila_lizard_crab_butterfly/Run()
	var/mob/living/basic/lizard/lizard = allocate(/mob/living/basic/lizard, run_loc_floor_bottom_left)
	var/mob/living/basic/cockroach/roach = allocate(/mob/living/basic/cockroach, get_step(run_loc_floor_bottom_left, EAST))
	lizard.ClickOn(roach)
	TEST_ASSERT(QDELETED(roach), "The lizard did not eat the cockroach")

	var/turf/crab_start = get_step(run_loc_floor_bottom_left, NORTH)
	var/mob/living/basic/crab/crab = allocate(/mob/living/basic/crab, crab_start)
	crab.setDir(NORTH)
	crab.Move(get_step(crab_start, NORTH), NORTH)
	TEST_ASSERT(crab.loc != crab_start, "The crab could not move")
	TEST_ASSERT(crab.dir == EAST || crab.dir == WEST, "A crab walking north faces [dir2text(crab.dir)] instead of sideways")

	var/mob/living/basic/butterfly/butterfly = allocate(/mob/living/basic/butterfly, get_step(run_loc_floor_bottom_left, NORTHEAST))
	TEST_ASSERT(butterfly.movement_type & FLYING, "A living butterfly does not fly")
	butterfly.death()
	TEST_ASSERT(!(butterfly.movement_type & FLYING), "A dead butterfly still flies")

/// A turtle hit by someone hides in its shell and cannot move until it comes out
/datum/unit_test/aquila_turtle_hides

/datum/unit_test/aquila_turtle_hides/Run()
	var/mob/living/basic/turtle/turtle = allocate(/mob/living/basic/turtle, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/bully = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	bully.set_combat_mode(TRUE)
	bully.ClickOn(turtle)
	TEST_ASSERT(turtle.hiding, "The turtle did not hide after a punch")
	TEST_ASSERT(HAS_TRAIT(turtle, TRAIT_IMMOBILIZED), "A hiding turtle can move")
	TEST_ASSERT(turtle.icon_state == "yeeslow_scared", "A hiding turtle shows [turtle.icon_state]")
	turtle.emerge_from_shell()
	TEST_ASSERT(!turtle.hiding && !HAS_TRAIT(turtle, TRAIT_IMMOBILIZED), "The turtle did not come out of its shell")

#undef TEST_ASSERT
