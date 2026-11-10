// AQUILA - testy regresji poprawek z review aq33/AquilaStation#598 (raport/ciecze_03_review_max.md w głównym folderze)
// Makra TEST_ASSERT z core są #undef na końcu _unit_tests.dm, więc test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Trzy kafle w linii z jedną grupą cieczy, środkowy zwracany jako drugi
/proc/aquila_liquids_make_line(turf/open/start, amount_per_tile = 100)
	var/turf/open/middle = get_step(start, EAST)
	var/turf/open/far = get_step(middle, EAST)
	start.add_liquid(/datum/reagent/water, amount_per_tile * 3)
	var/datum/liquid_group/group = start.liquids.liquid_group
	group.add_to_group(middle)
	group.add_to_group(far)
	group.update_volume_cache()
	return list(start, middle, far)

/// Drzwi zamknięte w środku zalanego korytarza dzielą kałużę na dwie, a sąsiedzi dostają krawędź w stronę drzwi
/datum/unit_test/aquila_liquid_door_split

/datum/unit_test/aquila_liquid_door_split/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	var/list/line = aquila_liquids_make_line(T)
	var/turf/open/middle = line[2]
	var/turf/open/far = line[3]
	for(var/turf/open/tile as anything in line)
		TEST_ASSERT(!QDELETED(tile.liquids), "Setup: a tile of the line has no liquid")
	TEST_ASSERT(T.liquids.liquid_group == far.liquids.liquid_group, "Setup: the line is not one group")

	middle.liquids_push_out_by_door()
	TEST_ASSERT(QDELETED(middle.liquids), "The door tile kept its liquid")
	TEST_ASSERT(!QDELETED(T.liquids) && !QDELETED(far.liquids), "Pushing out by a door removed the neighbours")
	TEST_ASSERT(T.liquids.liquid_group != far.liquids.liquid_group, "Closing a door between two puddles left them as one group")
	var/list/edges = T.liquids.liquid_group.cached_edge_turfs[T]
	TEST_ASSERT(edges && (EAST in edges), "The neighbour has no edge towards the door tile, so liquid would never flow back")
	for(var/turf/open/tile as anything in line)
		aquila_liquids_cleanup(tile)

/// Wiadro wody od 50 j. robi kałużę i nadal reaguje z podłogą (gasi płomień), a uran nie mnoży się przez pamięć rozlań
/datum/unit_test/aquila_liquid_spill_reacts_once

/datum/unit_test/aquila_liquid_spill_reacts_once/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/obj/effect/hotspot/flame = new(T)
	var/datum/reagents/bucket = new(200)
	bucket.add_reagent(/datum/reagent/water, 70)
	if(!QDELETED(flame))
		T.spill_reagents(bucket)
		TEST_ASSERT(QDELETED(flame), "A 70 u water spill did not put out the flame on the floor")
	else
		T.spill_reagents(bucket)
	TEST_ASSERT(!QDELETED(T.liquids), "A 70 u water spill made no puddle")
	aquila_liquids_cleanup(T)

	var/datum/reagents/uranium = new(100)
	uranium.add_reagent(/datum/reagent/uranium, 30)
	T.spill_reagents(uranium)
	T.spill_reagents(uranium)
	TEST_ASSERT(QDELETED(T.liquids), "Uranium (it turns into green glow) made a puddle on top of its glow")
	TEST_ASSERT(!T.liquid_residue?.total_volume, "Uranium was remembered as a spill on top of its glow")
	var/obj/effect/decal/cleanable/greenglow/glow = locate() in T
	TEST_ASSERT(glow, "Spilled uranium made no green glow")
	TEST_ASSERT(glow.reagents.get_reagent_amount(/datum/reagent/uranium) <= 60.5, "Green glow holds more uranium than was spilled")
	aquila_liquids_cleanup(T)
	qdel(bucket)
	qdel(uranium)

/// Termit w kałuży nie reaguje z podłogą co cykl (narastał na każdym kaflu ponad próg stopienia)
/datum/unit_test/aquila_liquid_thermite_once

/datum/unit_test/aquila_liquid_thermite_once/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/datum/reagents/thermite = new(100)
	thermite.add_reagent(/datum/reagent/thermite, 60)
	T.spill_reagents(thermite)
	var/datum/component/thermite/burning = T.GetComponent(/datum/component/thermite)
	TEST_ASSERT(burning, "A thermite spill did not coat the floor")
	var/coated = burning.amount
	TEST_ASSERT(!QDELETED(T.liquids), "60 u of thermite made no puddle")
	T.liquids.liquid_group.process_member(T)
	T.liquids.liquid_group.process_member(T)
	TEST_ASSERT(burning.amount == coated, "A thermite puddle kept adding thermite to the floor ([coated] -> [burning.amount])")
	qdel(burning)
	aquila_liquids_cleanup(T)
	qdel(thermite)

/// Granat albo rozbity zbiornik zostawia najwyżej LIQUID_SPLASH_PUDDLE_MAX cieczy, a nie całą zawartość
/datum/unit_test/aquila_liquid_chem_splash_cap

/datum/unit_test/aquila_liquid_chem_splash_cap/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/datum/reagents/tank = new(5000)
	tank.add_reagent(/datum/reagent/water, 1000)
	chem_splash(T, 1, list(tank), adminlog = FALSE)
	TEST_ASSERT(!QDELETED(T.liquids), "A 1000 u splash left no puddle")
	var/volume = T.liquids.liquid_group.reagents.total_volume
	TEST_ASSERT(volume <= LIQUID_SPLASH_PUDDLE_MAX + 1, "A 1000 u splash left [volume] u of liquid instead of at most [LIQUID_SPLASH_PUDDLE_MAX]")
	aquila_liquids_cleanup(T)
	qdel(tank)

/// Pompa podłogowa przy głębokiej cieczy zabiera tylko swój bufor, a nie całą kałużę
/datum/unit_test/aquila_liquid_floor_pump_deep

/datum/unit_test/aquila_liquid_floor_pump_deep/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	var/list/line = aquila_liquids_make_line(T, 800)
	var/datum/liquid_group/group = T.liquids.liquid_group
	var/before = group.reagents.total_volume
	var/obj/machinery/plumbing/floor_pump/input/pump = allocate(/obj/machinery/plumbing/floor_pump/input, T)
	pump.processes = pump.processes_required
	pump.pump_turf(T, 1, 1)
	TEST_ASSERT(!QDELETED(group), "A floor pump deleted a whole deep puddle")
	var/pumped = pump.reagents.total_volume
	TEST_ASSERT(pumped > 0, "The floor pump pumped nothing")
	TEST_ASSERT(abs(group.reagents.total_volume + pumped - before) < 1, "Liquid vanished while pumping ([before] -> [group.reagents.total_volume] + [pumped])")
	for(var/turf/open/tile as anything in line)
		aquila_liquids_cleanup(tile)

/// Szczelny skafander z hełmem chroni przed cieczą, sam kombinezon nie
/datum/unit_test/aquila_liquid_protection

/datum/unit_test/aquila_liquid_protection/Run()
	var/mob/living/carbon/human/wader = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!wader.is_liquid_protected(), "A human without a suit is protected from liquids")
	wader.equip_to_slot_or_del(new /obj/item/clothing/suit/space(wader), ITEM_SLOT_OCLOTHING)
	TEST_ASSERT(!wader.is_liquid_protected(), "A space suit without a helmet protects from liquids")
	wader.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space(wader), ITEM_SLOT_HEAD)
	TEST_ASSERT(wader.is_liquid_protected(), "A space suit with a helmet does not protect from liquids")

/// Krew z krwawienia zachowuje DNA, a duża porcja nie ginie w pamięci rozlań (pojemność 100 j.)
/datum/unit_test/aquila_liquid_pool_keeps_data

/datum/unit_test/aquila_liquid_pool_keeps_data/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	T.pool_liquid(/datum/reagent/blood, 130, T20C, list("blood_DNA" = "AQUILATEST", "blood_type" = "O-"))
	TEST_ASSERT(!QDELETED(T.liquids), "130 u of blood made no puddle")
	var/datum/reagent/blood/pooled = T.liquids.liquid_group.reagents.has_reagent(/datum/reagent/blood)
	TEST_ASSERT(pooled, "The puddle has no blood")
	TEST_ASSERT(pooled.volume >= 129, "Blood was lost on the way to the puddle ([pooled.volume] of 130 u)")
	TEST_ASSERT(pooled.data?["blood_DNA"] == "AQUILATEST", "Blood in the puddle lost its DNA")
	aquila_liquids_cleanup(T)

/// Zamarznięta płytka kałuża, dolana ponad próg bloku, wraca do kandydatów na bloki lodu
/datum/unit_test/aquila_liquid_ice_candidate_refill

/datum/unit_test/aquila_liquid_ice_candidate_refill/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	T.add_liquid(/datum/reagent/water, 60, chem_temp = T0C - 30)
	var/datum/liquid_group/group = T.liquids.liquid_group
	group.update_freezing()
	TEST_ASSERT(group.frozen, "Setup: cold water did not freeze")
	SSliquids.ice_block_candidates -= group
	group.add_reagent(T.liquids, /datum/reagent/water, LIQUID_ICE_BLOCK_VOLUME, T0C - 30)
	TEST_ASSERT(group.frozen, "Setup: topped up ice thawed")
	TEST_ASSERT(group in SSliquids.ice_block_candidates, "Deep ice topped up after freezing never becomes an ice block candidate")
	SSliquids.ice_block_candidates -= group
	aquila_liquids_cleanup(T)

/// Rzut o kafel w sprincie nie wjeżdża w zablokowany kafel (ściana, maszyna, supermateria)
/datum/unit_test/aquila_sprint_slide_blocked
	var/area/gravity_area
	var/old_gravity

/datum/unit_test/aquila_sprint_slide_blocked/Destroy()
	if(gravity_area)
		gravity_area.has_gravity = old_gravity
		gravity_area = null
	return ..()

/datum/unit_test/aquila_sprint_slide_blocked/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	gravity_area = get_area(T)
	old_gravity = gravity_area.has_gravity
	gravity_area.has_gravity = STANDARD_GRAVITY
	allocate(/obj/structure/grille, get_step(T, EAST))
	var/mob/living/carbon/human/sprinter = allocate(/mob/living/carbon/human, T)
	sprinter.m_intent = MOVE_INTENT_RUN
	var/datum/component/carbon_sprint/sprint = sprinter.GetComponent(/datum/component/carbon_sprint)
	sprint.sprinting = TRUE
	sprint.last_sprint_step = world.time
	sprinter.setDir(EAST)
	TEST_ASSERT(T.handle_slip(sprinter, 2 SECONDS, T, NO_SLIP_WHEN_WALKING), "Sprinting did not slip")
	TEST_ASSERT(!sprinter.GetComponent(/datum/component/force_move), "A sprint slip threw the mob into a blocked tile")

	var/mob/living/carbon/human/stander = allocate(/mob/living/carbon/human, T)
	stander.m_intent = MOVE_INTENT_RUN
	var/datum/component/carbon_sprint/held = stander.GetComponent(/datum/component/carbon_sprint)
	held.sprinting = TRUE // klawisz trzymany, ale ostatni krok sprintu dawno
	held.last_sprint_step = world.time - 10 SECONDS
	TEST_ASSERT(!stander.is_sprinting(), "Holding the sprint key while standing counts as sprinting")

/// Kałuża zmienia podłogę razem z kafelkiem, a pamięć rozlań przepada razem ze starym turfem
/datum/unit_test/aquila_liquid_change_turf

/datum/unit_test/aquila_liquid_change_turf/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/old_type = T.type
	T.add_liquid(/datum/reagent/water, 100)
	var/turf/open/plating = T.ChangeTurf(/turf/open/floor/plating)
	TEST_ASSERT(!QDELETED(plating.liquids), "The puddle vanished when the floor turned into plating")
	aquila_liquids_cleanup(plating)
	var/datum/reagents/splash = new(100)
	splash.add_reagent(/datum/reagent/water, 20)
	plating.spill_reagents(splash)
	var/datum/reagents/residue = plating.liquid_residue
	TEST_ASSERT(residue, "Setup: a small spill was not remembered")
	var/turf/open/back = plating.ChangeTurf(old_type)
	TEST_ASSERT(QDELETED(residue) && !back.liquid_residue, "The remembered spill survived the turf change")
	aquila_liquids_cleanup(back)
	qdel(splash)

/// Płomień, który pali zawartość kafla (wybuch), zapala palną kałużę; hipernoblium nie
/datum/unit_test/aquila_liquid_fire_act_ignites

/datum/unit_test/aquila_liquid_fire_act_ignites/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	T.add_liquid(/datum/reagent/fuel, 100)
	T.liquids.fire_act(1000, 100)
	TEST_ASSERT(T.liquids.fire_state, "fire_act from a flame on the tile did not ignite a fuel puddle")
	aquila_liquids_cleanup(T)

/// Cenzura: Login po raz drugi (reconnect, powrót z ducha) nie zostawia obrazków u kogoś, kto cenzury nie ma
/datum/unit_test/aquila_bodily_censor_relogin

/datum/unit_test/aquila_bodily_censor_relogin/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	var/obj/effect/decal/cleanable/feces/poop = allocate(/obj/effect/decal/cleanable/feces, T)
	var/datum/atom_hud/alternate_appearance/basic/bodily_censor/censor = poop.alternate_appearances?["bodily_censor"]
	TEST_ASSERT(censor, "Feces have no censored appearance")
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human, T)
	censor.add_hud_to(viewer)
	censor.add_hud_to(viewer) // drugie wejście do gry z cenzurą
	censor.onNewMob(viewer) // Login bez cenzury (mob bez klienta nie cenzuruje)
	TEST_ASSERT(!censor.hudusers[viewer], "A viewer without the censor kept the censored images after logging in again")

/// Przelana zatkana toaleta wylewa to, co było w spłuczce, a nie świeżą wodę
/datum/unit_test/aquila_toilet_overflow_cistern

/datum/unit_test/aquila_toilet_overflow_cistern/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/obj/structure/toilet/toilet = allocate(/obj/structure/toilet, T)
	toilet.reagents.clear_reagents()
	toilet.reagents.add_reagent(/datum/reagent/lube, 100)
	toilet.clogged = TRUE
	TEST_ASSERT(toilet.flush(null, TRUE), "Clogged toilet with a full cistern did not flush")
	TEST_ASSERT(!QDELETED(T.liquids), "Clogged toilet did not overflow into a puddle")
	TEST_ASSERT(T.liquids.liquid_group.reagents.has_reagent(/datum/reagent/lube), "Overflow did not carry what was in the cistern")
	TEST_ASSERT(!T.liquids.liquid_group.reagents.has_reagent(/datum/reagent/water), "Overflow made water out of nothing")
	aquila_liquids_cleanup(T)

#undef TEST_ASSERT
