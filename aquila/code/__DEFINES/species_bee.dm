// Rasy z BeeStation-Hornet: Psyfoza i Diona

#define SPECIES_PSYPHOZA "psyphoza"
#define SPECIES_DIONA "diona"

#define ispsyphoza(A) (is_species(A, /datum/species/psyphoza))
#define isdiona(A) (is_species(A, /datum/species/diona))
#define isnymph(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/nymph))

/// Psyfoza czuje otoczenie zmysłem psychicznym
#define TRAIT_PSYCHIC_SENSE "psychic_sense"
/// Źródło wrodzonej ślepoty psyfozy (oczy psyfozy)
#define PSYPHOZA_BLINDNESS_SOURCE "psyphoza_eyes"

/// Faction diony i jej nimf
#define FACTION_DIONA "diona"

/// Klucze cech wyglądu (dna.features, mutant_bodyparts, nazwy stanów m_[klucz]_[stan]_ADJ)
#define FEATURE_PSYPHOZA_CAP "psyphoza_cap"
#define FEATURE_DIONA_LEAVES "diona_leaves"
#define FEATURE_DIONA_THORNS "diona_thorns"
#define FEATURE_DIONA_FLOWERS "diona_flowers"
#define FEATURE_DIONA_MOSS "diona_moss"
#define FEATURE_DIONA_MUSHROOM "diona_mushroom"
#define FEATURE_DIONA_ANTENNAE "diona_antennae"
#define FEATURE_DIONA_EYES "diona_eyes"
#define FEATURE_DIONA_PBODY "diona_pbody"
