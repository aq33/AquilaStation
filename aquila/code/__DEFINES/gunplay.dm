// AQUILA - rework strzelania (silnik pocisku tg, autofire, odrzut, stan broni)

/// Pocisk trafił i dogrywa animację do miejsca trafienia, zniknie w następnym ticku
#define AQ_PROJECTILE_IMPACT_DELETE 1

/// Ile pikseli przelatuje pocisk o prędkości 1 kratki na decysekundę w jednej decysekundzie
#define AQ_PROJECTILE_PIXELS_PER_DS 32
/// Domyślna globalna prędkość pikselowa starego silnika (SSprojectiles.global_pixel_speed), od niej liczymy mnożnik set_pixel_speed()
#define AQ_PROJECTILE_LEGACY_PIXEL_SPEED 2

// Tryby ognia (wybierak)
#define AQ_FIREMODE_SAFE "safe"
#define AQ_FIREMODE_SEMI "semi"
#define AQ_FIREMODE_BURST "burst"
#define AQ_FIREMODE_AUTO "auto"

/// Klawisz: następny tryb ognia trzymanej broni
#define COMSIG_KB_AQ_CYCLE_FIREMODE "keybinding_aq_cycle_firemode"
/// Klawisz: zabezpiecz albo odbezpiecz trzymaną broń
#define COMSIG_KB_AQ_TOGGLE_SAFETY "keybinding_aq_toggle_safety"
/// Z /obj/item/gun/proc/set_firemode(): (new_mode)
#define COMSIG_AQ_GUN_FIREMODE_CHANGED "aq_gun_firemode_changed"

/// Maksymalny odrzut postaci w stopniach rozrzutu (Eris: MAX_ACCURACY_OFFSET)
#define AQ_RECOIL_MAX 45
/// Co ile spada odrzut postaci
#define AQ_RECOIL_DECAY_INTERVAL (0.1 SECONDS)

/// Licznik amunicji na HUD-zie (druga kolumna od prawej, w rzędzie wskaźnika staminy)
#define ui_aq_ammo_counter "EAST-2:26,CENTER-5:8"
