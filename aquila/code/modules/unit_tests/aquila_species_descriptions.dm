// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Najdłuższa historia gatunku w oknie wyboru (znaki we wszystkich akapitach razem)
#define SPECIES_LORE_MAX_LENGTH 1200

/// AQUILA - każdy gatunek do wyboru na start ma opis w oknie postaci, a historia nie zajmuje całego okna
/// (zgłoszenie 25.11: Mięsacz miał historię na 2300 znaków, a Jajoczłowiek nie miał nic)
/datum/unit_test/aquila_species_descriptions

/datum/unit_test/aquila_species_descriptions/Run()
	for(var/species_id in GLOB.roundstart_races)
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type()
		TEST_ASSERT(length(species.get_species_description()), "The species [species_id] has no description in the character window")
		var/lore_length = 0
		var/list/lore = species.get_species_lore()
		for(var/paragraph in lore)
			lore_length += length_char(paragraph)
		TEST_ASSERT(lore_length <= SPECIES_LORE_MAX_LENGTH, "The lore of [species_id] has [lore_length] characters (at most [SPECIES_LORE_MAX_LENGTH])")
		qdel(species)

#undef SPECIES_LORE_MAX_LENGTH
#undef TEST_ASSERT
