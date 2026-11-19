// AQUILA - system mechów (sloty, ciepło, dwa miejsca, zdalne sterowanie). Wzór: tg/Bee (sloty), Yogstation (ciepło, broń wręcz).

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

// Ciepło (jak overheat w Yogstation)
#define AQ_MECHA_HEAT_WARNING 50
#define AQ_MECHA_HEAT_DANGER 100
#define AQ_MECHA_HEAT_MAX 150
/// Chłodzenie bierne na sekundę, gdy overclock jest wyłączony
#define AQ_MECHA_PASSIVE_COOLING 3
/// Grzanie na sekundę przy włączonym overclocku
#define AQ_MECHA_OVERCLOCK_HEAT 8
/// Ile bezpieczników ma mech
#define AQ_MECHA_FUSES 3
/// Ile kabla na wymianę jednego bezpiecznika
#define AQ_MECHA_FUSE_CABLE 3
