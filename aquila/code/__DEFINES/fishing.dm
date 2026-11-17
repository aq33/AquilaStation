// AQUILA - woda na planetach i wędkarstwo (aquila/code/modules/planets/water/)

/// Przedmiot albo mob jest zanurzony w wodzie (element immerse)
#define TRAIT_IMMERSED "immersed"
/// Gracz właśnie łowi (jedno łowienie naraz)
#define TRAIT_GONE_FISHING "gone_fishing"

/// Wysłany do pola z łowiskiem, kiedy ktoś zarzuca wędkę (przed utworzeniem komponentu łowiska): (obj/item/fishing_rod/rod, mob/user)
#define COMSIG_PRE_FISHING "pre_fishing"
/// Wysłany do łowiska przy zarzuceniu wędki: (obj/item/fishing_rod/rod, mob/user). Zwraca FISHING_ROD_CAST_HANDLED.
#define COMSIG_FISHING_ROD_CAST "fishing_rod_cast"
	#define FISHING_ROD_CAST_HANDLED (1<<0)
/// Wysłany do łowienia po wygranej albo przegranej: (mob/user, win)
#define COMSIG_FISHING_CHALLENGE_COMPLETED "fishing_challenge_completed"
/// Wysłany z /client/MouseDown i /client/MouseUp do klienta: (object, location, control, params)
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"

/// Wpis w tabeli łowiska oznaczający pusty zarzut (nic nie bierze)
#define FISHING_DUD "dud"
/// Bazowa i najmniejsza trudność minigry (0-100)
#define FISHING_DEFAULT_DIFFICULTY 15
#define FISHING_MINIMUM_DIFFICULTY 6
/// O ile przynęta zmniejsza trudność
#define FISHING_BAIT_DIFFICULTY_MOD -5
/// Wysokość pola minigry w jednostkach ruchu ryby i przynęty (jak w tg)
#define FISHING_MINIGAME_AREA 1000

/// Nazwy łowisk (wspólne instancje w GLOB.preset_fish_sources)
#define FISHING_SPOT_PRESET_BEACH "beach"
#define FISHING_SPOT_PRESET_STORMY "stormy"
#define FISHING_SPOT_PRESET_JUNGLE "jungle"
#define FISHING_SPOT_PRESET_OASIS "oasis"
#define FISHING_SPOT_PRESET_LAVA "lava"
