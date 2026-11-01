// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - tłumaczenie nazw reagentów: GLOB.name2reagent szuka reagentu po ckey(name), a ckey() usuwa polskie litery.
/// Dwie nazwy różniące się tylko ogonkami (albo nazwa z samych polskich liter) dają ten sam albo pusty klucz
/// i jeden reagent po cichu znika z dozownika, chem mastera i rur. Ten test pilnuje, żeby każda nazwa miała własny klucz.
/datum/unit_test/aquila_reagent_name_keys

/datum/unit_test/aquila_reagent_name_keys/Run()
	TEST_ASSERT(length(GLOB.name2reagent), "GLOB.name2reagent is empty")

	// Pary o tej samej nazwie, które istniały przed tłumaczeniem i są celowe. Typ z tej listy może dzielić klucz z innym reagentem.
	var/list/allowed_shared_key = list(
		/datum/reagent/toxin/fakebeer, // podrabiane piwo celowo udaje zwykłe piwo
		/datum/reagent/fake_cbz, // podróbka skoncentrowanego BZ: ta sama nazwa, tylko szkodzi mózgowi
		/datum/reagent/blob/energized_jelly, // reagent szczepu bloba nosi tę samą nazwę co teslium/energized_jelly
		/datum/reagent/mutationtoxin/goofzombie, // niezakaźna wersja toksyny zombie, celowo wygląda jak zwykła
	)

	var/list/key_owners = list()
	for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		var/name = initial(reagent_type.name)
		if(!length(name))
			continue
		var/key = ckey(name)
		if(!length(key))
			Fail("[reagent_type] name \"[name]\" has no ASCII letters or digits, ckey() gives an empty key")
			continue
		var/datum/reagent/listed = GLOB.name2reagent[key]
		if(!listed)
			Fail("[reagent_type] (\"[name]\") is missing from GLOB.name2reagent under \"[key]\"")
			continue
		if(initial(listed.name) != name)
			Fail("[reagent_type] (\"[name]\") and [listed] (\"[initial(listed.name)]\") share the key \"[key]\", so [reagent_type] cannot be found by name")
			continue
		// Typ bez własnej nazwy dziedziczy ją po rodzicu, to nie jest kolizja
		var/datum/reagent/parent_type = type2parent(reagent_type)
		if(initial(parent_type.name) == name)
			continue
		var/datum/reagent/owner = key_owners[key]
		if(!owner)
			key_owners[key] = reagent_type
			continue
		if((reagent_type in allowed_shared_key) || (owner in allowed_shared_key))
			continue
		Fail("[reagent_type] and [owner] are both named \"[name]\", so only one of them can be found by name under \"[key]\"")

#undef TEST_ASSERT
