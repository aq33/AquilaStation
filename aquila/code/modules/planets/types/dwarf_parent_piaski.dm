// AQUILA - wspólny rodzic planet karłowatych. Tymczasowa kopia z partii piasków: tego samego rodzica definiuje partia
// lodu (types/dwarf.dm); przy scalaniu gałęzi zostaje wersja z partii lodu, a ten plik znika.

/datum/planet_type/dwarf
	name = "planeta karłowata"
	desc = "Mały, jednolity świat."
	surface_size = PLANET_SURFACE_SIZE_DWARF
	ruin_budget = 0
	// Sam rodzic nie ma generatora: nie trafia do misji ani losowania (bez system_tags)
	mission_target = FALSE

/datum/planet_type/dwarf/get_ruin_templates()
	return list()

/datum/planet_type/dwarf/get_main_ruin_templates()
	return list()
