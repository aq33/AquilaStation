// Gizmo z tg (tgstation/tgstation#95857, "Interface Science")

// Zagadkowe impulsy gizma
#define GIZMO_PULSE_1 "Gizmo Pulse 1"
#define GIZMO_PULSE_2 "Gizmo Pulse 2"
#define GIZMO_PULSE_3 "Gizmo Pulse 3"
#define GIZMO_PULSE_4 "Gizmo Pulse 4"
#define GIZMO_PULSE_5 "Gizmo Pulse 5"
#define GIZMO_PULSE_6 "Gizmo Pulse 6"
#define GIZMO_PULSE_7 "Gizmo Pulse 7"
#define GIZMO_PULSE_8 "Gizmo Pulse 8"

// Zagadkowe kable gizma (w tg w code/__DEFINES/wires.dm, tu trzymamy je u siebie, bo używa ich tylko gizmo)
#define CRYPTIC_WIRE_1 "Cryptic Wire 1"
#define CRYPTIC_WIRE_2 "Cryptic Wire 2"
#define CRYPTIC_WIRE_3 "Cryptic Wire 3"
#define CRYPTIC_WIRE_4 "Cryptic Wire 4"
#define CRYPTIC_WIRE_5 "Cryptic Wire 5"
#define CRYPTIC_WIRE_6 "Cryptic Wire 6"
#define CRYPTIC_WIRE_7 "Cryptic Wire 7"
#define CRYPTIC_WIRE_8 "Cryptic Wire 8"

/// From base of /datum/gizpulse/start_moving/activate(): (datum/gizpulse/pulse)
#define COMSIG_GIZMO_START_MOVING "gizmo_start_moving"
/// From base of /datum/gizpulse/stop_moving/activate(): (datum/gizpulse/pulse)
#define COMSIG_GIZMO_STOP_MOVING "gizmo_stop_moving"

/// From base of /datum/gizpulse/lights_on/activate(): ()
#define COMSIG_GIZMO_ON_STATE "gizmo_on_state"
/// From base of /datum/gizpulse/lights_off/activate(): ()
#define COMSIG_GIZMO_OFF_STATE "gizmo_off_state"

#define GIZMO_PUZZLE_WRONG 1
#define GIZMO_PUZZLE_CORRECT 2
#define GIZMO_PUZZLE_SOLVED 3

#define GIZMO_INTERFACE_WIRES "gizmo_interface_wires"
#define GIZMO_INTERFACE_VOICE "gizmo_interface_voices"

#define GIZMO_PICK_ONE "gizmo_pick_one"

/// Flagi wyładowania gizma (tg: ZAP_GIZMO_FLAGS = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)
#define GIZMO_ZAP_FLAGS (TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE)

/// Ładunek zwykłego ogniwa u nas (tg STANDARD_CELL_CHARGE = 10 kJ, u nas zwykłe ogniwo ma 1000)
#define GIZMO_CELL_CHARGE 1000
/// Odpowiednik tg STANDARD_BATTERY_CHARGE (bateria = 100 ogniw)
#define GIZMO_BATTERY_CHARGE (GIZMO_CELL_CHARGE * 100)
/// Ile dżuli tg odpowiada jednej naszej jednostce ładunku. tesla_zap liczy obrażenia tak samo jak tg (moc / 600)
#define GIZMO_TG_JOULES_PER_CHARGE 10

/// Common gizmo modes to pick from. They are also weighted so you have even more probability control isnt that cool
#define GIZMO_COMMON_MODES list(\
	/datum/gizmodes/mood_pulser = 1,\
	/datum/gizmodes/mopper = 1,\
	/datum/gizmodes/teleporter = 1,\
	/datum/gizmodes/electric = 1,\
	/datum/gizmodes/dispenser/food = 1,\
	/datum/gizmodes/sputter = 1,\
	/datum/gizmodes/copier = 1,\
	/datum/gizmodes/bad = 1,\
)
