// AQUILA - TYMCZASOWY rodzic planet karłowatych dla partii planet morskich i piasków. Właściwy /datum/planet_type/dwarf robi partia
// lodu w types/dwarf.dm; przy scalaniu gałęzi zostaje jej wersja, a ten plik (i jego include w aquila.dm) usuwamy.

/// Planeta karłowata (Shiptest: snowball, dustball, duneball, waterball): mała mapa bez ruin
/datum/planet_type/dwarf
	name = "planeta karłowata"
	desc = "Mały, jednolity świat."
	abstract_type = /datum/planet_type/dwarf
	surface_size = PLANET_SURFACE_SIZE_DWARF
	ruin_budget = 0

/datum/planet_type/dwarf/get_ruin_templates()
	return list()

/datum/planet_type/dwarf/get_main_ruin_templates()
	return list()
