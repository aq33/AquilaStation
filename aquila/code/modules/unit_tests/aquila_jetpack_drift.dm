// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Ile moli wolno się pomylić przy liczeniu paliwa
#define AQUILA_JETPACK_FUEL_EPSILON 0.0001

/// Środek pokoju testowego: dwa pola do każdej ściany, więc w zasięgu 1 nie ma się od czego odepchnąć
/proc/aquila_drift_test_center(datum/unit_test/test)
	var/turf/corner = test.run_loc_floor_bottom_left
	return locate(corner.x + 2, corner.y + 2, corner.z)

/// Port BeeStation/BeeStation-Hornet#14864: pchnięcie bez grawitacji niesie moba pętlą driftu aż do ściany,
/// pętlę da się wstrzymać (pause_for), a ślizg 0 nie dzieli przez zero (drift i paralaksa)
/datum/unit_test/aquila_drift_carries_mob

/datum/unit_test/aquila_drift_carries_mob/Run()
	var/turf/center = aquila_drift_test_center(src)
	TEST_ASSERT(!center.has_gravity(), "The test room has gravity, the drift test needs zero gravity")
	var/mob/living/carbon/human/floater = allocate(/mob/living/carbon/human, center)
	TEST_ASSERT(!floater.Process_Spacemove(EAST, continuous_move = TRUE), "A mob in the middle of the room has something to hold on to")
	TEST_ASSERT(floater.newtonian_move(EAST), "A push in zero gravity did not start a drift")
	var/datum/component/drift/drift = floater.GetComponent(/datum/component/drift)
	TEST_ASSERT(drift, "No drift component after a push")
	var/datum/move_loop/move/loop = drift.drifting_loop
	TEST_ASSERT(loop, "Drift has no movement loop")
	TEST_ASSERT(loop.status & MOVELOOP_STATUS_RUNNING, "The drift loop did not start")
	TEST_ASSERT(loop.status & MOVELOOP_STATUS_QUEUED, "The drift loop is not queued in SSspacedrift")
	// apply_initial_visuals(): ślizg dryfu ustawiony od razu, a jego własny sygnał zignorowany (bez pauzy pętli)
	var/drift_glide = MOVEMENT_ADJUSTED_GLIDE_SIZE(floater.inertia_move_delay, SSspacedrift.visual_delay)
	TEST_ASSERT(abs(floater.glide_size - drift_glide) < 0.01, "The drift did not set its glide ([floater.glide_size], expected [drift_glide])")
	TEST_ASSERT(!drift.delayed, "The drift paused itself on its own glide")

	// pause_for przekłada pętlę do późniejszego kubełka
	loop.pause_for(3)
	TEST_ASSERT_EQUAL(loop.queued_time, world.time + 3, "pause_for() did not requeue the loop")
	TEST_ASSERT(loop.status & MOVELOOP_STATUS_QUEUED, "The loop fell out of the queue after pause_for()")

	// Ślizg 0 (ruch bez animacji) w trakcie dryfu: bez dzielenia przez zero w dryfie i w paralaksie
	floater.set_glide_size(0)
	TEST_ASSERT_EQUAL(get_parallax_glide_rate(floater), 0, "A mob without glide gives parallax a glide time")
	floater.set_glide_size(8)
	TEST_ASSERT(get_parallax_glide_rate(floater) > 0, "A gliding mob gives parallax no glide time")
	TEST_ASSERT(drift.delayed, "Own glide did not pause the drift loop")

	var/start_x = floater.x
	var/deadline = world.time + 5 SECONDS
	UNTIL(floater.x > start_x || world.time > deadline)
	TEST_ASSERT(floater.x > start_x, "The drift did not carry the mob east")
	TEST_ASSERT_EQUAL(floater.y, center.y, "The drift changed direction")

	// Przy ścianie (zasięg 1) dryf się kończy
	deadline = world.time + 5 SECONDS
	UNTIL(!floater.GetComponent(/datum/component/drift) || world.time > deadline)
	TEST_ASSERT(!floater.GetComponent(/datum/component/drift), "The drift did not stop next to the wall")
	TEST_ASSERT(floater.x <= run_loc_floor_top_right.x, "The mob drifted into the wall")

/// Puszczony w trakcie dryfu przedmiot leci dalej sam (COMSIG_ATOM_NO_LONGER_PULLING)
/datum/unit_test/aquila_drift_released_pull

/datum/unit_test/aquila_drift_released_pull/Run()
	var/turf/center = aquila_drift_test_center(src)
	var/mob/living/carbon/human/puller = allocate(/mob/living/carbon/human, center)
	var/obj/item/crowbar/bar = allocate(/obj/item/crowbar, get_step(center, WEST))
	puller.start_pulling(bar)
	TEST_ASSERT_EQUAL(puller.pulling, bar, "Could not pull the crowbar")
	TEST_ASSERT(puller.newtonian_move(EAST), "A pulling mob did not start drifting")
	puller.stop_pulling()
	var/datum/component/drift/bar_drift = bar.GetComponent(/datum/component/drift)
	TEST_ASSERT(bar_drift, "The released crowbar did not keep the drift")
	TEST_ASSERT_EQUAL(bar_drift.drifting_loop?.direction, EAST, "The released crowbar drifts the wrong way")

/// Plecak odrzutowy na komponencie: ruch własny bez paliwa, stabilizacja zatrzymuje dryf bez zużycia,
/// jedno pchnięcie = jedno zużycie (dawniej carbon/Move() zużywał paliwo drugi raz), wyłączenie zdejmuje sygnały
/datum/unit_test/aquila_jetpack_stabilizers

/datum/unit_test/aquila_jetpack_stabilizers/Run()
	var/turf/center = aquila_drift_test_center(src)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human, center)
	var/obj/item/tank/jetpack/oxygen/jetpack = allocate(/obj/item/tank/jetpack/oxygen)
	TEST_ASSERT(pilot.equip_to_slot_if_possible(jetpack, ITEM_SLOT_BACK, disable_warning = TRUE), "Could not wear the jetpack")
	TEST_ASSERT(!pilot.Process_Spacemove(EAST), "A mob without a jetpack can move in the middle of the room")
	TEST_ASSERT(jetpack.turn_on(pilot), "A full jetpack did not turn on")
	TEST_ASSERT(jetpack.on, "Jetpack is not on after turn_on()")
	var/datum/component/jetpack/thrusters = jetpack.GetComponent(/datum/component/jetpack)
	TEST_ASSERT(thrusters, "Jetpack has no jetpack component")
	TEST_ASSERT_EQUAL(thrusters.user, pilot, "The jetpack component does not listen on the wearer")

	// Bez stabilizacji: własny ruch tak, zatrzymanie dryfu nie
	TEST_ASSERT(pilot.Process_Spacemove(EAST), "An active jetpack does not let the wearer move")
	TEST_ASSERT(!pilot.Process_Spacemove(EAST, continuous_move = TRUE), "A jetpack without stabilizers stops the drift")

	jetpack.configure_jetpack(TRUE)
	TEST_ASSERT(jetpack.stabilize, "configure_jetpack(TRUE) did not turn stabilizers on")
	TEST_ASSERT(thrusters.stabilize, "The component did not get the stabilizer setting")
	TEST_ASSERT_EQUAL(jetpack.GetComponent(/datum/component/jetpack), thrusters, "Reconfiguring made a second component")
	var/fuel = jetpack.air_contents.total_moles()
	TEST_ASSERT(pilot.Process_Spacemove(EAST, continuous_move = TRUE), "A stabilized jetpack does not stop the drift")
	TEST_ASSERT(!pilot.newtonian_move(EAST), "A stabilized jetpack let the wearer start drifting")
	TEST_ASSERT(!pilot.GetComponent(/datum/component/drift), "A stabilized wearer got a drift component")

	// Krok jak w client/Move() (Process_Spacemove, potem Move) bez pchnięcia nie zużywa paliwa
	var/turf/east = get_step(pilot, EAST)
	TEST_ASSERT(pilot.Process_Spacemove(EAST), "The jetpack does not allow the step")
	pilot.Move(east, EAST)
	TEST_ASSERT_EQUAL(pilot.loc, east, "Could not step east")
	TEST_ASSERT(abs(jetpack.air_contents.total_moles() - fuel) < AQUILA_JETPACK_FUEL_EPSILON, "Checks and a step without thrust used fuel ([fuel] -> [jetpack.air_contents.total_moles()])")

	// Jedno pchnięcie dysz zużywa paliwo raz
	TEST_ASSERT(thrusters.thrust(), "Thrust failed with fuel in the tank")
	var/used = fuel - jetpack.air_contents.total_moles()
	TEST_ASSERT(abs(used - 0.01) < AQUILA_JETPACK_FUEL_EPSILON, "One thrust should use 0.01 mol, used [used]")

	// Wyłączenie bez podanego użytkownika i tak zdejmuje sygnały z noszącego
	jetpack.turn_off(null)
	TEST_ASSERT(!jetpack.on, "Jetpack stayed on after turn_off()")
	TEST_ASSERT(isnull(thrusters.user), "The component kept listening on the wearer after turn_off()")
	TEST_ASSERT(!pilot.Process_Spacemove(EAST), "A turned off jetpack still lets the wearer move")

	// Zdjęcie z pleców wyłącza plecak
	TEST_ASSERT(jetpack.turn_on(pilot), "The jetpack did not turn on again")
	pilot.dropItemToGround(jetpack)
	TEST_ASSERT(!jetpack.on, "A dropped jetpack stayed on")
	TEST_ASSERT(isnull(thrusters.user), "A dropped jetpack kept listening on the old wearer")

/// Plecak odrzutowy hardsuitu ciągnie z butli w schowku skafandra (jetpack/suit siedzi w kombinezonie, nie na mobie)
/datum/unit_test/aquila_jetpack_hardsuit

/datum/unit_test/aquila_jetpack_hardsuit/Run()
	var/turf/center = aquila_drift_test_center(src)
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human, center)
	var/obj/item/clothing/suit/space/hardsuit/engine/elite/suit = allocate(/obj/item/clothing/suit/space/hardsuit/engine/elite)
	var/obj/item/tank/jetpack/suit/pack = suit.jetpack
	TEST_ASSERT(istype(pack), "The advanced hardsuit has no built-in jetpack")
	TEST_ASSERT(engineer.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "Could not put on the hardsuit")
	var/obj/item/tank/internals/oxygen/tank = allocate(/obj/item/tank/internals/oxygen)
	TEST_ASSERT(engineer.equip_to_slot_if_possible(tank, ITEM_SLOT_SUITSTORE, disable_warning = TRUE), "Could not put a tank into suit storage")

	TEST_ASSERT(pack.turn_on(engineer), "The hardsuit jetpack did not turn on with a tank in suit storage")
	var/datum/component/jetpack/thrusters = pack.GetComponent(/datum/component/jetpack)
	TEST_ASSERT_EQUAL(thrusters.user, engineer, "The hardsuit jetpack does not listen on the wearer")
	TEST_ASSERT(engineer.Process_Spacemove(EAST), "The hardsuit jetpack does not let the wearer move")
	var/fuel = tank.air_contents.total_moles()
	TEST_ASSERT(thrusters.thrust(), "The hardsuit jetpack could not thrust")
	var/used = fuel - tank.air_contents.total_moles()
	TEST_ASSERT(abs(used - 0.01) < AQUILA_JETPACK_FUEL_EPSILON, "One thrust of the hardsuit jetpack should use 0.01 mol from the suit storage tank, used [used]")

	pack.turn_off(engineer)
	TEST_ASSERT(isnull(thrusters.user), "The hardsuit jetpack kept listening after turn_off()")
	TEST_ASSERT(pack.air_contents != tank.air_contents, "The hardsuit jetpack kept the suit storage tank after turn_off()")

	// Taking the hardsuit off shuts the jetpack at once, not on the next process() (review of aq33/AquilaStation#600)
	TEST_ASSERT(pack.turn_on(engineer), "The hardsuit jetpack did not turn on again")
	engineer.dropItemToGround(suit, force = TRUE)
	TEST_ASSERT(!pack.on, "The hardsuit jetpack stayed on after the hardsuit was taken off")
	TEST_ASSERT(isnull(thrusters.user), "The hardsuit jetpack kept the former wearer flying")

	// A backpack jetpack only offers its toggle when worn on the back, not held in a hand
	var/obj/item/tank/jetpack/oxygen/backpack = allocate(/obj/item/tank/jetpack/oxygen)
	TEST_ASSERT(!backpack.item_action_slot_check(ITEM_SLOT_HANDS, engineer), "A jetpack held in a hand offers its toggle")
	TEST_ASSERT(backpack.item_action_slot_check(ITEM_SLOT_BACK, engineer), "A jetpack worn on the back offers no toggle")

/// Implant dysz też idzie przez komponent i nie ma stabilizacji
/datum/unit_test/aquila_jetpack_implant

/datum/unit_test/aquila_jetpack_implant/Run()
	var/turf/center = aquila_drift_test_center(src)
	var/mob/living/carbon/human/cyborg = allocate(/mob/living/carbon/human, center)
	var/obj/item/organ/cyberimp/chest/thrusters/implant = new
	implant.Insert(cyborg)
	implant.toggle()
	TEST_ASSERT(implant.on, "The thruster implant did not turn on (room air is above 30 kPa)")
	TEST_ASSERT(cyborg.Process_Spacemove(EAST), "The thruster implant does not let the mob move")
	TEST_ASSERT(!cyborg.Process_Spacemove(EAST, continuous_move = TRUE), "The thruster implant has no stabilizers, it must not stop the drift")
	implant.toggle()
	TEST_ASSERT(!implant.on, "The thruster implant did not turn off")
	TEST_ASSERT(!cyborg.Process_Spacemove(EAST), "A turned off thruster implant still lets the mob move")

/// Moduł jetpacka w hardsuicie (dawny MOD) idzie przez komponent, stabilizację przełącza konfiguracja modułu
/datum/unit_test/aquila_jetpack_module

/datum/unit_test/aquila_jetpack_module/Run()
	var/turf/center = aquila_drift_test_center(src)
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, center)
	var/obj/item/clothing/suit/space/hardsuit/suit = allocate(/obj/item/clothing/suit/space/hardsuit)
	var/obj/item/mod/module/jetpack/module = allocate(/obj/item/mod/module/jetpack)
	TEST_ASSERT(suit.install(module), "install() refused the jetpack module")
	TEST_ASSERT(wearer.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "Could not put on the hardsuit")
	module.on_select()
	TEST_ASSERT(module.active, "The jetpack module did not activate")
	var/datum/component/jetpack/thrusters = module.GetComponent(/datum/component/jetpack)
	TEST_ASSERT_EQUAL(thrusters?.user, wearer, "The jetpack module does not listen on the wearer")
	TEST_ASSERT(wearer.Process_Spacemove(EAST), "The jetpack module does not let the wearer move")
	TEST_ASSERT(!wearer.Process_Spacemove(EAST, continuous_move = TRUE), "The jetpack module without stabilizers stops the drift")
	module.configure_edit("stabilizers", "1")
	TEST_ASSERT(wearer.Process_Spacemove(EAST, continuous_move = TRUE), "The stabilized jetpack module does not stop the drift")
	module.on_select()
	TEST_ASSERT(!module.active, "The jetpack module did not deactivate")
	TEST_ASSERT(isnull(thrusters.user), "The jetpack module kept listening after deactivation")

#undef AQUILA_JETPACK_FUEL_EPSILON
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
