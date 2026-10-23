// AQUILA - bingle, port z Monkestation (Monkestation/Monkestation2.0#7051, oryginał z GoobStation)

#define isbingle(A) (istype(A, /mob/living/simple_animal/hostile/bingle))
#define IS_BINGLE(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/bingle))

#define POLL_IGNORE_BINGLE "bingle"
#define FACTION_BINGLE "bingle"
#define BINGLE_TRAIT "bingle_trait"

/// Co tyle punktów Dół ogłasza ankietę na nowego bingla
#define BINGLE_PIT_SPAWN_STEP 50
/// Co tyle punktów Dół rośnie o jedno pole
#define BINGLE_PIT_GROW_STEP 100
/// Od tylu punktów Dół przyjmuje żywe istoty
#define BINGLE_PIT_LIVING_THRESHOLD 100
/// Od tylu punktów bingle są pancerne
#define BINGLE_PIT_ARMOR_THRESHOLD 500
/// Największy Dół (bok kwadratu)
#define BINGLE_PIT_MAX_SIZE 40
