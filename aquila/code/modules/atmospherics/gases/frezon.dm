// AQUILA - Frezon (plan maszynowni E7), port z Space Station 14 (Content.Server/Atmos/Reactions/FrezonProductionReaction.cs,
// FrezonCoolantReaction.cs, stałe z Content.Shared/Atmos/Atmospherics.cs, MIT). Jedyne chłodziwo w grze: freonu z tg nie portujemy.
// Powstaje z tlenu i trytu w zimnie (poniżej 73,15 K), azot jest katalizatorem. Z azotem rozpada się na podtlenek azotu
// i pochłania 600 kJ na mol, mocniej w gorącu. Różnice względem SS14: bez heatScale (nasze reakcje liczą jeden tik).

/// Powyżej tej temperatury frezon nie powstaje, a w niej powstaje najwydajniej
#define FREZON_PRODUCTION_MAX_EFFICIENCY_TEMPERATURE 73.15
/// Ile moli tlenu na mol azotu (katalizatora) przy pełnej wydajności
#define FREZON_PRODUCTION_NITROGEN_RATIO 10
/// Ile moli tlenu idzie na mol trytu
#define FREZON_PRODUCTION_TRIT_RATIO 50
/// Jaka część reagującego tlenu i trytu przechodzi w frezon w jednym tiku (1/X)
#define FREZON_PRODUCTION_CONVERSION_RATE 50
/// Poniżej tej temperatury frezon nie chłodzi
#define FREZON_COOL_LOWER_TEMPERATURE 23.15
/// Od tej temperatury frezon zużywa się najszybciej, dalej rośnie już tylko chłodzenie
#define FREZON_COOL_MID_TEMPERATURE 373.15
/// Najwyżej tyle razy mocniej chłodzi w bardzo gorącym miejscu
#define FREZON_COOL_MAXIMUM_ENERGY_MODIFIER 10
/// Ile moli azotu zużywa mol frezonu
#define FREZON_NITROGEN_COOL_RATIO 5
/// Energia na zużyty mol frezonu (J, ujemna = chłodzi)
#define FREZON_COOL_ENERGY_RELEASED -600000
/// Jaka część frezonu zużywa się w jednym tiku (1/X)
#define FREZON_COOL_RATE_MODIFIER 20
/// Poniżej tej pojemności cieplnej (i tej ilości zużycia) reakcja nic nie robi, jak MinimumHeatCapacity w SS14
#define FREZON_MINIMUM_HEAT_CAPACITY 0.0003

/datum/gas/frezon
	id = GAS_FREZON
	specific_heat = 600 // najmocniejsze chłodziwo
	name = "Frezon"
	gas_overlay = "freon"
	color = "#3a758c"
	moles_visible = MOLES_GAS_VISIBLE * 2.4
	flags = GAS_FLAG_DANGEROUS
	breath_reagent = /datum/reagent/frezon
	price = 1

/datum/gas_reaction/frezon_production
	priority = 2
	name = "Powstawanie frezonu"
	id = "frezon_production"

/datum/gas_reaction/frezon_production/init_reqs()
	min_requirements = list(
		GAS_O2 = 0.01,
		GAS_N2 = 0.01,
		GAS_TRITIUM = 0.01,
		"MAX_TEMP" = FREZON_PRODUCTION_MAX_EFFICIENCY_TEMPERATURE
	)

/datum/gas_reaction/frezon_production/react(datum/gas_mixture/air, datum/holder)
	var/efficiency = air.return_temperature() / FREZON_PRODUCTION_MAX_EFFICIENCY_TEMPERATURE
	if(efficiency <= 0)
		return NO_REACTION
	var/loss = 1 - efficiency
	// Azot pozwala na tyle tlenu; przy wyższej wydajności potrzeba go mniej
	var/catalyst_limit = air.get_moles(GAS_N2) * (FREZON_PRODUCTION_NITROGEN_RATIO / efficiency)
	var/oxygen_limit = min(air.get_moles(GAS_O2), catalyst_limit) / FREZON_PRODUCTION_TRIT_RATIO
	var/tritium_burned = min(oxygen_limit, air.get_moles(GAS_TRITIUM))
	var/oxygen_burned = tritium_burned * FREZON_PRODUCTION_TRIT_RATIO
	var/oxygen_conversion = oxygen_burned / FREZON_PRODUCTION_CONVERSION_RATE
	var/tritium_conversion = tritium_burned / FREZON_PRODUCTION_CONVERSION_RATE
	var/total = oxygen_conversion + tritium_conversion
	if(total <= 0)
		return NO_REACTION
	air.adjust_moles(GAS_O2, -oxygen_conversion)
	air.adjust_moles(GAS_TRITIUM, -tritium_conversion)
	air.adjust_moles(GAS_FREZON, total * efficiency)
	air.adjust_moles(GAS_N2, total * loss)
	return REACTING

/datum/gas_reaction/frezon_coolant
	priority = 1
	name = "Chłodzenie frezonem"
	id = "frezon_coolant"

/datum/gas_reaction/frezon_coolant/init_reqs()
	min_requirements = list(
		GAS_N2 = 0.01,
		GAS_FREZON = 0.01,
		"TEMP" = FREZON_COOL_LOWER_TEMPERATURE
	)

/datum/gas_reaction/frezon_coolant/react(datum/gas_mixture/air, datum/holder)
	var/old_heat_capacity = air.heat_capacity()
	var/temperature = air.return_temperature()
	var/energy_modifier = 1
	var/scale = (temperature - FREZON_COOL_LOWER_TEMPERATURE) / (FREZON_COOL_MID_TEMPERATURE - FREZON_COOL_LOWER_TEMPERATURE)
	if(scale > 1)
		// W bardzo gorącym miejscu rośnie chłodzenie, a nie zużycie frezonu
		energy_modifier = min(scale, FREZON_COOL_MAXIMUM_ENERGY_MODIFIER)
		scale = 1
	if(scale <= 0)
		return NO_REACTION
	var/frezon = air.get_moles(GAS_FREZON)
	var/burn_rate = frezon * scale / FREZON_COOL_RATE_MODIFIER
	if(burn_rate <= FREZON_MINIMUM_HEAT_CAPACITY)
		return NO_REACTION
	var/nitrogen_used = min(burn_rate * FREZON_NITROGEN_COOL_RATIO, air.get_moles(GAS_N2))
	var/frezon_used = min(burn_rate, frezon)
	air.adjust_moles(GAS_N2, -nitrogen_used)
	air.adjust_moles(GAS_FREZON, -frezon_used)
	air.adjust_moles(GAS_NITROUS, nitrogen_used + frezon_used)
	var/energy_released = burn_rate * FREZON_COOL_ENERGY_RELEASED * energy_modifier
	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity > FREZON_MINIMUM_HEAT_CAPACITY)
		air.set_temperature(max((temperature * old_heat_capacity + energy_released) / new_heat_capacity, TCMB))
	return REACTING

/// Wdychany frezon: zimno w płucach, tęcza przed oczami i upojenie, z lekkimi uszkodzeniami komórek (SS14)
/datum/reagent/frezon
	name = "Frezon"
	description = "Bardzo zimny gaz chłodniczy. Wdychany uszkadza komórki, ale daje euforię."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // jak nitryl: przychodzi z oddechem, więc schodzi wolniej
	color = "#3a758c"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "gorycz i mróz"

/datum/reagent/frezon/on_mob_life(mob/living/carbon/M)
	M.adjustCloneLoss(0.5, FALSE)
	M.set_drugginess(15)
	M.drunkenness = max(M.drunkenness, 15)
	if(prob(10))
		to_chat(M, span_notice(pick("Czujesz zimno w płucach.", "Ogarnia cię dziwna euforia.")))
	..()
	return TRUE

/obj/machinery/portable_atmospherics/canister/frezon
	name = "kanister z frezonem"
	desc = "Frezon. Chłodzi wszystko, czego dotknie, z azotem nawet za mocno."
	gas_type = GAS_FREZON
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#3a758c#b8e6f0"

#undef FREZON_PRODUCTION_MAX_EFFICIENCY_TEMPERATURE
#undef FREZON_PRODUCTION_NITROGEN_RATIO
#undef FREZON_PRODUCTION_TRIT_RATIO
#undef FREZON_PRODUCTION_CONVERSION_RATE
#undef FREZON_COOL_LOWER_TEMPERATURE
#undef FREZON_COOL_MID_TEMPERATURE
#undef FREZON_COOL_MAXIMUM_ENERGY_MODIFIER
#undef FREZON_NITROGEN_COOL_RATIO
#undef FREZON_COOL_ENERGY_RELEASED
#undef FREZON_COOL_RATE_MODIFIER
#undef FREZON_MINIMUM_HEAT_CAPACITY
