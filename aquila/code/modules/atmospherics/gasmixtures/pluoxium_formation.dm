// Powstawanie pluoxium z tg (pluox_formation) w miejsce starego /turf/open/rad_act.
// Po porcie promieniowania z BeeStation/BeeStation-Hornet#13442 impulsy nie działają już na gaz,
// a pluoxium (paliwo i modyfikator stormdrive, katalizator nitrylu) musi skądś się brać.
// Zimna mieszanka CO2 i tlenu z odrobiną trytu zamienia się w pluoxium.

/// Najniższa temperatura reakcji
#define PLUOXIUM_FORMATION_MIN_TEMP 50
/// Najwyższa temperatura reakcji
#define PLUOXIUM_FORMATION_MAX_TEMP T0C
/// Najwięcej moli pluoxium na reakcję (na kafelek/mieszaninę na tyknięcie atmosu)
#define PLUOXIUM_FORMATION_MAX_RATE 1
/// Energia wydzielana na mol pluoxium
#define PLUOXIUM_FORMATION_ENERGY 250

/datum/gas_reaction/pluox_formation
	priority = 8
	name = "Powstawanie pluoksium"
	id = "pluox_formation"

/datum/gas_reaction/pluox_formation/init_reqs()
	min_requirements = list(
		GAS_CO2 = MINIMUM_MOLE_COUNT,
		GAS_O2 = MINIMUM_MOLE_COUNT,
		GAS_TRITIUM = MINIMUM_MOLE_COUNT,
		"TEMP" = PLUOXIUM_FORMATION_MIN_TEMP,
	)

/datum/gas_reaction/pluox_formation/react(datum/gas_mixture/air, datum/holder)
	var/temperature = air.return_temperature()
	if(temperature > PLUOXIUM_FORMATION_MAX_TEMP)
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	var/produced_amount = min(PLUOXIUM_FORMATION_MAX_RATE, air.get_moles(GAS_CO2), air.get_moles(GAS_O2) * 2, air.get_moles(GAS_TRITIUM) * 100)
	if(produced_amount <= 0)
		return NO_REACTION

	air.adjust_moles(GAS_CO2, -produced_amount)
	air.adjust_moles(GAS_O2, -produced_amount * 0.5)
	air.adjust_moles(GAS_TRITIUM, -produced_amount * 0.01)
	air.adjust_moles(GAS_PLUOXIUM, produced_amount)

	var/energy_released = produced_amount * PLUOXIUM_FORMATION_ENERGY
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air.set_temperature(max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB))
	return REACTING

#undef PLUOXIUM_FORMATION_MIN_TEMP
#undef PLUOXIUM_FORMATION_MAX_TEMP
#undef PLUOXIUM_FORMATION_MAX_RATE
#undef PLUOXIUM_FORMATION_ENERGY
