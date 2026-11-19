// AQUILA - robotyka: protezy, syntetycy, cyberpsychoza (aquila/code/modules/robotics/)

// --- Sloty organów ---
/// Organ chłodzenia syntetyka (chłodzenie powietrzem, cieczą, pasywny radiator)
#define ORGAN_SLOT_AQ_COOLING "aq_cooling"
/// Implant bezpieczeństwa przedawkowania
#define ORGAN_SLOT_AQ_OD_SAFETY "aq_od_safety"
/// Regulator rytmu dobowego
#define ORGAN_SLOT_AQ_CIRCADIAN "aq_circadian"
/// Wzmocnienie stawów
#define ORGAN_SLOT_AQ_BRACING "aq_bracing"
/// Wszczepiony zegarek
#define ORGAN_SLOT_AQ_TIMEPIECE "aq_timepiece"

// --- Źródła cech ---
/// Świeżo przymocowana proteza bez kalibracji (TRAIT_PARALYSIS na kończynie)
#define AQ_UNCALIBRATED_TRAIT "aq_uncalibrated"
/// Paraliż kończyny po EMP
#define AQ_LIMB_EMP_TRAIT "aq_limb_emp"
/// Cecha „Mocowania protez”: odpinanie i przypinanie własnych protez bez operacji
#define TRAIT_AQ_LIMB_MOUNTS "aq_limb_mounts"
/// Implant zakłócający augmenty: implanty cybernetyczne nosiciela nie działają
#define TRAIT_AQ_AUGMENTS_DISRUPTED "aq_augments_disrupted"
#define AQ_ANTI_AUGMENT_TRAIT "aq_anti_augment"

// --- EMP protez (tg: AUGGED_LIMB_EMP_*) ---
#define AQ_LIMB_EMP_BRUTE 2
#define AQ_LIMB_EMP_BURN 1.5
#define AQ_LIMB_EMP_PARALYZE_TIME (3 SECONDS)
/// Od jakiej części maksymalnych obrażeń EMP paraliżuje kończynę (tg robotic_emp_paralyze_damage_percent_threshold)
#define AQ_LIMB_EMP_PARALYZE_PERCENT 0.3

// --- Rany robotyczne (osobne rodzaje, żeby nie mieszały się z ranami organicznymi) ---
#define WOUND_AQ_ROBOTIC_BLUNT "robotic_blunt"
#define WOUND_AQ_ROBOTIC_ELECTRIC "robotic_electric"
#define WOUND_AQ_ROBOTIC_HEAT "robotic_heat"

// --- Nagrzanie syntetyka (0-100) ---
#define AQ_SYNTH_HEAT_WARN 50
#define AQ_SYNTH_HEAT_DAMAGE 75
#define AQ_SYNTH_HEAT_CRITICAL 90
/// Ile nagrzewa się ciało syntetyka na sekundę bez chłodzenia
#define AQ_SYNTH_HEAT_GAIN 1

// --- Cyberpsychoza (pojemność psychiki 100 minus obciążenie cybernetyką) ---
#define AQ_CYBERPSYCHOSIS_MILD 80
#define AQ_CYBERPSYCHOSIS_MODERATE 60
#define AQ_CYBERPSYCHOSIS_SEVERE 40
#define AQ_CYBERPSYCHOSIS_CRITICAL 20
