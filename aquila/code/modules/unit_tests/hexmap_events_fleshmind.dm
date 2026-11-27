// AQUILA - test Umysłu z ciała (eventy mapy hex, etap E9): pula kafla, oko kapłana i rdzeń, granice rozrostu przewodów,
// przejmowanie maszyn, poziomy z Mięsonapędem, kapłan przewodów, Mechiwer i usychanie roju po zniszczeniu rdzenia
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// One scene in the shared test room: the swarm grows through real procs and dies when its core is destroyed.
/datum/unit_test/aquila_hex_fleshmind
	/// Czy test dopisał obszar pokoju testowego do obszarów statku
	var/added_area = FALSE
	/// Pole przeniesione do zamkniętego obszaru => obszar, do którego wraca
	var/list/moved_turfs = list()

/datum/unit_test/aquila_hex_fleshmind/proc/spot(dx, dy)
	return locate(run_loc_floor_bottom_left.x + dx, run_loc_floor_bottom_left.y + dy, run_loc_floor_bottom_left.z)

/// Przenosi pole do obszaru typu area_type (tworzy go, jeśli nie ma), Destroy() je oddaje
/datum/unit_test/aquila_hex_fleshmind/proc/move_to_area(turf/T, area_type)
	var/area/old_area = get_area(T)
	var/area/new_area = GLOB.areas_by_type[area_type] || new area_type
	moved_turfs[T] = old_area
	new_area.contents += T
	T.change_area(old_area, new_area)

/datum/unit_test/aquila_hex_fleshmind/Destroy()
	for(var/turf/T as anything in moved_turfs)
		var/area/old_area = moved_turfs[T]
		var/area/current = get_area(T)
		old_area.contents += T
		T.change_area(current, old_area)
	moved_turfs.Cut()
	if(added_area)
		GLOB.the_station_areas -= /area/testroom
	return ..()

/datum/unit_test/aquila_hex_fleshmind/Run()
	// Pula: tylko antagoniści anomalii grawitacyjnej, nie losuje się jako zwykły event okrętu
	hex_terrain(HEX_TERRAIN_EMPTY)
	var/datum/round_event_control/control = hex_event_control(/datum/round_event_control/aquila_hex_fleshmind)
	TEST_ASSERT(control, "No Fleshmind event control")
	for(var/id in GLOB.hex_terrains)
		var/datum/hex_terrain/terrain = GLOB.hex_terrains[id]
		var/in_antags = (control.type in terrain.antags)
		TEST_ASSERT(!(control.type in terrain.events), "Fleshmind is among the plain events of [id]")
		TEST_ASSERT(in_antags == (id == HEX_TERRAIN_GRAVITY), "Fleshmind is [in_antags ? "" : "not "]in the antags of [id]")
	TEST_ASSERT(!hex_random_event_allowed(control), "Fleshmind still rolls as a plain ship event")
	TEST_ASSERT(ROLE_WIRE_PRIEST in GLOB.antagonist_bannable_roles, "The wire priest has no ban key")

	if(!(/area/testroom in GLOB.the_station_areas))
		GLOB.the_station_areas += /area/testroom
		added_area = TRUE

	// Pola, na które przewody nie mogą wejść: zamknięty obszar (bryg), drzwi i mob
	var/turf/closed_turf = spot(4, 0)
	move_to_area(closed_turf, /area/security/brig)
	var/turf/door_turf = spot(4, 4)
	allocate(/obj/machinery/door/airlock, door_turf)
	var/turf/mob_turf = spot(0, 4)
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human, mob_turf)
	var/obj/machinery/space_heater/heater = allocate(/obj/machinery/space_heater, spot(1, 2))
	var/obj/machinery/computer/upload/ai/upload = allocate(/obj/machinery/computer/upload/ai, spot(3, 2))
	TEST_ASSERT(fleshmind_can_corrupt(heater), "A space heater cannot be corrupted")
	TEST_ASSERT(!fleshmind_can_corrupt(upload), "The AI upload console can be corrupted")

	// Oko kapłana: odmawia pola z mobem, a na wolnym polu wyrasta rdzeń i oko znika
	var/datum/round_event/ghost_role/aquila_hex_fleshmind/event = new(FALSE)
	var/turf/center = spot(2, 2)
	var/mob/camera/fleshmind_eye/eye = event.make_eye(center, null)
	TEST_ASSERT(istype(eye), "No wire priest eye")
	TEST_ASSERT(isnull(eye.place_core(mob_turf)) && !QDELETED(eye), "The eye placed the core on a mob")
	TEST_ASSERT(isnull(eye.place_core(closed_turf)) && !QDELETED(eye), "The eye placed the core in the brig")
	var/obj/structure/fleshmind/structure/core/core = eye.place_core(center)
	TEST_ASSERT(istype(core) && QDELETED(eye), "The eye did not place the core")
	var/datum/fleshmind_controller/controller = core.our_controller
	TEST_ASSERT(controller?.core == core, "The core has no controller")
	TEST_ASSERT(controller.announce_timer && !controller.announced, "The crew heard of the swarm before it survived its first minutes")

	// Rozrost: wypełnia pokój, ale nie zamknięty obszar, drzwi ani pole z mobem; przejmuje grzejnik, nie konsolę SI
	for(var/i in 1 to 40)
		controller.wireweed_process(progress_structure = FALSE)
	TEST_ASSERT(length(controller.controlled_wireweed) > 10, "The wireweed grew to only [length(controller.controlled_wireweed)] pieces")
	for(var/turf/forbidden as anything in list(closed_turf, door_turf, mob_turf))
		TEST_ASSERT(!(locate(/obj/structure/fleshmind/wireweed) in forbidden), "Wireweed grew onto [forbidden] ([get_area(forbidden)])")
	for(var/obj/structure/fleshmind/wireweed/wireweed as anything in controller.controlled_wireweed)
		TEST_ASSERT(get_area(wireweed) == get_area(center), "Wireweed grew out of the test room at [AREACOORD(wireweed)]")
	TEST_ASSERT(heater.GetComponent(/datum/component/machine_corruption), "The space heater on wireweed was not corrupted")
	TEST_ASSERT(!upload.GetComponent(/datum/component/machine_corruption), "The AI upload console was corrupted")
	TEST_ASSERT((locate(/datum/component/machine_corruption) in controller.controlled_machine_components), "The controller does not count the corrupted machine")
	heater.emp_act(EMP_HEAVY)
	TEST_ASSERT(!heater.GetComponent(/datum/component/machine_corruption), "An EMP did not burn the wireweed out of the space heater")

	// Twarde granice: limit przewodów i promień od rdzenia
	var/before_cap = length(controller.controlled_wireweed)
	controller.max_wireweed = before_cap
	var/obj/structure/fleshmind/wireweed/far_piece = locate() in spot(4, 2)
	if(far_piece)
		qdel(far_piece)
		before_cap--
	controller.max_wireweed = before_cap
	TEST_ASSERT(isnull(controller.wireweed_process(progress_structure = FALSE)), "The wireweed grew past its piece limit")
	TEST_ASSERT_EQUAL(length(controller.controlled_wireweed), before_cap, "The wireweed count changed at its limit")
	controller.max_radius = 1
	TEST_ASSERT(!controller.can_spread_to(spot(4, 2)), "The wireweed may grow farther than its radius")
	controller.max_radius = FLESHMIND_MAX_RADIUS
	TEST_ASSERT(controller.can_spread_to(spot(4, 2)), "A free turf of the room is not a spread target")

	// Poziomy: wytrzymałość rdzenia rośnie, na trzecim poziomie pojawia się Mięsonapęd (raz)
	var/old_integrity = core.max_integrity
	TEST_ASSERT(controller.level_up() && controller.level == 2, "The swarm did not reach level 2")
	TEST_ASSERT(controller.level_up() && controller.level == FLESHMIND_LEVEL_MAX, "The swarm did not reach its last level")
	TEST_ASSERT(!controller.level_up(), "The swarm went past its last level")
	TEST_ASSERT_EQUAL(core.max_integrity, old_integrity + 2 * FLESHMIND_LEVEL_UP_CORE_INTEGRITY, "The core did not grow tougher with the levels")
	var/mob/living/basic/fleshmind/tyrant/tyrant = locate() in controller.controlled_mobs
	TEST_ASSERT(istype(tyrant) && tyrant.our_controller == controller, "No Fleshdrive at the last level")
	TEST_ASSERT(tyrant.gold_core_spawnable == NO_SPAWN && !tyrant.playable, "The Fleshdrive is gold core spawnable or playable")

	// Kapłan przewodów: frakcja, akcje i antagonista
	var/datum/mind/priest_mind = new("fleshmind_unit_test")
	var/mob/living/carbon/human/priest = fleshmind_make_priest(spot(1, 1), priest_mind, controller)
	TEST_ASSERT(istype(priest) && fleshmind_is_ally(priest), "The wire priest is not of the swarm")
	var/datum/component/human_corruption/corruption = priest.GetComponent(/datum/component/human_corruption)
	TEST_ASSERT(corruption?.our_controller == controller, "The wire priest is not linked to the swarm")
	TEST_ASSERT_EQUAL(length(corruption.granted_actions), 5, "The wire priest has a wrong number of actions")
	TEST_ASSERT(priest.mind?.has_antag_datum(/datum/antagonist/fleshmind_wire_priest), "The wire priest has no antagonist datum")
	TEST_ASSERT(priest.fleshmind_controller() == controller, "The wire priest actions see no controller")

	// Mechiwer: zdrowej ofiary nie połyka, słabą tak; martwe ciało przerabia na moba, który je nosi i oddaje po śmierci
	var/mob/living/basic/fleshmind/mechiver/mechiver = controller.spawn_mob(spot(0, 0), /mob/living/basic/fleshmind/mechiver)
	TEST_ASSERT(istype(mechiver) && mechiver.gold_core_spawnable == NO_SPAWN, "No Mechiver")
	TEST_ASSERT(!mechiver.try_consume(bystander), "The Mechiver swallowed a healthy target")
	for(var/i in 1 to 20) // ludzie biorą mniej obrażeń niż podano, więc ranimy po trochu aż do progu połknięcia
		if(bystander.health < bystander.maxHealth * FLESHMIND_MECHIVER_CONSUME_THRESHOLD - 5)
			break
		bystander.adjustBruteLoss(10)
	TEST_ASSERT(mechiver.try_consume(bystander) && bystander.loc == mechiver, "The Mechiver did not swallow a weak target (health [bystander.health]/[bystander.maxHealth], stat [bystander.stat], loc [bystander.loc], buckled [bystander.buckled], anchored [bystander.anchored], mechiver stat [mechiver.stat])")
	TEST_ASSERT(!mechiver.try_consume(priest), "The Mechiver swallowed a member of the swarm")
	bystander.death()
	mechiver.release_mob()
	var/mob/living/basic/fleshmind/carrier = bystander.loc
	TEST_ASSERT(istype(carrier) && carrier != mechiver && carrier.contained_mob == bystander, "The Mechiver did not turn the corpse into a swarm mob")
	TEST_ASSERT(!carrier.key, "A swarm mob got a player")
	carrier.death()
	TEST_ASSERT(isturf(bystander.loc), "The corpse did not drop out of the dead swarm mob")

	// Zniszczenie rdzenia: struktury i ściany znikają, kapłan traci łącze, moby się przeciążają, przewody usychają
	TEST_ASSERT(length(controller.controlled_structures), "The core sprouted without its first structures")
	var/priest_brute = priest.getBruteLoss()
	qdel(core)
	TEST_ASSERT(controller.decaying && isnull(controller.core), "The swarm did not notice its core died")
	TEST_ASSERT(isnull(controller.announce_timer) && !controller.announced, "The swarm still announces itself after its core died")
	TEST_ASSERT(!length(controller.controlled_structures) && !length(controller.controlled_walls), "Structures outlived the core")
	TEST_ASSERT(!priest.GetComponent(/datum/component/human_corruption) && !fleshmind_is_ally(priest), "The wire priest kept the swarm link")
	TEST_ASSERT(!priest.mind?.has_antag_datum(/datum/antagonist/fleshmind_wire_priest), "The wire priest stayed an antagonist")
	TEST_ASSERT(priest.getBruteLoss() > priest_brute, "The dying core did not hurt the wire priest")
	TEST_ASSERT(isnull(controller.wireweed_process()), "The wireweed grew after the core died")
	for(var/mob/living/basic/fleshmind/swarm_mob as anything in controller.controlled_mobs.Copy())
		TEST_ASSERT(swarm_mob.death_timer, "[swarm_mob] does not break apart after the core died")
		swarm_mob.break_apart()
	controller.handle_slow_decay(1000)
	TEST_ASSERT(QDELETED(controller), "The swarm controller outlived its wireweed")
	qdel(priest)
	qdel(event)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
