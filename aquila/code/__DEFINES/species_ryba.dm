// Akwarianin: własna rasa Aquili. Rybka w szklanym kloszu z wodą, noszona przez mechaniczny pancerz.

#define SPECIES_AQUARIAN "aquarian"

#define isaquarian(A) (is_species(A, /datum/species/aquarian))

/// Pancerz, klosz i rybki
#define AQUARIAN_ICON 'aquila/icons/mob/species/aquarian/aquarian.dmi'

/// Klucze w dna.features i w zapisie postaci
#define FEATURE_AQUARIAN_FISH "aquarian_fish"
#define FEATURE_AQUARIAN_ARMOR "aquarian_armor"
#define FEATURE_AQUARIAN_WATER "aquarian_water"

/// Fabryczna czerwień pancerza (z tym kolorem nie rysujemy nakładki farby)
#define AQUARIAN_DEFAULT_ARMOR "a32a26"
/// Woda bez zabarwienia
#define AQUARIAN_DEFAULT_WATER "ffffff"

/// Pojemność klosza
#define AQUARIAN_DOME_VOLUME 100
/// Poniżej tego rybka zaczyna się dusić
#define AQUARIAN_WATER_LOW 30
/// Obrażenia głowy (od uderzeń), od których klosz pęka i cieknie
#define AQUARIAN_CRACK_DAMAGE 15

/// Temperatury wody w kloszu
#define AQUARIAN_WATER_FREEZE T0C
#define AQUARIAN_WATER_COLD (T0C + 10)
#define AQUARIAN_WATER_HOT (T0C + 45)
#define AQUARIAN_WATER_BOIL (T0C + 100)

/// Ile duszenia rybka zbiera na cykl życia (2 s) przy pustym kloszu (przy 200 umiera)
#define AQUARIAN_SUFFOCATION_EMPTY 8
/// Ile duszenia na cykl życia przy za małej ilości wody albo zamarzniętej wodzie
#define AQUARIAN_SUFFOCATION_LOW 2
