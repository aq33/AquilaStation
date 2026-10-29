/datum/design/component/utility
	category = list(WIREMOD_CIRCUITRY, WIREMOD_UTILITY_COMPONENTS)

/datum/design/component/utility/router
	name = "Komponent: router"
	id = "comp_router"
	build_path = /obj/item/circuit_component/router

/datum/design/component/utility/multiplexer
	name = "Komponent: multiplekser"
	id = "comp_multiplexer"
	build_path = /obj/item/circuit_component/router/multiplexer

/datum/design/component/utility/typecast
	name = "Komponent: rzutowanie typu"
	id = "comp_typecast"
	build_path = /obj/item/circuit_component/typecast

/datum/design/component/utility/clock
	name = "Komponent: zegar"
	id = "comp_clock"
	build_path = /obj/item/circuit_component/clock

/datum/design/component/utility/delay
	name = "Komponent: opóźnienie"
	id = "comp_delay"
	build_path = /obj/item/circuit_component/delay

/datum/design/component/utility/timepiece
	name = "Komponent: czasomierz"
	id = "comp_timepiece"
	build_path = /obj/item/circuit_component/timepiece

/datum/design/component/utility/typecheck
	name = "Komponent: sprawdzanie typu"
	id = "comp_typecheck"
	build_path = /obj/item/circuit_component/compare/typecheck

/datum/design/component/utility/wire_bundle
	name = "Komponent: wiązka przewodów"
	id = "comp_wire_bundle"
	build_path = /obj/item/circuit_component/wire_bundle

/datum/design/component/utility/setter_trigger
	name = "Komponent: ustawianie zmiennej z wyzwalaczem"
	id = "comp_setter_trigger"
	build_path = /obj/item/circuit_component/variable/setter/trigger
