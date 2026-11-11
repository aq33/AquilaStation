// AQUILA - Ciecze, port z Monkestation 2.0 (code/__DEFINES/liquids.dm, master 6a4365b)
// Dopisane u nas: próg kałuży, sumowanie małych rozlań, zamarzanie i bloki lodu.

#define WATER_HEIGH_DIFFERENCE_SOUND_CHANCE 50
#define WATER_HEIGH_DIFFERENCE_DELTA_SPLASH 7 //Delta needed for the splash effect to be made in 1 go

#define REQUIRED_MEMBER_PROCESSES 10

#define REQUIRED_EVAPORATION_PROCESSES 20
#define EVAPORATION_CHANCE 50

#define REQUIRED_FIRE_PROCESSES 10
#define REQUIRED_FIRE_POWER_PER_UNIT 5
#define FIRE_BURN_PERCENT 10

#define PARTIAL_TRANSFER_AMOUNT 0.3

//Required amount of a reagent to be simulated on turf exposures from liquids (to prevent gaming the system with cheap dillutions)
#define LIQUID_REAGENT_THRESHOLD_TURF_EXPOSURE 5

//Threshold at which the difference of height makes us need to climb/blocks movement/allows to fall down
#define TURF_HEIGHT_BLOCK_THRESHOLD 20

#define LIQUID_HEIGHT_DIVISOR 10

#define ONE_LIQUIDS_HEIGHT LIQUID_HEIGHT_DIVISOR

#define LIQUID_STATE_PUDDLE 1
#define LIQUID_STATE_ANKLES 2
#define LIQUID_STATE_WAIST 3
#define LIQUID_STATE_SHOULDERS 4
#define LIQUID_STATE_FULLTILE 5
#define TOTAL_LIQUID_STATES 5
#define LYING_DOWN_SUBMERGEMENT_STATE_BONUS 2

#define LIQUID_ANKLES_LEVEL_HEIGHT 8
#define LIQUID_WAIST_LEVEL_HEIGHT 19
#define LIQUID_SHOULDERS_LEVEL_HEIGHT 29
#define LIQUID_FULLTILE_LEVEL_HEIGHT 39

#define LIQUID_FIRE_STATE_NONE 0
#define LIQUID_FIRE_STATE_SMALL 1
#define LIQUID_FIRE_STATE_MILD 2
#define LIQUID_FIRE_STATE_MEDIUM 3
#define LIQUID_FIRE_STATE_HUGE 4
#define LIQUID_FIRE_STATE_INFERNO 5

//Height at which we consider the tile "full" and dont drop liquids on it from the upper Z level
#define LIQUID_HEIGHT_CONSIDER_FULL_TILE 50

//Scaled with how much a person is submerged
#define SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT 60

#define CHOKE_REAGENTS_INGEST_ON_FALL_AMOUNT 4

/// Ułamek zanurzenia moba (0-1); leżący jest zanurzony głębiej
#define SUBMERGEMENT_PERCENT(living, liquids) min(1, ((living.mobility_flags & MOBILITY_STAND) ? liquids.liquid_group.group_overlay_state : liquids.liquid_group.group_overlay_state + LYING_DOWN_SUBMERGEMENT_STATE_BONUS) / TOTAL_LIQUID_STATES)

/// Trait ubrania (kombinezony): ciecz nie dotyka noszącego
#define LIQUID_PROTECTION "liquid_protection"

/// Turf z tym traitem nie przyjmuje rozlewającej się cieczy (bariera)
#define TRAIT_BLOCK_LIQUID_SPREAD "block_liquid_spread"

///from /obj/effect/abstract/liquid_turf/Initialize() (obj/effect/abstract/liquid_turf/liquids)
#define COMSIG_TURF_LIQUIDS_CREATION "turf_liquids_creation"
	#define BLOCK_LIQUID_CREATION (1<<0)

#define FIRE_PRIORITY_LIQUID_TURFS 19

#define SSLIQUIDS_RUN_TYPE_TURFS 1
#define SSLIQUIDS_RUN_TYPE_GROUPS 2
#define SSLIQUIDS_RUN_TYPE_EVAPORATION 4
#define SSLIQUIDS_RUN_TYPE_FIRE 5
#define SSLIQUIDS_RUN_TYPE_CACHED_EDGES 7

// AQUILA - nasze progi

/// Rozlanie poniżej tej ilości na kafelek robi zwykły rozprysk (plama, mokra podłoga), od niej powstaje kałuża
#define LIQUID_SPILL_THRESHOLD 50
/// Gęsta ciecz (krew) rozlewa się na sąsiedni kafelek dopiero, gdy na każdy kafelek kałuży wypada tyle jednostek
#define LIQUID_VISCOUS_SPREAD_PER_TURF 50
/// Po tym czasie bez nowego rozlania pamięć małych rozlań na kafelku przepada
#define LIQUID_RESIDUE_DECAY_TIME (5 MINUTES)

/// Od tylu jednostek na kafelek zamarznięta ciecz robi blok lodu (poziom "ponad głowę")
#define LIQUID_ICE_BLOCK_VOLUME (LIQUID_FULLTILE_LEVEL_HEIGHT * LIQUID_HEIGHT_DIVISOR)
/// Ułamek objętości, który musi zamarzać, żeby zamarzła cała grupa
#define LIQUID_FREEZE_FRACTION 0.5
/// Jak szybko temperatura grupy dąży do temperatury powietrza (ułamek różnicy na przebieg członków)
#define LIQUID_AIR_TEMPERATURE_SHARE 0.25
/// Ile kafli grupy próbkujemy przy wymianie ciepła z powietrzem
#define LIQUID_TEMPERATURE_SAMPLES 5
/// Ile bloków lodu może powstać w jednym przebiegu SSliquids (każdy blokuje atmos)
#define LIQUID_ICE_BLOCKS_PER_RUN 10
/// Czas wybijania się z bloku lodu od środka
#define LIQUID_ICE_BLOCK_ESCAPE_TIME (20 SECONDS)
/// Jak długo uwolniona postać nie da się uwięzić w nowym bloku (w próżni woda zamarza z powrotem po kilku sekundach)
#define LIQUID_ICE_REFREEZE_GRACE (30 SECONDS)

GLOBAL_LIST_INIT(liquid_blacklist, list(
	/datum/reagent/sorium,
	/datum/reagent/liquid_dark_matter,
))

/// AQUILA - reagenty, które przy rozlaniu same zamieniają się w coś na podłodze (gaz, świecąca plama, kupka, brud),
/// więc rozlane reagują z podłogą i nie trafiają do kałuży ani pamięci rozlań (inaczej byłyby podwójnie)
GLOBAL_LIST_INIT(liquid_turf_converting, typecacheof(list(
	/datum/reagent/oxygen,
	/datum/reagent/nitrogen,
	/datum/reagent/carbondioxide,
	/datum/reagent/nitrous_oxide,
	/datum/reagent/toxin/plasma,
	/datum/reagent/uranium,
	/datum/reagent/consumable/flour,
	/datum/reagent/consumable/sodiumchloride,
	/datum/reagent/carbon,
	/datum/reagent/glitter,
	/datum/reagent/ants,
)))

/// AQUILA - najwięcej cieczy, jaka zostaje w kałuży po rozprysku z granatu albo rozbitego zbiornika
#define LIQUID_SPLASH_PUDDLE_MAX 200

#define MOVESPEED_ID_LIQUIDS "LIQUIDS"
