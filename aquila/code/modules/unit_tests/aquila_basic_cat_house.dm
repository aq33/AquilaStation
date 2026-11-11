// AQUILA - cat house, feral cat, Jerry and the tabby (new cat content from BeeStation/BeeStation-Hornet, decision D10) and Tyson (D11)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// A cat that clicks a free cat house goes in, shows in it and comes out; a dog does not get in; a dying cat is pushed out
/datum/unit_test/aquila_cat_house

/datum/unit_test/aquila_cat_house/Run()
	var/obj/structure/cat_house/house = allocate(/obj/structure/cat_house, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/basic/pet/dog/corgi/dog = allocate(/mob/living/basic/pet/dog/corgi, get_step(run_loc_floor_bottom_left, NORTHEAST))
	dog.melee_attack(house, ignore_cooldown = TRUE)
	TEST_ASSERT(dog.loc != house, "A dog got into the cat house")

	var/mob/living/basic/pet/cat/tabby/cat = allocate(/mob/living/basic/pet/cat/tabby, run_loc_floor_bottom_left)
	cat.melee_attack(house, ignore_cooldown = TRUE)
	TEST_ASSERT(cat.loc == house, "The cat did not go into the cat house")
	TEST_ASSERT(house.resident_cat == cat, "The cat house does not know its resident")
	TEST_ASSERT(house.managed_overlays, "The cat does not show inside the cat house")

	var/mob/living/basic/pet/cat/jerry/other = allocate(/mob/living/basic/pet/cat/jerry, get_step(run_loc_floor_bottom_left, NORTH))
	other.melee_attack(house, ignore_cooldown = TRUE)
	TEST_ASSERT(other.loc != house, "A second cat got into an occupied cat house")

	house.eject_cat()
	TEST_ASSERT(isturf(cat.loc) && isnull(house.resident_cat), "The cat did not come out of the cat house")

	cat.melee_attack(house, ignore_cooldown = TRUE)
	TEST_ASSERT(cat.loc == house, "The cat did not go back into the cat house")
	cat.death()
	TEST_ASSERT(isturf(cat.loc), "A dead cat stayed in the cat house")

	var/has_recipe = FALSE
	for(var/datum/stack_recipe/recipe in GLOB.wood_recipes)
		if(recipe.result_type == /obj/structure/cat_house)
			has_recipe = TRUE
	TEST_ASSERT(has_recipe, "A cat house cannot be built from wood")

	var/found_subtree = FALSE
	for(var/datum/ai_planning_subtree/subtree as anything in other.ai_controller.planning_subtrees)
		if(istype(subtree, /datum/ai_planning_subtree/reside_in_home))
			found_subtree = TRUE
	TEST_ASSERT(found_subtree, "Cats do not look for cat houses on their own")

/// The feral cat attacks people on sight
/datum/unit_test/aquila_feral_cat

/datum/unit_test/aquila_feral_cat/Run()
	var/mob/living/basic/pet/cat/feral/feral = allocate(/mob/living/basic/pet/cat/feral, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/targeting_strategy/targeting = GET_TARGETING_STRATEGY(feral.ai_controller.blackboard[BB_TARGETING_STRATEGY])
	TEST_ASSERT(targeting.can_attack(feral, victim), "The feral cat does not want to attack people")
	var/health_before = victim.health
	feral.melee_attack(victim, ignore_cooldown = TRUE)
	TEST_ASSERT(victim.health < health_before, "The feral cat bite did nothing")

/// Tyson turns into the security dog on duty, remembers it at round end and brings it back next shift
/datum/unit_test/aquila_security_dog

/datum/unit_test/aquila_security_dog/Run()
	var/save_path = "data/npc_saves/security_dog.json"
	var/old_save = fexists(save_path) ? rustg_file_read(save_path) : null
	fdel(save_path)

	var/turf/kennel = run_loc_floor_bottom_left
	var/list/before = kennel.contents.Copy()
	var/mob/living/basic/pet/dog/bullterrier/tyson/spawner = new(kennel)
	TEST_ASSERT(QDELETED(spawner), "The Tyson spawner stayed")
	var/mob/living/basic/pet/dog/dog = locate() in (kennel.contents - before)
	TEST_ASSERT(dog, "Tyson did not report for duty")
	allocated += dog
	var/datum/component/security_dog/duty = dog.GetComponent(/datum/component/security_dog)
	TEST_ASSERT(duty, "The dog on duty has no security posting")
	TEST_ASSERT(dog.real_name in (GLOB.security_dog_male_names + GLOB.security_dog_female_names), "The security dog is called [dog.real_name]")
	var/list/examine_text = dog.examine(dog)
	TEST_ASSERT(findtext(jointext(examine_text, " "), "pies ochrony"), "The security dog examine line is missing")

	// Alive at round end: the next shift gets the same dog with one more shift of service
	duty.check_survival()
	var/list/next_shift = requisition_security_dog()
	TEST_ASSERT(next_shift["name"] == dog.real_name, "The next shift got [next_shift["name"]] instead of [dog.real_name]")
	TEST_ASSERT(next_shift["breed"] == dog.type, "The next shift got another breed")
	TEST_ASSERT(next_shift["tenure"] == 1, "The tenure was not counted")

	// A dead dog leaves no save behind
	duty.memory_saved = FALSE
	dog.death()
	TEST_ASSERT(!fexists(save_path), "A dead security dog was remembered")

	fdel(save_path)
	if(old_save)
		rustg_file_write(old_save, save_path)

/// A corrupt security dog save gives a new dog and is removed; the test chamber Tyson neither reads nor writes the ship dog's save
/datum/unit_test/aquila_security_dog_save_safety
	/// Whatever save was there before the test, put back in Destroy()
	var/old_save

/datum/unit_test/aquila_security_dog_save_safety/Run()
	var/save_path = "data/npc_saves/security_dog.json"
	old_save = fexists(save_path) ? rustg_file_read(save_path) : null

	fdel(save_path)
	rustg_file_write("{\"name\": \"Rex\", broken", save_path)
	var/list/on_duty = requisition_security_dog()
	TEST_ASSERT(islist(on_duty) && on_duty["name"] && ispath(on_duty["breed"]), "A corrupt save gave no dog")
	TEST_ASSERT(!fexists(save_path), "The corrupt save was kept")

	// The ship dog's save stays as it was, whatever the test chamber dog does
	var/ship_save = "{\"name\":\"Walter\",\"gender\":\"male\",\"breed\":\"/mob/living/basic/pet/dog/bullterrier\",\"tenure\":7}"
	rustg_file_write(ship_save, save_path)
	var/turf/kennel = run_loc_floor_bottom_left
	var/list/before = kennel.contents.Copy()
	new /mob/living/basic/pet/dog/bullterrier/tyson/test_chamber(kennel)
	var/mob/living/basic/pet/dog/dog = locate() in (kennel.contents - before)
	TEST_ASSERT(dog, "The test chamber Tyson did not report for duty")
	allocated += dog
	var/datum/component/security_dog/duty = dog.GetComponent(/datum/component/security_dog)
	TEST_ASSERT(duty, "The test chamber dog has no security posting")
	TEST_ASSERT(duty.tenure == 0, "The test chamber dog took the ship dog's tenure")
	duty.check_survival()
	TEST_ASSERT(rustg_file_read(save_path) == ship_save, "The test chamber dog overwrote the ship dog's save")
	dog.death()
	TEST_ASSERT(fexists(save_path), "The dead test chamber dog deleted the ship dog's save")

/datum/unit_test/aquila_security_dog_save_safety/Destroy()
	var/save_path = "data/npc_saves/security_dog.json"
	fdel(save_path)
	if(old_save)
		rustg_file_write(old_save, save_path)
	return ..()

#undef TEST_ASSERT
