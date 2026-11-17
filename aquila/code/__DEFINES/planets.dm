// AQUILA - planety z lądowaniem (aquila/code/modules/planets/)

/// Bok kwadratu powierzchni planety w polach, jak w Shiptest (QUADRANT_MAP_SIZE). Na poziomie rezerwacji użyteczne jest
/// ok. 239 pól między krawędziami tranzytu, więc każda odwiedzona planeta zajmuje własny poziom Z
#define PLANET_SURFACE_SIZE 127
/// Większy kwadrat dla planet, które wylosowały ruinę główną za dużą na zwykły (najdłuższe ruiny Shiptesta mają ok. 160 pól)
#define PLANET_SURFACE_SIZE_LARGE 191
/// Mniejszy kwadrat planet karłowatych
#define PLANET_SURFACE_SIZE_DWARF 95
/// Grubość niezniszczalnej krawędzi wokół powierzchni
#define PLANET_EDGE_WIDTH 3
/// Bok kwadratu lądowiska (jak w Bayu: 31 × 31)
#define PLANET_LANDING_ZONE_SIZE 31
/// Ile lądowisk wyznacza generator
#define PLANET_LANDING_ZONES 3

/// Ile procent ticku może zająć generowanie powierzchni planety. CHECK_TICK pozwala procedurze asynchronicznej zająć tick
/// do limitu MC (ok. 80-98%), a wtedy MC nie mieścił się w ticku: przez całe generowanie (kilkadziesiąt sekund) co 2-4
/// ticki jeden przepadał i serwer zwalniał (TD) u wszystkich graczy, nie tylko u lądujących.
#define PLANET_GEN_TICK_LIMIT 50
/// CHECK_TICK z niższym limitem dla generowania planet
#define PLANET_CHECK_TICK (TICK_USAGE > min(PLANET_GEN_TICK_LIMIT, Master.current_ticklimit) ? stoplag() : 0)

/// Stan powierzchni planety
#define PLANET_SURFACE_NONE 0
#define PLANET_SURFACE_GENERATING 1
#define PLANET_SURFACE_READY 2

/// Wysłany do słuchaczy pogody planety przy zmianie etapu (menedżer dźwięku przełącza pętlę)
#define COMSIG_PLANET_WEATHER_CHANGED "planet_weather_changed"
/// Wysłany do planety, kiedy jej powierzchnia jest gotowa (albo generator się poddał)
#define COMSIG_PLANET_SURFACE_READY "planet_surface_ready"

/// Biomy generatora planet (jak w Shiptest): poziomy temperatury i wilgotności
#define PLANET_BIOME_COLDEST "coldest"
#define PLANET_BIOME_COLD "cold"
#define PLANET_BIOME_WARM "warm"
#define PLANET_BIOME_TEMPERATE "temperate"
#define PLANET_BIOME_HOT "hot"
#define PLANET_BIOME_HOTTEST "hottest"

#define PLANET_BIOME_COLDEST_CAVE "coldest_cave"
#define PLANET_BIOME_COLD_CAVE "cold_cave"
#define PLANET_BIOME_WARM_CAVE "warm_cave"
#define PLANET_BIOME_HOT_CAVE "hot_cave"

#define PLANET_BIOME_LOWEST_HUMIDITY "lowest_humidity"
#define PLANET_BIOME_LOW_HUMIDITY "low_humidity"
#define PLANET_BIOME_MEDIUM_HUMIDITY "medium_humidity"
#define PLANET_BIOME_HIGH_HUMIDITY "high_humidity"
#define PLANET_BIOME_HIGHEST_HUMIDITY "highest_humidity"
