// AQUILA - drony eksploracyjne (port z tgstation, code/__DEFINES/adventure.dm)

/// Plik z tekstami dronów w strings/
#define EXODRONE_FILE "exodrone.json"

//Special preset nodes

/// Victory node - Get loot and exit
#define WIN_NODE "WIN"
/// Failure node - No loot, get damaged and exit.
#define FAIL_NODE "FAIL"
/// Failure node - No loot and drone blown up.
#define FAIL_DEATH_NODE "FAIL_DEATH"
/// Return node - navigates to previous adventure node.
#define GO_BACK_NODE "GO BACK"

//Adventure results
#define ADVENTURE_RESULT_SUCCESS "success"
#define ADVENTURE_RESULT_DAMAGE "damage"
#define ADVENTURE_RESULT_DEATH "death"

// Exploration drone states

/// Drone is stationside - allow changing tools and such.
#define EXODRONE_IDLE "idle"
/// Drone is traveling from or to the exploration site
#define EXODRONE_TRAVEL "travel"
/// Drone is in adventure/event caused timeout
#define EXODRONE_BUSY "busy"
/// Drone is at exploration site either idle or in simple event
#define EXODRONE_EXPLORATION "exploration"
/// Drone is currently playing an adventure
#define EXODRONE_ADVENTURE "adventure"

// Scanner bands, use these to guess what's in the site and prepare drone accordingly.
#define EXOSCANNER_BAND_PLASMA "Pasmo absorpcji plazmy"
#define EXOSCANNER_BAND_LIFE "Węglowodory/tlen cząsteczkowy"
#define EXOSCANNER_BAND_TECH "Wąskopasmowe fale radiowe"
#define EXOSCANNER_BAND_RADIATION "Egzotyczne promieniowanie"
#define EXOSCANNER_BAND_DENSITY "Zwiększona gęstość"

// Exodrone tools. Klucze są też jakościami w przygodach JSON, więc zostają po angielsku.
#define EXODRONE_TOOL_WELDER "welder"
#define EXODRONE_TOOL_TRANSLATOR "translator"
#define EXODRONE_TOOL_LASER "laser"
#define EXODRONE_TOOL_MULTITOOL "multitool"
#define EXODRONE_TOOL_DRILL "drill"

GLOBAL_LIST_INIT(exodrone_tool_metadata, list(
	EXODRONE_TOOL_WELDER = list("name" = "spawarka", "description" = "Wytrzymała spawarka.", "icon" = "burn"),
	EXODRONE_TOOL_TRANSLATOR = list("name" = "tłumacz", "description" = "Mocne oprogramowanie do tłumaczenia i zapisu danych.", "icon" = "language"),
	EXODRONE_TOOL_LASER = list("name" = "laser", "description" = "Wielofunkcyjne narzędzie do walki i precyzyjnego cięcia.", "icon" = "bolt"),
	EXODRONE_TOOL_MULTITOOL = list("name" = "multitool", "description" = "Wielofunkcyjne narzędzie do elektroniki. Ma zestaw czujników promieniowania i fal radiowych.", "icon" = "broadcast-tower"),
	EXODRONE_TOOL_DRILL = list("name" = "wiertło", "description" = "Wytrzymałe wiertło, przydatne w górnictwie.", "icon" = "screwdriver")
))

// Site traits. Wartości są też wymaganiami w przygodach JSON, więc zostają po angielsku.

/// Some kind of ruined interior
#define EXPLORATION_SITE_RUINS "ruins"
/// Power, wires and machinery present.
#define EXPLORATION_SITE_TECHNOLOGY "technology present"
/// It's a space station
#define EXPLORATION_SITE_STATION "space station"
/// It's ancient alien site
#define EXPLORATION_SITE_ALIEN "alien"
/// Carbon-based life-forms can live here
#define EXPLORATION_SITE_HABITABLE "habitable"
/// Site is in space
#define EXPLORATION_SITE_SPACE "in space"
/// Site is located on planet/moon/whatever surface
#define EXPLORATION_SITE_SURFACE "on surface"
/// Site is a space ship
#define EXPLORATION_SITE_SHIP "spaceship"
/// Site is civilized and populated, trading stations,cities etc. Lack of this trait means it's wilderness
#define EXPLORATION_SITE_CIVILIZED "civilized"

/// Scan types

// Wide scan, untargeted scan only reveals interest points. Cost increases exponentially with each firing. No scan conditions.
#define EXOSCAN_WIDE "wide"
// Point scan, reveals name/description and general band information. Flat cost. Affected by scan conditions of the site
#define EXOSCAN_POINT "point"
// Deep scan, reveals event scan texts. Linear cost increase with distance. Affected by scan conditions of the site.
#define EXOSCAN_DEEP "deep"

///  Adventure Effect Types

//completely removes the quality
#define ADVENTURE_EFFECT_TYPE_REMOVE "Remove"
//adds/substracts value from quality
#define ADVENTURE_EFFECT_TYPE_ADD "Add"
//sets quality to specific value
#define ADVENTURE_EFFECT_TYPE_SET "Set"

/// Adventure Effect Value Types

/// rolls value between low and high inclusive
#define ADVENTURE_QUALITY_TYPE_RANDOM "random"
#define ADVENTURE_RANDOM_QUALITY_LOW_FIELD "low"
#define ADVENTURE_RANDOM_QUALITY_HIGH_FIELD "high"

// Sygnały (tg: code/__DEFINES/dcs/signals/signals_adventure.dm)

/// Exoprobe adventure finished: (result) result is ADVENTURE_RESULT_??? values
#define COMSIG_ADVENTURE_FINISHED "adventure_done"
/// Sent on initial adventure qualities generation from /datum/adventure/proc/initialize_qualities(): (list/quality_list)
#define COMSIG_ADVENTURE_QUALITY_INIT "adventure_quality_init"
/// Sent on adventure node delay start: (delay_time, delay_message)
#define COMSIG_ADVENTURE_DELAY_START "adventure_delay_start"
/// Sent on adventure delay finish: ()
#define COMSIG_ADVENTURE_DELAY_END "adventure_delay_end"
/// Exoprobe status changed : ()
#define COMSIG_EXODRONE_STATUS_CHANGED "exodrone_status_changed"
/// Sent on begingging of new scan : (datum/exoscan/new_scan)
#define COMSIG_EXOSCAN_STARTED "exoscan_started"
/// Sent on successful finish of exoscan: (datum/exoscan/finished_scan)
#define COMSIG_EXOSCAN_FINISHED "exoscan_finished"
/// Sent on exoscan failure/manual interruption: ()
#define COMSIG_EXOSCAN_INTERRUPTED "exoscan_interrupted"
