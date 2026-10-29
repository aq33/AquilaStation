/datum/design/integrated_circuit
	name = "Układ scalony"
	desc = "Podstawa wszystkich układów. Na nim montuje się całą elektronikę."
	id = "integrated_circuit"
	build_path = /obj/item/integrated_circuit
	build_type = IMPRINTER | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Multitool do układów"
	desc = "Multitool do układów, którym zaznaczasz obiekty i wczytujesz je do układu."
	id = "circuit_multitool"
	build_path = /obj/item/multitool/circuit
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass = 1000, /datum/material/iron = 1000, /datum/material/copper = 500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/usb_cable
	name = "Kabel USB"
	desc = "Kabel, przez który niektóre powłoki łączą się z pobliskimi komputerami i maszynami."
	id = "usb_cable"
	build_path = /obj/item/usb_cable
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(/datum/material/iron = 1000, /datum/material/copper = 1500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/component
	name = "Komponent ( PUSTY WPIS )"
	desc = "Komponent montowany w układzie scalonym."
	build_type = IMPRINTER | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 500, /datum/material/copper = 1500)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	category = list(WIREMOD_CIRCUITRY)

/datum/design/component/New()
	. = ..()
	if(build_path)
		var/obj/item/circuit_component/component_path = build_path
		desc = initial(component_path.display_desc)

/datum/design/component/arbitrary_input_amount/arithmetic
	name = "Komponent arytmetyczny"
	id = "comp_arithmetic"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/arithmetic
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/arbitrary_input_amount/bitwise
	name = "Komponent bitowy"
	id = "comp_bitwise"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/bitwise
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/bitflag
	name = "Komponent flag bitowych"
	id = "comp_bitflag"
	build_path = /obj/item/circuit_component/compare/bitflag
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/clock
	name = "Komponent zegara"
	id = "comp_clock"
	build_path = /obj/item/circuit_component/clock
	category = list(WIREMOD_CIRCUITRY, WIREMOD_TIME_COMPONENTS)

/datum/design/component/comparison
	name = "Komponent porównania"
	id = "comp_comparison"
	build_path = /obj/item/circuit_component/compare/comparison
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/logic
	name = "Komponent logiczny"
	id = "comp_logic"
	build_path = /obj/item/circuit_component/compare/logic
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/delay
	name = "Komponent opóźnienia"
	id = "comp_delay"
	build_path = /obj/item/circuit_component/delay
	category = list(WIREMOD_CIRCUITRY, WIREMOD_TIME_COMPONENTS)

/datum/design/component/index
	name = "Komponent indeksu"
	id = "comp_index"
	build_path = /obj/item/circuit_component/indexer/index
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/write
	name = "Komponent zapisu"
	id = "comp_write"
	build_path = /obj/item/circuit_component/indexer/write
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/append
	name = "Komponent dołączania"
	id = "comp_append"
	build_path = /obj/item/circuit_component/append
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/pop
	name = "Komponent zdejmowania"
	id = "comp_pop"
	build_path = /obj/item/circuit_component/pop
	category = list(WIREMOD_CIRCUITRY,WIREMOD_LIST_COMPONENTS)

/datum/design/component/length
	name = "Komponent długości"
	id = "comp_length"
	build_path = /obj/item/circuit_component/length
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS, WIREMOD_STRING_COMPONENTS)

/datum/design/component/light
	name = "Komponent światła"
	id = "comp_light"
	build_path = /obj/item/circuit_component/light
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/list_constructor
	name = "Konstruktor listy"
	id = "comp_list_constructor"
	build_path = /obj/item/circuit_component/arbitrary_input_amount/list_constructor
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/list_length_constructor
	name = "Konstruktor listy o długości"
	id = "comp_list_length_constructor"
	build_path = /obj/item/circuit_component/list_length_constructor
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/not
	name = "Komponent negacji"
	id = "comp_not"
	build_path = /obj/item/circuit_component/not
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/ram
	name = "Komponent RAM"
	id = "comp_ram"
	build_path = /obj/item/circuit_component/ram
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MEMORY_COMPONENTS)

/datum/design/component/random
	name = "Komponent losowy"
	id = "comp_random"
	build_path = /obj/item/circuit_component/random
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/round
	name = "Komponent zaokrąglania"
	id = "comp_round"
	build_path = /obj/item/circuit_component/round
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/species
	name = "Komponent rozpoznawania gatunku"
	id = "comp_species"
	build_path = /obj/item/circuit_component/species
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/speech
	name = "Komponent mowy"
	id = "comp_speech"
	build_path = /obj/item/circuit_component/speech
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/tostring
	name = "Komponent konwersji na tekst"
	id = "comp_tostring"
	build_path = /obj/item/circuit_component/tostring
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS, WIREMOD_CONVERSION_COMPONENTS)

/datum/design/component/trig
	name = "Komponent trygonometryczny"
	id = "comp_trig"
	build_path = /obj/item/circuit_component/trig/trig
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/adv_trig
	name = "Zaawansowany komponent trygonometryczny"
	id = "comp_adv_trig"
	build_path = /obj/item/circuit_component/trig/adv_trig
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/hyper_trig
	name = "Komponent funkcji hiperbolicznych"
	id = "comp_hyper_trig"
	build_path = /obj/item/circuit_component/trig/hyper_trig
	category = list(WIREMOD_CIRCUITRY, WIREMOD_MATH_COMPONENTS)

/datum/design/component/typecast
	name = "Komponent rzutowania typu"
	id = "comp_typecast"
	build_path = /obj/item/circuit_component/compare/typecast
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/concat
	name = "Komponent łączenia tekstu"
	id = "comp_concat"
	build_path = /obj/item/circuit_component/concat
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS)

/datum/design/component/textcase
	name = "Komponent wielkości liter"
	id = "comp_textcase"
	build_path = /obj/item/circuit_component/textcase
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS)

/datum/design/component/hear
	name = "Komponent aktywacji głosem"
	id = "comp_hear"
	build_path = /obj/item/circuit_component/hear
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/contains
	name = "Komponent wyszukiwania w tekście"
	id = "comp_string_contains"
	build_path = /obj/item/circuit_component/compare/contains
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS)

/datum/design/component/self
	name = "Komponent własny"
	id = "comp_self"
	build_path = /obj/item/circuit_component/self
	category = list(WIREMOD_CIRCUITRY, WIREMOD_REFERENCE_COMPONENTS)

/datum/design/component/radio
	name = "Komponent radiowy"
	id = "comp_radio"
	build_path = /obj/item/circuit_component/radio
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/gps
	name = "Komponent GPS"
	id = "comp_gps"
	build_path = /obj/item/circuit_component/gps
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/direction
	name = "Komponent kierunku"
	id = "comp_direction"
	build_path = /obj/item/circuit_component/direction
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/health
	name = "Komponent zdrowia"
	id = "comp_health"
	build_path = /obj/item/circuit_component/health
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/combiner
	name = "Komponent łączący"
	id = "comp_combiner"
	build_path = /obj/item/circuit_component/combiner
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/pull
	name = "Komponent ciągnięcia"
	id = "comp_pull"
	build_path = /obj/item/circuit_component/pull
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/soundemitter
	name = "Komponent emitera dźwięku"
	id = "comp_soundemitter"
	build_path = /obj/item/circuit_component/soundemitter
	category = list(WIREMOD_CIRCUITRY, WIREMOD_OUTPUT_COMPONENTS)

/datum/design/component/mmi
	name = "Komponent MMI"
	id = "comp_mmi"
	build_path = /obj/item/circuit_component/mmi
	category = list(WIREMOD_CIRCUITRY, WIREMOD_INPUT_COMPONENTS)

/datum/design/component/multiplexer
	name = "Komponent multipleksera"
	id = "comp_multiplexer"
	build_path = /obj/item/circuit_component/multiplexer
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LOGIC_COMPONENTS)

/datum/design/component/get_column
	name = "Komponent pobierania kolumny"
	id = "comp_get_column"
	build_path = /obj/item/circuit_component/get_column
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/index_table
	name = "Komponent indeksu tabeli"
	id = "comp_index_table"
	build_path = /obj/item/circuit_component/index_table
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/concat_list
	name = "Komponent łączenia listy"
	id = "comp_concat_list"
	build_path = /obj/item/circuit_component/concat_list
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/select_query
	name = "Komponent zapytania"
	id = "comp_select_query"
	build_path = /obj/item/circuit_component/select
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS, WIREMOD_LOGIC_COMPONENTS)

/datum/design/compact_remote_shell
	name = "Powłoka: kompaktowy pilot"
	desc = "Ręczna powłoka z jednym dużym przyciskiem."
	id = "compact_remote_shell"
	build_path = /obj/item/compact_remote
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 5000)
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/controller_shell
	name = "Powłoka: kontroler"
	desc = "Ręczna powłoka z kilkoma przyciskami."
	id = "controller_shell"
	build_path = /obj/item/controller
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 7000)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/scanner_shell
	name = "Powłoka: skaner"
	desc = "Ręczna powłoka ze skanerem."
	id = "scanner_shell"
	build_path = /obj/item/scanner
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 4000, /datum/material/iron = 5000)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/bot_shell
	name = "Powłoka: robot"
	desc = "Nieruchoma powłoka, która mieści więcej komponentów. Ma port USB do łączenia z komputerami i maszynami."
	id = "bot_shell"
	build_path = /obj/item/shell/bot
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/money_bot_shell
	name = "Powłoka: robot finansowy"
	desc = "Nieruchoma powłoka podobna do zwykłej powłoki robota, ale przyjmuje i wydaje pieniądze."
	id = "money_bot_shell"
	build_path = /obj/item/shell/money_bot
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/iron = 10000, /datum/material/gold = 50)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/drone_shell
	name = "Powłoka: dron"
	desc = "Powłoka, która potrafi sama się przemieszczać."
	id = "drone_shell"
	build_path = /obj/item/shell/drone
	build_type = PROTOLATHE | COMPONENT_PRINTER
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 11000,
		/datum/material/gold = 500,
	)
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/server_shell
	name = "Powłoka: serwer"
	desc = "Bardzo duża powłoka, której nie da się przenosić. Mieści najwięcej komponentów."
	id = "server_shell"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
		/datum/material/gold = 1500,
	)
	build_path = /obj/item/shell/server
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/airlock_shell
	name = "Powłoka: śluza"
	desc = "Powłoka w kształcie drzwi, której po złożeniu nie da się przenosić."
	id = "door_shell"
	materials = list(
		/datum/material/glass = 5000,
		/datum/material/iron = 15000,
	)
	build_path = /obj/item/shell/airlock
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/assembly_shell
	name = "Powłoka: zespół modułowy"
	desc = "Powłoka, która działa jak zespół."
	id = "assembly_shell"
	materials = list(
		/datum/material/glass = 2000,
		/datum/material/iron = 5000,
	)
	build_path = /obj/item/assembly/modular
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)
