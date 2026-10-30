#define EFFECT_DANGER_HELPFUL	"0"
#define EFFECT_DANGER_FLAVOR	"1"
#define EFFECT_DANGER_ANNOYING	"2"
#define EFFECT_DANGER_HINDRANCE	"3"
#define EFFECT_DANGER_HARMFUL	"4"
#define EFFECT_DANGER_DEADLY	"5"

#define	ANTIGEN_BLOOD	"blood"
#define	ANTIGEN_COMMON	"common"
#define	ANTIGEN_RARE	"rare"
#define	ANTIGEN_ALIEN	"alien"
#define ANTIGEN_UNIQUE	"unique"

//blood antigens
#define	ANTIGEN_O	"O"
#define	ANTIGEN_A	"A"
#define	ANTIGEN_B	"B"
#define	ANTIGEN_RH	"Rh"
//common antigens
#define	ANTIGEN_Q	"Q"
#define	ANTIGEN_U	"U"
#define	ANTIGEN_V	"V"
//rare antigens
#define	ANTIGEN_M	"M"
#define	ANTIGEN_N	"N"
#define	ANTIGEN_P	"P"
//alien antigens
#define	ANTIGEN_X	"X"
#define	ANTIGEN_Y	"Y"
#define	ANTIGEN_Z	"Z"
//Unique antigens
#define ANTIGEN_IG "Ig" //For TB


#define DISEASE_BUMP "bump"
#define DISEASE_TOUCH "touch"

#define DISEASE_NORMAL "normal"
#define DISEASE_TRANSFORMATION "transformation"
#define DISEASE_GONDOLA "gondola"
#define DISEASE_GONDOLA_DIGITAL "digital_gondola"
#define DISEASE_XENO "xeno"
#define DISEASE_CORGI "corgi"
#define DISEASE_SLIME "slime"
#define DISEASE_MORPH "morph"
#define DISEASE_ROBOT "robot"
#define DISEASE_MONKEY "monkey"
#define DISEASE_COLD "cold"
#define DISEASE_HEART "heart"
#define DISEASE_SANDWICH "sandwich"
#define DISEASE_TRAUMA "trauma"
#define DISEASE_DECLONING "decloning"
#define DISEASE_ANXIETY "anxiety"
#define DISEASE_SHOCK "shock"
#define DISEASE_FUNGUS "fungal_spores"
#define DISEASE_DEBUG "debug"

#define COMSIG_CRACKER_PUZZLE_FAILURE "cracker_puzzle_failure"
#define COMSIG_CRACKER_PUZZLE_SUCCESS "cracker_puzzle_success"

#define COMSIG_SYMPTOM_ATTACH "symptom_attach"
#define COMSIG_SYMPTOM_DETACH "symptom_detach"
#define COMSIG_SYMPTOM_TRIGGER "symptom_trigger"

#define COMSIG_CARBON_TAKE_BRUTE_DAMAGE "carbon_take_brute"

// ---------------------------------------------------------------------------
// AQ: definicje z tg/Monke potrzebne wirusologii, których nasza baza nie ma.
// ---------------------------------------------------------------------------

// Flagi chorób (Monke code/__DEFINES/diseases.dm). Nasze CURABLE/CAN_CARRY/CAN_RESIST zajmują bity 0-2.
#define DISEASE_DORMANT (1<<3)
#define DISEASE_COPYSTAGE (1<<4)
#define DISEASE_ANALYZED (1<<5)

// Nazwy stopni groźności z tg odpowiadają naszym DISEASE_* (zmienna `danger`).
#define DISEASE_SEVERITY_POSITIVE DISEASE_POSITIVE
#define DISEASE_SEVERITY_NONTHREAT DISEASE_NONTHREAT
#define DISEASE_SEVERITY_MINOR DISEASE_MINOR
#define DISEASE_SEVERITY_MEDIUM DISEASE_MEDIUM
#define DISEASE_SEVERITY_HARMFUL DISEASE_HARMFUL
#define DISEASE_SEVERITY_DANGEROUS DISEASE_DANGEROUS
#define DISEASE_SEVERITY_BIOHAZARD DISEASE_BIOHAZARD

/// Każdy podtyp patogenu poza gotowcami.
#define WILD_ACUTE_DISEASES (subtypesof(/datum/disease/acute) - typesof(/datum/disease/acute/premade))

// Strefy ciała do liczenia sterylności.
#define BODY_ZONE_EVERYTHING "everything"
#define BODY_ZONE_ARMS "arms"
#define BODY_ZONE_LEGS "legs"

/// Czas od startu rundy (Monke liczy go od STATION_TIME_PASSED, którego nie mamy).
#define ROUND_TIME(...) gameTimestamp("hh:mm:ss", world.time - SSticker.round_start_time)

#ifndef TRAIT_IMMUNODEFICIENCY
#define TRAIT_IMMUNODEFICIENCY "immunodeficiency"
#endif
#define TRAIT_VIRUS_SCANNER "virus_scanner"
#define TRAIT_NEARSIGHTED_CORRECTED "fixes_nearsighted"
#define TRAIT_PLASMA_LOVER_METABOLISM "plasma_lover_metabolism"

#define POLL_IGNORE_PLAGUERAT "plague_rat"

#define isvirusdish(A) (istype(A, /obj/item/weapon/virusdish))
#define is_reagent_container(O) (istype(O, /obj/item/reagent_containers))

#define CIRCUIT_COLOR_MEDICAL "#00CCFF"
#define FIRE_PRIORITY_PATHOGEN 31

#ifndef TRAIT_VIRUS_RESISTANCE
#define TRAIT_VIRUS_RESISTANCE "virus_resistance"
#endif

// Zużycie prądu maszyn (tg code/__DEFINES/machines.dm).
#define BASE_MACHINE_IDLE_CONSUMPTION 10
#define BASE_MACHINE_ACTIVE_CONSUMPTION (BASE_MACHINE_IDLE_CONSUMPTION * 10)

/// Bazowa cena paczki cargo (tg CARGO_CRATE_VALUE).
#define CARGO_CRATE_VALUE 200
