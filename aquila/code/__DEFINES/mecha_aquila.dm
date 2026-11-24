// AQUILA - system mechów (sloty, overclock, dwa miejsca, zdalne sterowanie). Wzór: tg/Bee (sloty, overclock), Yogstation (broń wręcz).

// Kategorie slotów podwozia (jak MECHA_L_ARM/... w tg)
#define AQ_MECHA_L_ARM "l_arm"
#define AQ_MECHA_R_ARM "r_arm"
#define AQ_MECHA_UTILITY "utility"
#define AQ_MECHA_POWER "power"
#define AQ_MECHA_ARMOR "armor"
/// Wyposażenie na ramię: trafia do wolnego lewego albo prawego
#define AQ_MECHA_SLOT_ARM "arm"
/// Wyposażenie, które nie zajmuje slotu (zestawy konwersji, moduły wbudowane w podwozie)
#define AQ_MECHA_SLOT_NONE "none"
/// Wyposażenie zamontowane ponad limit (gotowe mechy z mapy i od admina)
#define AQ_MECHA_SLOT_OVERFLOW "overflow"

// Overclock (overclock_mode z tg, z czasem odnowienia zamiast ciepła)
/// Jak długo działa włączony overclock
#define AQ_MECHA_OVERCLOCK_DURATION (15 SECONDS)
/// Odnowienie overclocku po jego wyłączeniu
#define AQ_MECHA_OVERCLOCK_COOLDOWN (45 SECONDS)
