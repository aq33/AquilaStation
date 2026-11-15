/**
 * Profiler byond-tracy (fork ParadiseSS13, pliki .utracy w data/profiler), opis w tools/tracy/README.md.
 *
 * Włącza go zmienna środowiskowa AQUILA_TRACY=1 przy starcie Dream Daemona, bez przebudowy .dmb.
 * AQUILA_TRACY_DLL podaje ścieżkę do biblioteki, domyślnie prof.dll (Windows) albo libprof.so (Linux) obok .dmb.
 *
 * Ten plik jest ostatnim include'em builda: BYOND inicjuje zmienne statyczne w odwrotnej kolejności deklaracji,
 * więc ta rusza przed wszystkimi innymi i przed Master, a profil obejmuje cały start świata (jak Genesis() w tg).
 * Nie łącz z debuggerem auxtools: oba podpinają się pod wykonywanie procek.
 */
GLOBAL_REAL_VAR(aquila_tracy_file) = world.aquila_init_tracy()

/// Starts byond-tracy if AQUILA_TRACY is set. Returns the .utracy file name it writes, or null.
/world/proc/aquila_init_tracy()
	if(!GetConfig("env", "AQUILA_TRACY"))
		return null
	var/library = GetConfig("env", "AQUILA_TRACY_DLL")
	if(!library)
		switch(system_type)
			if(MS_WINDOWS)
				library = "prof.dll"
			if(UNIX)
				library = "libprof.so"
	var/result = call_ext(library, "init")()
	if(length(result) && copytext(result, 1, 2) == ".")
		log << "byond-tracy: profil zapisywany do data/profiler/[result]"
		return result
	if(result != "0")
		log << "byond-tracy: nie udało się włączyć profilera ([library]): [result]"
		return null
	log << "byond-tracy: profiler włączony"
	return result
