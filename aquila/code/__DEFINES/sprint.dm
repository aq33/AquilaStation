// Sprint i kondycja: port BeeStation/BeeStation-Hornet#14750 (tylko sprint) + wywrotka na ścianie i upadek ze schodów (nowe)

////
/// KONDYCJA (pula /datum/stamina_container, niezależna od staminaloss)
////

///Maksymalna kondycja (92: od pełnej do zadyszki ok. 24 kratki sprintu na wprost)
#define SPRINT_STAMINA_MAX 92
///Ile kondycji wraca na sekundę
#define SPRINT_STAMINA_REGEN 10
///Mnożnik regeneracji, gdy się leży
#define SPRINT_STAMINA_RESTING_REGEN_MULTIPLIER 2
///Poniżej tej części kondycji wchodzi wyczerpanie
#define SPRINT_STAMINA_EXHAUSTION_THRESHOLD (0.4)
///Powyżej tej części kondycji wyczerpanie mija
#define SPRINT_STAMINA_EXHAUSTION_RECOVERY_THRESHOLD (0.7)
///Poniżej tej części pasek pulsuje na czerwono jako ostrzeżenie
#define SPRINT_STAMINA_EXHAUSTION_WARNING (0.5)
///Spowolnienie przy wyczerpaniu (w Bee 3)
#define SPRINT_STAMINA_EXHAUSTION_SLOWDOWN 1.5

////
/// SPRINT
////

///Okno, w którym przerwa w ruchu nie zrywa rozpędu
#define SPRINT_SUSTAINED_RUN_GRACE (0.5 SECONDS)
///Po tylu kratkach w jednym kierunku sprint liczy się jako rozpęd (mała chmurka kurzu)
#define SPRINT_SUSTAINED_THRESHOLD 8
///Koszt kondycji za kratkę sprintu
#define SPRINT_COST 2.3
///Mnożnik kosztu po skosie
#define SPRINT_DIAGONAL_MODIFIER 1.4
///Mnożnik kosztu przy ciągnięciu albo noszeniu czegoś, co spowalnia
#define SPRINT_HAUL_MODIFIER 2
///Jak długo po kroku sprintu kondycja się nie regeneruje
#define SPRINT_REGEN_DELAY (1 SECONDS)
///Jak długo po ostatnim kroku sprintu upadek ze schodów jeszcze się liczy
#define SPRINT_RECENT_STEP_WINDOW (1 SECONDS)

////
/// WYWROTKA NA ŚCIANIE (nowe)
////

///Od tylu kratek rozpędu wpadnięcie w ścianę może przewrócić
#define SPRINT_WALLSLAM_MIN_MOVES 1
///Szansa (%) przy minimalnym rozpędzie
#define SPRINT_WALLSLAM_BASE_CHANCE 100
///Dodatkowa szansa (%) za każdą kratkę ponad minimum
#define SPRINT_WALLSLAM_CHANCE_PER_TILE 0
///Maksymalna szansa (%)
#define SPRINT_WALLSLAM_MAX_CHANCE 100
///Obrażenia brute w głowę przy minimalnym rozpędzie
#define SPRINT_WALLSLAM_BASE_DAMAGE 3
///Dodatkowe obrażenia za każdą kratkę ponad minimum
#define SPRINT_WALLSLAM_DAMAGE_PER_TILE 0.5
///Maksymalne obrażenia
#define SPRINT_WALLSLAM_MAX_DAMAGE 10
///Czas przewrócenia
#define SPRINT_WALLSLAM_KNOCKDOWN (2 SECONDS)

////
/// UPADEK ZE SCHODÓW (nowe)
////

///Szansa (%) na potknięcie przy sprincie w dół schodów
#define SPRINT_STAIRS_TRIP_CHANCE_DOWN 15
///Szansa (%) na potknięcie przy sprincie w górę schodów
#define SPRINT_STAIRS_TRIP_CHANCE_UP 5
///Dodatkowa szansa (%) przy wyczerpaniu
#define SPRINT_STAIRS_TRIP_EXHAUSTED_BONUS 20
///Obrażenia brute w losową kończynę
#define SPRINT_STAIRS_TRIP_DAMAGE 6
///Czas przewrócenia
#define SPRINT_STAIRS_TRIP_KNOCKDOWN (3 SECONDS)
///Najdłuższy zjazd po schodach (w kratkach)
#define SPRINT_STAIRS_MAX_SLIDE 10

///Wyczerpanie po sprincie: brak sprintu, spowolnienie, zadyszka (nie da się mówić)
#define TRAIT_EXHAUSTED "exhausted"
///Źródło cech i modyfikatorów kondycji
#define SPRINT_STAMINA_TRAIT "sprint_stamina"

#define MOVESPEED_ID_SPRINT_EXHAUSTION "sprint_exhaustion"

#define COMSIG_KB_CARBON_SPRINT_DOWN "keybinding_carbon_sprint_down"
#define COMSIG_KB_CARBON_SPRINT_UP "keybinding_carbon_sprint_up"

///Pozycja paska kondycji: wąski pasek tuż na lewo od błyskawicy staminy (ui_stamina)
#define ui_sprint_stamina "EAST-2:26,CENTER-5:8"
