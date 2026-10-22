// Zdecentralizowane AI (port Monkestation/Monkestation2.0#11862, oryginał z Yogstation)

#define AI_HEATSINK_CAPACITY 5000
#define AI_HEATSINK_COEFF 1
///All AI machinery heat production is multiplied by this value
#define AI_TEMPERATURE_MULTIPLIER 4
///Temperature limit of all AI machinery
#define AI_TEMP_LIMIT (T0C + 15)

///How many ticks can an AI data core store? When this amount of ticks have passed while it's in an INVALID state it can no longer be used by an AI
#define MAX_AI_DATA_CORE_TICKS 15
///How many ticks can a server cabinet store. If it reaches 0 the resources will no longer be available.
#define MAX_AI_EXPANSION_TICKS 15

//AI Project Categories.
#define AI_PROJECT_HUDS "Czujniki i HUD-y"
#define AI_PROJECT_CAMERAS "Kamery"
#define AI_PROJECT_INDUCTION "Indukcja"
#define AI_PROJECT_SURVEILLANCE "Inwigilacja"
#define AI_PROJECT_EFFICIENCY "Wydajność"
#define AI_PROJECT_MISC "Różne"

///How much is the AI download progress increased by per second. Need to reach 100 to be downloaded
#define AI_DOWNLOAD_PER_PROCESS 0.5

//Needs UI change to properly work!
#define AI_MAX_CPUS_PER_RACK 4
//Needs UI change to properly work!
#define AI_MAX_RAM_PER_RACK 4

///How many AI research points does 1 THz generate per second?
#define AI_RESEARCH_PER_CPU 0.5

///How long between each data core being able to send a warning.
#define AI_DATA_CORE_WARNING_COOLDOWN (5 MINUTES)

#define MAX_AI_BITCOIN_MINED_PER_TICK 100
#define AI_BITCOIN_PRICE 3.5

///The minimum speed an AI CPU can be set by an Overclocking station.
#define MINIMUM_CPU_SPEED 1
///The minimum power an AI CPU can be set by an Overclocking station.
#define MINIMUM_CPU_POWER 0.5

///Power usage of an active data core (W)
#define AI_DATA_CORE_POWER_USAGE 750
///How much power does a CPU consume per tick?
#define AI_BASE_POWER_PER_CPU 150
///Multiplied by number of RAM sticks to see power consumption per tick. Added to by power consumption of CPUs
#define AI_POWER_PER_CARD 50

///How many Life ticks between camera memory tracking checks
#define AI_CAMERA_MEMORY_TICKS 15

///For non-physical AI hardware (RAM expansions)
#define RACK_CREATOR (1<<15)

#define SUCCESSFUL_OVERCLOCK "success"
#define FAILED_OVERCLOCK_SPEED "Za wysokie taktowanie"
#define FAILED_OVERCLOCK_POWER "Za wysoki mnożnik mocy"
#define FAILED_OVERCLOCK_NO_POWER "Za niski mnożnik mocy"

///from /mob/living/silicon/ai/proc/set_core_display_icon(): (icon_used)
#define COMSIG_AI_ICON_CHANGE "ai_icon_change"
///from /mob/living/silicon/ai/Initialize(): (mob/living/silicon/ai/new_ai)
#define COMSIG_GLOB_AI_CREATED "!ai_created"
