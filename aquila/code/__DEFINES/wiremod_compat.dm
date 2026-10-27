// Definicje z tg potrzebne wiremodowi z tg (aquila/code/modules/wiremod).
// Wartości jak w tgstation/tgstation, chyba że opisano inaczej.

// Kategorie w drukarce komponentów i w imprinterze (u tg to podkategorie RND_SUBCATEGORY_CIRCUITRY_*)
#define WIREMOD_CIRCUITRY "Circuitry"
#define WIREMOD_CORE "Rdzeń"
#define WIREMOD_SHELLS "Obudowy"
#define WIREMOD_COMPONENTS "Komponenty"
#define WIREMOD_ACTION_COMPONENTS "Akcje"
#define WIREMOD_BCI_COMPONENTS "BCI"
#define WIREMOD_ENTITY_COMPONENTS "Byty"
#define WIREMOD_ID_COMPONENTS "Dostęp ID"
#define WIREMOD_LIST_COMPONENTS "Listy"
#define WIREMOD_MATH_COMPONENTS "Matematyka"
#define WIREMOD_COMM_COMPONENTS "Komunikacja"
#define WIREMOD_SENSOR_COMPONENTS "Czujniki"
#define WIREMOD_STRING_COMPONENTS "Tekst"
#define WIREMOD_UTILITY_COMPONENTS "Narzędzia"

#define WIREMODE_CATEGORIES list(\
	WIREMOD_CORE,\
	WIREMOD_SHELLS,\
	WIREMOD_ACTION_COMPONENTS,\
	WIREMOD_BCI_COMPONENTS,\
	WIREMOD_ENTITY_COMPONENTS,\
	WIREMOD_ID_COMPONENTS,\
	WIREMOD_LIST_COMPONENTS,\
	WIREMOD_MATH_COMPONENTS,\
	WIREMOD_COMM_COMPONENTS,\
	WIREMOD_SENSOR_COMPONENTS,\
	WIREMOD_STRING_COMPONENTS,\
	WIREMOD_UTILITY_COMPONENTS,\
	)

/// U tg to 10 kJ. U nas zwykła bateria ma 1000 jednostek, więc zużycie na wejście zostaje jak w starym wiremodzie (1 na sygnał).
#define STANDARD_CELL_CHARGE 1000

#define TRAIT_CIRCUIT_UNDUPABLE "circuit_undupable"
#define TRAIT_CIRCUIT_UI_OPEN "circuit_ui_open"
#define TRAIT_CONNECTED_TO_CIRCUIT "connected_to_circuit"
#define CIRCUIT_HEAR_TRAIT "circuit_hear"

#define COOLDOWN_SIGNALLER_SEND "cooldown_signaller_send"
#define COOLDOWN_CIRCUIT_SOUNDEMITTER "circuit_soundemitter"
#define COOLDOWN_CIRCUIT_SPEECH "circuit_speech"
#define COOLDOWN_CIRCUIT_PATHFIND_SAME "circuit_pathfind_same"
#define COOLDOWN_CIRCUIT_PATHFIND_DIF "circuit_pathfind_different"
#define COOLDOWN_CIRCUIT_TARGET_INTERCEPT "circuit_target_intercept"
#define COOLDOWN_CIRCUIT_VIEW_SENSOR "circuit_view_sensor"
#define TIMER_COOLDOWN_RUNNING(cd_source, cd_index) LAZYACCESS(cd_source.cooldowns, cd_index)

#define MAX_BITFIELD_SIZE 24

#define IS_UNCONSCIOUS_AND_ALIVE(mob) (IS_UNCONSCIOUS(mob) && mob.stat != DEAD)
#define IS_DEAD_OR_FAKING(mob) (mob.stat == DEAD || HAS_TRAIT(mob, TRAIT_FAKEDEATH))

#define SFX_TERMINAL_TYPE "terminal_type"

#define FA_ICON_MONEY_BILL_TRANSFER "fa-money-bill-transfer"
#define FA_ICON_STOPWATCH "fa-stopwatch"

// Sygnały wysyłane przez nasze maszyny dla obudów i portów USB
#define COMSIG_DISPENSERBOT_ADD_ITEM "moneybot_add_item"
#define COMSIG_DISPENSERBOT_REMOVE_ITEM "moneybot_remove_item"
#define COMSIG_AIRLOCK_SHELL_ALLOWED "airlock_shell_try_allowed"
	#define ACCESS_ALLOWED (1<<0)
	#define ACCESS_DISALLOWED (1<<1)
#define COMSIG_SCANGATE_SHELL_PASS "scangate_shell_pass"
#define COMSIG_GUN_CHAMBER_PROCESSED "gun_chamber_processed"
#define COMSIG_EMITTER_MACHINE_SET_ON "emitter_machine_set_on"
#define COMSIG_EMITTER_MACHINE_ON_FIRE "emitter_machine_fire"
#define COMSIG_ATMOS_MACHINE_SET_ON "atmos_machine_set_on"
#define COMSIG_ASSEMBLY_PULSED "assembly_pulsed"
#define COMSIG_ASSEMBLY_ATTACHED "assembly_attached"
#define COMSIG_ASSEMBLY_DETACHED "assembly_detached"
#define COMSIG_ASSEMBLY_PRE_ATTACH "assembly_pre_attach"
	#define COMPONENT_CANCEL_ATTACH (1<<0)
#define COMSIG_TECHWEB_ADD_DESIGN "techweb_add_design"
#define COMSIG_TECHWEB_REMOVE_DESIGN "techweb_remove_design"
#define COMSIG_POWERNET_CIRCUIT_TRANSMISSION "powernet_circuit_transmision"

#define isAdminGhostAI(M) IsAdminGhost(M)
#define REGEX_REPLACE_HANDLER SHOULD_NOT_OVERRIDE(TRUE)
