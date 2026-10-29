// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - wiremod z tg: każdy komponent z projektem ma kategorię, projekty mają id, nasze komponenty liczą, a układ da się zapisać i wczytać
/datum/unit_test/aquila_wiremod

/datum/unit_test/aquila_wiremod/Run()
	// Z tg (circuit_component_category): komponent dostępny z badań musi mieć kategorię
	for(var/datum/design/design as anything in subtypesof(/datum/design/component))
		var/obj/item/circuit_component/path = initial(design.build_path)
		if(!path)
			continue
		TEST_ASSERT(initial(path.category) != COMPONENT_DEFAULT_CATEGORY, "[path] has a category of '[COMPONENT_DEFAULT_CATEGORY]' when it has a research design that players can potentially access!")
		TEST_ASSERT(initial(design.id) != DESIGN_ID_IGNORE, "[design] has no design id, our techweb would never unlock it")

	// Typy złożone są tworzone przed GLOB, więc listy z wiremod_basic_types muszą mieć gotowe typy
	TEST_ASSERT(PORT_TYPE_LIST(PORT_TYPE_NUMBER), "PORT_TYPE_LIST(PORT_TYPE_NUMBER) did not return a composite datatype")
	TEST_ASSERT(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY), "PORT_TYPE_ASSOC_LIST did not return a composite datatype")

	var/obj/item/circuit_component/bitwise/bitwise = allocate(/obj/item/circuit_component/bitwise)
	var/datum/port/input/first = bitwise.bitwise_ports[1]
	var/datum/port/input/second = bitwise.bitwise_ports[2]
	first.set_value(12)
	second.set_value(10)
	bitwise.bitwise_option.set_value("And")
	bitwise.input_received(null)
	TEST_ASSERT_EQUAL(bitwise.output.value, 8, "Bitwise And of 12 and 10")

	var/obj/item/circuit_component/round/rounder = allocate(/obj/item/circuit_component/round)
	rounder.input.set_value(2.5)
	rounder.round_option.set_value("Floor")
	rounder.input_received(null)
	TEST_ASSERT_EQUAL(rounder.output.value, 2, "Round Floor of 2.5")

	var/obj/item/circuit_component/compare/bitflag/flag = allocate(/obj/item/circuit_component/compare/bitflag)
	flag.input.set_value(5)
	flag.bit.set_value(2)
	TEST_ASSERT(flag.do_comparisons(), "Bit 2 of 5 should be set")

	// Zapis i wczytanie układu (duplikator z tg)
	var/obj/item/integrated_circuit/loaded/circuit = allocate(/obj/item/integrated_circuit/loaded)
	var/obj/item/circuit_component/arithmetic/arithmetic = new
	TEST_ASSERT(circuit.add_component(arithmetic), "Could not add an arithmetic component to a circuit")
	var/obj/item/circuit_component/speech/speech = new
	TEST_ASSERT(circuit.add_component(speech), "Could not add a speech component to a circuit")
	var/list/errors = list()
	var/obj/item/integrated_circuit/loaded/copy = allocate(/obj/item/integrated_circuit/loaded)
	copy.load_circuit_data(circuit.convert_to_json(), errors)
	TEST_ASSERT(!length(errors), "Loading a saved circuit gave errors: [english_list(errors)]")
	TEST_ASSERT_EQUAL(length(copy.attached_components), length(circuit.attached_components), "Loaded circuit component count")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
