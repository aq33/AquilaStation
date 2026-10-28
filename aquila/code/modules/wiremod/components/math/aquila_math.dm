// Komponenty matematyczne ze starego wiremoda, których tg nie ma. Przepięte na API z tg.

#define COMP_BITWISE_AND "And"
#define COMP_BITWISE_OR "Or"
#define COMP_BITWISE_XOR "Xor"
#define COMP_BITWISE_LEFTSHIFT "Left Shift"
#define COMP_BITWISE_RIGHTSHIFT "Right Shift"

/**
 * # Bitwise Component
 *
 * A component that preforms bitwise and, or and xor operations, as well as left shifts and right shifts
 * All input and output values are floored
 */
/obj/item/circuit_component/bitwise
	display_name = "Bitwise"
	desc = "Komponent, który działa na bitach liczb całkowitych. Wartości dziesiętne są ignorowane."
	category = "Math"

	var/datum/port/input/option/bitwise_option

	/// The result from the output
	var/datum/port/output/output

	var/list/bitwise_ports
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL
	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

/obj/item/circuit_component/bitwise/populate_options()
	var/static/component_options = list(
		COMP_BITWISE_AND,
		COMP_BITWISE_OR,
		COMP_BITWISE_XOR,
		COMP_BITWISE_LEFTSHIFT,
		COMP_BITWISE_RIGHTSHIFT,
	)
	bitwise_option = add_option_port("Bitwise Option", component_options)

/obj/item/circuit_component/bitwise/populate_ports()
	bitwise_ports = list()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = bitwise_ports, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_NUMBER, \
		prefix = "Port", \
		minimum_amount = 2 \
	)
	output = add_output_port("Output", PORT_TYPE_NUMBER, order = 1.1)

/obj/item/circuit_component/bitwise/input_received(datum/port/input/port)
	var/list/ports = bitwise_ports.Copy()
	var/datum/port/input/first_port = popleft(ports)
	var/result = FLOOR(first_port.value, 1)

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.value
		if(isnull(value))
			continue
		value = FLOOR(value, 1)

		switch(bitwise_option.value)
			if(COMP_BITWISE_AND)
				result &= value
			if(COMP_BITWISE_OR)
				result |= value
			if(COMP_BITWISE_XOR)
				result ^= value
			if(COMP_BITWISE_LEFTSHIFT)
				result = FLOOR(result * 2**value, 1) //Bitshifts are done with powers of two instead of the >> and << operators to allow negative shifts
			if(COMP_BITWISE_RIGHTSHIFT)
				result = FLOOR(result * 2**(-value), 1)

	output.set_output(result)

#undef COMP_BITWISE_AND
#undef COMP_BITWISE_OR
#undef COMP_BITWISE_XOR
#undef COMP_BITWISE_LEFTSHIFT
#undef COMP_BITWISE_RIGHTSHIFT

/**
 * # Bitflag Component
 *
 * Checks if a specific bit in a number is a one or zero.
 * Its best use is to combine it with the bitwise component to put multiple booleans in one number.
 */
/obj/item/circuit_component/compare/bitflag
	display_name = "Bitflag"
	desc = "Komponent, który określa, czy dany bit liczby jest włączony, czy wyłączony."
	category = "Math"

	/// The number containing the flags
	var/datum/port/input/input
	/// The bit that needs to be checked
	var/datum/port/input/bit

/obj/item/circuit_component/compare/bitflag/populate_custom_ports()
	input = add_input_port("Input", PORT_TYPE_NUMBER)
	bit = add_input_port("Bit", PORT_TYPE_NUMBER)

/obj/item/circuit_component/compare/bitflag/do_comparisons()
	var/value = round(input.value)
	var/bit_value = round(bit.value)
	return (value >> bit_value) & 1

#define COMP_ROUND_ROUND "Round"
#define COMP_ROUND_FLOOR "Floor"
#define COMP_ROUND_CEIL "Ceil"

/**
 * # Round Component
 *
 * This component can round, floor, and ceil number inputs.
 */
/obj/item/circuit_component/round
	display_name = "Round"
	desc = "Komponent, który potrafi obciąć niechlujne części dziesiętne liczby."
	category = "Math"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/option/round_option

	/// The input port
	var/datum/port/input/input

	/// The result from the output
	var/datum/port/output/output

/obj/item/circuit_component/round/populate_options()
	var/static/component_options = list(
		COMP_ROUND_ROUND,
		COMP_ROUND_FLOOR,
		COMP_ROUND_CEIL,
	)
	round_option = add_option_port("Round Option", component_options)

/obj/item/circuit_component/round/populate_ports()
	input = add_input_port("Input", PORT_TYPE_NUMBER)
	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/round/input_received(datum/port/input/port)
	var/value = input.value
	if(isnull(value))
		output.set_output(null) //Pass the null along
		return

	switch(round_option.value)
		if(COMP_ROUND_ROUND)
			value = round(value, 1)
		if(COMP_ROUND_FLOOR)
			value = FLOOR(value, 1)
		if(COMP_ROUND_CEIL)
			value = CEILING(value, 1)

	output.set_output(value)

#undef COMP_ROUND_ROUND
#undef COMP_ROUND_FLOOR
#undef COMP_ROUND_CEIL

#define COMP_TRIG_SECANT "SEC"
#define COMP_TRIG_COSECANT "CSC"
#define COMP_TRIG_COTANGENT "COT"
#define COMP_TRIG_HYPERBOLIC_SINE "SINH"
#define COMP_TRIG_HYPERBOLIC_COSINE "COSH"
#define COMP_TRIG_AHYPERBOLIC_SINE "ASINH"
#define COMP_TRIG_AHYPERBOLIC_COSINE "ACOSH"

/**
 * # Advanced Trigonometry Component
 *
 * Secant, cosecant, cotangent and the hyperbolic functions. Plain sine/cosine/tangent live in the tg trigonometry component.
 */
/obj/item/circuit_component/advanced_trigonometry
	display_name = "Advanced Trigonometry"
	desc = "Po wybitnych postępach w dziedzinie matematyki naukowcy NanoTrasen odkryli, jak obliczać odwrotności funkcji trygonometrycznych i funkcje hiperboliczne."
	category = "Math"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	//An increase in power usage due to more complex calculations
	energy_usage_per_input = 0.002 * STANDARD_CELL_CHARGE

	var/datum/port/input/option/trig_option

	/// The input port
	var/datum/port/input/input

	/// The result from the output
	var/datum/port/output/output

/obj/item/circuit_component/advanced_trigonometry/populate_options()
	var/static/component_options = list(
		COMP_TRIG_SECANT,
		COMP_TRIG_COSECANT,
		COMP_TRIG_COTANGENT,
		COMP_TRIG_HYPERBOLIC_SINE,
		COMP_TRIG_HYPERBOLIC_COSINE,
		COMP_TRIG_AHYPERBOLIC_SINE,
		COMP_TRIG_AHYPERBOLIC_COSINE,
	)
	trig_option = add_option_port("Trigonometry Option", component_options)

/obj/item/circuit_component/advanced_trigonometry/populate_ports()
	input = add_input_port("Input", PORT_TYPE_NUMBER)
	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/advanced_trigonometry/input_received(datum/port/input/port)
	output.set_output(do_calculation(input.value))

/obj/item/circuit_component/advanced_trigonometry/proc/do_calculation(value)
	if(isnull(value))
		return null
	switch(trig_option.value)
		if(COMP_TRIG_HYPERBOLIC_COSINE)
			return (NUM_E**value + NUM_E**(-value))/2
		if(COMP_TRIG_HYPERBOLIC_SINE)
			return (NUM_E**value - NUM_E**(-value))/2
		if(COMP_TRIG_AHYPERBOLIC_SINE)
			return log(value+sqrt(value**2+1))
		if(COMP_TRIG_AHYPERBOLIC_COSINE)
			return value < 1 ? null : log(value+sqrt(value**2-1))
	value = TODEGREES(value) //apparently BYOND doesn't believe in the almighty radian
	switch(trig_option.value)
		if(COMP_TRIG_SECANT)
			return cos(value) == 0 ? null : SEC(value)
		if(COMP_TRIG_COSECANT)
			return sin(value) == 0 ? null : CSC(value)
		if(COMP_TRIG_COTANGENT)
			return sin(value) == 0 ? null : (cos(value) * CSC(value)) //The define for COT uses 1/tan(x), which throws a divide by zero error when x = pi/2 + kpi where k is an integer

#undef COMP_TRIG_SECANT
#undef COMP_TRIG_COSECANT
#undef COMP_TRIG_COTANGENT
#undef COMP_TRIG_HYPERBOLIC_SINE
#undef COMP_TRIG_HYPERBOLIC_COSINE
#undef COMP_TRIG_AHYPERBOLIC_SINE
#undef COMP_TRIG_AHYPERBOLIC_COSINE
