/datum/design/component/string
	category = list(WIREMOD_CIRCUITRY, WIREMOD_STRING_COMPONENTS)

/datum/design/component/string/tostring
	name = "Komponent: na tekst"
	id = "comp_tostring"
	build_path = /obj/item/circuit_component/tostring

/datum/design/component/string/tonumber
	name = "Komponent: na liczbę"
	id = "comp_tonumber"
	build_path = /obj/item/circuit_component/tonumber

/datum/design/component/string/concat
	name = "Komponent: konkatenacja"
	id = "comp_concat"
	build_path = /obj/item/circuit_component/concat

/datum/design/component/string/textcase
	name = "Komponent: wielkość liter"
	id = "comp_textcase"
	build_path = /obj/item/circuit_component/textcase

/datum/design/component/string/contains
	name = "Komponent: zawieranie tekstu"
	id = "comp_string_contains"
	build_path = /obj/item/circuit_component/compare/contains

/datum/design/component/string/replace
	name = "Komponent: zamiana tekstu"
	id = "comp_replace"
	build_path = /obj/item/circuit_component/compare/contains/replace
