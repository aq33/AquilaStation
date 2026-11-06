// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - regresja: niepodległość działu nie wciąga szefów i ma własną opcję w preferencjach antagonistów
/datum/unit_test/aquila_review_separatist_optin

/datum/unit_test/aquila_review_separatist_optin/Run()
	for(var/list/department in GLOB.aquila_independence_departments)
		for(var/job in department["jobs"])
			TEST_ASSERT(!(job in GLOB.command_positions), "The [department["name"]] department strike still drafts the head of staff [job]")
	TEST_ASSERT(GLOB.role_preference_entries[/datum/role_preference/midround_living/aquila_separatist], "The separatist role has no entry in the antagonist preferences")

/// AQUILA - regresja: wydłużona ręka nie sięga przez całą salę
/datum/unit_test/aquila_review_extendoarm_reach

/datum/unit_test/aquila_review_extendoarm_reach/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/action/cooldown/spell/pointed/projectile/extendoarm/arm = new(user)
	arm.Grant(user)
	var/turf/far = locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	TEST_ASSERT(far, "No turf four tiles away")
	TEST_ASSERT(arm.before_cast(far) & SPELL_CANCEL_CAST, "The extendo arm reached four tiles away")
	var/obj/item/projectile/arm_projectile = arm.projectile_type
	TEST_ASSERT(initial(arm_projectile.range) <= arm.cast_range + 1, "The extendo arm projectile flies further than the spell reaches")
	qdel(arm)

/// AQUILA - regresja: skrzynka z zabawkami przyjmuje tylko zabawki
/datum/unit_test/aquila_review_clown_toybox

/datum/unit_test/aquila_review_clown_toybox/Run()
	var/obj/item/storage/toolbox/clown_toys/box = allocate(/obj/item/storage/toolbox/clown_toys, run_loc_floor_bottom_left)
	var/obj/item/screwdriver/tool = allocate(/obj/item/screwdriver, run_loc_floor_bottom_left)
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, run_loc_floor_bottom_left)
	SEND_SIGNAL(box, COMSIG_TRY_STORAGE_INSERT, tool, null, TRUE)
	TEST_ASSERT(tool.loc != box, "The toy box took a screwdriver")
	SEND_SIGNAL(box, COMSIG_TRY_STORAGE_INSERT, crayon, null, TRUE)
	TEST_ASSERT(crayon.loc == box, "The toy box refused a crayon")

/// AQUILA - regresja: karta pod przykrywką nie obniża zagrożenia jak karta agenta
/datum/unit_test/aquila_review_undercover_threat

/datum/unit_test/aquila_review_undercover_threat/Run()
	var/mob/living/carbon/human/detective = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	detective.equip_to_slot_if_possible(allocate(/obj/item/clothing/under/color/grey), ITEM_SLOT_ICLOTHING, disable_warning = TRUE) // karta ID wymaga munduru
	var/base_threat = detective.assess_threat(NONE)
	var/obj/item/card/id/syndicate/undercover/undercover = allocate(/obj/item/card/id/syndicate/undercover)
	detective.equip_to_slot_if_possible(undercover, ITEM_SLOT_ID, disable_warning = TRUE)
	TEST_ASSERT(detective.wear_id == undercover, "Could not put on the undercover ID")
	TEST_ASSERT(detective.assess_threat(NONE) == base_threat, "The undercover ID changed the threat level like an agent card")
	detective.dropItemToGround(undercover, TRUE)
	var/obj/item/card/id/syndicate/agent = allocate(/obj/item/card/id/syndicate)
	detective.equip_to_slot_if_possible(agent, ITEM_SLOT_ID, disable_warning = TRUE)
	TEST_ASSERT(detective.assess_threat(NONE) < base_threat, "The agent card no longer lowers the threat level")

/// AQUILA - regresja: gremlin nie loguje się do konsoli komunikacji
/datum/unit_test/aquila_review_gremlin_console

/datum/unit_test/aquila_review_gremlin_console/Run()
	var/obj/machinery/computer/communications/console = allocate(/obj/machinery/computer/communications, run_loc_floor_bottom_left)
	var/mob/living/simple_animal/hostile/gremlin/gremlin = allocate(/mob/living/simple_animal/hostile/gremlin, run_loc_floor_bottom_left)
	console.authenticated = FALSE
	for(var/i in 1 to 50)
		console.npc_tamper_act(gremlin)
	TEST_ASSERT(!console.authenticated, "A gremlin logged in to the communications console")

/// AQUILA - regresja: bosa noga małpy zostawia w krwi ślady łap, a mycie zmywa krew ze stóp
/datum/unit_test/aquila_review_paw_prints

/datum/unit_test/aquila_review_paw_prints/Run()
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	walker.set_species(/datum/species/monkey)
	walker.AddElement(/datum/element/forced_gravity) // pokój testowy nie ma grawitacji, a bez niej ślady nie powstają (w butach też)
	TEST_ASSERT(!walker.shoes, "The monkey has shoes")
	TEST_ASSERT(walker.get_footprint_sprite() == FOOTPRINT_SPRITE_PAWS, "Monkey legs do not make paw prints")
	var/turf/pool_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/next_turf = get_step(pool_turf, EAST)
	var/obj/effect/decal/cleanable/blood/pool = allocate(/obj/effect/decal/cleanable/blood, pool_turf)
	// Jedna świeża plama to BLOOD_AMOUNT_PER_DECAL (20), czyli za mało na ślad: w butach jest tak samo, ślady zostawia dopiero większa kałuża
	pool.bloodiness = MAX_SHOE_BLOODINESS
	walker.forceMove(pool_turf)
	TEST_ASSERT(LAZYACCESS(walker.aquila_feet_blood, BLOOD_STATE_HUMAN) > 0, "Bare feet did not get bloody in a blood pool")
	walker.Move(next_turf, EAST)
	TEST_ASSERT(walker.loc == next_turf, "The monkey did not walk")
	var/obj/effect/decal/cleanable/blood/footprints/print = locate() in next_turf
	TEST_ASSERT(print, "Bloody bare feet left no footprints (gravity [walker.has_gravity(next_turf)], standing [walker.mobility_flags & MOBILITY_STAND], feet [LAZYACCESS(walker.aquila_feet_blood, BLOOD_STATE_HUMAN)], state [walker.aquila_feet_blood_state], sprite [walker.get_footprint_sprite()], shoes [walker.shoes])")
	TEST_ASSERT(print.footprint_sprite == FOOTPRINT_SPRITE_PAWS, "A monkey left [print.footprint_sprite] prints instead of paw prints")
	qdel(print)
	SEND_SIGNAL(walker, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	TEST_ASSERT(!walker.aquila_feet_blood, "Washing did not clean the bare feet")

/// AQUILA - regresja: awatar w domenie z bójką na plaży dostaje broń, choć strój zakłada z visualsOnly
/datum/unit_test/aquila_review_beachbum_avatar

/datum/unit_test/aquila_review_beachbum_avatar/Run()
	var/mob/living/carbon/human/avatar = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/outfit/beachbum_combat/outfit = new
	avatar.equipOutfit(outfit, TRUE)
	TEST_ASSERT(!avatar.is_holding_item_of_type(/obj/item/gun), "Visuals-only equip handed out a weapon, the test no longer checks the avatar path")
	outfit.give_weapon(avatar)
	TEST_ASSERT(avatar.is_holding_item_of_type(/obj/item/gun), "The beach brawl outfit gave no weapon")

#undef TEST_ASSERT
