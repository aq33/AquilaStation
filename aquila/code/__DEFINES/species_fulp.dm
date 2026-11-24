// Rasy z Fulpstation (fulpstation/fulpstation, fulp_modules/features/species/)

#define SPECIES_BEEFMAN "beefman"
#define isbeefman(A) (is_species(A, /datum/species/beefman))

/// Klucze cech mięsoczłowieka w dna.features i w zapisie postaci. Wartości to polskie nazwy z GLOB.beefman_colors/eyes/mouths.
#define FEATURE_BEEF_COLOR "beef_color"
#define FEATURE_BEEF_EYES "beef_eyes"
#define FEATURE_BEEF_MOUTH "beef_mouth"

/// Plik z częściami ciała, oczami i ustami mięsoczłowieka
#define BEEFMAN_BODYPARTS_ICON 'aquila/icons/mob/species/beefman/beefman_bodyparts.dmi'

/// Powyżej tej temperatury ciała mięsoczłowiek puszcza sok (25°C)
#define BEEFMAN_BLEEDOUT_LEVEL 298.15
/// Temperatura, do której wraca ciało mięsoczłowieka (bodytemp_normal = T20C w oryginale)
#define BEEFMAN_BODYTEMP_NORMAL T20C
/// Krwawienie sokiem na jedną kończynę za każdy poziom (oryginał: 0-5, odwodniony 2-10)
#define BEEFMAN_JUICE_PER_LEVEL 0.1
