// AQUILA - Ciecze: pola reagentów z Monkestation 2.0 (code/modules/reagents/chemistry/reagents.dm) i nasze zamarzanie.

/datum/reagent
	/// Czy paruje z płytkiej kałuży
	var/evaporates = TRUE
	/// Ile jednostek odparowuje na jedno wywołanie parowania
	var/evaporation_rate = 1
	/// Moc ognia w kałuży. Zero = liczona z accelerant_quality (patrz get_liquid_fire_power)
	var/liquid_fire_power = 0
	/// Krycie kałuży (alfa), uśredniane po objętości
	var/opacity = 175
	/// Czy kałuża z tym reagentem jest śliska (tylko w sprincie)
	var/slippery = TRUE
	/// Czy reagent ma reakcję z podłogą pod kałużą (np. krew robi plamę, termit pali podłogę)
	var/turf_exposure = FALSE
	/// Temperatura zamarzania w kałuży (K). null = nie zamarza
	var/freezing_point = null

/// Wołane przy parowaniu z kałuży
/datum/reagent/proc/evaporate(turf/exposed_turf, reac_volume)
	return

/// Moc ognia na jednostkę w kałuży. Domyślnie z accelerant_quality molotowów (Yogstation #19738), żeby nie dublować wpisów.
/datum/reagent/proc/get_liquid_fire_power()
	if(liquid_fire_power)
		return liquid_fire_power
	return accelerant_quality * 2.5

/// Alkohole palą się według mocy: czysty etanol 10, wódka 6, piwo 2 (nie pali się, bo próg to 5 na jednostkę)
/datum/reagent/consumable/ethanol/get_liquid_fire_power()
	if(liquid_fire_power)
		return liquid_fire_power
	if(type == /datum/reagent/consumable/ethanol)
		return 10
	return round(boozepwr / 10)

/datum/reagent/oil
	liquid_fire_power = 15

// Reakcje z podłogą pod kałużą (lista z Monke, bez reagentów, których nie mamy). Termit i ClF3 wypadły:
// reagowały co cykl bez zużycia (termit narastał na każdym kaflu, ClF3 bez końca dziurawił pokład), a z podłogą reagują raz przy rozlaniu.
/datum/reagent/blood
	turf_exposure = TRUE
	opacity = 230
	freezing_point = T0C - 1

/datum/reagent/water
	freezing_point = T0C
	evaporation_rate = 2

/datum/reagent/water/holywater
	turf_exposure = TRUE

/datum/reagent/lube
	turf_exposure = TRUE

/datum/reagent/space_cleaner
	turf_exposure = TRUE

/datum/reagent/carpet
	turf_exposure = TRUE

/datum/reagent/drying_agent
	turf_exposure = TRUE

/datum/reagent/metalgen
	turf_exposure = TRUE

/datum/reagent/cryostylane
	turf_exposure = TRUE

/datum/reagent/firefighting_foam
	turf_exposure = TRUE

/datum/reagent/consumable/frostoil
	turf_exposure = TRUE

/datum/reagent/consumable/nutriment/fat/oil
	turf_exposure = TRUE

// Zamarzanie: napoje i jedzenie w płynie to głównie woda, alkohole zamarzają tym niżej, im są mocniejsze
/datum/reagent/consumable
	freezing_point = T0C - 2

/datum/reagent/consumable/ethanol
	freezing_point = T0C - 114

/datum/reagent/consumable/ethanol/New()
	. = ..()
	if(type != /datum/reagent/consumable/ethanol && freezing_point == T0C - 114)
		freezing_point = T0C - round(boozepwr * 0.5)

/datum/reagent/consumable/nutriment/fat/oil
	freezing_point = T0C - 10
