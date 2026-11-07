/*
 * Zestawy komory testowej
 *
 * Każdy PR, który dodaje coś do sprawdzenia w grze, dostaje własny plik w tym folderze,
 * np. kits/pr_430_darkspawn.dm, oraz jedną linię #include w aquila/aquila.dm (sekcja "Komora testowa").
 * Po przetestowaniu PR usuwa się ten plik i jego #include - nic więcej nie trzeba sprzątać.
 *
 * Najprostszy zestaw to lista typów:
 *
 * /datum/test_chamber_kit/pr_430
 * 	name = "Darkspawn"
 * 	pr = "aq33/AquilaStation#430"
 * 	description = "Użyj Divulge na człowieku i sprawdź, czy dostajesz klasy."
 * 	items = list(
 * 		/obj/item/storage/box/monkeycubes = 1,
 * 		/mob/living/carbon/human = 2
 * 	)
 *
 * Jeśli zestaw musi coś ustawić (antag, reagenty, zasilanie maszyny), nadpisz setup().
 */
/datum/test_chamber_kit
	/// Nazwa w menu; zestaw bez nazwy jest pomijany (typy pośrednie)
	var/name
	/// Testowany PR w pełnej postaci, np. "aq33/AquilaStation#430"
	var/pr
	/// Co sprawdzić - wypisywane adminowi po zrzuceniu zestawu
	var/description
	/// typ => ilość; każdy typ dostaje własny turf, kolejne sztuki lądują na tym samym
	var/list/items

/// turfs - wolne turfy areny posortowane od środka, center - środek areny
/datum/test_chamber_kit/proc/spawn_kit(list/turfs, turf/center, mob/user)
	var/list/spawned = list()
	var/index = 1
	for(var/path in items)
		var/turf/T = turfs[min(index++, length(turfs))]
		for(var/i in 1 to (items[path] || 1))
			// Stos łączy się ze stosem tego samego rodzaju na kratce (przy tworzeniu i przy wejściu) i znika jako osobna sztuka
			var/turf/spawn_turf = ispath(path, /obj/item/stack) ? stack_free_turf(path, T, turfs) : T
			spawned += new path(spawn_turf)
	setup(spawned, turfs, center, user)

/// Kratka bez stosu, z którym nowy stos path by się połączył: T, a gdy tam już leży taki stos, pierwsza wolna od niego
/// kratka z turfs. Gdy żadnej nie ma, zostaje T
/datum/test_chamber_kit/proc/stack_free_turf(path, turf/T, list/turfs)
	var/obj/item/stack/stack_path = path
	var/merge_type = initial(stack_path.merge_type) || path
	if(!stack_would_merge(T, merge_type))
		return T
	for(var/turf/candidate as anything in turfs)
		if(!stack_would_merge(candidate, merge_type))
			return candidate
	return T

/datum/test_chamber_kit/proc/stack_would_merge(turf/T, merge_type)
	for(var/obj/item/stack/existing in T)
		if(existing.merge_type == merge_type)
			return TRUE
	return FALSE

/// Dodatkowe przygotowanie po zrzuceniu przedmiotów z items
/datum/test_chamber_kit/proc/setup(list/spawned, list/turfs, turf/center, mob/user)
	return
