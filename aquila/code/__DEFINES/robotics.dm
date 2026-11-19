// AQUILA - robotyka: protezy, syntetycy, cyberpsychoza (aquila/code/modules/robotics/)

// --- Sloty organów ---
/// Wzmocnienie stawów
#define ORGAN_SLOT_AQ_BRACING "aq_bracing"

// --- Źródła cech ---
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

// --- Cyberpsychoza (pojemność psychiki 100 minus obciążenie cybernetyką) ---
#define AQ_CYBERPSYCHOSIS_MILD 80
#define AQ_CYBERPSYCHOSIS_MODERATE 60
#define AQ_CYBERPSYCHOSIS_SEVERE 40
#define AQ_CYBERPSYCHOSIS_CRITICAL 20
