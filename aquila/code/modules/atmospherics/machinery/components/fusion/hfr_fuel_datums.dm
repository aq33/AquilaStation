///Global list of recipes for atmospheric machines to use
GLOBAL_LIST_INIT(hfr_fuels_list, hfr_fuels_create_list())

/*
 * Global proc to build the gas recipe global list
 */
/proc/hfr_fuels_create_list()
	. = list()
	for(var/fuel_mix_path in subtypesof(/datum/hfr_fuel))
		var/datum/hfr_fuel/fuel_mix = new fuel_mix_path()

		.[fuel_mix.id] = fuel_mix

/datum/hfr_fuel
	///Id for the mix
	var/id = ""
	///The gases that are going to be used as fuel ("GasX + GasY fuel")
	var/name = ""
	///Multiplier for the minimum heat output of the HFR (min 0.01)
	var/negative_temperature_multiplier = 1
	///Multiplier for the maximum heat output of the HFR (min 0.01)
	var/positive_temperature_multiplier = 1
	///Multiplier for the energy released (min 0.01)
	var/energy_concentration_multiplier = 1
	///Multiplier for the fuel consumption (min 0.01)
	var/fuel_consumption_multiplier = 1
	///Multiplier for the gas production (min 0.01)
	var/gas_production_multiplier = 1
	///Max allowed temperature multiplier, scales the max temperature we can hit, see FUSION_MAXIMUM_TEMPERATURE (Maxed at 1, don't go getting any ideas)
	var/temperature_change_multiplier = 1
	///These are the main fuels, only 2 gases that are the ones being consumed by the fusion reaction (eg. H2 and trit)
	var/requirements = list()
	///Gases that gets produced directly in the internal gasmix
	var/primary_products = list()
	///Gases that gets produced in the moderator gasmix or directly ejected (must be 6 gases), the order indicate at what power level the gases are going to be made (from power level 1 to 6)
	var/secondary_products = list()
	///Flags to decide what behaviour the meltdown will have depending on the fuel mix used
	var/meltdown_flags = HYPERTORUS_FLAG_BASE_EXPLOSION

/datum/hfr_fuel/New()
	. = ..()
	temperature_change_multiplier = min(temperature_change_multiplier, 1)

// AQUILA: tylko trzy paliwa z planu maszynowni (D10, HFR okrojony). Wartości i hel w produktach jak w tg,
// produkty egzotyczne (freon, halon, hiper-noblium) zamienione na nasze gazy: frezon, BZ, pluoksium.
/datum/hfr_fuel/plasma_oxy_fuel
	id = "plasma_o2_fuel"
	name = "Plazma + tlen"
	negative_temperature_multiplier = 2.5
	positive_temperature_multiplier = 0.1
	energy_concentration_multiplier = 10
	fuel_consumption_multiplier = 3.3
	gas_production_multiplier = 1.4
	temperature_change_multiplier = 0.6
	requirements = list(GAS_PLASMA, GAS_O2)
	primary_products = list(GAS_CO2, GAS_H2O)
	secondary_products = list(GAS_CO2, GAS_H2O, GAS_FREZON, GAS_NITROUS, GAS_PLUOXIUM, GAS_BZ)
	meltdown_flags = HYPERTORUS_FLAG_BASE_EXPLOSION | HYPERTORUS_FLAG_MINIMUM_SPREAD

/datum/hfr_fuel/tritium_oxy_fuel
	id = "t2_o2_fuel"
	name = "Tryt + tlen"
	negative_temperature_multiplier = 2.1
	positive_temperature_multiplier = 0.5
	energy_concentration_multiplier = 2
	fuel_consumption_multiplier = 1.2
	gas_production_multiplier = 0.8
	temperature_change_multiplier = 0.8
	requirements = list(GAS_TRITIUM, GAS_O2)
	primary_products = list(GAS_HELIUM, GAS_PLUOXIUM)
	secondary_products = list(GAS_HELIUM, GAS_PLASMA, GAS_O2, GAS_N2, GAS_BZ, GAS_PLUOXIUM)
	meltdown_flags = HYPERTORUS_FLAG_BASE_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_MEDIUM_SPREAD

/datum/hfr_fuel/hydrogen_tritium_fuel
	id = "h2_t2_fuel"
	name = "Wodór + tryt"
	negative_temperature_multiplier = 1
	positive_temperature_multiplier = 1
	energy_concentration_multiplier = 1
	fuel_consumption_multiplier = 1
	gas_production_multiplier = 1
	temperature_change_multiplier = 0.85
	requirements = list(GAS_H2, GAS_TRITIUM)
	primary_products = list(GAS_HELIUM)
	secondary_products = list(GAS_HELIUM, GAS_PLASMA, GAS_O2, GAS_N2, GAS_BZ, GAS_PLUOXIUM)
	meltdown_flags = HYPERTORUS_FLAG_MEDIUM_EXPLOSION | HYPERTORUS_FLAG_RADIATION_PULSE | HYPERTORUS_FLAG_EMP | HYPERTORUS_FLAG_MEDIUM_SPREAD
