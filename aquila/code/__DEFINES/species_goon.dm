// Rasy z Goonstation (goonstation/goonstation, code/datums/mutantraces.dm, licencja CC BY-NC-SA 3.0): mops (Pug) i żaba (Amphibian)

#define SPECIES_PUG "pug"
#define SPECIES_AMPHIBIAN "amphibian"

#define ispug(A) (is_species(A, /datum/species/pug))
#define isamphibian(A) (is_species(A, /datum/species/amphibian))

/// Klucze umaszczenia w dna.features i w zapisie postaci (wartości: odmiany z Goona, np. "fawn", "golden")
#define FEATURE_PUG_COAT "pug_coat"
#define FEATURE_AMPHIBIAN_SKIN "amphibian_skin"

/// Części ciała, oczy, ogon mopsa (przełożone z szablonu Goona na nasz)
#define PUG_BODYPARTS_ICON 'aquila/icons/mob/species/pug/bodyparts.dmi'
/// Części ciała i oczy żaby
#define AMPHIBIAN_BODYPARTS_ICON 'aquila/icons/mob/species/amphibian/bodyparts.dmi'

/// Sprint do końca wytrzymałości, a potem padnięcie na ziemię z zadyszką (Goon: PROP_MOB_FAILED_SPRINT_FLOP)
#define TRAIT_FAILED_SPRINT_FLOP "failed_sprint_flop"
/// Oddycha pod wodą i nie zwalnia w cieczach (Goon: mutantrace.aquatic)
#define TRAIT_AQUATIC "aquatic"
