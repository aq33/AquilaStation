// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]") }

/// AQUILA - medibot mówi kwestie z dźwiękiem najwyżej raz na MEDBOT_VOICE_COOLDOWN (kilka medibotów zagłuszało ambulatorium)
/datum/unit_test/aquila_medbot_voice_cooldown

/datum/unit_test/aquila_medbot_voice_cooldown/Run()
	var/mob/living/basic/bot/medbot/bot = allocate(/mob/living/basic/bot/medbot, run_loc_floor_bottom_left)
	TEST_ASSERT(bot.medbot_voice("Pavulon już jest.", 'aquila/sound/voice/medbot/pawulon_jest.ogg'), "The first voiced line was blocked")
	TEST_ASSERT(!bot.medbot_voice("Tu jeszcze troszeczke pavuloniku.", 'aquila/sound/voice/medbot/jeszcze_pawulon.ogg'), "A second voiced line played right after the first")
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	bot.on_work_target_found(patient)
	TEST_ASSERT(!COOLDOWN_FINISHED(bot, found_speech_cooldown), "Finding a patient didn't start the greeting cooldown")

/// AQUILA - roślina na łopatce wrzucona do kosza znika, a łopatka zostaje w ręce; ręką i kultywatorem roślinę da się wyrwać
/datum/unit_test/aquila_plant_spade_disposal

/datum/unit_test/aquila_plant_spade_disposal/proc/plant_tomato(obj/item/plant_tray/tray)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	tray.reagents.add_reagent(/datum/reagent/water, 50)
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/tomato, get_turf(tray))
	return seeds.plant(tray, null, TRUE, null, TRUE)

/datum/unit_test/aquila_plant_spade_disposal/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(origin, EAST))
	var/obj/machinery/disposal/bin/bin = allocate(/obj/machinery/disposal/bin, get_step(origin, NORTH))
	var/obj/item/shovel/spade/spade = allocate(/obj/item/shovel/spade)
	user.put_in_active_hand(spade)

	// Łopatka z rośliną (stan po async_catch_attackby) kliknięta w kosz
	var/datum/component/plant/plant = plant_tomato(tray)
	TEST_ASSERT_NOTNULL(plant, "Couldn't plant a tomato")
	var/obj/item/plant/plant_item = plant.plant_item
	tray.vis_contents -= plant_item
	plant_item.forceMove(spade)
	spade.vis_contents |= plant_item
	plant.RegisterSignal(spade, COMSIG_ITEM_PRE_ATTACK, TYPE_PROC_REF(/datum/component/plant, catch_spade_attack))
	plant.RegisterSignal(plant_item, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/component/plant, catch_moved))
	spade.melee_attack_chain(user, bin)
	TEST_ASSERT(QDELETED(plant_item), "The plant on the spade wasn't thrown away into the disposal bin")
	TEST_ASSERT(spade.loc == user, "The spade went into the disposal bin together with the plant ([spade.loc])")

	// Wyrwanie ręką (prawy przycisk albo rozbrajanie, czas skrócony do zera)
	tray = allocate(/obj/item/plant_tray, get_step(origin, NORTHEAST))
	plant = plant_tomato(tray)
	TEST_ASSERT_NOTNULL(plant, "Couldn't plant a second tomato")
	plant_item = plant.plant_item
	TEST_ASSERT(plant.rip_out(user, 0), "Ripping the plant out by hand failed")
	TEST_ASSERT(QDELETED(plant_item), "The ripped out plant stayed in the tray")

	// Kultywator na tacy bez chwastów nie wyrywa niczego sam (wybór rośliny z menu), ale z chwastami dalej je pieli
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.weed_level = 20
	var/obj/item/cultivator/cultivator = allocate(/obj/item/cultivator)
	user.dropItemToGround(spade)
	user.put_in_active_hand(cultivator)
	cultivator.melee_attack_chain(user, tray)
	TEST_ASSERT(planter.weed_level == 0, "The cultivator didn't remove the weeds (level [planter.weed_level])")

/// AQUILA - pager nowego członka drużyny trafia do kieszeni, a nie na dno plecaka
/datum/unit_test/aquila_squad_pager_pocket

/datum/unit_test/aquila_squad_pager_pocket/Run()
	var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	member.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(member), ITEM_SLOT_ICLOTHING)
	member.equip_to_slot_or_del(new /obj/item/storage/backpack(member), ITEM_SLOT_BACK)
	var/datum/squad/squad = GLOB.squad_manager.squads[1]
	squad.add_member(member, give_items = TRUE)
	var/obj/item/squad_pager/pager = member.l_store
	if(!istype(pager))
		pager = member.r_store
	TEST_ASSERT(istype(pager), "The squad pager isn't in a pocket (left: [member.l_store], right: [member.r_store])")
	TEST_ASSERT(pager.squad == squad, "The pager in the pocket is tuned to another squad")
	squad.remove_member(member)

#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
