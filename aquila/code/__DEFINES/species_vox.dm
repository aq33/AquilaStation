// Rasa z Yogstation: Vox

#define SPECIES_VOX "vox"

#define isvox(A) (is_species(A, /datum/species/vox))

/// Klasa oddechu Voxa: azot zamiast tlenu (Yogstation)
#define BREATH_VOX /datum/breathing_class/vox

/// Ikony części ciała Voxa (stany vox_[strefa]_[odcień], vox_husk_[strefa])
#define VOX_BODYPARTS_ICON 'aquila/icons/mob/species/vox/bodyparts.dmi'
/// Odcień łusek, gdy postać nie ma zapisanego
#define VOX_DEFAULT_SKIN_TONE "lime"

/// Klucze cech wyglądu (dna.features)
#define FEATURE_VOX_SKIN_TONE "vox_skin_tone"
#define FEATURE_VOX_QUILLS "vox_quills"
#define FEATURE_VOX_FACIAL_QUILLS "vox_facial_quills"
#define FEATURE_VOX_BODY_MARKINGS "vox_body_markings"
#define FEATURE_VOX_TAIL_MARKINGS "vox_tail_markings"
#define FEATURE_VOX_TAIL_MARKINGS_COLOR "vox_tail_markings_color"
/// Maska na start: VOX_MASK_BREATH albo VOX_MASK_RESPIRATOR
#define FEATURE_VOX_MASK "vox_mask"
/// Butla na start: VOX_TANK_SMALL albo VOX_TANK_LARGE
#define FEATURE_VOX_TANK "vox_tank"

#define VOX_MASK_BREATH "breath"
#define VOX_MASK_RESPIRATOR "respirator"
#define VOX_TANK_SMALL "small"
#define VOX_TANK_LARGE "large"

/// Ogon w mutant_bodyparts (spokojny i merdający)
#define VOX_TAIL_PART "vox_tail"
#define VOX_TAIL_WAGGING_PART "wagging_vox_tail"
