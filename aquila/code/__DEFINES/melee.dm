#define MARTIALART_NANOJUTSU "nanojutsu"

// Blokowanie z nowego Bee (BeeStation-Hornet code/__DEFINES/combat.dm). Bity 0-3 są w core (BLOCKING_ACTIVE ... BLOCKING_HUNTER)
/// Po udanym bloku broń ma 50% szansy na oddanie ciosu (w trybie walki)
#define BLOCKING_COUNTERATTACK (1<<4)
/// Po udanym bloku 20% szansy na przewrócenie atakującego i opóźnienie jego następnego ciosu
#define BLOCKING_UNBALANCE (1<<5)
/// Cios tym przedmiotem zablokuje tylko inny przedmiot z tą flagą
#define BLOCKING_UNBLOCKABLE (1<<6)
/// Zablokowanie ciosu tym przedmiotem nie kosztuje staminy
#define BLOCKING_EFFORTLESS (1<<7)
/// Przerwa między blokami tej samej osoby (tarcze jej nie mają)
#define BLOCK_CD (2 SECONDS)

// Parowanie z Paradise (code/datums/components/parry.dm)
/// Jak długo po wciśnięciu klawisza parowanie działa
#define PARRY_DEFAULT_TIMEOUT (1 SECONDS)
/// Opóźnienie ataku po wciśnięciu parowania
#define CLICK_CD_PARRY 8
#define ALL_ATTACK_TYPES list(MELEE_ATTACK, UNARMED_ATTACK, PROJECTILE_ATTACK, THROWN_PROJECTILE_ATTACK, LEAP_ATTACK)
#define NON_PROJECTILE_ATTACKS list(MELEE_ATTACK, UNARMED_ATTACK, LEAP_ATTACK)
