// Basic boty (/mob/living/basic/bot) na drzewach zachowań, port bazy z tgstation (code/__DEFINES/robots.dm, ai/bot_keys.dm).
// Stare boty (/mob/living/simple_animal/bot) używają liczbowych BOT_IDLE itd. z code/__DEFINES/robots.dm, więc tu
// stany mają przedrostek BBOT_ i od razu polski tekst (pokazywany w panelu, PDA i konsoli SI).

// Flagi trybu (bot_mode_flags)
/// Bot jest włączony
#define BOT_MODE_ON (1<<0)
/// Bot sam patroluje po nadajnikach
#define BOT_MODE_AUTOPATROL (1<<1)
/// Bot słucha poleceń z PDA i konsoli SI
#define BOT_MODE_REMOTE_ENABLED (1<<2)
/// Bot może dostać osobowość (pAI albo duch)
#define BOT_MODE_CAN_BE_SAPIENT (1<<3)

// Flagi obudowy (bot_access_flags)
/// Panel serwisowy otwarty
#define BOT_COVER_MAINTS_OPEN (1<<0)
/// Panel sterowania zablokowany
#define BOT_COVER_LOCKED (1<<1)
/// Bot zhakowany (emag albo SI)
#define BOT_COVER_EMAGGED (1<<2)
/// Zhakowany przez SI (da się cofnąć)
#define BOT_COVER_HACKED (1<<3)

// Stany (mode) - tekst widoczny dla graczy
#define BBOT_IDLE "Bezczynny"
#define BBOT_HUNT "W pościgu"
#define BBOT_PATROL "Patrolowanie"
#define BBOT_SUMMON "Wezwany"
#define BBOT_MOVING "W drodze na miejsce pracy"
#define BBOT_ARREST "Aresztowanie"
#define BBOT_CLEANING "Sprzątanie"
#define BBOT_HEALING "Leczenie"
#define BBOT_REPAIRING "Naprawianie"
#define BBOT_WORKING "Praca"
#define BBOT_DELIVER "W drodze do miejsca dostawy"
#define BBOT_GO_HOME "W drodze do bazy"
#define BBOT_BLOCKED "Czekanie na wolną drogę"
#define BBOT_NO_ROUTE "Nie można dotrzeć do celu"

// Wynik pracy bota nad celem (/mob/living/basic/bot/proc/work_on_target)
/// Praca skończona, cel zwolniony
#define BOT_WORK_DONE 1
/// Praca trwa, wywołaj znowu
#define BOT_WORK_CONTINUE 2
/// Nie da się, cel na czarną listę
#define BOT_WORK_FAILED 3
/// Cel uciekł poza zasięg, idź za nim (cel zostaje)
#define BOT_WORK_OUT_OF_REACH 4

// Tablica (blackboard)
#define BB_BEACON_TARGET "beacon_target"
#define BB_PREVIOUS_BEACON_TARGET "previous_beacon_target"
#define BB_BOT_SUMMON_TARGET "bot_summon_target"
#define BB_TEMPORARY_IGNORE_LIST "temporary_ignore_list"
#define BB_UNREACHABLE_LIST_COOLDOWN "unreachable_list_cooldown"
#define BB_BOT_BEACON_COOLDOWN "bot_beacon_cooldown"
/// Cel bieżącej pracy (pacjent, plama, dziura w podłodze, przestępca...)
#define BB_BOT_WORK_TARGET "bot_work_target"
/// Następna pogawędka bota
#define BB_BOT_CHATTER_COOLDOWN "bot_chatter_cooldown"

/// Sygnał: ustawiono flagi trybu bota (mode_flags)
#define COMSIG_BOT_MODE_FLAGS_SET "bot_mode_flags_set"
/// Sygnał: bot wraca do stanu wyjściowego
#define COMSIG_BOT_RESET "bot_reset"

/// Rodzaje botów do sterowania przez PDA (bot_type)
#define BASIC_MED_BOT "Medibot"
#define BASIC_CLEAN_BOT "Cleanbot"
#define BASIC_SEC_BOT "Securitron"
#define BASIC_REPAIR_BOT "Repairbot"
#define BASIC_FIRE_BOT "Firebot"

/// Czy to basic bot (nowe boty na drzewach)
#define isbasicbot(A) (istype(A, /mob/living/basic/bot))
