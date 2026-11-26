// AQUILA - Spalanie gazów liczone w DM tak samo jak w auxmos.
// auxmos.dll (Windows) ma feature citadel_reactions i liczy genericfire w Rust (src/reaction/citadel.rs, generic_fire()).
// libauxmos.so (serwer, CI) go nie ma, więc tę samą reakcję liczyło DM, ale inaczej: odwrócone progi temperatury,
// bez FIRE_MAXIMUM_BURN_RATE i bez entalpii produktów. Ten plik to wierne przepisanie wersji z Rust (auxmos v2.5.2-b),
// żeby nowe paliwa (wodór, metan) grzały tak samo na obu systemach. Test: aquila/code/modules/unit_tests/aquila_generic_fire.dm
// Pełne nadpisanie bez ..(): wpis w aquila/LEGACY_OVERRIDES.md.

/// Odpowiednik GAS_MIN_MOLES z auxmos (src/gas/constants.rs)
#define AQ_FIRE_GAS_MIN_MOLES 0.0001
/// Odpowiednik FIRE_MAXIMUM_BURN_RATE z auxmos
#define AQ_FIRE_MAXIMUM_BURN_RATE 0.2
/// Odpowiednik SUPER_SATURATION_THRESHOLD z auxmos (plazma daje tryt zamiast CO2)
#define AQ_FIRE_SUPER_SATURATION_THRESHOLD 96

/datum/gas_reaction/genericfire/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	if(temperature <= 0)
		return NO_REACTION
	var/datum/auxgm/gas_data = GLOB.gas_data
	var/list/oxidation_temps = gas_data.oxidation_temperatures
	var/list/oxidation_rates = gas_data.oxidation_rates
	var/list/fuel_temps = gas_data.fire_temperatures
	var/list/fuel_rates = gas_data.fire_burn_rates

	// get_fire_info_with_lock(): ile każdego gazu bierze udział i ile mocy daje
	var/list/oxidizers = list()
	var/list/fuels = list()
	var/oxidation_power = 0
	var/total_fuel = 0
	for(var/gas in air.get_gases())
		var/moles = air.get_moles(gas)
		if(moles <= AQ_FIRE_GAS_MIN_MOLES)
			continue
		var/oxidation_temp = oxidation_temps[gas]
		if(!isnull(oxidation_temp))
			if(temperature > oxidation_temp)
				var/amount = moles * max(0, 1 - oxidation_temp / temperature)
				oxidizers[gas] = amount
				oxidation_power += amount * oxidation_rates[gas]
			continue
		var/fuel_temp = fuel_temps[gas]
		if(!isnull(fuel_temp) && temperature > fuel_temp)
			var/amount = moles * max(0, 1 - fuel_temp / temperature)
			fuels[gas] = amount
			total_fuel += amount / fuel_rates[gas]
	if(oxidation_power < AQ_FIRE_GAS_MIN_MOLES || total_fuel <= AQ_FIRE_GAS_MIN_MOLES)
		return NO_REACTION

	var/oxidation_ratio = oxidation_power / total_fuel
	if(oxidation_ratio > 1)
		for(var/gas in oxidizers)
			oxidizers[gas] /= oxidation_ratio
	else
		for(var/gas in fuels)
			fuels[gas] *= oxidation_ratio

	var/list/datums = gas_data.datums
	var/list/burn_results = list()
	var/radiation_released = 0
	for(var/gas in oxidizers + fuels)
		var/amount = AQ_FIRE_MAXIMUM_BURN_RATE * (oxidizers[gas] || fuels[gas])
		var/datum/gas/gas_datum = datums[gas]
		radiation_released += amount * gas_datum.fire_radiation_released
		var/products = gas_datum.fire_products
		if(islist(products))
			for(var/product in products)
				burn_results[product] += products[product] * amount
		else if(isnum(products))
			burn_results[oxidation_ratio > AQ_FIRE_SUPER_SATURATION_THRESHOLD ? GAS_TRITIUM : GAS_CO2] += amount
		burn_results[gas] -= amount
	var/fire_amount = min(oxidation_power, total_fuel) * 2 * AQ_FIRE_MAXIMUM_BURN_RATE

	// Bilans Hessa: energia wewnętrzna + PV przed reakcją, minus entalpia tworzenia tego, co przybyło
	var/initial_enthalpy = temperature * (air.heat_capacity() + R_IDEAL_GAS_EQUATION * air.total_moles())
	var/delta_enthalpy = 0
	for(var/gas in burn_results)
		var/change = burn_results[gas]
		air.adjust_moles(gas, change)
		var/datum/gas/gas_datum = datums[gas]
		delta_enthalpy -= change * gas_datum.enthalpy
	var/final_capacity = air.heat_capacity() + R_IDEAL_GAS_EQUATION * air.total_moles()
	if(final_capacity > 0)
		air.set_temperature((initial_enthalpy + delta_enthalpy) / final_capacity)
	temperature = air.return_temperature()

	air.reaction_results["fire"] = fire_amount
	if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		fire_expose(holder, air, temperature)
	if(radiation_released > 0)
		radiation_burn(holder, radiation_released)
	return fire_amount > 0 ? REACTING : NO_REACTION

#undef AQ_FIRE_GAS_MIN_MOLES
#undef AQ_FIRE_MAXIMUM_BURN_RATE
#undef AQ_FIRE_SUPER_SATURATION_THRESHOLD

// Plazma i tryt palą się tylko w swoich reakcjach (plasmafire, tritfire). Z fire_temperature spalał je też genericfire,
// na Windows (Rust) od zawsze, a na serwerze dopiero po tej poprawce: pożary plazmy byłyby gorętsze niż dotąd.
// Bez fire_temperature ani Rust, ani DM nie biorą ich do genericfire. Zapłon od iskry sprawdza je w LINDA_fire.dm wprost.
/datum/gas/plasma
	fire_temperature = null

/datum/gas/tritium
	fire_temperature = null

/// AQUILA - Ile moli paliwa (każdego gazu z fire_temperature) może zapłonąć w tej temperaturze.
/// Zastępuje w LINDA_fire.dm sztywne sprawdzanie samej plazmy i trytu, więc wodór czy metan zapalą się od iskry.
/datum/gas_mixture/proc/aq_fire_fuel_moles(temperature)
	. = 0
	var/list/fuel_temps = GLOB.gas_data.fire_temperatures
	for(var/gas in fuel_temps)
		if(gas == GAS_N2)
			continue // azot w core ma fire_temperature 2300 K, ale bez produktów i entalpii: nie może sam podtrzymać ognia w powietrzu
		if(fuel_temps[gas] < temperature)
			. += get_moles(gas)
