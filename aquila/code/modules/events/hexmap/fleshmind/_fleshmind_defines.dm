// AQUILA - Umysł z ciała (Fleshmind): define'y roju (port z Bubberstation/Bubberstation modular_zubbers/code/game/gamemodes/fleshmind/_fleshmind_defines.dm)
// Ours keeps only what the port uses and adds the hard limits of the swarm (decision of the review of aq33/AquilaStation#720):
// one core, at most FLESHMIND_MAX_WIREWEED wireweed within FLESHMIND_MAX_RADIUS of it, three levels instead of six.

/// Frakcja roju: moby, struktury i kapłan przewodów się nie atakują
#define FACTION_FLESHMIND "fleshmind"

#define FLESHMIND_LIGHT_BLUE "#50edd9"

/// Najwyższy poziom roju (u Bubbera 6, a na 6 rój przejmuje prom i kończy rundę)
#define FLESHMIND_LEVEL_MAX 3
/// Punkty roju potrzebne na poziom 2 i 3 (przewody + 5 za strukturę + przejęte maszyny)
#define FLESHMIND_LEVEL_2_POINTS 80
#define FLESHMIND_LEVEL_3_POINTS 160
/// O tyle rośnie wytrzymałość rdzenia z każdym poziomem
#define FLESHMIND_LEVEL_UP_CORE_INTEGRITY 300

/// Twarda granica rozrostu: najwyżej tyle przewodów
#define FLESHMIND_MAX_WIREWEED 200
/// Najdalej tyle pól od rdzenia
#define FLESHMIND_MAX_RADIUS 20
/// Najwyżej tyle struktur (bez ścian i drzwi)
#define FLESHMIND_MAX_STRUCTURES 12
/// Najwyżej tyle mobów roju naraz
#define FLESHMIND_MAX_MOBS 12
/// Najwyżej tyle przejętych maszyn
#define FLESHMIND_MAX_MACHINES 25

/// Postęp potrzebny na jeden rozrost i postęp na sekundę (jak u Bubbera: 125 na sekundę, 200 na rozrost)
#define FLESHMIND_SPREAD_PROGRESS_REQUIRED 200
#define FLESHMIND_SPREAD_PROGRESS_PER_SECOND 125
/// Co tyle rozrostów nowa struktura (u Bubbera 50 przy nieograniczonym rozroście)
#define FLESHMIND_SPREADS_FOR_STRUCTURE 20
/// Rozrosty i struktury od razu po wykiełkowaniu rdzenia
#define FLESHMIND_INITIAL_SPREADS 20
#define FLESHMIND_INITIAL_STRUCTURES 3
/// Najdalej o tyle pól przewody przeskakują rurami wentylacji
#define FLESHMIND_MAX_VENT_SPREAD 15
/// Ile przewodów usycha na sekundę po zniszczeniu rdzenia
#define FLESHMIND_DECAY_PER_SECOND 2

/// Po tylu sekundach od wykiełkowania rdzenia czujniki okrętu ogłaszają rój
#define FLESHMIND_ANNOUNCE_DELAY (3 MINUTES)
/// Po tylu sekundach oko kapłana samo stawia rdzeń
#define FLESHMIND_EYE_FORCE_SPAWN_TIME (3 MINUTES)

/// Rdzeń uszkodzony: przewody w tym promieniu znowu rosną
#define FLESHMIND_CORE_DAMAGE_ACTIVATION_RANGE 6
/// Coś roju zginęło: przewody w tym promieniu znowu rosną
#define FLESHMIND_GENERAL_ACTIVATION_RANGE 2

#define FLESHMIND_WIREWEED_HEAL_CHANCE 10
#define FLESHMIND_WIREWEED_HEAL_AMOUNT 3
#define FLESHMIND_WIREWEED_CUT_TIME (1.5 SECONDS)

#define FLESHMIND_MALFUNCTION_RESET_TIME (3 SECONDS)
#define FLESHMIND_MALFUNCTION_CORE_DEATH_TIME (20 SECONDS)
#define FLESHMIND_MALFUNCTION_LOW 0.5
#define FLESHMIND_MALFUNCTION_MEDIUM 1
#define FLESHMIND_MALFUNCTION_HIGH 2

#define FLESHMIND_STRUCTURE_EMP_LIGHT_TIME (3 SECONDS)
#define FLESHMIND_STRUCTURE_EMP_HEAVY_TIME (7 SECONDS)
#define FLESHMIND_STRUCTURE_EMP_LIGHT_DAMAGE 30
#define FLESHMIND_STRUCTURE_EMP_HEAVY_DAMAGE 50
#define FLESHMIND_MOB_EMP_LIGHT_DAMAGE 5
#define FLESHMIND_MOB_EMP_HEAVY_DAMAGE 10

/// Zasięg, na jaki działa większość struktur
#define FLESHMIND_VIEW_RANGE 7

/// Mechiwer połyka cel, który ma mniej niż tyle zdrowia (ułamek)
#define FLESHMIND_MECHIVER_CONSUME_THRESHOLD 0.3
#define FLESHMIND_MECHIVER_CONVERSION_TIME (20 SECONDS)
#define FLESHMIND_MECHIVER_TORMENT_LOWER 20
#define FLESHMIND_MECHIVER_TORMENT_UPPER 40

/// Sygnał na kontrolerze: rój zmienił poziom (nowy poziom)
#define COMSIG_FLESHMIND_LEVEL_UP "fleshmind_level_up"

/// Godziny gry żywą postacią potrzebne do roli kapłana przewodów (gdy config włącza limity godzin)
#define FLESHMIND_PRIEST_LIVING_HOURS 4
