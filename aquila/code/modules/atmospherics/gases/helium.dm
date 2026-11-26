// AQUILA - Hel (plan maszynowni E17). Obojętny produkt fuzji w reaktorze HFR (paliwa z trytem), dane jak w tg.
// Nie pali się i nie reaguje. Dobre chłodziwo moderatora: lekki i obojętny.

/datum/gas/helium
	id = GAS_HELIUM
	specific_heat = 15
	name = "Hel"
	price = 3

/obj/machinery/portable_atmospherics/canister/helium
	name = "kanister z helem"
	desc = "Hel. Obojętny gaz z reakcji fuzji, nadaje się do balonów i chłodzenia."
	gas_type = GAS_HELIUM
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#9b5d7f#e0e0ff"
