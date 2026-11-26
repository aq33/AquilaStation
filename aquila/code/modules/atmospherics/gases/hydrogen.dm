// AQUILA - Wodór (plan maszynowni E6). Paliwo: pali się w ogólnym spalaniu (genericfire) do pary wodnej,
// ciepło daje entalpia tworzenia wody (241,8 kJ na mol). Powstaje w elektrolizerze z pary wodnej.

/datum/gas/hydrogen
	id = GAS_H2
	specific_heat = 15
	name = "Wodór"
	flags = GAS_FLAG_DANGEROUS
	fire_products = list(GAS_H2O = 1)
	fire_burn_rate = 2 // 2 H2 + O2 -> 2 H2O
	fire_temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	enthalpy = 0 // pierwiastek
	price = 1

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "kanister z wodorem"
	desc = "Wodór. Lekki, palny i w dużych ilościach bardzo głośny."
	gas_type = GAS_H2
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#d0d2a0#ffffff"
