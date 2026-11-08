// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - audyt circuity (nr 10 i 78): broń z układem dostaje trafienie pocisku i doładowuje się z ogniwa układu po strzale
/datum/unit_test/aquila_audyt_circuit_gun

/datum/unit_test/aquila_audyt_circuit_gun/Run()
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/gun/energy/wiremod_gun/gun = allocate(/obj/item/gun/energy/wiremod_gun, run_loc_floor_bottom_left)
	var/obj/item/integrated_circuit/loaded/circuit = allocate(/obj/item/integrated_circuit/loaded, run_loc_floor_bottom_left)
	var/datum/component/shell/shell = gun.GetComponent(/datum/component/shell)
	shell.attach_circuit(circuit)
	var/obj/item/circuit_component/wiremod_gun/gun_comp = locate() in circuit.attached_components
	TEST_ASSERT(gun_comp, "The circuit gun component did not join the circuit")

	var/obj/item/target = allocate(/obj/item/pen, run_loc_floor_bottom_left)
	var/obj/item/projectile/energy/wiremod_gun/beam = allocate(/obj/item/projectile/energy/wiremod_gun, run_loc_floor_bottom_left)
	beam.fired_from = gun
	beam.firer = shooter
	beam.on_hit(target)
	TEST_ASSERT_EQUAL(gun_comp.shot.value, target, "Shot Entity did not get the hit object")
	TEST_ASSERT_EQUAL(gun_comp.shooter.value, shooter, "Shooter did not get the firer")

	// Strzał zużywa całe ogniwo broni (100 z 100), potem process_chamber doładowuje je z układu
	gun.cell.use(gun.cell.charge)
	var/circuit_charge = circuit.cell.charge
	gun.process_chamber()
	TEST_ASSERT(gun.cell.charge > 0, "The gun cell did not recharge from the circuit after the shot")
	TEST_ASSERT(circuit.cell.charge < circuit_charge, "The circuit cell did not pay for the recharge")
	TEST_ASSERT(gun.can_shoot(), "The recharged gun cannot fire again")

/// AQUILA - audyt circuity (nr 36): wszczepiony BCI siedzi w mobie, więc komponenty widzą jego położenie
/datum/unit_test/aquila_audyt_bci_location

/datum/unit_test/aquila_audyt_bci_location/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/organ/cyberimp/bci/bci = allocate(/obj/item/organ/cyberimp/bci, run_loc_floor_bottom_left)
	var/datum/component/shell/shell = bci.GetComponent(/datum/component/shell)
	var/obj/item/circuit_component/core = shell.attached_circuit.attached_components[1]
	bci.Insert(patient)
	TEST_ASSERT_EQUAL(bci.owner, patient, "The BCI was not implanted")
	TEST_ASSERT_EQUAL(bci.loc, patient, "The implanted BCI is not inside its owner")
	TEST_ASSERT_EQUAL(core.get_location(), get_turf(patient), "A BCI component does not see its owner's turf")
	bci.Remove(patient)
	TEST_ASSERT(bci.loc != patient, "The removed BCI stayed inside its old owner")

/// AQUILA - audyt circuity (nr 50): komponent konsoli rekordów ustawia ten sam status poszukiwania co konsola, HUD i secboty
/datum/unit_test/aquila_audyt_arrest_status

/datum/unit_test/aquila_audyt_arrest_status/Run()
	var/obj/machinery/computer/secure_data/console = allocate(/obj/machinery/computer/secure_data, run_loc_floor_bottom_left)
	console.authenticated = TRUE
	var/obj/item/integrated_circuit/circuit = allocate(/obj/item/integrated_circuit, run_loc_floor_bottom_left)
	var/obj/item/circuit_component/arrest_console_arrest/arrest = new
	TEST_ASSERT(circuit.add_component(arrest), "Could not add the arrest component to a circuit")
	arrest.attached_console = console
	TEST_ASSERT("Search" in arrest.status_option.possible_options, "The arrest component has no Search status")
	TEST_ASSERT("Monitor" in arrest.status_option.possible_options, "The arrest component has no Monitor status")

	var/datum/data/record/record = new
	record.fields["criminal"] = "None"
	arrest.targets.set_value(list(list("security_record" = record, "name" = "Testowy")))
	arrest.status_option.set_value(COMP_STATE_ARREST)
	arrest.input_received(null)
	TEST_ASSERT_EQUAL(record.fields["criminal"], "Arrest", "The arrest component set a status the HUD and secbots do not know")
	qdel(record)

/// AQUILA - audyt circuity (nr 28): komponent Wirenet w zespole podpiętym do przewodów śledzi maszynę
/datum/unit_test/aquila_audyt_wirenet_assembly

/datum/unit_test/aquila_audyt_wirenet_assembly/Run()
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, run_loc_floor_bottom_left)
	var/obj/item/assembly/wiremod/assembly = allocate(/obj/item/assembly/wiremod, run_loc_floor_bottom_left)
	var/obj/item/integrated_circuit/loaded/circuit = allocate(/obj/item/integrated_circuit/loaded, run_loc_floor_bottom_left)
	var/obj/item/circuit_component/wirenet_receive/receiver = new
	TEST_ASSERT(circuit.add_component(receiver), "Could not add the wirenet receiver to a circuit")
	var/datum/component/shell/shell = assembly.GetComponent(/datum/component/shell)
	shell.attach_circuit(circuit)
	var/datum/component/circuit_component_wirenet_connection/connection = receiver.GetComponent(/datum/component/circuit_component_wirenet_connection)
	TEST_ASSERT(connection, "The wirenet receiver has no wirenet connection")

	var/color = door.wires.colors[1]
	TEST_ASSERT(door.wires.attach_assembly(color, assembly), "The circuit assembly cannot be attached to airlock wires")
	TEST_ASSERT_EQUAL(connection.tracked_movable, door, "The wirenet component does not follow the machine its assembly is wired into")
	door.wires.detach_assembly(color)
	TEST_ASSERT(isnull(connection.tracked_movable), "The wirenet component still follows the machine after detaching")

/// AQUILA - audyt circuity (nr 51): układ wkłada się do implantu przez etui i wyjmuje śrubokrętem
/datum/unit_test/aquila_audyt_implant_case

/datum/unit_test/aquila_audyt_implant_case/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/implantcase/circuit/implant_case = allocate(/obj/item/implantcase/circuit, run_loc_floor_bottom_left)
	var/obj/item/integrated_circuit/circuit = allocate(/obj/item/integrated_circuit, run_loc_floor_bottom_left)
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver, run_loc_floor_bottom_left)
	var/datum/component/shell/shell = implant_case.imp.GetComponent(/datum/component/shell)
	user.put_in_active_hand(circuit)
	implant_case.attackby(circuit, user)
	TEST_ASSERT_EQUAL(shell.attached_circuit, circuit, "The circuit did not go into the implant through its case")
	TEST_ASSERT_EQUAL(circuit.loc, implant_case.imp, "The inserted circuit is not inside the implant")
	implant_case.tool_act(user, screwdriver, TOOL_SCREWDRIVER, FALSE)
	TEST_ASSERT(isnull(shell.attached_circuit), "The screwdriver on the case did not remove the circuit")

/// AQUILA - audyt circuity (nr 52): śluza z elektroniką „Obudowa” pyta układ o wpuszczenie, a dostępy z elektroniki zostają
/datum/unit_test/aquila_audyt_airlock_access_event

/datum/unit_test/aquila_audyt_airlock_access_event/Run()
	var/mob/living/carbon/human/visitor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, run_loc_floor_top_right)
	door.req_access = list(ACCESS_CAPTAIN)
	var/obj/item/electronics/airlock/electronics = allocate(/obj/item/electronics/airlock, run_loc_floor_bottom_left)
	electronics.shell = TRUE
	electronics.apply_circuit_shell(door)
	var/datum/component/shell/shell = door.GetComponent(/datum/component/shell)
	TEST_ASSERT(shell, "The airlock electronics shell option did not make a circuit shell")
	var/obj/item/integrated_circuit/loaded/circuit = allocate(/obj/item/integrated_circuit/loaded, run_loc_floor_bottom_left)
	shell.attach_circuit(circuit)
	TEST_ASSERT(!door.allowed(visitor), "A circuit that does not answer let a visitor without access in")

	var/obj/item/circuit_component/airlock_access_event/event = locate() in circuit.attached_components
	TEST_ASSERT(event, "The access event component did not join the circuit")
	event.open_airlock.connect(event.event_triggered)
	TEST_ASSERT(door.allowed(visitor), "The access event answering Should Open Airlock did not open a normal airlock shell")
	TEST_ASSERT_EQUAL(event.accessing_entity.value, visitor, "The access event did not report who tried the door")

/// AQUILA - audyt circuity (nr 53): poza combat mode dystrybutor oddaje układ obudowie zamiast go magazynować
/datum/unit_test/aquila_audyt_dispenser_circuit

/datum/unit_test/aquila_audyt_dispenser_circuit/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/structure/dispenser_bot/dispenser = allocate(/obj/structure/dispenser_bot, run_loc_floor_bottom_left)
	var/obj/item/integrated_circuit/circuit = allocate(/obj/item/integrated_circuit, run_loc_floor_bottom_left)
	var/obj/item/pen/pen = allocate(/obj/item/pen, run_loc_floor_bottom_left)
	var/datum/component/shell/shell = dispenser.GetComponent(/datum/component/shell)
	user.set_combat_mode(FALSE)
	user.put_in_active_hand(circuit)
	dispenser.attackby(circuit, user)
	TEST_ASSERT_EQUAL(shell.attached_circuit, circuit, "The circuit went into the dispenser storage instead of the shell")
	TEST_ASSERT(!(circuit in dispenser.stored_items), "The circuit is both the shell circuit and a stored item")
	user.put_in_active_hand(pen)
	dispenser.attackby(pen, user)
	TEST_ASSERT(pen in dispenser.stored_items, "An ordinary item no longer goes into the dispenser storage")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
