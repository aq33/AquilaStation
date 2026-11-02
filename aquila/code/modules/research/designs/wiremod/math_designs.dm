/datum/design/component/math
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/math/arithmetic
	name = "Komponent: arytmetyka"
	id = "comp_arithmetic"
	build_path = /obj/item/circuit_component/arithmetic

/datum/design/component/math/trigonometry
	name = "Komponent: trygonometria"
	id = "comp_trig"
	build_path = /obj/item/circuit_component/trigonometry

/datum/design/component/math/arctan2
	name = "Komponent: arcus tangens 2"
	id = "comp_arctan2"
	build_path = /obj/item/circuit_component/arctan2

/datum/design/component/math/comparison
	name = "Komponent: porównanie"
	id = "comp_comparison"
	build_path = /obj/item/circuit_component/compare/comparison

/datum/design/component/math/logic
	name = "Komponent: logika"
	id = "comp_logic"
	build_path = /obj/item/circuit_component/compare/logic

/datum/design/component/math/toggle
	name = "Komponent: przełącznik"
	id = "comp_toggle"
	build_path = /obj/item/circuit_component/compare/toggle

/datum/design/component/math/binary_conversion
	name = "Komponent: konwersja na system dwójkowy"
	id = "comp_binary_conversion"
	build_path = /obj/item/circuit_component/binary_conversion

/datum/design/component/math/decimal_conversion
	name = "Komponent: konwersja na system dziesiętny"
	id = "comp_decimal_conversion"
	build_path = /obj/item/circuit_component/decimal_conversion

/datum/design/component/math/not
	name = "Komponent: negacja"
	id = "comp_not"
	build_path = /obj/item/circuit_component/not

/datum/design/component/math/random
	name = "Komponent: losowanie"
	id = "comp_random"
	build_path = /obj/item/circuit_component/random

/datum/design/component/math/length
	name = "Komponent: długość"
	id = "comp_length"
	build_path = /obj/item/circuit_component/length

// Komponenty ze starego wiremoda, których tg nie ma (aquila_math.dm)
/datum/design/component/math/bitwise
	name = "Komponent: operacje bitowe"
	id = "comp_bitwise"
	build_path = /obj/item/circuit_component/bitwise

/datum/design/component/math/bitflag
	name = "Komponent: flaga bitowa"
	id = "comp_bitflag"
	build_path = /obj/item/circuit_component/compare/bitflag

/datum/design/component/math/round
	name = "Komponent: zaokrąglanie"
	id = "comp_round"
	build_path = /obj/item/circuit_component/round

/datum/design/component/math/advanced_trigonometry
	name = "Komponent: trygonometria zaawansowana"
	id = "comp_adv_trig"
	build_path = /obj/item/circuit_component/advanced_trigonometry
