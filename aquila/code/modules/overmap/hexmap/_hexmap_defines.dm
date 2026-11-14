// AQUILA - rework mapy FTL: mapa strategiczna z kafli hex (raport/ftl_mapa_06_plan_pr.md, PR A)

/// Ile jednostek współrzędnych starmap.json przypada na jeden hex (jak w makiecie)
#define HEX_UNITS_PER_HEX 4.6
/// Margines pustych hexów wokół układów sektora
#define HEX_MARGIN 2

/// Koszt skoku o jeden hex, w procentach naładowania napędu: pełny napęd starcza na 3 kafle (okno pokazuje 34%)
#define HEX_FTL_COST_HEX (100 / 3)
/// Koszt przejścia przez bramę do innego sektora: jak dwa kafle
#define HEX_FTL_COST_GATE (200 / 3)
/// Pełny napęd
#define HEX_FTL_FULL_CHARGE 100
/// Po skoku napęd stygnie i się nie ładuje
#define HEX_FTL_COOLDOWN (60 SECONDS)
/// Rozruch przed skokiem po hexach (zamiast 30 s komputera Seegson) i jego krótszy dźwięk
#define HEX_FTL_STARTUP (10 SECONDS)
#define HEX_FTL_START_SOUND 'nsv13/sound/effects/ship/slipstream_start.ogg'
/// Czas lotu: stała część + za każdy hex trasy
#define HEX_FTL_TRAVEL_BASE (20 SECONDS)
#define HEX_FTL_TRAVEL_PER_HEX (10 SECONDS)
/// Skok awaryjny trafia w losowy hex w tym promieniu
#define HEX_EMERGENCY_MIN 1
#define HEX_EMERGENCY_MAX 2
/// Floty AI przechodzą jeden kafel co tyle
#define HEX_FLEET_STEP_MIN (2 MINUTES)
#define HEX_FLEET_STEP_MAX (5 MINUTES)
/// Pusty hex bez nikogo i bez zawartości oddaje swój układ po tym czasie
#define HEX_EMPTY_CLEANUP_DELAY (2 MINUTES)

/// Typy terenu (identyfikatory jak w makiecie v4; zapisywane w hexmap.json)
#define HEX_TERRAIN_EMPTY "empty"
#define HEX_TERRAIN_ASTEROIDS "meteor"
#define HEX_TERRAIN_JUNK "junk"
#define HEX_TERRAIN_NEBULA "nebula"
#define HEX_TERRAIN_ELECTRICAL "estorm"
#define HEX_TERRAIN_ION "storm"
#define HEX_TERRAIN_RADIATION "rad"
#define HEX_TERRAIN_FLARE "flare"
#define HEX_TERRAIN_ANOMALIES "anom"
#define HEX_TERRAIN_GRAVITY "grav"
#define HEX_TERRAIN_CARP "carp"
#define HEX_TERRAIN_WORMHOLE "wh"
#define HEX_TERRAIN_BLACK_HOLE "bh"
#define HEX_TERRAIN_COMET "comet"
#define HEX_TERRAIN_MINES "mines"
#define HEX_TERRAIN_SIGNAL "signal"

/// Nowy nieznany sygnał albo pole anomalii pojawia się co tyle (decyzja: losowo na całej mapie, co jakiś czas)
#define HEX_RANDOM_TERRAIN_MIN (10 MINUTES)
#define HEX_RANDOM_TERRAIN_MAX (20 MINUTES)
/// Najwięcej sygnałów i pól anomalii naraz na całej mapie
#define HEX_MAX_SIGNALS 10
#define HEX_MAX_ANOMALY_FIELDS 12
/// Burze, kometa i karpie przesuwają się o kafel co tyle
#define HEX_DRIFT_MIN (10 MINUTES)
#define HEX_DRIFT_MAX (15 MINUTES)

/// Kolejny event, gdy okręt stoi na kaflu zagrożenia
#define HEX_STAY_EVENT_MIN (8 MINUTES)
#define HEX_STAY_EVENT_MAX (12 MINUTES)
/// Event z kafla i event statkowy nie wypadają bliżej siebie niż tyle
#define HEX_EVENT_SPACING (4 MINUTES)
/// Znacznik w puli kafla: wadliwa SI z istniejącej SI zamiast eventu
#define HEX_POOL_MALF "malf"

/// Wojna frakcji (część D): sztaby, ekonomia i depoty co tyle
#define HEX_WAR_TICK (5 MINUTES)
/// Pierwsze przejęcie flot ze startu rundy: po spawnie losowych flot układów (generate_anomaly po 15 s)
#define HEX_WAR_SETUP_DELAY (30 SECONDS)
/// Najwięcej flot sztabu na frakcję (bez konwojów)
#define HEX_WAR_MAX_FLEETS 5
#define HEX_WAR_MAX_PIRATE_FLEETS 3
/// Najwięcej konwojów naraz na frakcję
#define HEX_WAR_MAX_CONVOYS 2
/// Stacja handlowa po napadzie piratów nie handluje przez tyle
#define HEX_WAR_RAID_TIME (20 MINUTES)
/// Ranny dowódca wraca z nową flotą po tylu minutach
#define HEX_WAR_RETURN_MIN (15 MINUTES)
#define HEX_WAR_RETURN_MAX (25 MINUTES)
/// Zasięg sztabu: cele i floty dalej niż tyle kafli nie wchodzą w plan
#define HEX_WAR_REACH 8
/// Natarcie tylko przy takiej przewadze sił
#define HEX_WAR_ADVANTAGE 1.2

/// Najwięcej okrętów eskorty kupionej na stacjach (część F)
#define HEX_ESCORT_MAX 4

/// Części na nową atomówkę w fabryce frakcji z działającą kwaterą główną
#define HEX_WAR_NUKE_PARTS 8

/// Obiekty strategiczne układów
#define HEX_FAC_MINE "mine"
#define HEX_FAC_FACTORY "factory"
#define HEX_FAC_YARD "yard"
#define HEX_FAC_DEPOT "depot"
#define HEX_FAC_POST "post"
#define HEX_FAC_HQ "hq"
#define HEX_FAC_TRADE "trade"

/// Rozkazy flot sztabu
#define HEX_ORDER_IDLE "idle"
#define HEX_ORDER_HOLD "hold"
#define HEX_ORDER_DEFEND "defend"
#define HEX_ORDER_ATTACK "attack"
#define HEX_ORDER_ESCORT "escort"
#define HEX_ORDER_REPAIR "repair"
#define HEX_ORDER_RAID "raid"
#define HEX_ORDER_HOME "home"
#define HEX_ORDER_HUNT "hunt"
#define HEX_ORDER_CONVOY "convoy"

/// Los dowódcy
#define HEX_CMD_ACTIVE "active"
#define HEX_CMD_WOUNDED "wounded"
#define HEX_CMD_DEAD "dead"

/// Mgła wojny: zasięg widoku w kaflach
#define HEX_FOG_SHIP 3
#define HEX_FOG_ALLY 1
#define HEX_FOG_POST 3

/// Zapis stanu mapy hex obok starmap.json
#define HEXMAP_SAVE_PATH "config/starmap/hexmap.json"
#define HEXMAP_SAVE_VERSION 1
/// Kopie kampanii
#define CAMPAIGN_BACKUP_DIR "data/campaign_backups/"
#define CAMPAIGN_BACKUP_AUTO_KEEP 10

/// Identyfikator hexa: sektor, kolumna, wiersz (współrzędne offsetowe, nieparzyste wiersze przesunięte w prawo)
#define HEX_ID(sector, col, row) "[sector]:[col]:[row]"
