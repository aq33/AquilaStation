// AQUILA - regression tests of the max review of aq33/AquilaStation#625 (basic mobs part 2): each test runs the reported case
// and checks the result. Report: raport/mobabilities_06_review_max.md.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AI movement: space is safe for mobs that move in it (spacewalk) and flyers, not for the rest (pets stay inside);
/// a lassoed carp keeps swimming in space with its rider
/datum/unit_test/aquila_review625_space_movement

/datum/unit_test/aquila_review625_space_movement/Run()
	var/turf/open/space/void = locate(/turf/open/space)
	TEST_ASSERT(void, "No space turf in the world to test with")
	var/mob/living/basic/carp/carp = allocate(/mob/living/basic/carp, run_loc_floor_bottom_left)
	var/mob/living/basic/pet/dog/corgi/corgi = allocate(/mob/living/basic/pet/dog/corgi, get_step(run_loc_floor_bottom_left, EAST))
	TEST_ASSERT(void.can_cross_safely(carp), "A carp (spacewalk) does not swim into space on its own")
	TEST_ASSERT(!void.can_cross_safely(corgi), "A corgi walks out into space")
	corgi.movement_type |= FLYING
	TEST_ASSERT(void.can_cross_safely(corgi), "A flying mob does not cross space")
	TEST_ASSERT(run_loc_floor_bottom_left.can_cross_safely(corgi), "A plain floor is not safe")

	carp.setup_tamed_riding()
	var/datum/component/riding/tamed/riding = carp.GetComponent(/datum/component/riding/tamed)
	TEST_ASSERT(riding, "The carp got no riding component")
	TEST_ASSERT(riding.override_allow_spacemove, "A ridden carp cannot move in space")
	var/mob/living/carbon/human/rider = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	carp.buckle_mob(rider, TRUE)
	TEST_ASSERT(rider.spacewalk, "The carp's rider does not get its spacewalk")
	carp.unbuckle_mob(rider, TRUE)
	TEST_ASSERT(!rider.spacewalk, "The rider kept spacewalk after getting off")

/// Moved movement speeds: basic mobs skip the simple animal +1 config, so the copied speeds got +1; clowns never step every tick
/datum/unit_test/aquila_review625_speeds

/datum/unit_test/aquila_review625_speeds/Run()
	// Our simple animals: run delay + 1 (MULTIPLICATIVE_MOVESPEED) + speed 0
	var/simple_delay = CONFIG_GET(number/movedelay/run_delay) + 1
	for(var/mob_type in list(/mob/living/basic/carp, /mob/living/basic/trooper/syndicate, /mob/living/basic/alien, /mob/living/basic/goose))
		var/mob/living/basic/walker = allocate(mob_type, run_loc_floor_bottom_left)
		TEST_ASSERT(walker.cached_multiplicative_slowdown >= simple_delay, "[mob_type] moves faster ([walker.cached_multiplicative_slowdown] ds per tile) than our simple animal did ([simple_delay])")
		qdel(walker)
	for(var/mob_type in typesof(/mob/living/basic/clown))
		var/mob/living/basic/clown/clown = allocate(mob_type, run_loc_floor_bottom_left)
		TEST_ASSERT(clown.cached_multiplicative_slowdown > 0, "[mob_type] steps every tick ([clown.cached_multiplicative_slowdown] ds per tile)")
		qdel(clown)

/// Nasty blocks hurt only attackers without hardattacks; basic mobs hit mechs again (20 per hit like the old simple animals)
/datum/unit_test/aquila_review625_blocks_and_mechs

/datum/unit_test/aquila_review625_blocks_and_mechs/Run()
	var/mob/living/carbon/human/blocker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/chainsaw/saw = allocate(/obj/item/chainsaw)
	blocker.put_in_active_hand(saw)
	var/mob/living/basic/hivebot/hivebot = allocate(/mob/living/basic/hivebot, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/basic/carp/carp = allocate(/mob/living/basic/carp, get_step(run_loc_floor_bottom_left, NORTH))
	TEST_ASSERT(hivebot.hardattacks, "The hivebot lost hardattacks")
	TEST_ASSERT(!carp.hardattacks, "The carp has hardattacks it never had")
	saw.on_block(blocker, hivebot, "atak", 10, MELEE_ATTACK)
	TEST_ASSERT_EQUAL(hivebot.health, hivebot.maxHealth, "A nasty block hurt a hivebot (hardattacks)")
	saw.on_block(blocker, carp, "atak", 10, MELEE_ATTACK)
	TEST_ASSERT(carp.health < carp.maxHealth, "A nasty block did not hurt a carp")

	var/obj/mecha/working/ripley/mech = allocate(/obj/mecha/working/ripley, get_step(run_loc_floor_bottom_left, NORTHEAST))
	// Ripley odbija 15% ciosów (deflect_chance), przez co test padał losowo
	mech.deflect_chance = 0
	var/integrity_before = mech.obj_integrity
	carp.next_move = 0
	carp.melee_attack(mech, ignore_cooldown = TRUE)
	TEST_ASSERT(mech.obj_integrity < integrity_before, "A carp does no damage to a mech")

/// Geese do not eat brains (eating one deleted the brainmob) and do not hiss at food
/datum/unit_test/aquila_review625_goose

/datum/unit_test/aquila_review625_goose/Run()
	var/mob/living/basic/goose/goose = allocate(/mob/living/basic/goose, run_loc_floor_bottom_left)
	var/obj/item/organ/brain/brain = allocate(/obj/item/organ/brain, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/food/cookie/cookie = allocate(/obj/item/food/cookie, get_step(run_loc_floor_bottom_left, NORTH))
	TEST_ASSERT(!goose_can_eat(brain), "A goose would eat a brain")
	TEST_ASSERT(goose_can_eat(cookie), "A goose would not eat a cookie")
	TEST_ASSERT_EQUAL(goose.on_tried_gobbling(goose, brain), COMSIG_MOB_CANCEL_EAT, "Feeding a goose a brain was not cancelled")
	var/datum/component/aggro_emote/emote = goose.GetComponent(/datum/component/aggro_emote)
	TEST_ASSERT(emote?.living_only, "The goose's aggro emote does not keep living_only")

/// Holodeck mobs leave no real loot; mapped sizes (resize) scale basic mobs
/datum/unit_test/aquila_review625_loot_and_size

/datum/unit_test/aquila_review625_loot_and_size/Run()
	var/mob/living/basic/clown/holoclown = allocate(/mob/living/basic/clown, run_loc_floor_bottom_left)
	holoclown.flags_1 |= HOLOGRAM_1
	var/list/before = run_loc_floor_bottom_left.contents.Copy()
	holoclown.death()
	for(var/atom/movable/thing in run_loc_floor_bottom_left)
		if(thing in before)
			continue
		if(ismob(thing) || (isobj(thing) && !istype(thing, /obj/effect/decal) && !istype(thing, /obj/effect/temp_visual)))
			return Fail("A holodeck clown dropped [thing.type]")

	var/mob/living/basic/mining/gutlunch/grublunch/baby = allocate(/mob/living/basic/mining/gutlunch/grublunch, get_step(run_loc_floor_bottom_left, EAST))
	sleep(3) // the scale animates over 2 ds
	var/matrix/scale = baby.transform
	TEST_ASSERT(scale.a < 1, "The grublunch is not smaller than a grown gutlunch")

/// A nest gives each of its mobs its own faction list, so taming one does not befriend the whole nest
/datum/unit_test/aquila_review625_spawner_faction

/datum/unit_test/aquila_review625_spawner_faction/Run()
	var/obj/structure/spawner/syndicate/beacon = allocate(/obj/structure/spawner/syndicate, run_loc_floor_bottom_left)
	var/datum/component/spawner/spawner = beacon.GetComponent(/datum/component/spawner)
	spawner.spawn_delay = 0
	spawner.try_spawn_mob()
	spawner.spawn_delay = 0
	spawner.try_spawn_mob()
	TEST_ASSERT_EQUAL(length(spawner.spawned_mobs), 2, "The beacon did not spawn two troopers")
	var/mob/living/first = spawner.spawned_mobs[1]
	var/mob/living/second = spawner.spawned_mobs[2]
	TEST_ASSERT(first.faction != second.faction, "Two mobs of one nest share a faction list")
	var/mob/living/carbon/human/tamer = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	first.befriend(tamer)
	TEST_ASSERT(!second.faction_check_mob(tamer), "Befriending one mob of the nest befriended the other too")
	for(var/mob/living/spawned as anything in spawner.spawned_mobs.Copy())
		qdel(spawned)

/// A dying crate mimic and a polymorphed space dragon drop the bodies they swallowed; the dragon of a player who logged out
/// keeps its AI off
/datum/unit_test/aquila_review625_swallowed_bodies

/datum/unit_test/aquila_review625_swallowed_bodies/Run()
	var/mob/living/basic/mimic/crate/crate = allocate(/mob/living/basic/mimic/crate, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/trapped = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	trapped.forceMove(crate)
	crate.death()
	TEST_ASSERT(!QDELETED(trapped), "The crate mimic deleted the body inside it")
	TEST_ASSERT(isturf(trapped.loc), "The body stayed inside the dead crate mimic")

	var/mob/living/basic/space_dragon/dragon = allocate(/mob/living/basic/space_dragon, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/carbon/human/eaten = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	eaten.forceMove(dragon)
	var/mob/living/basic/carp/new_form = allocate(/mob/living/basic/carp, get_step(run_loc_floor_bottom_left, EAST))
	dragon.wabbajack_act(new_form)
	TEST_ASSERT(isturf(eaten.loc), "A polymorphed space dragon kept the body it ate")
	TEST_ASSERT(!QDELETED(eaten), "A polymorphed space dragon deleted the body it ate")

	var/mob/living/basic/space_dragon/antag_dragon = allocate(/mob/living/basic/space_dragon, get_step(run_loc_floor_bottom_left, NORTH))
	antag_dragon.mind_initialize()
	TEST_ASSERT_EQUAL(antag_dragon.ai_controller.get_expected_ai_status(), AI_STATUS_OFF, "The AI would drive a player's dragon")

/// The shuttle barmaid (a basic xenomorph with an access card) opens doors with its card
/datum/unit_test/aquila_review625_barmaid_access

/datum/unit_test/aquila_review625_barmaid_access/Run()
	var/mob/living/basic/alien/maid/barmaid/barmaid = allocate(/mob/living/basic/alien/maid/barmaid, run_loc_floor_bottom_left)
	TEST_ASSERT(barmaid.access_card, "The barmaid has no access card")
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, get_step(run_loc_floor_bottom_left, EAST))
	door.req_access = list(ACCESS_BAR)
	TEST_ASSERT(door.allowed(barmaid), "The barmaid's access card does not open a bar door")

/// Unspent rounds in a gun (get_ammo() also counts a spent shell left in the chamber)
/proc/aquila_live_rounds(obj/item/gun/ballistic/gun)
	. = gun.chambered?.BB ? 1 : 0
	for(var/obj/item/ammo_casing/round as anything in gun.magazine?.stored_ammo)
		if(ispath(round) || round.BB)
			.++

/// A pump shotgun copy cycles its own rounds (rack() wants two hands) and keeps shooting instead of dry-firing
/datum/unit_test/aquila_review625_shotgun_mimic

/datum/unit_test/aquila_review625_shotgun_mimic/Run()
	var/obj/item/gun/ballistic/shotgun/shotgun = allocate(/obj/item/gun/ballistic/shotgun, run_loc_floor_bottom_left)
	var/mob/living/basic/mimic/copy/ranged/gun_mimic = allocate(/mob/living/basic/mimic/copy/ranged, run_loc_floor_bottom_left, shotgun)
	gun_mimic.ai_controller?.set_ai_status(AI_STATUS_OFF)
	var/turf/aim = locate(min(run_loc_floor_bottom_left.x + 3, run_loc_floor_top_right.x), run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/ammo_before = aquila_live_rounds(shotgun)
	TEST_ASSERT(ammo_before >= 2, "The shotgun copy started with [ammo_before] shells")
	gun_mimic.fire_gun(aim)
	sleep(max(shotgun.fire_delay, 1) + 10) // the gun's own semi-auto cooldown
	gun_mimic.fire_gun(aim)
	sleep(2)
	TEST_ASSERT(aquila_live_rounds(shotgun) <= ammo_before - 2, "The pump shotgun copy fired once and then only clicked ([aquila_live_rounds(shotgun)] of [ammo_before] shells left)")
	TEST_ASSERT(!gun_mimic.ai_controller?.blackboard[BB_GUNMIMIC_GUN_EMPTY], "The shotgun copy thinks its loaded gun is empty")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
