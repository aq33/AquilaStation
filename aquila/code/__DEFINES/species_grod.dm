// Grod: rasa gąsienic z koroną (aquila/code/modules/mob/living/carbon/human/species_types/grod.dm)

#define SPECIES_GROD "grod"
#define isgrod(A) (is_species(A, /datum/species/grod))

/// Folder sprite'ów Groda
#define GROD_ICON_BODY 'aquila/icons/mob/species/grod/bodyparts.dmi'
#define GROD_ICON_CROWNS 'aquila/icons/mob/species/grod/crowns.dmi'
#define GROD_ICON_MARKINGS 'aquila/icons/mob/species/grod/markings.dmi'
#define GROD_ICON_TAILS 'aquila/icons/mob/species/grod/tails.dmi'
#define GROD_ICON_CROWN_SPIDER 'aquila/icons/mob/species/grod/crown_spider.dmi'
#define GROD_ICON_ACTIONS 'aquila/icons/mob/species/grod/actions_grod.dmi'

/// Pająk-korona: zdrowie pełne i bazowe
#define GROD_CROWNSPIDER_HEALTH 30
/// Najmniejsze obrażenia mózgu po przejęciu ciała przez koronę
#define GROD_CROWN_INFEST_DAMAGE 30
/// Kieszenie górnych dłoni mieszczą rzeczy najwyżej tej wielkości
#define GROD_POCKET_MAX_WEIGHT WEIGHT_CLASS_NORMAL
