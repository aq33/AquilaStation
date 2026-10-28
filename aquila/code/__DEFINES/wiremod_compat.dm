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
	// ACCESS_DISALLOWED jest już w heretic.dm
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
// Konsole i pady z portem USB (aquila/code/modules/wiremod/usb/consoles_pads.dm)
#define COMSIG_ADVANCED_CAMERA_EYE_CREATED "advanced_camera_eye_created"
#define COMSIG_REMOTE_CAMERA_ASSIGN_USER "remote_camera_assign_user"
#define COMSIG_TELEPORTER_NEW_TARGET "teleporter_new_target"

// Sygnały dla portów USB atmosu i urządzeń ściennych (aquila/code/modules/wiremod/usb/atmos_wall.dm)
#ifndef COMSIG_AIRALARM_UPDATE_MODE
#define COMSIG_AIRALARM_UPDATE_MODE "airalarm_set_mode"
#endif
/// Alarm powietrza wysłał alert (alert_level: 0 czysto, 1 drobny, 2 poważny)
#ifndef COMSIG_AIRALARM_ALERT_POSTED
#define COMSIG_AIRALARM_ALERT_POSTED "airalarm_alert_posted"
#endif
#ifndef COMSIG_FIREALARM_ON_TRIGGER
#define COMSIG_FIREALARM_ON_TRIGGER "firealarm_trigger"
#endif
#ifndef COMSIG_FIREALARM_ON_RESET
#define COMSIG_FIREALARM_ON_RESET "firealarm_reset"
#endif
#ifndef COMSIG_LIGHT_SWITCH_SET
#define COMSIG_LIGHT_SWITCH_SET "light_switch_set"
#endif
#ifndef COMSIG_VITALS_SET_PATIENT
#define COMSIG_VITALS_SET_PATIENT "vitals_set_patient"
#endif

// Komputery modułowe jako obudowy układów (aquila/code/modules/wiremod/modular_computers/)
/// Program da się obsługiwać z układu nawet wtedy, gdy nie jest uruchomiony (u tg flaga w program_flags)
#define PROGRAM_CIRCUITS_RUN_WHEN_CLOSED (1<<5)
/// Komputer został włączony: (mob/user)
#define COMSIG_MODULAR_COMPUTER_TURNED_ON "comsig_modular_computer_turned_on"
/// Komputer został wyłączony: (loud)
#define COMSIG_MODULAR_COMPUTER_SHUT_DOWN "comsig_modular_computer_shut_down"
/// Wysyłany do programu po udanym starcie: (mob/user)
#define COMSIG_COMPUTER_PROGRAM_START "computer_program_start"
/// Wysyłany do programu po zamknięciu: (forced)
#define COMSIG_COMPUTER_PROGRAM_KILL "computer_program_kill"
/// Radar pyta, czy cel da się śledzić: (atom/signal, turf/signal_turf, turf/computer_turf)
#define COMSIG_MODULAR_COMPUTER_RADAR_TRACKABLE "comsig_modular_computer_radar_trackable"
	#define COMPONENT_RADAR_TRACK_ANYWAY (1<<0)
	#define COMPONENT_RADAR_DONT_TRACK (1<<1)
/// Radar szuka śledzonego atomu: (list/atom_container)
#define COMSIG_MODULAR_COMPUTER_RADAR_FIND_ATOM "comsig_modular_computer_radar_find_atom"
/// Użytkownik wybrał cel w radarze: (selected_ref)
#define COMSIG_MODULAR_COMPUTER_RADAR_SELECTED "comsig_modular_computer_radar_selected"
/// Komunikator odebrał wiadomość: (datum/signal/subspace/messaging/tablet_msg/signal, job, name)
#define COMSIG_MODULAR_PDA_MESSAGE_RECEIVED "comsig_modular_pda_message_received"
/// Notatnik zmienił treść notatki: (new_note) - u tg robi to COMSIG_UI_ACT, którego u nas nie ma
#define COMSIG_COMPUTER_NOTEPAD_UPDATED "computer_notepad_updated"

// Komponent MMI z modułem B.O.R.I.S. (aquila/code/modules/wiremod/components/action/mmi.dm)
/// SI kliknęła atom (z /mob/living/silicon/ai/ClickOn przed attack_ai): (mob/living/silicon/ai/user)
#ifndef COMSIG_ATOM_ATTACK_AI
#define COMSIG_ATOM_ATTACK_AI "atom_attack_ai"
#endif

// Syntezator, aparat i wiązka przewodów (aquila/code/modules/wiremod/usb/misc_objects.dm, components/action/camera.dm, components/utility/wire_bundle.dm)
/// Pytanie do instrumentu, czy przerwać granie: (atom/music_player). Zwróć IGNORE_INSTRUMENT_CHECKS, by grać dalej.
#define COMSIG_INSTRUMENT_SHOULD_STOP_PLAYING "instrument_should_stop_playing"
	#define IGNORE_INSTRUMENT_CHECKS (1<<0)
/// Aparat zrobił zdjęcie: (atom/target, mob/user)
#define COMSIG_CAMERA_IMAGE_CAPTURED "camera_image_captured"
/// Maks. odległość celu zdjęcia robionego przez układ scalony
#define CAMERA_CIRCUIT_MAX_RANGE 7
/// Przewód dostał impuls: (wire, user). U nas wysyła go tylko /datum/wires/wire_bundle_component.
#define COMSIG_PULSE_WIRE "pulse_wire"
#define MAX_WIRE_COUNT 17
#define TRAIT_COMPONENT_WIRE_BUNDLE "component_wire_bundle"
