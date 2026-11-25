// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - runda 6591: span_* z aquila/code/__DEFINES/span.dm nie miały nawiasów wokół argumentu,
/// więc span_deadsay(warunek ? "a" : "b") liczyło "<span ...>" + warunek (oględziny martwego kota i kozy)
/datum/unit_test/aquila_span_macro_ternary

/datum/unit_test/aquila_span_macro_ternary/Run()
	var/naive = FALSE
	TEST_ASSERT_EQUAL(span_deadsay(naive ? "spi" : "martwy"), "<span class='deadsay'>martwy</span>", "span_deadsay() does not wrap a ternary argument")

/// AQUILA - runda 6591: wybiórcze oczyszczanie krwi w nosicielu bez reagentów sypało runtime'em co tick (306 razy)
/datum/unit_test/aquila_nanite_purging_no_reagents

/datum/unit_test/aquila_nanite_purging_no_reagents/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	QDEL_NULL(host.reagents)
	var/datum/nanite_program/purging_advanced/program = new
	program.host_mob = host
	TEST_ASSERT(!program.check_conditions(), "The program reported work on a host without toxins or reagents")
	program.active_effect()
	program.host_mob = null
	qdel(program)

/// AQUILA - runda 6591: cień światła jechał z promem, światło chowało go w trakcie ruchu i afterShuttleMove() czytało null.z
/datum/unit_test/aquila_light_shadow_shuttle_move

/datum/unit_test/aquila_light_shadow_shuttle_move/Run()
	var/turf/old_turf = run_loc_floor_bottom_left
	var/turf/new_turf = locate(old_turf.x + 1, old_turf.y, old_turf.z)
	var/obj/effect/abstract/aq_light_shadow/shadow = allocate(/obj/effect/abstract/aq_light_shadow, old_turf)
	TEST_ASSERT(!shadow.onShuttleMove(new_turf, old_turf, list(0, 0, 0), NORTH), "The light shadow joins the shuttle move list")
	TEST_ASSERT_EQUAL(shadow.loc, old_turf, "The shuttle moved the light shadow itself")

/// AQUILA - runda 6591: ponowne Grant() akcji temu samemu mobowi rejestrowało sygnał drugi raz (ostrzeżenie „overridden”)
/datum/unit_test/aquila_mob_cooldown_regrant

/datum/unit_test/aquila_mob_cooldown_regrant/Run()
	var/mob/living/carbon/human/frog = allocate(/mob/living/carbon/human)
	var/datum/action/cooldown/mob_cooldown/sticky_tongue/tongue = new(frog)
	tongue.Grant(frog)
	tongue.Grant(frog) // transfer_actions() przy transfer_to() na ten sam mob
	TEST_ASSERT_EQUAL(tongue.owner, frog, "The action lost its owner after the second Grant()")
	tongue.Remove(frog)
	TEST_ASSERT(!length(tongue.signal_procs?[frog]), "The action still listens to the mob after Remove()")
	qdel(tongue)

/// AQUILA - runda 6591: checkTurfVis() z celem w nullspace czytało null.x
/datum/unit_test/aquila_cameranet_null_turf

/datum/unit_test/aquila_cameranet_null_turf/Run()
	TEST_ASSERT(!GLOB.cameranet.checkTurfVis(null), "A null turf counts as visible to cameras")

/// AQUILA - runda 6591: small_craft rejestrował COMSIG_MOB_OVERMAP_CHANGE na statku, a sygnał wysyła mob.
/// Drugi członek załogi dawał ostrzeżenie „overridden”, a pilot przeniesiony poza myśliwiec dalej nim sterował
/datum/unit_test/aquila_small_craft_pilot_signal
	var/obj/structure/overmap/small_craft/combat/light/fighter
	var/stopped_count = 0

/datum/unit_test/aquila_small_craft_pilot_signal/proc/count_stop(mob/source)
	SIGNAL_HANDLER
	stopped_count++

/datum/unit_test/aquila_small_craft_pilot_signal/Run()
	var/turf/center = SSmapping.get_station_center()
	TEST_ASSERT(center, "No station center")
	fighter = new(center)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human, center)
	var/mob/living/carbon/human/gunner = allocate(/mob/living/carbon/human, center)
	fighter.start_piloting(pilot, OVERMAP_USER_ROLE_PILOT)
	fighter.enter(pilot)
	fighter.start_piloting(gunner, OVERMAP_USER_ROLE_GUNNER) // drugi członek załogi: wcześniej ostrzeżenie „overridden on” statku
	fighter.enter(gunner)
	TEST_ASSERT(LAZYFIND(fighter.operators, pilot), "Entering the fighter stopped the pilot")

	// Pilot wyrzucony poza myśliwiec przestaje nim sterować
	pilot.forceMove(center)
	TEST_ASSERT(!LAZYFIND(fighter.operators, pilot), "The pilot moved out of the fighter still pilots it")
	TEST_ASSERT(fighter.pilot != pilot, "The fighter still has the moved pilot as its pilot")

	// Zwykłe wysiadanie: jedno zejście ze sterów, nie dwa (eject() zmienia overmapę moba)
	RegisterSignal(gunner, COMSIG_STOPPED_PILOTING, PROC_REF(count_stop))
	fighter.stop_piloting(gunner, force = TRUE)
	UnregisterSignal(gunner, COMSIG_STOPPED_PILOTING)
	TEST_ASSERT_EQUAL(stopped_count, 1, "Ejecting sent COMSIG_STOPPED_PILOTING the wrong number of times")
	TEST_ASSERT(gunner.loc == center, "The gunner did not leave the fighter")

/datum/unit_test/aquila_small_craft_pilot_signal/Destroy()
	QDEL_NULL(fighter)
	return ..()

/// AQUILA - runda 6589: druga emp_act() munduru losowała sensor_mode bez update_sensors(), więc noszący zostawał na suit_sensors_list
/datum/unit_test/aquila_uniform_emp_sensor_list

/datum/unit_test/aquila_uniform_emp_sensor_list/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/under/uniform = allocate(/obj/item/clothing/under/rank/medical/virologist)
	wearer.equip_to_slot_or_del(uniform, ITEM_SLOT_ICLOTHING)
	TEST_ASSERT(wearer.w_uniform == uniform, "The uniform was not worn")
	for(var/i in 1 to 30)
		uniform.emp_act(EMP_HEAVY)
		var/on_list = (wearer in GLOB.suit_sensors_list)
		TEST_ASSERT_EQUAL(on_list, uniform.sensor_mode > SENSOR_OFF, "After an EMP the sensor list does not match sensor mode [uniform.sensor_mode]")

	// A spare uniform held in hand does not change the worn uniform's sensors
	uniform.update_sensors(SENSOR_COORDS)
	TEST_ASSERT(wearer in GLOB.suit_sensors_list, "The worn uniform with sensors on is not on the sensor list")
	var/obj/item/clothing/under/spare = allocate(/obj/item/clothing/under/rank/medical/virologist)
	wearer.put_in_hands(spare)
	TEST_ASSERT(spare.loc == wearer, "The spare uniform is not held")
	spare.update_sensors(SENSOR_COORDS)
	spare.update_sensors(SENSOR_OFF)
	TEST_ASSERT(wearer in GLOB.suit_sensors_list, "Turning off a held spare uniform removed the wearer from the sensor list")
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_SUIT_SENSORS), "Turning off a held spare uniform removed the wearer's sensor trait")

/// AQUILA - rundy 6585 i 6587: flak ranił pocisk zniszczony już przez inny flak na tym samym kaflu („taking damage after deletion”)
/datum/unit_test/aquila_flak_deleted_projectile

/datum/unit_test/aquila_flak_deleted_projectile/Run()
	var/obj/effect/temp_visual/flak/flak = allocate(/obj/effect/temp_visual/flak, run_loc_floor_bottom_left, "syndicate")
	var/obj/item/projectile/guided_munition/torpedo/torpedo = new(run_loc_floor_bottom_left)
	torpedo.faction = "nanotrasen"
	qdel(torpedo)
	flak.on_entered(run_loc_floor_bottom_left, torpedo)
	TEST_ASSERT(QDELETED(torpedo), "The torpedo came back")

/// AQUILA - runda 6589: przycisk lobby zdjęty z ekranu dostawał MouseExited i czytał null.game_phase()
/datum/unit_test/aquila_lobby_button_without_lobby

/datum/unit_test/aquila_lobby_button_without_lobby/Run()
	var/atom/movable/screen/aq_lobby/button/join/join = allocate(/atom/movable/screen/aq_lobby/button/join, null, null)
	var/atom/movable/screen/aq_lobby/button/ready/ready = allocate(/atom/movable/screen/aq_lobby/button/ready, null, null)
	join.MouseExited()
	ready.MouseExited()

/// AQUILA - runda 6589: lampa w nullspace czytała null.lightswitch
/datum/unit_test/aquila_light_without_area

/datum/unit_test/aquila_light_without_area/Run()
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light, run_loc_floor_bottom_left)
	lamp.moveToNullspace()
	TEST_ASSERT(!lamp.has_power(), "A light in nullspace has power")

/// AQUILA - runda 6588: drabina bez drabiny docelowej (abordażysta KNPC) przenosiła moba przez forceMove(null) w losowe miejsce
/datum/unit_test/aquila_ladder_without_target

/datum/unit_test/aquila_ladder_without_target/Run()
	var/obj/structure/ladder/ladder = allocate(/obj/structure/ladder, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/climber = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!ladder.travel(TRUE, climber, FALSE, null, FALSE), "Travel to a missing ladder succeeded")
	TEST_ASSERT_EQUAL(climber.loc, run_loc_floor_bottom_left, "The climber moved without a target ladder")

/// AQUILA - runda 6589: rzucona mysz w dłoni: dropped() wypuszczało ją samo, a release() dalej wołało null.forceMove()
/datum/unit_test/aquila_mob_holder_release_in_hand

/datum/unit_test/aquila_mob_holder_release_in_hand/Run()
	var/mob/living/carbon/human/holder_human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse, run_loc_floor_bottom_left)
	var/obj/item/clothing/head/mob_holder/holder = new(run_loc_floor_bottom_left, mouse)
	holder_human.put_in_hands(holder)
	TEST_ASSERT(holder.loc == holder_human, "The holder is not in the hand")
	holder.release()
	TEST_ASSERT(isturf(mouse.loc), "The mouse did not get out of the holder")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
