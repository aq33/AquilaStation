// Liczby ekonomii gangów Aquili (mechanika wzorowana na trybie gang war z Goonstation, kod pisany od nowa).
// Plik dołączany jako pierwszy z gangów w aquila/aquila.dm, define'y są wspólne dla wszystkich plików gangu.

/// Punkty, z którymi każdy członek zaczyna (i które dostaje nowy członek)
#define GANG_START_POINTS 1500
/// Premia dla tego, kto przyniósł przychód (reszta gangu dostaje pełną kwotę, on o tyle więcej)
#define GANG_EARNER_BONUS 0.25

// Rodzaje przychodu (składniki wyniku gangu)
#define GANG_SCORE_TURF "turf"
#define GANG_SCORE_CASH "cash"
#define GANG_SCORE_GUN "gun"
#define GANG_SCORE_DRUG "drug"
#define GANG_SCORE_EVENT "event"

/// Promień terenu zajmowanego przez jeden znak (kafelki, okrąg)
#define GANG_TAG_RADIUS 7
/// Promień, z którego znak zbiera „gorąco” od przechodzących ludzi
#define GANG_TAG_SIGHT 4
/// Teren wokół szafki gangu
#define GANG_LOCKER_RADIUS 4
/// Punkty za postawienie znaku
#define GANG_TAG_POINTS 50
/// Co ile znaki dają dochód
#define GANG_TERRITORY_INTERVAL (15 SECONDS)
/// Najwyższy dochód z jednego znaku na cykl
#define GANG_TAG_MAX_INCOME 6
/// Gorąco znaku spada co cykl do tej części
#define GANG_HEAT_DECAY 0.9

/// Ile gotówki mieści szafka
#define GANG_LOCKER_CASH_CAP 20000
/// Kredyty prane co sekundę
#define GANG_LAUNDER_PER_SECOND 66
/// Ile kredytów to jeden punkt
#define GANG_CREDITS_PER_POINT 5
/// Punkty za sprzedaną broń palną
#define GANG_GUN_POINTS 300
/// Pierwsze jednostki każdego narkotyku liczą się potrójnie
#define GANG_DRUG_BONUS_UNITS 300
/// Po tylu jednostkach narkotyk przestaje być skupowany przez gang
#define GANG_DRUG_UNIT_LIMIT 1000
/// Co ile członek może odebrać nowy mundur z szafki
#define GANG_UNIFORM_COOLDOWN (5 MINUTES)

/// Punkty dla każdego członka za otwarcie skrzyni ze zrzutu
#define GANG_CRATE_POINTS 3000
/// Punkty dla każdego członka za otwarcie torby
#define GANG_DUFFLE_POINTS 1000
#define GANG_CRATE_FIRST_DROP (15 MINUTES)
#define GANG_CRATE_INTERVAL (20 MINUTES)
/// Ostrzeżenie o zrzucie przed lądowaniem
#define GANG_CRATE_WARNING (5 MINUTES)
/// Skrzynia po wylądowaniu jest zamknięta tyle czasu
#define GANG_CRATE_LOCK_TIME (10 SECONDS)
#define GANG_DUFFLE_FIRST_DROP (8 MINUTES)
#define GANG_DUFFLE_INTERVAL (20 MINUTES)
/// Ile toreb dostaje każdy gang na raz
#define GANG_DUFFLES_PER_GANG 2

/// Po tylu minutach śmierci szefa członkowie mogą przejąć dowodzenie
#define GANG_TAKEOVER_DELAY (5 MINUTES)

/// Koszt Dominatora w punktach
#define GANG_DOMINATOR_COST 20000
