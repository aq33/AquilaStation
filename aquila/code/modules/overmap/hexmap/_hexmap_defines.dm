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

/// Typy terenu (PR B dokłada resztę)
#define HEX_TERRAIN_EMPTY "empty"

/// Zapis stanu mapy hex obok starmap.json
#define HEXMAP_SAVE_PATH "config/starmap/hexmap.json"
#define HEXMAP_SAVE_VERSION 1
/// Kopie kampanii
#define CAMPAIGN_BACKUP_DIR "data/campaign_backups/"
#define CAMPAIGN_BACKUP_AUTO_KEEP 10

/// Identyfikator hexa: sektor, kolumna, wiersz (współrzędne offsetowe, nieparzyste wiersze przesunięte w prawo)
#define HEX_ID(sector, col, row) "[sector]:[col]:[row]"
