// Lag switches (port tgstation#59717, #62999). Indeksy listy SSlag_switch.measures.
// Bez DISABLE_NON_OBSJOBS z tg: blokadę dołączania mamy jako GLOB.enter_allowed (Toggle Entering).

/// Duchy nie latają swobodnie (dalej mogą orbitować i skakać), admini wyłączeni
#define DISABLE_DEAD_KEYLOOP 1
/// Duchy nie mają zoomu ani t-raya i wracają do zwykłego widoku, admini wyłączeni
#define DISABLE_GHOST_ZOOM_TRAY 2
/// Bez runechatu, zamiast niego dymki; mówiący z TRAIT_BYPASS_MEASURES wyłączeni
#define DISABLE_RUNECHAT 3
/// Bez ikon icon2html w verbach (np. examine); usr z TRAIT_BYPASS_MEASURES wyłączony
#define DISABLE_USR_ICON2HTML 4
/// Jedna wiadomość IC/dchat co slowmode_cooldown na klienta, TRAIT_BYPASS_MEASURES wyłączony
#define SLOWMODE_SAY 5
/// Bez parallaxu, jakby każdy go wyłączył w ustawieniach, TRAIT_BYPASS_MEASURES wyłączony
#define DISABLE_PARALLAX 6
/// Bez dźwięku kroków, TRAIT_BYPASS_MEASURES wyłączony
#define DISABLE_FOOTSTEPS 7

/// Liczba przełączników powyżej
#define MEASURES_AMOUNT 7

/// Mob z tą cechą omija przełączniki oznaczone jako omijalne
#define TRAIT_BYPASS_MEASURES "bypass_lagswitch_measures"

/// Klient się połączył: (client/connected)
#define COMSIG_GLOB_CLIENT_CONNECT "!client_connect"
