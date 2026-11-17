// Rasy z Monkestation2.0: małpolud (Simian) i floranin (Floran)

#define SPECIES_SIMIAN "simian"
#define SPECIES_FLORAN "floran"

#define issimian(A) (is_species(A, /datum/species/simian))
#define isfloran(A) (is_species(A, /datum/species/floran))

/// Przy biegu przeskakuje stoły i barierki zamiast się na nie wspinać (Monkestation)
#define TRAIT_VAULTING "vaulting"
/// Agresywne małpy go nie atakują, chyba że wcześniej je skrzywdził (Monkestation)
#define TRAIT_MONKEYFRIEND "monkeyfriend"
