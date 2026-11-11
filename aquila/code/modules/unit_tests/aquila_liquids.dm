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

	// W próżni woda i tak zamarza po kilku sekundach i blok może powstać od nowa: uwolniony nie może trafić do niego znowu.
	// Pełna ścieżka: wymiana ciepła z odessanym kafelkiem, przebieg bloków SSliquids, zejście z kafla.
	var/datum/liquid_group/thawed = T.liquids.liquid_group
	var/datum/gas_mixture/old_air = T.air.copy()
	T.air.clear()
	T.air.set_temperature(TCMB)
	for(var/i in 1 to 20)
		thawed.share_air_temperature()
		if(thawed.frozen)
			break
	T.air.copy_from(old_air)
	TEST_ASSERT(thawed.frozen, "Water left in vacuum did not freeze again through heat exchange")
	TEST_ASSERT(thawed in SSliquids.ice_block_candidates, "Refrozen deep water is not an ice block candidate")
	SSliquids.process_ice_blocks()
	TEST_ASSERT(locate(/obj/structure/liquid_ice_block) in T, "SSliquids did not turn the refrozen deep water into a new ice block")
	TEST_ASSERT(victim.loc == T, "The human who just broke free was trapped again by the refrozen block")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_IMMOBILIZED), "The human next to the new block cannot move")
	var/turf/away = get_step(T, EAST)
	TEST_ASSERT(victim.Move(away) && victim.loc == away, "The human could not step off the tile with the new ice block")
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
	TEST_ASSERT(censor.theImage?.name == "brud", "Censored feces keep their real name in the right-click menu")

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

/// AQUILA - kamera zgłasza wypróżnienie poza ubikacją (jedno zgłoszenie za kał z moczem) i samo oddawanie moczu
/datum/unit_test/aquila_public_defecation_camera
	var/datum/data/record/record

/datum/unit_test/aquila_public_defecation_camera/Destroy()
	if(record)
		GLOB.data_core.security -= record
		QDEL_NULL(record)
	return ..()

/datum/unit_test/aquila_public_defecation_camera/Run()
	if(!CONFIG_GET(flag/shitting_enabled))
		return
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/mob/living/carbon/human/pooper = allocate(/mob/living/carbon/human, T)
	pooper.real_name = "Testowy Załatwiacz"
	pooper.name = pooper.real_name
	record = new
	record.fields["name"] = pooper.name
	record.fields["id"] = "aquila_test_[REF(pooper)]"
	record.fields["criminal"] = "None"
	record.fields["crim"] = list()
	GLOB.data_core.security += record

	pooper.set_defecation(DEFECATION_SHIT_YOURSELF)
	pooper.urination = 40
	pooper.finish_defecate_here(FALSE)
	TEST_ASSERT(!length(record.fields["crim"]), "Defecating with no camera around was reported")

	allocate(/obj/machinery/camera, get_step(T, NORTH))
	pooper.set_defecation(DEFECATION_SHIT_YOURSELF)
	pooper.urination = 40
	pooper.finish_defecate_here(FALSE)
	var/list/crimes = record.fields["crim"]
	TEST_ASSERT(length(crimes) == 1, "Defecating with urine in view of a camera made [length(crimes)] reports instead of one")
	var/datum/data/crime/crime = crimes[1]
	TEST_ASSERT(crime.crimeName == "Publiczne wypróżnianie się", "Camera reported [crime.crimeName] instead of public defecation")
	TEST_ASSERT(record.fields["criminal"] == "Arrest", "Public defecation did not set the Arrest status")

	pooper.set_defecation(40)
	pooper.urination = 40
	pooper.urinate_voluntarily()
	TEST_ASSERT(length(crimes) == 2, "Urinating in view of a camera was not reported")

	// Mimowolne popuszczenie nie jest zgłaszane
	pooper.set_defecation(DEFECATION_ACTUALLY_SHIT_YOURSELF + 10)
	pooper.urination = 0
	pooper.accidental_release()
	TEST_ASSERT(length(crimes) == 2, "An accidental release in view of a camera was reported")

	// Status więźnia nie jest nadpisywany, ale wpis dochodzi
	record.fields["criminal"] = "Incarcerated"
	pooper.set_defecation(DEFECATION_SHIT_YOURSELF)
	pooper.urination = 0
	pooper.finish_defecate_here(FALSE)
	TEST_ASSERT(length(crimes) == 3, "Defecating on the spot as a prisoner was not added to the record")
	TEST_ASSERT(record.fields["criminal"] == "Incarcerated", "A camera report overwrote the Incarcerated status with [record.fields["criminal"]]")

	// Nieprzytomny nie jest zgłaszany
	pooper.stat = UNCONSCIOUS
	pooper.set_defecation(DEFECATION_SHIT_YOURSELF)
	pooper.finish_defecate_here(FALSE)
	pooper.stat = CONSCIOUS
	TEST_ASSERT(length(crimes) == 3, "An unconscious mob was reported by the camera")
	aquila_liquids_cleanup(T)

/// AQUILA - mokra podłoga: chodem bez poślizgu, w biegu poślizg, w sprincie poślizg rzuca jeszcze kafel dalej
/datum/unit_test/aquila_wet_floor_slip
	/// Pokój testowy nie ma generatora grawitacji, a bez grawitacji handle_slip nic nie robi
	var/area/gravity_area
	var/old_gravity

/datum/unit_test/aquila_wet_floor_slip/Destroy()
	if(gravity_area)
		gravity_area.has_gravity = old_gravity
		gravity_area = null
	return ..()

/datum/unit_test/aquila_wet_floor_slip/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	gravity_area = get_area(T)
	old_gravity = gravity_area.has_gravity
	gravity_area.has_gravity = STANDARD_GRAVITY
	TEST_ASSERT(T.has_gravity(), "Test floor still has no gravity")
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, T)
	walker.m_intent = MOVE_INTENT_WALK
	TEST_ASSERT(!T.handle_slip(walker, 2 SECONDS, T, NO_SLIP_WHEN_WALKING), "Walking slipped on a wet floor")

	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, T)
	runner.m_intent = MOVE_INTENT_RUN
	TEST_ASSERT(!runner.is_sprinting(), "A fresh human counts as sprinting")
	TEST_ASSERT(T.handle_slip(runner, 2 SECONDS, T, NO_SLIP_WHEN_WALKING), "Running did not slip on a wet floor")
	TEST_ASSERT(!(runner.mobility_flags & MOBILITY_STAND), "Runner stayed standing after slipping")
	TEST_ASSERT(!runner.GetComponent(/datum/component/force_move), "Running without sprint slid forward")

	var/mob/living/carbon/human/sprinter = allocate(/mob/living/carbon/human, T)
	sprinter.m_intent = MOVE_INTENT_RUN
	var/datum/component/carbon_sprint/sprint = sprinter.GetComponent(/datum/component/carbon_sprint)
	TEST_ASSERT(sprint, "Human has no sprint component")
	sprint.sprinting = TRUE
	sprint.last_sprint_step = world.time // prawdziwy krok sprintu przed chwilą (sama flaga nie wystarcza)
	sprinter.setDir(EAST)
	TEST_ASSERT(T.handle_slip(sprinter, 2 SECONDS, T, NO_SLIP_WHEN_WALKING), "Sprinting did not slip on a wet floor")
	TEST_ASSERT(sprinter.GetComponent(/datum/component/force_move), "Slipping in a sprint did not throw the sprinter forward")

/// AQUILA - palna kałuża zapala się od kliknięcia gorącym przedmiotem i od wejścia z ogniem w ręce, zimnym nie
/datum/unit_test/aquila_liquid_ignition

/datum/unit_test/aquila_liquid_ignition/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	var/turf/open/T2 = get_step(T, EAST)
	aquila_liquids_cleanup(T)
	aquila_liquids_cleanup(T2)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, get_step(T, NORTH))
	var/obj/item/lighter/lighter = allocate(/obj/item/lighter, user)
	user.put_in_hands(lighter)

	T.add_liquid(/datum/reagent/fuel, 100)
	TEST_ASSERT(!QDELETED(T.liquids), "100 units of fuel did not make a puddle")
	T.attackby(lighter, user)
	TEST_ASSERT(!T.liquids.fire_state, "An unlit lighter set the puddle on fire")
	lighter.set_lit(TRUE)
	T.attackby(lighter, user)
	TEST_ASSERT(T.liquids.fire_state, "Clicking a fuel puddle with a lit lighter did not ignite it")
	aquila_liquids_cleanup(T)

	T2.add_liquid(/datum/reagent/fuel, 100)
	user.forceMove(T2)
	TEST_ASSERT(T2.liquids.fire_state, "Walking into a fuel puddle with a lit lighter in hand did not ignite it")
	aquila_liquids_cleanup(T2)
	user.ExtinguishMob()

/// AQUILA - krew z krwawienia: mniej niż 50 j. to same plamy, więcej sumuje się w kałużę krwi
/datum/unit_test/aquila_liquid_bleeding_pool

/datum/unit_test/aquila_liquid_bleeding_pool/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, T)
	patient.blood_volume = BLOOD_VOLUME_NORMAL
	patient.bleed(20)
	TEST_ASSERT(QDELETED(T.liquids), "A single small bleed made a puddle")
	for(var/i in 1 to 20)
		if(!QDELETED(T.liquids))
			break
		patient.bleed(20)
	TEST_ASSERT(!QDELETED(T.liquids), "Bleeding 400 units onto one tile did not make a puddle")
	TEST_ASSERT(T.liquids.liquid_group.reagents.has_reagent(/datum/reagent/blood), "Puddle from bleeding has no blood")
	// Kałuża krwi nie rozchodzi się od razu na sąsiednie kafelki (zgłoszenie: krzyż z 5 kafelków pod ciałem)
	var/datum/liquid_group/blood_group = T.liquids.liquid_group
	blood_group.update_volume_cache()
	blood_group.check_edges(T)
	blood_group.process_cached_edges()
	TEST_ASSERT(length(blood_group.members) == 1, "A [round(blood_group.total_reagent_volume)] unit blood puddle spread onto [length(blood_group.members)] tiles")
	aquila_liquids_cleanup(T)
	// Woda nie jest gęsta, więc rozlewa się jak dotąd
	T.add_liquid(/datum/reagent/water, 60)
	TEST_ASSERT(!T.liquids.liquid_group.is_viscous(), "Water counts as a viscous liquid")
	aquila_liquids_cleanup(T)
	// Do kałuży trafia tylko część krwi: wykrwawienie się jednego ciała to kilka kafelków, nie kilkadziesiąt
	patient.blood_volume = BLOOD_VOLUME_NORMAL
	patient.unpooled_blood = 0
	for(var/i in 1 to 500)
		if(patient.blood_volume < 20)
			break
		patient.bleed(BLOOD_VOLUME_NORMAL)
	TEST_ASSERT(patient.blood_volume < 20, "Test setup: the body did not bleed out ([round(patient.blood_volume)] units left)")
	TEST_ASSERT(!QDELETED(T.liquids?.liquid_group), "A body that bled out left no puddle")
	TEST_ASSERT(T.liquids.liquid_group.total_reagent_volume <= BLOOD_VOLUME_NORMAL * 0.3, "A body that bled out pooled [round(T.liquids.liquid_group.total_reagent_volume)] units of blood")
	aquila_liquids_cleanup(T)

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

/// AQUILA - zraszacze: alarm pożarowy włączony ręcznie wylewa wodę z oczyszczaczy w obszarze, emag i EMP bardzo dużo
/datum/unit_test/aquila_firealarm_sprinkler
	var/obj/machinery/firealarm/fire_alarm

/datum/unit_test/aquila_firealarm_sprinkler/Destroy()
	var/area/alarm_area = get_area(fire_alarm)
	alarm_area?.firereset()
	fire_alarm = null
	return ..()

/datum/unit_test/aquila_firealarm_sprinkler/Run()
	var/turf/open/T = run_loc_floor_bottom_left
	aquila_liquids_cleanup(T)
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = allocate(/obj/machinery/atmospherics/components/unary/vent_scrubber, T)
	scrubber.on = TRUE
	scrubber.set_machine_stat(scrubber.machine_stat & ~NOPOWER) // pokój testowy nie ma APC
	var/mob/living/carbon/human/puller = allocate(/mob/living/carbon/human, get_step(T, EAST))
	fire_alarm = allocate(/obj/machinery/firealarm, get_step(T, EAST))
	fire_alarm.set_is_operational(TRUE)

	fire_alarm.alarm()
	TEST_ASSERT(QDELETED(T.liquids), "A fire alarm without a player (fire sensor) spilled water")

	fire_alarm.last_alarm = -INFINITY
	fire_alarm.alarm(puller)
	TEST_ASSERT(!QDELETED(T.liquids), "A fire alarm pulled by a player spilled no water from the scrubber")
	var/normal_volume = T.liquids.liquid_group.reagents.total_volume
	var/floor_tiles = 0
	for(var/turf/open/floor/floor_tile in get_area(T))
		floor_tiles++
	TEST_ASSERT(normal_volume >= min(floor_tiles * 15, 5000) - 1, "A normal sprinkler spilled [normal_volume] units, not enough to cover the [floor_tiles] floor tiles of the room")
	TEST_ASSERT(T.liquids.liquid_group.reagents.has_reagent(/datum/reagent/water), "The sprinkler puddle is not water")
	TEST_ASSERT(T.liquids.liquid_group.always_evaporates, "A normal sprinkler puddle does not evaporate quickly")

	// Zalanie dolane do kałuży ze zwykłego zraszacza zabiera jej szybkie parowanie
	fire_alarm.last_sprinkle = -INFINITY
	fire_alarm.release_sprinkler_water(TRUE)
	TEST_ASSERT(!T.liquids.liquid_group.always_evaporates && T.liquids.liquid_group.evaporation_multiplier == 1, "A flood poured into a sprinkler puddle kept its quick evaporation")
	aquila_liquids_cleanup(T)

	fire_alarm.obj_flags |= EMAGGED
	fire_alarm.last_alarm = -INFINITY
	fire_alarm.last_sprinkle = -INFINITY
	fire_alarm.alarm(puller)
	TEST_ASSERT(!QDELETED(T.liquids) && T.liquids.liquid_group.reagents.total_volume >= 300, "An emagged fire alarm pulled by a player did not flood the scrubber")
	aquila_liquids_cleanup(T)

	fire_alarm.obj_flags &= ~EMAGGED
	fire_alarm.last_sprinkle = -INFINITY
	fire_alarm.emp_act(EMP_LIGHT)
	TEST_ASSERT(!QDELETED(T.liquids) && T.liquids.liquid_group.reagents.total_volume >= 300, "An EMP on the fire alarm did not flood the scrubber")
	aquila_liquids_cleanup(T)

	// Zepsuty (niezmontowany) alarm i wyłączony oczyszczacz nie leją wody
	fire_alarm.last_sprinkle = -INFINITY
	fire_alarm.buildstage = 0
	fire_alarm.emp_act(EMP_LIGHT)
	TEST_ASSERT(QDELETED(T.liquids), "An EMP on an unbuilt fire alarm flooded the room")
	fire_alarm.buildstage = 2
	scrubber.on = FALSE
	fire_alarm.last_sprinkle = -INFINITY
	fire_alarm.emp_act(EMP_LIGHT)
	TEST_ASSERT(QDELETED(T.liquids), "A switched off scrubber spilled water")
	aquila_liquids_cleanup(T)

#undef TEST_ASSERT
