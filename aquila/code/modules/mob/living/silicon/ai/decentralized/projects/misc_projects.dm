// coolant_manager.dm, cryptominer.dm, memory_compressor.dm, quick_shuttle.dm, research_booster.dm i rgb.dm z Monke

/datum/ai_project/coolant_manager
	name = "Lepsze zarządzanie chłodzeniem"
	description = "Optymalizacja chłodzenia sprzętu podnosi dopuszczalną temperaturę maszyn SI o 10 stopni."
	category = AI_PROJECT_EFFICIENCY
	research_cost = 2250
	can_be_run = FALSE

/datum/ai_project/coolant_manager/finish()
	var/datum/ai_os/os_used = ai.get_ai_os()
	if(os_used?.temp_limit == AI_TEMP_LIMIT) //Limit to only 1 AI doing it.
		os_used.temp_limit += 10

/datum/ai_project/crypto_miner
	name = "Koparka kryptowalut"
	description = "Połowa wolnego CPU kopie kryptowaluty dla budżetu zaopatrzenia. Zmniejsza o połowę generowanie punktów badań SI."
	category = AI_PROJECT_MISC
	research_cost = 2000

/datum/ai_project/crypto_miner/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	dashboard.crypto_mining = TRUE

/datum/ai_project/crypto_miner/stop()
	dashboard.crypto_mining = FALSE
	return ..()

/datum/ai_project/memory_compressor
	name = "Kompresja pamięci"
	description = "Zaawansowana kompresja pamięci jądra daje 3 TB RAM więcej. Zajmuje 15% CPU."
	category = AI_PROJECT_EFFICIENCY
	research_cost = 2250

/datum/ai_project/memory_compressor/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	dashboard.free_ram += 3
	dashboard.cpu_usage[name] = 0.15

/datum/ai_project/memory_compressor/stop()
	if(running)
		dashboard.free_ram -= 3
		dashboard.cpu_usage[name] = 0
	return ..()

/datum/ai_project/memory_compressor/canRun()
	. = ..()
	if(!.)
		return
	var/total_cpu_used = 0
	for(var/I in dashboard.cpu_usage)
		total_cpu_used += dashboard.cpu_usage[I]
	if(total_cpu_used < 0.85)
		return TRUE
	to_chat(ai, span_warning("Nie można uruchomić. Potrzeba 15% wolnego CPU!"))
	return FALSE

/datum/ai_project/quick_shuttle
	name = "Optymalizacja nawigacji promu zaopatrzenia"
	description = "Liczenie trasy promu zaopatrzenia algorytmem A* skraca jego lot o 20%."
	research_cost = 2500
	ram_required = 4
	category = AI_PROJECT_MISC
	/// Mutiplier to how fast the supply shuttle is while the program is active.
	var/shuttle_speed = 0.8
	/// Czy to my skróciliśmy lot (tylko jedna SI naraz)
	var/applied = FALSE

/datum/ai_project/quick_shuttle/canRun()
	. = ..()
	if(!.)
		return
	if(!SSshuttle.supply)
		to_chat(ai, span_warning("Nie wykryto promu zaopatrzenia."))
		return FALSE
	if(GLOB.ai_supply_shuttle_boosted)
		to_chat(ai, span_warning("Inna SI już optymalizuje trasę promu."))
		return FALSE

/datum/ai_project/quick_shuttle/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	SSshuttle.supply.callTime *= shuttle_speed
	GLOB.ai_supply_shuttle_boosted = TRUE
	applied = TRUE

/datum/ai_project/quick_shuttle/stop()
	if(applied && SSshuttle.supply)
		SSshuttle.supply.callTime /= shuttle_speed
		GLOB.ai_supply_shuttle_boosted = FALSE
	applied = FALSE
	return ..()

GLOBAL_VAR_INIT(ai_supply_shuttle_boosted, FALSE)
///Which AI project is boosting the research servers (+20% general research income)
GLOBAL_DATUM(ai_research_booster, /datum/ai_project/research_booster)

/datum/ai_project/research_booster
	name = "Przyspieszenie badań"
	description = "Szybki RAM zamiast wolnych dysków daje serwerom badań około 20% więcej punktów."
	research_cost = 2500
	ram_required = 8
	category = AI_PROJECT_MISC

/datum/ai_project/research_booster/Destroy()
	if(GLOB.ai_research_booster == src)
		GLOB.ai_research_booster = null
	return ..()

/datum/ai_project/research_booster/canRun()
	. = ..()
	if(!.)
		return
	if(!length(SSresearch.servers))
		to_chat(ai, span_warning("Nie znaleziono serwerów badań."))
		return FALSE
	if(GLOB.ai_research_booster && GLOB.ai_research_booster != src)
		to_chat(ai, span_warning("Inna sztuczna inteligencja już przyspiesza sieć badań; pomijam zbędne przetwarzanie."))
		return FALSE

/datum/ai_project/research_booster/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	GLOB.ai_research_booster = src

/datum/ai_project/research_booster/stop()
	if(GLOB.ai_research_booster == src)
		GLOB.ai_research_booster = null
	return ..()

/datum/ai_project/rgb
	name = "Podświetlenie RGB"
	description = "Zmienne natężenie prądu w oświetleniu serwerów daje ładne kolory."
	research_cost = 500
	ram_required = 0
	category = AI_PROJECT_MISC

/datum/ai_project/rgb/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	ai.partytime()

/datum/ai_project/rgb/stop()
	ai.stoptheparty()
	return ..()
