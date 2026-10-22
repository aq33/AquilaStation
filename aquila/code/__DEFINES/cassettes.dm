// AQUILA - kasety z Monkestation (code/modules/cassettes, autor Dwasint)

/// Kasety nagrane przez graczy i zatwierdzone przez adminów (zapisywane w trakcie gry)
#define CASSETTE_BASE_DIR "data/cassette_storage/"
/// Lista zatwierdzonych kaset w CASSETTE_BASE_DIR
#define CASSETTE_ID_FILE (CASSETTE_BASE_DIR + "ids.json")
/// Dane kasety o danym ID
#define CASSETTE_FILE(id) (CASSETTE_BASE_DIR + "[id].json")
/// Ile razy kupiono każdą kasetę w bibliotece (ranking „najpopularniejsze”)
#define CASSETTE_PURCHASES_FILE (CASSETTE_BASE_DIR + "purchases.json")
/// Kasety dołączone do repozytorium - zawsze zatwierdzone, wczytywane przy każdym starcie
#define CASSETTE_BUILTIN_DIR "config/cassettes/"

/// Nowa albo zmieniona kaseta, niezgłoszona do zatwierdzenia
#define CASSETTE_STATUS_UNAPPROVED 0
/// Czeka na decyzję admina
#define CASSETTE_STATUS_REVIEWING 1
#define CASSETTE_STATUS_APPROVED 2
#define CASSETTE_STATUS_DENIED 3
#define CASSETTE_STATUS_DELETED 4

/// Ile utworów mieści jedna strona kasety
#define MAX_SONGS_PER_CASSETTE_SIDE 7
/// Ile aquilosów kosztuje zgłoszenie kasety do zatwierdzenia (zwracane przy odrzuceniu)
#define CASSETTE_SUBMIT_COST 500
/// Głośność walkmana (0-1) w przeglądarce słuchacza
#define WALKMAN_GAIN 0.5
