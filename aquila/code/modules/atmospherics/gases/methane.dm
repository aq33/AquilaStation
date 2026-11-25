// AQUILA - Metan (plan maszynowni E8), dane z Shiptest (code/modules/atmospherics/auxgm/gas_types.dm).
// Paliwo: pali się w ogólnym spalaniu (CH4 + 2 O2 -> CO2 + 2 H2O), około 802 kJ na mol z bilansu entalpii.
// Źródła: bańki gazu bagiennego na planetach dżungli (aquila/code/modules/planets/swamp_gas.dm) i metanowy olbrzym.
// Metan z odpływów i sedesów dojdzie z biogazownią (osobny PR).

/datum/gas/methane
	id = GAS_METHANE
	specific_heat = 35
	name = "Metan"
	flags = GAS_FLAG_DANGEROUS
	fire_products = list(GAS_H2O = 2, GAS_CO2 = 1)
	enthalpy = -74600 // entalpia tworzenia, ciepło spalania daje bilans z produktami
	fire_burn_rate = 0.5 // jeden mol metanu na dwa mole tlenu
	fire_temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 50
	price = 1

/obj/machinery/portable_atmospherics/canister/methane
	name = "kanister z metanem"
	desc = "Metan. Pali się czysto i nie zostawia sadzy. Trzymać z dala od iskier."
	gas_type = GAS_METHANE
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#c8a060#5a4a2a"
