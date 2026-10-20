// AQUILA - krwawe robaki (port z tgstation#93787)

#define BLOOD_WORM_BLOOD_TO_HEALTH (100 / BLOOD_VOLUME_NORMAL)
#define BLOOD_WORM_HEALTH_TO_BLOOD (BLOOD_VOLUME_NORMAL / 100)

/// Przy jakim procencie zdrowia robak zostaje wyrzucony z nosiciela
#define BLOOD_WORM_EJECT_THRESHOLD 0.1

/// O ile szybciej krwawią nosiciele. Robak wychodzi dopiero przy 10% krwi, a dorosły ma jej bardzo dużo,
/// więc bez tego krwawienie prawie by mu nie szkodziło
#define BLOOD_WORM_BLEED_MOD 1.5

/// Poniżej tego ciśnienia (kPa) robak poza nosicielem traci zdrowie (tgstation#96607)
#define BLOOD_WORM_MIN_PRESSURE 20

#define isbloodworm(A) (istype(A, /mob/living/simple_animal/hostile/blood_worm))

/// Robak z moba: sam robak albo robak siedzący w nosicielu
#define FIND_BLOOD_WORM(mob) ((isbloodworm(mob) ? mob : null) || ((mob && HAS_TRAIT(mob, TRAIT_BLOOD_WORM_HOST)) ? (locate(/mob/living/simple_animal/hostile/blood_worm) in mob) : null))

/// Klucz w danych krwi: jak bardzo krew jest syntetyczna (0-1). Syntetyczna krew słabiej karmi robaki
#define BLOOD_DATA_SYNTH_CONTENT "synth_content"

/// Mob w środku ma żywego krwawego robaka
#define TRAIT_BLOOD_WORM_HOST "blood_worm_host"
/// Mob widzi poziom krwi innych (HUD krwi)
#define TRAIT_BLOOD_HUD "blood_hud"
/// Źródło cech nadawanych nosicielowi i robakowi w nosicielu
#define BLOOD_WORM_HOST_TRAIT "blood_worm_host_trait"
/// Źródło cech z siedzenia pod drzwiami
#define UNDER_DOOR_TRAIT "under_door_trait"

/// Klucze w hud_list (tekstowe, żeby nie zajmować indeksów GLOB.huds)
#define BLOOD_WORM_BLOOD_HUD "blood_worm_blood"
#define BLOOD_WORM_TEAM_HUD "blood_worm_team"

/// Od /mob/living/simple_animal/hostile/blood_worm/proc/consume_blood() : (normal_blood_amount, synth_blood_amount, total_blood_amount)
#define COMSIG_BLOOD_WORM_CONSUMED_BLOOD "blood_worm_consumed_blood"
/// Od rozmnożenia w kokonie dorosłego : ()
#define COMSIG_BLOOD_WORM_REPRODUCED "blood_worm_reproduced"

#define FACTION_BLOOD_WORM "blood_worm"
#define ALERT_BLOODWORM_INFO "bloodworm_info"
#define POLL_IGNORE_BLOOD_WORM "blood_worm"
#define LANGUAGE_BLOOD_WORM "blood_worm"
