// Rework drużyn Aquili (aquila/code/modules/squads/)

// Funkcje w drużynie. Dowódca to osobna flaga (squad.leader), funkcja zostaje pod spodem.
#define SQUAD_POSITION_SOLDIER "soldier"
#define SQUAD_POSITION_MEDIC "medic"
#define SQUAD_POSITION_ENGINEER "engineer"
/// Tylko do wyboru zestawu i ikon: dowódca nie ma tej funkcji zapisanej na stałe
#define SQUAD_POSITION_LEADER "leader"

#define SQUAD_POSITIONS list(SQUAD_POSITION_SOLDIER, SQUAD_POSITION_MEDIC, SQUAD_POSITION_ENGINEER)

// Stan członka drużyny w konsoli i w pagerze
#define SQUAD_STATUS_OK "ok"
#define SQUAD_STATUS_INJURED "injured"
#define SQUAD_STATUS_CRITICAL "critical"
#define SQUAD_STATUS_DEAD "dead"
#define SQUAD_STATUS_SSD "ssd"

// Znaczniki rozkazów
#define SQUAD_MARKER_MOVE "move"
#define SQUAD_MARKER_ATTACK "attack"
#define SQUAD_MARKER_DEFEND "defend"
#define SQUAD_MARKER_RETREAT "retreat"
#define SQUAD_MARKER_RALLY "rally"
#define SQUAD_MARKER_TARGET "target"
/// Osobisty znacznik najbliższego automatu drużyny („Po sprzęt” z konsoli XO), poza listą SQUAD_MARKER_TYPES
#define SQUAD_MARKER_GEAR "gear"

#define SQUAD_MARKER_TYPES list(SQUAD_MARKER_MOVE, SQUAD_MARKER_ATTACK, SQUAD_MARKER_DEFEND, SQUAD_MARKER_RETREAT, SQUAD_MARKER_RALLY, SQUAD_MARKER_TARGET)

/// Jak długo znacznik wisi w świecie i na mapie
#define SQUAD_MARKER_DURATION (90 SECONDS)
/// Odstęp między rozkazami na ekranie jednej drużyny (wspólny dla dowódcy i XO)
#define SQUAD_ORDER_COOLDOWN (30 SECONDS)
/// Odstęp między znacznikami jednego nadawcy
#define SQUAD_MARKER_COOLDOWN (3 SECONDS)
/// Najdłuższy rozkaz na ekranie
#define SQUAD_ORDER_MAX_LEN 200
/// Po tylu sekundach od śmierci dowódcy dowodzenie przejmuje następny
#define SQUAD_LEADER_SUCCESSION_DELAY (10 SECONDS)
/// Grzywna za każdy niezwrócony przedmiot z zestawu
#define SQUAD_LOAN_FINE 300
/// Auto-przydział omija drużyny, które mają tylu członków (XO może dopisać więcej)
#define SQUAD_AUTO_MAX_MEMBERS 12
/// Ile komunikatów drużyny może czekać w kolejce za tym na ekranie
#define SQUAD_ALERT_QUEUE_MAX 3
