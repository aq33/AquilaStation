// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Sprzątanie kałuż i pamięci rozlań po teście, żeby nie przeszły do kolejnych
/proc/aquila_liquids_cleanup(turf/T)
	if(!QDELETED(T.liquids?.liquid_group))
		qdel(T.liquids.liquid_group)
	QDEL_NULL(T.liquids)
	T.clear_liquid_residue()
	for(var/obj/structure/liquid_ice_block/block in T)
		QDEL_NULL(block.reagents)
		qdel(block)
	for(var/obj/effect/decal/cleanable/C in T)
		qdel(C)

/// AQUILA - ciecze: rozlanie poniżej 50 j. robi rozprysk, a małe rozlania na jednym kafelku sumują się w kałużę
/datum/unit_test/aquila_liquid_spill_threshold

/datum/unit_test/aquila_liquid_spill_threshold/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/datum/reagents/splash = new(100)
	splash.add_reagent(/datum/reagent/water, 30)
	T.spill_reagents(splash)
	TEST_ASSERT(QDELETED(T.liquids), "30 units of water made a puddle below the threshold")
	TEST_ASSERT(T.liquid_residue?.total_volume >= 29, "Small spill was not remembered on the turf")

	T.spill_reagents(splash)
	TEST_ASSERT(!QDELETED(T.liquids), "Two small spills (60 units) did not add up into a puddle")
	TEST_ASSERT(T.liquids.liquid_group.reagents.total_volume >= 59, "Puddle lost the remembered small spill ([T.liquids.liquid_group.reagents.total_volume] units)")
	TEST_ASSERT(!T.liquid_residue, "Residue was not cleared after making a puddle")
	aquila_liquids_cleanup(T)

	var/datum/reagents/bucket = new(200)
	bucket.add_reagent(/datum/reagent/water, 80)
	T.spill_reagents(bucket)
	TEST_ASSERT(!QDELETED(T.liquids), "80 units of water did not make a puddle")
	aquila_liquids_cleanup(T)
	qdel(splash)
	qdel(bucket)

/// AQUILA - ciecze: woda w zimnie zamarza w całości, paliwo nie
/datum/unit_test/aquila_liquid_freezing

/datum/unit_test/aquila_liquid_freezing/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	T.add_liquid(/datum/reagent/water, 100, chem_temp = T0C - 40)
	TEST_ASSERT(!QDELETED(T.liquids), "add_liquid made no puddle")
	TEST_ASSERT(T.liquids.liquid_group.frozen, "Water at -40 C did not freeze")
	TEST_ASSERT(T.liquids.frozen, "Frozen group did not freeze its tile")
	var/datum/liquid_group/frozen_group = T.liquids.liquid_group
	TEST_ASSERT(frozen_group in SSliquids.ice_block_candidates, "Frozen group is not an ice block candidate")
	aquila_liquids_cleanup(T)
	TEST_ASSERT(!(frozen_group in SSliquids.ice_block_candidates), "Deleted frozen group stayed in SSliquids.ice_block_candidates (hard delete)")

	T.add_liquid(/datum/reagent/fuel, 100, chem_temp = T0C - 40)
	TEST_ASSERT(!T.liquids.liquid_group.frozen, "Welding fuel froze")
	aquila_liquids_cleanup(T)

/// AQUILA - ciecze: głęboka zamarznięta woda robi blok lodu, który więzi człowieka i po zniszczeniu oddaje ciecz
/datum/unit_test/aquila_liquid_ice_block

/datum/unit_test/aquila_liquid_ice_block/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, T)
	T.add_liquid(/datum/reagent/water, LIQUID_ICE_BLOCK_VOLUME + 50, chem_temp = T0C - 40)
	var/datum/liquid_group/group = T.liquids.liquid_group
	TEST_ASSERT(group.frozen, "Deep water at -40 C did not freeze")
	TEST_ASSERT(group.freeze_into_block(T), "Deep frozen water did not turn into an ice block")
	var/obj/structure/liquid_ice_block/block = locate() in T
	TEST_ASSERT(block, "No ice block on the turf")
	TEST_ASSERT(QDELETED(T.liquids), "Puddle stayed under the ice block")
	TEST_ASSERT(victim.loc == block, "Human standing on the tile was not trapped in the ice")
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_IMMOBILIZED), "Trapped human can still move")
	TEST_ASSERT(block.reagents.total_volume >= LIQUID_ICE_BLOCK_VOLUME, "Ice block does not hold the frozen water")

	qdel(block)
	TEST_ASSERT(victim.loc == T, "Breaking the ice did not release the human")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_IMMOBILIZED), "Released human is still immobilized")
	TEST_ASSERT(!QDELETED(T.liquids), "Breaking the ice did not give the water back")
	TEST_ASSERT(!T.liquids.liquid_group.frozen, "Water from a broken ice block froze right back (it would trap the human again)")

	// W próżni woda i tak zamarza po kilku sekundach i blok może powstać od nowa: uwolniony nie może trafić do niego znowu
	var/datum/liquid_group/thawed = T.liquids.liquid_group
	thawed.reagents.chem_temp = TCMB
	thawed.update_freezing()
	TEST_ASSERT(thawed.frozen, "Water left in vacuum did not freeze again")
	TEST_ASSERT(thawed.freeze_into_block(T), "Refrozen deep water did not make a new ice block")
	TEST_ASSERT(victim.loc == T, "The human who just broke free was trapped again by the refrozen block")
	aquila_liquids_cleanup(T)

/// AQUILA - pojemnik rzucony w przedmiot działa tylko na przedmiot, bez kałuży pod nim (jak chlust zlewką)
/datum/unit_test/aquila_liquid_splash_object

/datum/unit_test/aquila_liquid_splash_object/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/obj/structure/table/table = allocate(/obj/structure/table, T)
	var/obj/item/reagent_containers/glass/bucket/bucket = allocate(/obj/item/reagent_containers/glass/bucket, T)
	bucket.reagents.add_reagent(/datum/reagent/water, 70)
	bucket.SplashReagents(table, TRUE)
	TEST_ASSERT(QDELETED(T.liquids), "Splashing a table also spilled a puddle under it")
	TEST_ASSERT(!bucket.reagents.total_volume, "Splashed bucket kept its water")
	aquila_liquids_cleanup(T)

/// AQUILA - cenzura: usunięcie widza (np. moba z lobby) nie kasuje zastępczego wyglądu kupy dla innych
/datum/unit_test/aquila_bodily_censor_viewer_deleted

/datum/unit_test/aquila_bodily_censor_viewer_deleted/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	var/obj/effect/decal/cleanable/feces/poop = allocate(/obj/effect/decal/cleanable/feces, T)
	var/datum/atom_hud/alternate_appearance/basic/bodily_censor/censor = poop.alternate_appearances?["bodily_censor"]
	TEST_ASSERT(censor, "Feces have no censored appearance")
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human, T)
	censor.add_hud_to(viewer)
	qdel(viewer)
	TEST_ASSERT(!QDELETED(censor), "Deleting a viewer deleted the censored appearance for everyone")
	TEST_ASSERT(poop.alternate_appearances?["bodily_censor"] == censor, "Feces lost their censored appearance")

/// AQUILA - wyłom: po gwałtownej dekompresji odessany kafel ma temperaturę kosmosu
/datum/unit_test/aquila_decompression_chill

/datum/unit_test/aquila_decompression_chill/Run()
	var/turf/open/floor/T = run_loc_floor_bottom_left
	TEST_ASSERT(istype(T), "Test floor is not a floor")
	var/datum/gas_mixture/old_air = T.air.copy()
	T.air.clear()
	T.handle_decompression_floor_rip(0)
	var/chilled_temperature = T.air.return_temperature()
	T.air.copy_from(old_air)
	TEST_ASSERT(chilled_temperature <= TCMB + 0.1, "Decompressed tile kept [chilled_temperature] K instead of the temperature of space")

/// AQUILA - mocz: picie dokłada potrzebę, popuszczenie oddaje większą część, wypróżnienie na miejscu obie
/datum/unit_test/aquila_urination

/datum/unit_test/aquila_urination/Run()
	if(!CONFIG_GET(flag/shitting_enabled))
		return
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/mob/living/carbon/human/drinker = allocate(/mob/living/carbon/human, T)
	TEST_ASSERT(drinker.getorganslot(ORGAN_SLOT_BLADDER), "Humans spawn without a bladder")
	drinker.set_defecation(DEFECATION_NONE)
	drinker.adjust_hydration(300)
	TEST_ASSERT(drinker.urination > 0, "Drinking did not fill the bladder")
	TEST_ASSERT(drinker.defecation == drinker.urination, "Urine need is not a part of the defecation need")

	// Więcej moczu niż kału: popuszczenie oddaje tylko mocz
	drinker.adjust_defecation(20)
	var/feces_before = drinker.feces_need()
	drinker.accidental_release()
	TEST_ASSERT(drinker.urination == 0, "Accidental release kept the urine although there was more of it")
	TEST_ASSERT(abs(drinker.defecation - feces_before) < 0.1, "Accidental release of urine changed the feces part")
	TEST_ASSERT(!(locate(/obj/effect/decal/cleanable/feces) in T), "Urine release left feces")

	// Na miejscu: obie części naraz
	drinker.adjust_hydration(300)
	drinker.finish_defecate_here(FALSE)
	TEST_ASSERT(drinker.defecation == DEFECATION_NONE && drinker.urination == 0, "Defecating on the spot did not empty both parts")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/feces) in T, "Defecating on the spot left no feces")
	aquila_liquids_cleanup(T)

/// AQUILA - mokra podłoga ślizga tylko w sprincie (zwykły bieg już nie)
/datum/unit_test/aquila_wet_floor_sprint_only

/datum/unit_test/aquila_wet_floor_sprint_only/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, T)
	runner.m_intent = MOVE_INTENT_RUN
	TEST_ASSERT(!runner.is_sprinting(), "A fresh human counts as sprinting")
	TEST_ASSERT(!T.handle_slip(runner, 2 SECONDS, T, NO_SLIP_WHEN_WALKING), "Running without sprint slipped on a wet floor")
	TEST_ASSERT(runner.mobility_flags & MOBILITY_STAND, "Runner fell over on a wet floor without sprinting")

/// AQUILA - zatkana toaleta: spłukanie przelewa wodę i zawartość muszli na podłogę
/datum/unit_test/aquila_toilet_overflow

/datum/unit_test/aquila_toilet_overflow/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/obj/structure/toilet/toilet = allocate(/obj/structure/toilet, T)
	toilet.clogged = TRUE
	toilet.receive_waste(20, 1)
	TEST_ASSERT(toilet.flush(null, TRUE), "Clogged toilet with a full cistern did not flush")
	TEST_ASSERT(!QDELETED(T.liquids), "Clogged toilet did not overflow into a puddle")
	TEST_ASSERT(T.liquids.liquid_group.reagents.has_reagent(/datum/reagent/ammonia/urine), "Overflow did not carry the urine from the bowl")
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/feces) in T, "Overflow did not spill the feces from the bowl")
	TEST_ASSERT(!toilet.bowl_urine && !toilet.bowl_feces, "Bowl kept its contents after overflowing")
	TEST_ASSERT(toilet.clogged, "Overflowing unclogged the toilet by itself")
	aquila_liquids_cleanup(T)

#undef TEST_ASSERT
