// AQUILA - basic mobs part 2, "rest" group (tg 926bf40c5a): mimics, venus human trap, Netherworld, clowns, fugu, lightgeist,
// space dragon. The AI is driven through its controller (SelectBehaviors/ProcessBehavior), player clicks through ClickOn().
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define LEFT_CLICK "icon-x=16;icon-y=16;left=1;button=left"
#define RIGHT_CLICK_PARAMS "icon-x=16;icon-y=16;right=1;button=right"

/// Lets the controller plan and run one behaviour of the given type; returns TRUE if it was planned
/proc/aquila_rest_run_behavior(datum/ai_controller/controller, behavior_type)
	controller.SelectBehaviors(1)
	var/datum/ai_behavior/behavior = GET_AI_BEHAVIOR(behavior_type)
	if(!controller.current_behaviors[behavior])
		return FALSE
	controller.ProcessBehavior(1, behavior)
	return TRUE

/// Clicks as a player in a basic mob, in combat mode or with the legacy intents
/proc/aquila_rest_click(mob/living/clicker, atom/target, harm = FALSE, right = FALSE)
	if(clicker.uses_legacy_intents())
		clicker.a_intent_change(harm ? INTENT_HARM : (right ? INTENT_DISARM : INTENT_HELP))
	else
		clicker.set_combat_mode(harm, silent = TRUE)
	clicker.next_click = 0
	clicker.next_move = 0
	clicker.ClickOn(target, (right && !clicker.uses_legacy_intents()) ? RIGHT_CLICK_PARAMS : LEFT_CLICK)

/// The lightgeist with the legacy intents
/mob/living/basic/lightgeist/aquila_legacy

/mob/living/basic/lightgeist/aquila_legacy/uses_legacy_intents()
	return TRUE

/// A lightgeist's AI goes for a hurt mob and heals it (healing_touch), leaves healthy ones alone;
/// a player lightgeist heals by clicking, in both control modes
/datum/unit_test/aquila_lightgeist_heals

/datum/unit_test/aquila_lightgeist_heals/Run()
	var/mob/living/basic/lightgeist/geist = allocate(/mob/living/basic/lightgeist, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = geist.ai_controller

	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The lightgeist did not look for patients")
	TEST_ASSERT(isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]), "The lightgeist picked a healthy human")

	patient.adjustBruteLoss(20)
	controller.CancelActions()
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The lightgeist did not look for patients again")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], patient, "The lightgeist did not pick the hurt human")
	var/brute_before = patient.getBruteLoss()
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	geist.next_move = 0
	geist.next_click = 0
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/basic_melee_attack), "The lightgeist did not go for its patient")
	TEST_ASSERT(patient.getBruteLoss() < brute_before, "The lightgeist's AI did not heal the patient")
	TEST_ASSERT(patient in controller.blackboard[BB_FRIENDS_LIST], "The healed human did not become the lightgeist's friend")
	controller.CancelActions()

	for(var/legacy in list(FALSE, TRUE))
		var/mob/living/basic/lightgeist/player = allocate(legacy ? /mob/living/basic/lightgeist/aquila_legacy : /mob/living/basic/lightgeist, get_step(run_loc_floor_bottom_left, NORTH))
		player.ai_controller.set_ai_status(AI_STATUS_OFF)
		TEST_ASSERT(player.combat_mode_indicator, "A playable lightgeist has no combat mode indicator")
		for(var/harm in list(FALSE, TRUE))
			patient.adjustFireLoss(10)
			var/burn_before = patient.getFireLoss()
			aquila_rest_click(player, patient, harm)
			TEST_ASSERT(patient.getFireLoss() < burn_before, "[legacy ? "legacy intents" : "combat mode"], [harm ? "harm" : "help"]: a player lightgeist did not heal by clicking")
		qdel(player)

/// A Netherworld creature finds and hits a human through its AI and hits harder when hurt (health_scaling_effects);
/// its teleport is not blocked when nobody sees it (unobserved_actor); the blank body scales too
/datum/unit_test/aquila_netherworld_creatures

/datum/unit_test/aquila_netherworld_creatures/Run()
	var/mob/living/basic/creature/creature = allocate(/mob/living/basic/creature, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = creature.ai_controller
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The creature did not look for targets")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The creature did not pick the human next to it")
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	creature.next_move = 0
	creature.next_click = 0
	var/brute_before = victim.getBruteLoss()
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/basic_melee_attack), "The creature did not go for its target")
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The creature's AI attack did not hurt the human")
	controller.CancelActions()

	var/full_damage = creature.melee_damage
	creature.adjustBruteLoss(creature.maxHealth * 0.8)
	sleep(1) // the stats update asynchronously
	TEST_ASSERT(creature.melee_damage > full_damage, "A hurt creature does not hit harder")
	creature.adjustBruteLoss(-creature.maxHealth)
	sleep(1)
	TEST_ASSERT_EQUAL(creature.melee_damage, full_damage, "A healed creature kept the extra damage")

	var/datum/component/unobserved_actor/blocker = creature.GetComponent(/datum/component/unobserved_actor)
	TEST_ASSERT(blocker, "The creature's teleport has no unobserved actor component")
	var/datum/action/cooldown/spell/jaunt/creature_teleport/teleport = locate() in creature.actions
	TEST_ASSERT(teleport, "The creature has no teleport")
	TEST_ASSERT(!(SEND_SIGNAL(creature, COMSIG_MOB_BEFORE_SPELL_CAST, teleport, creature) & SPELL_CANCEL_CAST), "The teleport was blocked although no player sees the creature")

	var/mob/living/basic/blankbody/blank = allocate(/mob/living/basic/blankbody, get_step(run_loc_floor_bottom_left, NORTH))
	var/blank_damage = blank.melee_damage
	blank.adjustBruteLoss(blank.maxHealth * 0.8)
	sleep(1)
	TEST_ASSERT(blank.melee_damage > blank_damage, "A hurt blank body does not hit harder")

	// A fugu gland doubles the damage for good: the scaling changes melee damage only by its own modifier
	blank.adjustBruteLoss(-blank.maxHealth)
	sleep(1)
	TEST_ASSERT_EQUAL(blank.melee_damage, blank_damage, "A healed blank body kept the extra damage")
	var/obj/item/fugu_gland/gland = allocate(/obj/item/fugu_gland)
	gland.glandify_basic_mob(blank, victim)
	var/glanded_damage = blank.melee_damage
	TEST_ASSERT(glanded_damage >= blank_damage * 2, "The fugu gland did not double the blank body's damage")
	blank.adjustBruteLoss(1)
	sleep(1)
	TEST_ASSERT(blank.melee_damage >= glanded_damage, "One hit took away the fugu gland's damage ([blank.melee_damage] < [glanded_damage])")

/// The venus human trap with the legacy intents
/mob/living/basic/venus_human_trap/aquila_legacy

/mob/living/basic/venus_human_trap/aquila_legacy/uses_legacy_intents()
	return TRUE

/// A venus human trap's AI tangles a human out of reach with a vine (leash) and its bites heal it (lifesteal);
/// a player trap tangles by clicking out of reach in combat mode / on the harm intent, in both control modes
/datum/unit_test/aquila_venus_human_trap

/datum/unit_test/aquila_venus_human_trap/Run()
	var/mob/living/basic/venus_human_trap/trap = allocate(/mob/living/basic/venus_human_trap, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/ai_controller/controller = trap.ai_controller
	var/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/tangle = controller.blackboard[BB_TARGETED_ACTION]
	TEST_ASSERT(istype(tangle), "The trap has no tangle ability in its blackboard")
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The trap did not look for targets")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The trap did not pick the human")
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/targeted_mob_ability), "The trap's AI did not plan to tangle its target")
	TEST_ASSERT(victim.GetComponent(/datum/component/leash), "The tangle did not leash the human to the trap")
	TEST_ASSERT(tangle.next_use_time > world.time, "The tangle did not start its cooldown")
	controller.CancelActions()

	// Lifesteal: a bite on a living target heals the trap
	victim.forceMove(get_step(run_loc_floor_bottom_left, EAST))
	trap.adjustBruteLoss(20)
	var/trap_health = trap.health
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	trap.next_move = 0
	trap.next_click = 0
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/basic_melee_attack), "The trap did not bite a target next to it")
	TEST_ASSERT(trap.health > trap_health, "The bite did not heal the trap (lifesteal)")
	controller.CancelActions()
	qdel(trap)

	for(var/legacy in list(FALSE, TRUE))
		var/mob/living/basic/venus_human_trap/player = allocate(legacy ? /mob/living/basic/venus_human_trap/aquila_legacy : /mob/living/basic/venus_human_trap, run_loc_floor_bottom_left)
		player.ai_controller.set_ai_status(AI_STATUS_OFF)
		var/mob/living/carbon/human/prey = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z))
		aquila_rest_click(player, prey, harm = FALSE)
		TEST_ASSERT(!prey.GetComponent(/datum/component/leash), "[legacy ? "legacy intents" : "combat mode"]: a click out of combat mode tangled the prey")
		aquila_rest_click(player, prey, harm = TRUE)
		TEST_ASSERT(prey.GetComponent(/datum/component/leash), "[legacy ? "legacy intents" : "combat mode"]: a harmful click out of reach did not tangle the prey")
		qdel(player)
		qdel(prey)

/// A wumborian fugu's AI inflates when it has a target (invulnerable, stronger, tears walls) and deflates when the effect ends;
/// a fugu gland makes a basic mob bigger and stronger
/datum/unit_test/aquila_wumborian_fugu

/datum/unit_test/aquila_wumborian_fugu/Run()
	var/mob/living/basic/wumborian_fugu/fugu = allocate(/mob/living/basic/wumborian_fugu, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/ai_controller/controller = fugu.ai_controller
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The fugu did not look for targets")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The fugu did not pick the human")
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/targeted_mob_ability), "The fugu's AI did not plan to inflate")
	var/datum/status_effect/inflated/wumbo = fugu.has_status_effect(/datum/status_effect/inflated)
	TEST_ASSERT(wumbo, "The fugu did not inflate")
	TEST_ASSERT(fugu.status_flags & GODMODE, "The inflated fugu is not invulnerable")
	TEST_ASSERT(fugu.melee_damage > 0, "The inflated fugu does no damage")
	TEST_ASSERT(HAS_TRAIT(fugu, TRAIT_FUGU_GLANDED), "The inflated fugu has no glanded trait")
	var/health_before = fugu.health
	fugu.adjustBruteLoss(30)
	TEST_ASSERT_EQUAL(fugu.health, health_before, "The inflated fugu took damage")
	qdel(wumbo)
	TEST_ASSERT(!(fugu.status_flags & GODMODE), "The deflated fugu stayed invulnerable")
	TEST_ASSERT_EQUAL(fugu.melee_damage, 0, "The deflated fugu kept its damage")
	TEST_ASSERT_EQUAL(fugu.icon_state, "Fugu0", "The deflated fugu kept the inflated sprite")
	controller.CancelActions()

	// The gland works on basic mobs
	var/mob/living/basic/blankbody/blank = allocate(/mob/living/basic/blankbody, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTHEAST))
	var/obj/item/fugu_gland/gland = allocate(/obj/item/fugu_gland, user.loc)
	var/old_max = blank.maxHealth
	gland.afterattack(blank, user, TRUE)
	TEST_ASSERT(blank.maxHealth > old_max, "The fugu gland did not toughen a basic mob")
	TEST_ASSERT(HAS_TRAIT(blank, TRAIT_FUGU_GLANDED), "The fugu gland did not mark the basic mob")
	TEST_ASSERT(QDELETED(gland), "The fugu gland was not used up")

/// Clowns: an attacked clown and the clowns around it retaliate through the AI, the honkling's hit injects laughter;
/// the living lube wets the floor it walks on, the clownana's AI drops peels (rustle), the glutton shrugs off weak hits
/datum/unit_test/aquila_clowns

/datum/unit_test/aquila_clowns/Run()
	var/mob/living/basic/clown/honkling/clown = allocate(/mob/living/basic/clown/honkling, run_loc_floor_bottom_left)
	var/mob/living/basic/clown/buddy = allocate(/mob/living/basic/clown, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = clown.ai_controller
	TEST_ASSERT(isclown(clown), "isclown() does not know basic clowns")
	controller.SelectBehaviors(1)
	TEST_ASSERT(!controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], "A clown picked a target before anyone hit it")

	attacker.set_combat_mode(TRUE, silent = TRUE)
	attacker.next_click = 0
	attacker.next_move = 0
	attacker.ClickOn(clown, LEFT_CLICK)
	TEST_ASSERT(attacker in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The punched clown does not remember its attacker")
	sleep(1) // the retaliation callback runs asynchronously
	TEST_ASSERT(attacker in buddy.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST], "The other clown did not join the fight")
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/target_from_retaliate_list), "The clown did not pick a target from its retaliation list")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], attacker, "The clown did not target its attacker")
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	clown.next_move = 0
	clown.next_click = 0
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/basic_melee_attack), "The clown did not attack its attacker")
	TEST_ASSERT(attacker.reagents.has_reagent(/datum/reagent/consumable/laughter), "The honkling's hit did not inject laughter")
	controller.CancelActions()

	// Living lube wets the floor it moves over
	var/mob/living/basic/clown/lube/lube = allocate(/mob/living/basic/clown/lube, locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y + 3, run_loc_floor_bottom_left.z))
	lube.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/turf/open/lubed = get_step(lube, NORTH)
	lube.Move(lubed, NORTH)
	TEST_ASSERT(lubed.GetComponent(/datum/component/wet_floor), "The living lube did not wet the floor it walked on")

	// The clownana's AI drops peels with its rustle ability
	var/mob/living/basic/clown/banana/banana = allocate(/mob/living/basic/clown/banana, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 3, run_loc_floor_bottom_left.z))
	TEST_ASSERT(aquila_rest_run_behavior(banana.ai_controller, /datum/ai_behavior/use_mob_ability), "The clownana's AI did not use rustle")
	TEST_ASSERT(locate(/obj/item/grown/bananapeel) in range(1, banana), "The clownana did not drop banana peels")

	// The glutton's fat stops weak hits but not strong ones
	var/mob/living/basic/clown/mutant/glutton/glutton = allocate(/mob/living/basic/clown/mutant/glutton, locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	glutton.ai_controller.set_ai_status(AI_STATUS_OFF)
	attacker.forceMove(get_step(glutton, WEST))
	var/obj/item/kitchen/knife/knife = allocate(/obj/item/kitchen/knife, attacker.loc)
	knife.force = 5
	attacker.put_in_active_hand(knife)
	attacker.next_click = 0
	attacker.next_move = 0
	attacker.ClickOn(glutton, LEFT_CLICK)
	TEST_ASSERT_EQUAL(glutton.health, glutton.maxHealth, "A weak hit got through the glutton's fat")
	knife.force = 20
	attacker.next_click = 0
	attacker.next_move = 0
	attacker.ClickOn(glutton, LEFT_CLICK)
	TEST_ASSERT(glutton.health < glutton.maxHealth, "A strong hit did not hurt the glutton")

/// Mimics: a crate mimic sleeps until someone tries to open it, then bites through its AI; a copy mimic takes the look of
/// its object, befriends its creator and dies when the object is taken out; a gun copy shoots through its AI and goes for
/// melee when the gun is empty; a vending machine copy speaks the lines from its blackboard
/datum/unit_test/aquila_mimics

/datum/unit_test/aquila_mimics/Run()
	var/mob/living/basic/mimic/crate/crate = allocate(/mob/living/basic/mimic/crate, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = crate.ai_controller
	TEST_ASSERT(HAS_TRAIT(crate, TRAIT_AI_PAUSED), "The crate mimic is not inert at the start")
	victim.set_combat_mode(FALSE, silent = TRUE)
	victim.next_click = 0
	victim.next_move = 0
	victim.ClickOn(crate, LEFT_CLICK)
	TEST_ASSERT(!HAS_TRAIT(crate, TRAIT_AI_PAUSED), "Trying to open the crate mimic did not wake it up")
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The awake crate did not look for targets")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The awake crate did not pick the human")
	controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time - 1)
	crate.next_move = 0
	crate.next_click = 0
	var/brute_before = victim.getBruteLoss()
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/basic_melee_attack), "The crate did not attack")
	TEST_ASSERT(victim.getBruteLoss() > brute_before, "The crate's bite did not hurt")
	controller.CancelActions()
	qdel(crate)

	// A copy of an item: its look, its creator as a friend, death when the item is taken out
	var/mob/living/carbon/human/creator = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	var/obj/item/kitchen/knife/knife = allocate(/obj/item/kitchen/knife, run_loc_floor_bottom_left)
	var/mob/living/basic/mimic/copy/copy = allocate(/mob/living/basic/mimic/copy, run_loc_floor_bottom_left, knife, creator)
	TEST_ASSERT_EQUAL(copy.name, knife.name, "The copy did not take the name of its item")
	TEST_ASSERT_EQUAL(knife.loc, copy, "The copied item is not inside the copy")
	TEST_ASSERT(creator in copy.ai_controller.blackboard[BB_FRIENDS_LIST], "The copy did not befriend its creator")
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(copy.ai_controller.blackboard[BB_TARGETING_STRATEGY])
	TEST_ASSERT(!strategy.can_attack(copy, creator), "The copy would attack its creator")
	knife.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(QDELETED(copy) || copy.stat == DEAD, "The copy lived on after its item was taken out")

	// A gun copy shoots through its AI
	var/obj/item/gun/energy/laser/laser = allocate(/obj/item/gun/energy/laser, run_loc_floor_bottom_left)
	var/mob/living/basic/mimic/copy/ranged/gun_mimic = allocate(/mob/living/basic/mimic/copy/ranged, run_loc_floor_bottom_left, laser)
	victim.forceMove(locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	creator.forceMove(locate(run_loc_floor_bottom_left.x, run_loc_floor_bottom_left.y + 4, run_loc_floor_bottom_left.z))
	var/datum/aquila_bullet_recorder/recorder = new
	recorder.RegisterSignal(victim, COMSIG_ATOM_BULLET_ACT, TYPE_PROC_REF(/datum/aquila_bullet_recorder, on_bullet_act))
	var/datum/ai_controller/gun_controller = gun_mimic.ai_controller
	// Strzał z rozrzutem może chybić (CI pada co kilka przebiegów), więc kopia ma kilka prób
	var/gun_hit = FALSE
	for(var/attempt in 1 to 5)
		gun_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
		TEST_ASSERT(aquila_rest_run_behavior(gun_controller, /datum/ai_behavior/basic_ranged_attack/avoid_friendly_fire), "The gun copy did not plan to shoot")
		if(aquila_wait_for_hit(recorder))
			gun_hit = TRUE
			break
		gun_controller.CancelActions()
	TEST_ASSERT(gun_hit, "The gun copy's shot did not hit")
	gun_controller.CancelActions()
	laser.cell.use(laser.cell.charge)
	gun_mimic.fire_gun(victim)
	TEST_ASSERT(gun_controller.blackboard[BB_GUNMIMIC_GUN_EMPTY], "The gun copy did not notice its gun is empty")
	gun_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	gun_controller.SelectBehaviors(1)
	TEST_ASSERT(!gun_controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/basic_ranged_attack/avoid_friendly_fire)], "The gun copy kept shooting an empty gun")
	TEST_ASSERT(gun_controller.current_behaviors[GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)], "The gun copy with an empty gun did not go for melee")
	gun_controller.CancelActions()
	qdel(recorder)

	// A vending machine brought to life speaks from its blackboard
	var/obj/machinery/vending/cola/vendor = allocate(/obj/machinery/vending/cola, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z))
	var/mob/living/basic/mimic/copy/vending_mimic = allocate(/mob/living/basic/mimic/copy, vendor.loc, vendor, null, TRUE)
	TEST_ASSERT(QDELETED(vendor), "The vending machine stayed after it came to life")
	vending_mimic.ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, list(BB_EMOTE_SAY = list("Agresywna strategia rozwojowa!"), BB_SPEAK_CHANCE = 100))
	vending_mimic.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	TEST_ASSERT(aquila_rest_run_behavior(vending_mimic.ai_controller, /datum/ai_behavior/perform_speech), "The vending machine mimic did not speak its line with a target")

/// The space dragon with the legacy intents
/mob/living/basic/space_dragon/aquila_legacy

/mob/living/basic/space_dragon/aquila_legacy/uses_legacy_intents()
	return TRUE

/// Space dragon: the AI breathes fire at its target through the controller; a player breathes fire by clicking out of reach,
/// uses the wing buffet with the secondary click (right click / disarm intent) in both control modes, tears walls, swallows
/// corpses to heal and summons a carp rift as the antagonist
/datum/unit_test/aquila_space_dragon

/datum/unit_test/aquila_space_dragon/Run()
	var/turf/corner = run_loc_floor_bottom_left
	var/mob/living/basic/space_dragon/dragon = allocate(/mob/living/basic/space_dragon, corner)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(corner.x + 3, corner.y, corner.z))
	var/datum/ai_controller/controller = dragon.ai_controller
	TEST_ASSERT_EQUAL(controller.blackboard[BB_TARGETED_ACTION], dragon.fire_breath, "The dragon's fire breath is not in its blackboard")
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/find_potential_targets), "The AI dragon did not look for targets")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], victim, "The AI dragon did not pick the human")
	TEST_ASSERT(aquila_rest_run_behavior(controller, /datum/ai_behavior/targeted_mob_ability), "The AI dragon did not plan to breathe fire")
	sleep(1 SECONDS) // the fire goes one tile a tick
	TEST_ASSERT(victim.getFireLoss() > 0, "The AI dragon's fire breath did not burn the human")
	controller.CancelActions()
	qdel(dragon)

	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		var/mob/living/basic/space_dragon/player = allocate(legacy ? /mob/living/basic/space_dragon/aquila_legacy : /mob/living/basic/space_dragon, corner)
		player.ai_controller.set_ai_status(AI_STATUS_OFF)
		TEST_ASSERT(player.combat_mode_indicator, "[mode]: the player dragon has no combat mode indicator")
		victim.fully_heal(TRUE)
		victim.forceMove(locate(corner.x + 3, corner.y + 1, corner.z))
		aquila_rest_click(player, victim, harm = TRUE)
		TEST_ASSERT(player.fire_breath.next_use_time > world.time, "[mode]: a click out of reach did not breathe fire")
		sleep(1 SECONDS)
		TEST_ASSERT(victim.getFireLoss() > 0, "[mode]: the player's fire breath did not burn the human")

		aquila_rest_click(player, victim, right = TRUE)
		TEST_ASSERT(HAS_TRAIT(player, TRAIT_WING_BUFFET), "[mode]: the secondary click out of reach did not start the wing buffet")
		sleep(2 SECONDS) // windup and endlag
		TEST_ASSERT(!HAS_TRAIT(player, TRAIT_WING_BUFFET), "[mode]: the wing buffet did not end")
		TEST_ASSERT(victim.IsParalyzed(), "[mode]: the wing buffet did not knock the human down")
		victim.SetParalyzed(0)
		qdel(player)

	// Swallowing a corpse heals the dragon, the corpse comes back out on death
	var/mob/living/basic/space_dragon/eater = allocate(/mob/living/basic/space_dragon, corner)
	eater.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human, get_step(corner, NORTH))
	corpse.death()
	eater.adjustBruteLoss(100)
	var/hurt_health = eater.health
	eater.eat(corpse)
	TEST_ASSERT_EQUAL(corpse.loc, eater, "The dragon did not swallow the corpse")
	TEST_ASSERT(eater.health > hurt_health, "Swallowing a corpse did not heal the dragon")

	// Wall tearing (wall_tearer): a click on a wall starts tearing it
	var/turf/wall_turf = locate(corner.x + 1, corner.y + 4, corner.z)
	var/old_wall_type = wall_turf.type
	wall_turf.ChangeTurf(/turf/closed/wall)
	eater.forceMove(get_step(wall_turf, SOUTH))
	eater.next_click = 0
	eater.next_move = 0
	eater.ClickOn(wall_turf, LEFT_CLICK)
	sleep(4.5 SECONDS)
	TEST_ASSERT(!iswallturf(wall_turf), "The dragon did not tear down the wall")
	wall_turf.ChangeTurf(old_wall_type)

	eater.death()
	TEST_ASSERT(corpse.loc != eater, "The dead dragon kept the swallowed corpse")

	// The antagonist summons a carp rift in an allowed area
	var/mob/living/basic/space_dragon/antag_dragon = allocate(/mob/living/basic/space_dragon, corner)
	antag_dragon.ai_controller.set_ai_status(AI_STATUS_OFF)
	antag_dragon.mind_initialize()
	var/datum/antagonist/space_dragon/dragon_datum = antag_dragon.mind.add_antag_datum(/datum/antagonist/space_dragon)
	TEST_ASSERT(dragon_datum, "The dragon did not become the space dragon antagonist")
	dragon_datum.chosen_rift_areas += get_area(antag_dragon)
	var/datum/action/innate/summon_rift/rift_action = dragon_datum.rift_ability
	TEST_ASSERT(rift_action, "The antagonist dragon has no rift summon action")
	rift_action.Activate()
	var/obj/structure/carp_rift/rift = locate() in get_turf(antag_dragon)
	TEST_ASSERT(rift, "The antagonist dragon did not summon a carp rift")
	TEST_ASSERT(rift in dragon_datum.rift_list, "The rift is not on the antagonist's rift list")
	dragon_datum.objective_complete = TRUE // no rift failure effects while cleaning up
	qdel(rift)
	antag_dragon.mind.remove_antag_datum(/datum/antagonist/space_dragon)

// --- end of the "rest" group tests
#undef LEFT_CLICK
#undef RIGHT_CLICK_PARAMS
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
