// AQUILA: regression tests for the review of aq33/AquilaStation#613 (basic mob framework and core code that assumed simple animals).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_LEFT_CLICK "icon-x=16;icon-y=16;left=1;button=left"
#define CTRL_LEFT_CLICK "icon-x=16;icon-y=16;left=1;button=left;ctrl=1"

/// Feeding a tamed dog from the hand (ClickOn, both control modes) keeps the friendship; a real hit with a weapon still ends it
/datum/unit_test/aquila_relay_feeding_keeps_friend

/datum/unit_test/aquila_relay_feeding_keeps_friend/Run()
	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		var/turf/start = run_loc_floor_bottom_left
		var/mob/living/carbon/human/user = allocate(legacy ? /mob/living/carbon/human/legacy_intents_test : /mob/living/carbon/human, start)
		var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, get_step(start, EAST))
		corgi.ai_controller.set_ai_status(AI_STATUS_OFF)
		corgi.befriend(user)
		TEST_ASSERT(user in corgi.ai_controller.blackboard[BB_FRIENDS_LIST], "[mode]: befriend() did not make the user a friend")

		if(user.uses_legacy_intents())
			user.a_intent_change(INTENT_HELP)
		else
			user.set_combat_mode(FALSE, silent = TRUE)
		for(var/i in 1 to 3)
			var/obj/item/stack/sheet/bone/bone = allocate(/obj/item/stack/sheet/bone, start)
			user.put_in_active_hand(bone)
			user.next_click = 0
			user.next_move = 0
			user.ClickOn(corgi, TEST_LEFT_CLICK)
			TEST_ASSERT(QDELETED(bone) || bone.loc != user, "[mode]: the tamed corgi did not eat the bone from the hand")
			TEST_ASSERT(user in corgi.ai_controller.blackboard[BB_FRIENDS_LIST], "[mode]: feeding a bone (force [initial(bone.force)]) counted as an attack and unfriended the user")
			TEST_ASSERT(("[REF(user)]" in corgi.faction), "[mode]: feeding a bone removed the friend faction")
		user.drop_all_held_items()

		// A real weapon hit still goes through the relay
		var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox, start)
		user.put_in_active_hand(toolbox)
		if(user.uses_legacy_intents())
			user.a_intent_change(INTENT_HARM)
		else
			user.set_combat_mode(TRUE, silent = TRUE)
		user.next_click = 0
		user.next_move = 0
		user.ClickOn(corgi, TEST_LEFT_CLICK)
		TEST_ASSERT(corgi.health < corgi.maxHealth, "[mode]: the toolbox did not hit the corgi")
		TEST_ASSERT(!(user in corgi.ai_controller.blackboard[BB_FRIENDS_LIST]), "[mode]: hitting the corgi with a toolbox did not reach unfriend_attacker")
		user.drop_all_held_items()
		qdel(toolbox)
		qdel(corgi)
		qdel(user)

#undef TEST_LEFT_CLICK

/// Animal attacks on living mobs and projectiles reach relay_attackers (retaliation, hiding)
/datum/unit_test/aquila_relay_animals_and_projectiles

/datum/unit_test/aquila_relay_animals_and_projectiles/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, start)

	// A shot makes the turtle hide in its shell
	var/mob/living/basic/turtle/turtle = allocate(/mob/living/basic/turtle, get_step(start, EAST))
	turtle.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/obj/item/projectile/beam/laser/laser = allocate(/obj/item/projectile/beam/laser, get_step(start, EAST))
	laser.firer = shooter
	turtle.bullet_act(laser)
	TEST_ASSERT(turtle.hiding, "the turtle did not hide in its shell after being shot")

	// A basic mob attack makes the goat retaliate against the animal
	var/mob/living/basic/goat/goat = allocate(/mob/living/basic/goat, get_step(start, NORTH))
	goat.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/mob/living/basic/bear/bear = allocate(/mob/living/basic/bear, get_step(start, NORTHEAST))
	bear.ai_controller.set_ai_status(AI_STATUS_OFF)
	bear.melee_attack(goat, ignore_cooldown = TRUE)
	TEST_ASSERT(goat.health < goat.maxHealth, "the bear did not hurt the goat")
	TEST_ASSERT(bear in goat.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "the goat did not want to retaliate against the bear that bit it")

	// A pacifist animal does not count as an attacker
	var/mob/living/basic/goat/calm_goat = allocate(/mob/living/basic/goat, locate(start.x + 2, start.y, start.z))
	calm_goat.ai_controller.set_ai_status(AI_STATUS_OFF)
	ADD_TRAIT(bear, TRAIT_PACIFISM, "unit_test")
	bear.melee_attack(calm_goat, ignore_cooldown = TRUE)
	TEST_ASSERT(!(bear in calm_goat.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]), "a pacifist bear that did not bite counted as an attacker")

/// Atmosphere damage, density, getting up after a table and burning of basic mobs
/datum/unit_test/aquila_basic_framework_review

/datum/unit_test/aquila_basic_framework_review/Run()
	var/turf/open/start = run_loc_floor_bottom_left

	// No oxygen hurts (the element used to store no damage)
	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, start)
	corgi.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/datum/gas_mixture/air = start.return_air()
	var/old_oxygen = air.get_moles(GAS_O2)
	air.set_moles(GAS_O2, 0)
	SEND_SIGNAL(corgi, COMSIG_LIVING_HANDLE_BREATHING, SSMOBS_DT, 1)
	air.set_moles(GAS_O2, old_oxygen)
	TEST_ASSERT(corgi.health < corgi.maxHealth, "a corgi without oxygen took no damage from atmos_requirements")
	corgi.revive(full_heal = TRUE, admin_revive = TRUE)

	// Density follows posture, small mobs stay passable
	var/mob/living/basic/chicken/chicken = allocate(/mob/living/basic/chicken, get_step(start, EAST))
	chicken.ai_controller.set_ai_status(AI_STATUS_OFF)
	chicken.forceMove(get_step(start, NORTH))
	chicken.Knockdown(2 SECONDS)
	chicken.SetKnockdown(0)
	TEST_ASSERT(!chicken.density, "a chicken became dense after being knocked down and getting up")
	chicken.death()
	chicken.revive(full_heal = TRUE, admin_revive = TRUE)
	TEST_ASSERT(!chicken.density, "a chicken became dense after a revival")
	corgi.Knockdown(2 SECONDS)
	corgi.SetKnockdown(0)
	TEST_ASSERT(corgi.density, "a corgi stopped being dense after a knockdown")

	// A table puts only cats to rest among animals, and an AI cat gets up again
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, get_step(start, NORTHEAST))
	var/obj/structure/table/table = allocate(/obj/structure/table, locate(start.x + 2, start.y, start.z))
	table.tableplace(user, corgi)
	TEST_ASSERT(!corgi.resting, "a corgi placed on a table lies there (only cats did before)")
	var/mob/living/basic/pet/cat/cat = allocate(/mob/living/basic/pet/cat, get_step(start, NORTHEAST))
	cat.ai_controller.set_ai_status(AI_STATUS_OFF)
	table.tableplace(user, cat)
	TEST_ASSERT(cat.resting, "a cat placed on a table does not lie down")
	TEST_ASSERT(cat.ai_rest_timer, "nothing will get the resting AI cat up")
	cat.ai_stop_resting()
	TEST_ASSERT(!cat.resting, "the AI cat did not get up")

	// Fire heats a basic mob up and the temperature element burns it
	corgi.forceMove(start)
	corgi.revive(full_heal = TRUE, admin_revive = TRUE)
	corgi.adjust_fire_stacks(5)
	corgi.IgniteMob()
	TEST_ASSERT(corgi.on_fire, "the corgi did not catch fire")
	for(var/i in 1 to 4)
		corgi.handle_fire()
	SEND_SIGNAL(corgi, COMSIG_LIVING_LIFE, SSMOBS_DT, 1)
	corgi.ExtinguishMob()
	TEST_ASSERT(corgi.health < corgi.maxHealth, "a burning corgi took no damage (body temperature [corgi.bodytemperature])")

/// Pet command targeting (paw, modifier clicks, end) and whole-word voice triggers
/datum/unit_test/aquila_pet_commands_review

/datum/unit_test/aquila_pet_commands_review/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, start)
	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, get_step(start, EAST))
	corgi.ai_controller.set_ai_status(AI_STATUS_OFF)
	corgi.befriend(user)
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse, get_step(start, NORTH))
	mouse.ai_controller?.set_ai_status(AI_STATUS_OFF)

	var/datum/component/obeys_commands/obeys = corgi.GetComponent(/datum/component/obeys_commands)
	var/datum/pet_command/attack/attack
	for(var/command_name in obeys.available_commands)
		if(istype(obeys.available_commands[command_name], /datum/pet_command/attack))
			attack = obeys.available_commands[command_name]
	TEST_ASSERT(attack, "the corgi has no attack command")
	attack.try_activate_command(user, radial_command = TRUE)
	TEST_ASSERT(user.mouse_override_icon, "the targeting mode set no paw pointer")
	user.next_click = 0
	user.ClickOn(mouse, CTRL_LEFT_CLICK)
	TEST_ASSERT(isnull(corgi.ai_controller.blackboard[BB_CURRENT_PET_TARGET]), "a Ctrl+click (pull) picked the attack target")
	TEST_ASSERT(user.mouse_override_icon, "a Ctrl+click ended the targeting mode")
	user.stop_pulling()
	user.next_click = 0
	user.ClickOn(mouse, "icon-x=16;icon-y=16;left=1;button=left")
	TEST_ASSERT(corgi.ai_controller.blackboard[BB_CURRENT_PET_TARGET] == mouse, "a click in the targeting mode did not pick the target")
	TEST_ASSERT(isnull(user.mouse_override_icon), "the paw pointer stayed after picking a target")

	// The timeout ends the mode: later clicks are ordinary clicks
	corgi.ai_controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
	attack.try_activate_command(user, radial_command = TRUE)
	attack.stop_targeting(user)
	user.next_click = 0
	user.ClickOn(mouse, "icon-x=16;icon-y=16;left=1;button=left")
	TEST_ASSERT(isnull(corgi.ai_controller.blackboard[BB_CURRENT_PET_TARGET]), "a click after the targeting mode ended still picked a target")
	TEST_ASSERT(isnull(user.mouse_override_icon), "the paw pointer stayed after the targeting mode ended")

	// Whole words only
	var/datum/pet_command/fetch
	var/datum/pet_command/sit
	var/datum/pet_command/follow
	for(var/command_name in obeys.available_commands)
		var/datum/pet_command/command = obeys.available_commands[command_name]
		if(istype(command, /datum/pet_command/fetch))
			fetch = command
		else if(istype(command, /datum/pet_command/idle))
			sit = command
		else if(istype(command, /datum/pet_command/follow))
			follow = command
	TEST_ASSERT(fetch && sit && follow, "the corgi lacks the fetch, stay or follow command")
	var/datum/pet_command/sic = attack
	TEST_ASSERT(fetch.find_command_in_text("Aport!"), "\"Aport!\" is not the fetch command")
	TEST_ASSERT(!fetch.find_command_in_text("Złóż raport kapitanowi."), "\"raport\" triggered the fetch command")
	TEST_ASSERT(sit.find_command_in_text("siad"), "\"siad\" is not the sit command")
	TEST_ASSERT(!sit.find_command_in_text("To mój sąsiad."), "\"sąsiad\" triggered the sit command")
	TEST_ASSERT(sit.find_command_in_text("Zostań, piesku."), "\"Zostań\" is not the stay command")
	TEST_ASSERT(!sit.find_command_in_text("On tu zostanie."), "\"zostanie\" triggered the stay command")
	TEST_ASSERT(follow.find_command_in_text("Za mną!"), "\"Za mną\" is not the follow command")
	TEST_ASSERT(!follow.find_command_in_text("Kto przychodzi?"), "\"przychodzi\" triggered the follow command")
	TEST_ASSERT(sic.find_command_in_text("Kill him"), "the English \"kill\" trigger is gone")
	TEST_ASSERT(!sic.find_command_in_text("That takes skill"), "\"skill\" triggered the attack command")

#undef CTRL_LEFT_CLICK

/// tiny_mob_hunter: no bonus without a landed hit
/datum/unit_test/aquila_tiny_mob_hunter_needs_hit

/datum/unit_test/aquila_tiny_mob_hunter_needs_hit/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/basic/crab/crab = allocate(/mob/living/basic/crab, start)
	crab.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse, get_step(start, EAST))
	mouse.ai_controller?.set_ai_status(AI_STATUS_OFF)
	ADD_TRAIT(crab, TRAIT_PACIFISM, "unit_test")
	crab.melee_attack(mouse, ignore_cooldown = TRUE)
	TEST_ASSERT(mouse.health == mouse.maxHealth, "a pacifist crab hurt the mouse through the tiny mob hunter bonus")

/// Core code that only knew simple animals takes basic mobs too
/datum/unit_test/aquila_basic_mobs_in_core

/datum/unit_test/aquila_basic_mobs_in_core/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, start)

	// Specimen freight: the basic specimen is packed with its AI asleep and wakes up when it leaves the crate
	var/obj/structure/closet/crate/large/freight_objective/crate = allocate(/obj/structure/closet/crate/large/freight_objective, get_step(start, EAST))
	var/datum/freight_type/single/specimen/specimen_type = new /datum/freight_type/single/specimen(/mob/living/basic/pet/dog/corgi)
	var/mob/living/specimen = specimen_type.add_item_to_crate(crate)
	TEST_ASSERT(istype(specimen, /mob/living/basic/pet/dog/corgi) && specimen.loc == crate, "the basic specimen was not packed into the crate")
	TEST_ASSERT(HAS_TRAIT(specimen, TRAIT_AI_PAUSED), "the AI of the packed specimen is not asleep")
	specimen.forceMove(start)
	TEST_ASSERT(!HAS_TRAIT(specimen, TRAIT_AI_PAUSED), "the specimen let out of the crate keeps its AI asleep")
	qdel(specimen_type)
	qdel(specimen)

	// Gold capture device: hostile basic mobs are too aggressive, pets go in
	var/obj/item/capturedevice/device = allocate(/obj/item/capturedevice, start)
	var/mob/living/basic/bear/bear = allocate(/mob/living/basic/bear, get_step(start, NORTH))
	bear.ai_controller.set_ai_status(AI_STATUS_OFF)
	device.attack(bear, user)
	TEST_ASSERT(bear.loc != device, "the capture device caught a hostile bear")
	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, get_step(start, NORTH))
	corgi.ai_controller.set_ai_status(AI_STATUS_OFF)
	device.attack(corgi, user)
	TEST_ASSERT(corgi.loc == device, "the capture device did not catch a corgi")
	corgi.forceMove(get_step(start, NORTH))

	// Petsplosion copies pets, not bears or bots
	var/mob/living/simple_animal/bot/cleanbot/cleanbot = allocate(/mob/living/simple_animal/bot/cleanbot, locate(start.x + 2, start.y, start.z))
	TEST_ASSERT(!is_hostile_basicmob(corgi) && is_hostile_basicmob(bear), "a corgi counts as hostile or a bear as peaceful")
	if(is_station_level(corgi.z))
		TEST_ASSERT(petsplosion_can_dupe(corgi), "petsplosion skips the corgi")
	TEST_ASSERT(!petsplosion_can_dupe(bear), "petsplosion copies a bear")
	TEST_ASSERT(!petsplosion_can_dupe(cleanbot), "petsplosion copies a cleanbot")

	// The cleanbot kills a basic mouse it hunts
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse, get_step(start, NORTHEAST))
	mouse.ai_controller?.set_ai_status(AI_STATUS_OFF)
	cleanbot.pests = TRUE
	cleanbot.get_targets()
	TEST_ASSERT(is_type_in_typecache(mouse, cleanbot.target_types), "the cleanbot does not hunt mice")
	cleanbot.target = mouse
	cleanbot.UnarmedAttack(mouse)
	TEST_ASSERT(QDELETED(mouse) || mouse.stat == DEAD, "the cleanbot did not kill the mouse")

	// The cryo cell takes a basic mob
	var/obj/machinery/atmospherics/components/unary/cryo_cell/cryo = allocate(/obj/machinery/atmospherics/components/unary/cryo_cell, locate(start.x, start.y + 2, start.z))
	cryo.state_open = TRUE
	corgi.forceMove(cryo.loc)
	cryo.close_machine()
	TEST_ASSERT(cryo.occupant == corgi, "the cryo cell does not take a corgi")
	cryo.open_machine()
	corgi.forceMove(get_step(start, NORTH))

	// A tamed cow stops being a mount when it dies
	var/mob/living/basic/cow/cow = allocate(/mob/living/basic/cow, get_step(start, NORTHEAST))
	cow.ai_controller.set_ai_status(AI_STATUS_OFF)
	cow.setup_tamed_riding()
	TEST_ASSERT(cow.GetComponent(/datum/component/riding), "the tamed cow is not rideable")
	cow.death()
	TEST_ASSERT(!cow.GetComponent(/datum/component/riding), "a dead tamed cow is still rideable")

	// Lazarus: old friends stay friends in the faction and in the AI together with the new one
	var/mob/living/carbon/human/old_friend = allocate(/mob/living/carbon/human, locate(start.x + 2, start.y + 1, start.z))
	corgi.befriend(old_friend)
	corgi.death()
	var/obj/item/lazarus_injector/injector = allocate(/obj/item/lazarus_injector, start)
	injector.afterattack(corgi, user, TRUE)
	TEST_ASSERT(corgi.stat != DEAD, "the lazarus injector did not revive the corgi")
	for(var/mob/living/friend as anything in list(user, old_friend))
		TEST_ASSERT(("[REF(friend)]" in corgi.faction) && (friend in corgi.ai_controller.blackboard[BB_FRIENDS_LIST]), "[friend == user ? "the reviver" : "the old friend"] is not a friend in both the faction and the AI after the lazarus injector")

	// Stabilized gold extract: a basic familiar disappears on death
	var/obj/item/slimecross/stabilized/gold/extract = allocate(/obj/item/slimecross/stabilized/gold, start)
	extract.mob_type = /mob/living/basic/pet/dog/corgi
	user.put_in_active_hand(extract)
	extract.process()
	var/datum/status_effect/stabilized/gold/gold_effect = user.has_status_effect(/datum/status_effect/stabilized/gold)
	TEST_ASSERT(gold_effect, "the stabilized gold extract gave no effect")
	gold_effect.tick()
	var/mob/living/basic/familiar = gold_effect.familiar
	TEST_ASSERT(istype(familiar), "the stabilized gold extract made no basic familiar")
	TEST_ASSERT(familiar.basic_mob_flags & DEL_ON_DEATH, "the basic familiar does not disappear on death")
	qdel(extract)

	// The keycard device turns basic mobs away without a runtime
	var/obj/machinery/keycard_auth/keycard = allocate(/obj/machinery/keycard_auth, locate(start.x + 2, start.y + 2, start.z))
	TEST_ASSERT(keycard.ui_status(corgi) == UI_CLOSE, "a corgi can use the keycard authentication device")

#undef TEST_ASSERT
