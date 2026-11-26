// AQUILA - Premia wzrostu od dwutlenku węgla (plan maszynowni E11).
// Owoce rosną półtora raza szybciej, gdy w powietrzu rośliny jest 1–10 kPa CO2 (szklarnia albo kapsuła ksenoflory).
// Przy szybszym wzroście roślina tak samo szybciej zużywa wodę i odżywki. Na statku CO2 w powietrzu prawie nie ma,
// więc zwykłe uprawy się nie zmieniają; za dużo CO2 (powyżej 10 kPa) premii nie daje.

/// Od tylu kPa CO2 rośliny rosną szybciej
#define PLANT_CO2_MIN_KPA 1
/// Do tylu kPa CO2 rośliny rosną szybciej
#define PLANT_CO2_MAX_KPA 10
/// Mnożnik wzrostu w dobrym stężeniu CO2
#define PLANT_CO2_GROWTH_MULT 1.5

/datum/plant_feature/fruit/process(delta_time)
	return ..(delta_time * get_co2_growth_multiplier())

/// Mnożnik wzrostu z ciśnienia cząstkowego CO2 w powietrzu rośliny
/datum/plant_feature/fruit/proc/get_co2_growth_multiplier()
	var/atom/holder = parent?.plant_item?.loc
	if(!holder)
		return 1
	var/datum/gas_mixture/air
	if(istype(holder, /obj/machinery/atmospherics/components/binary/xenoflora_pod))
		var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = holder
		air = pod.get_plant_air()
	else
		var/turf/plant_turf = get_turf(holder)
		air = plant_turf?.return_air()
	var/total_moles = air?.total_moles()
	if(!total_moles)
		return 1
	var/co2_kpa = air.return_pressure() * air.get_moles(GAS_CO2) / total_moles
	if(co2_kpa < PLANT_CO2_MIN_KPA || co2_kpa > PLANT_CO2_MAX_KPA)
		return 1
	return PLANT_CO2_GROWTH_MULT

#undef PLANT_CO2_MIN_KPA
#undef PLANT_CO2_MAX_KPA
#undef PLANT_CO2_GROWTH_MULT
