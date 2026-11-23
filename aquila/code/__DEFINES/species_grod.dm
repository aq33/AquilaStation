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
/// Ile rąk ma Grod (dwie zwykłe i para na odnóżach)
#define GROD_HANDS 4
/// Postawy Groda (BeeStation/BeeStation-Hornet#5442): ruch (domyślna, dwie ręce, szybciej) i praca (cztery ręce, wolniej)
#define GROD_STANCE_MOBILE 0
#define GROD_STANCE_INTERACT 1
/// Grod jest o 10% szybszy od człowieka (bieg trwa 2 ticki)
#define GROD_SPEEDMOD -0.2
/// Bazowy mnożnik zmęczenia Groda
#define GROD_STAMINAMOD 1.2
/// Postawa pracy: spowolnienie, dodatkowe zmęczenie i koszt w głodzie
#define GROD_INTERACT_SLOWDOWN 0.8
#define GROD_INTERACT_STAMINAMOD 0.3
#define GROD_STANCE_NUTRITION 20
#define MOVESPEED_ID_GROD_INTERACT "GROD_INTERACT"
#define TRAIT_SOURCE_GROD_STANCE "grod_stance"
/// Kokon (BeeStation/BeeStation-Hornet#7202): szansa rozerwania ręką z zewnątrz
#define GROD_COCOON_RIP_CHANCE 33
/// Ile trwa wyrwanie się z kokonu od środka
#define GROD_COCOON_RESIST_TIME (10 SECONDS)
/// Ile rośnie nowe ciało z korony posadzonej w tacy hydroponicznej
#define GROD_COCOON_GROW_TIME (2 MINUTES)
