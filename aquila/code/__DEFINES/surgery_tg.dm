// AQUILA - szkielet chirurgii z tgstation#93697 (aquila/code/modules/surgery_tg/).
// Nazwy i wartości jak w tg (code/__DEFINES/surgery.dm, code/__DEFINES/bodyparts.dm), żeby kolejne pliki operacji dało się przenosić 1:1.

// --- Gotowość do operacji ---

/// Mob albo kończyna przygotowana do operacji (serwety, prześcieradło). Bez tego nowe operacje się nie pokazują.
#define TRAIT_READY_TO_OPERATE "ready_to_operate"
/// Może operować samego siebie także przy operacjach bez OPERATION_SELF_OPERABLE (z karą do czasu)
#define TRAIT_SELF_SURGERY "self_surgery"
/// Ignoruje wszystkie modyfikatory szybkości operacji (kary i premie) i nigdy nie partaczy
#define TRAIT_IGNORE_SURGERY_MODIFIERS "ignore_surgery_modifiers"
/// Nie czuje bólu (mutacje z tg). Pacjent nie czuje operacji, operacja idzie trochę szybciej.
#define TRAIT_ANALGESIA "analgesia"
/// id statusu /datum/status_effect/surgery_prepped (źródło TRAIT_READY_TO_OPERATE: TRAIT_STATUS_EFFECT(SURGERY_PREPPED_ID))
#define SURGERY_PREPPED_ID "surgery_prepped"
/// Opcje w menu radialnym serwet/prześcieradła (surgery_initiator)
#define SURGERY_PREP_CHOICE_ADD "Przygotuj do operacji narzędziami"
#define SURGERY_PREP_CHOICE_REMOVE "Zdejmij przygotowanie do operacji"

// --- Stan chirurgiczny kończyny (bodypart.surgery_state) ---

/// Skóra nacięta
#define SURGERY_SKIN_CUT (1<<0)
/// Skóra odciągnięta, potrzebne do prawie każdej operacji
#define SURGERY_SKIN_OPEN (1<<1)
/// Naczynia odsłonięte, przecięte i krwawią
#define SURGERY_VESSELS_UNCLAMPED (1<<2)
/// Naczynia odsłonięte, ale zaciśnięte
#define SURGERY_VESSELS_CLAMPED (1<<3)
/// Organy w kończynie nacięte
#define SURGERY_ORGANS_CUT (1<<4)
/// Kość nawiercona (wyklucza przepiłowaną)
#define SURGERY_BONE_DRILLED (1<<5)
/// Kość przepiłowana
#define SURGERY_BONE_SAWED (1<<6)
/// Chirurgia plastyczna: nałożony plastik
#define SURGERY_PLASTIC_APPLIED (1<<7)
/// Proteza odkręcona
#define SURGERY_PROSTHETIC_UNSECURED (1<<8)
/// Jama ciała rozwarta (implanty w jamie)
#define SURGERY_CAVITY_WIDENED (1<<9)

DEFINE_BITFIELD(surgery_state, list(
	"SKIN CUT" = SURGERY_SKIN_CUT,
	"SKIN OPEN" = SURGERY_SKIN_OPEN,
	"VESSELS UNCLAMPED" = SURGERY_VESSELS_UNCLAMPED,
	"VESSELS CLAMPED" = SURGERY_VESSELS_CLAMPED,
	"ORGANS CUT" = SURGERY_ORGANS_CUT,
	"BONE DRILLED" = SURGERY_BONE_DRILLED,
	"BONE SAWED" = SURGERY_BONE_SAWED,
	"PLASTIC APPLIED" = SURGERY_PLASTIC_APPLIED,
	"PROSTHETIC UNSECURED" = SURGERY_PROSTHETIC_UNSECURED,
	"CAVITY OPENED" = SURGERY_CAVITY_WIDENED,
))

/// Stan po ludzku (analizator, komputer operacyjny). Kolejność ma znaczenie.
#define SURGERY_STATE_READABLE list(\
	"Skóra nacięta" = SURGERY_SKIN_CUT, \
	"Skóra odciągnięta" = SURGERY_SKIN_OPEN, \
	"Naczynia krwawią (niezaciśnięte)" = SURGERY_VESSELS_UNCLAMPED, \
	"Naczynia zaciśnięte" = SURGERY_VESSELS_CLAMPED, \
	"Organy nacięte" = SURGERY_ORGANS_CUT, \
	"Kość nawiercona" = SURGERY_BONE_DRILLED, \
	"Kość przepiłowana" = SURGERY_BONE_SAWED, \
	"Nałożony plastik" = SURGERY_PLASTIC_APPLIED, \
	"Proteza odkręcona" = SURGERY_PROSTHETIC_UNSECURED, \
	"Jama ciała rozwarta" = SURGERY_CAVITY_WIDENED, \
)

/// Wymagania operacji po ludzku. must_must_not to "must" albo "must not", jak w tg.
#define SURGERY_STATE_GUIDES(must_must_not) list(\
	"skóra [must_must_not == "must" ? "musi" : "nie może"] być nacięta" = SURGERY_SKIN_CUT, \
	"skóra [must_must_not == "must" ? "musi" : "nie może"] być odciągnięta" = SURGERY_SKIN_OPEN, \
	"naczynia [must_must_not == "must" ? "muszą" : "nie mogą"] krwawić (niezaciśnięte)" = SURGERY_VESSELS_UNCLAMPED, \
	"naczynia [must_must_not == "must" ? "muszą" : "nie mogą"] być zaciśnięte" = SURGERY_VESSELS_CLAMPED, \
	"organy [must_must_not == "must" ? "muszą" : "nie mogą"] być nacięte" = SURGERY_ORGANS_CUT, \
	"kość [must_must_not == "must" ? "musi" : "nie może"] być nawiercona" = SURGERY_BONE_DRILLED, \
	"kość [must_must_not == "must" ? "musi" : "nie może"] być przepiłowana" = SURGERY_BONE_SAWED, \
	"plastik [must_must_not == "must" ? "musi" : "nie może"] być nałożony" = SURGERY_PLASTIC_APPLIED, \
	"proteza [must_must_not == "must" ? "musi" : "nie może"] być odkręcona" = SURGERY_PROSTHETIC_UNSECURED, \
	"jama ciała [must_must_not == "must" ? "musi" : "nie może"] być rozwarta" = SURGERY_CAVITY_WIDENED, \
)

/// Stan ma wszystkie podane flagi
#define HAS_SURGERY_STATE(input_state, check_state) ((input_state & (check_state)) == (check_state))
/// Stan ma którąkolwiek z podanych flag
#define HAS_ANY_SURGERY_STATE(input_state, check_state) ((input_state & (check_state)))
/// Kończyna ma wszystkie podane flagi
#define LIMB_HAS_SURGERY_STATE(limb, check_state) HAS_SURGERY_STATE(limb?.surgery_state, check_state)
/// Kończyna ma którąkolwiek z podanych flag
#define LIMB_HAS_ANY_SURGERY_STATE(limb, check_state) HAS_ANY_SURGERY_STATE(limb?.surgery_state, check_state)

#define ALL_SURGERY_SKIN_STATES (SURGERY_SKIN_CUT|SURGERY_SKIN_OPEN)
#define ALL_SURGERY_VESSEL_STATES (SURGERY_VESSELS_UNCLAMPED|SURGERY_VESSELS_CLAMPED)
#define ALL_SURGERY_BONE_STATES (SURGERY_BONE_DRILLED|SURGERY_BONE_SAWED)
#define ALL_SURGERY_ORGAN_STATES (SURGERY_ORGANS_CUT)
/// Te stany znikają przy zamknięciu operacji (kauteryzacja, zszycie, przykręcenie obudowy)
#define ALL_SURGERY_STATES_UNSET_ON_CLOSE (ALL_SURGERY_SKIN_STATES|ALL_SURGERY_VESSEL_STATES|ALL_SURGERY_BONE_STATES|ALL_SURGERY_ORGAN_STATES|SURGERY_CAVITY_WIDENED)

/// Stany włączone na stałe, gdy kończyna nie ma skóry / kości / naczyń (tg). U nas każda kończyna ma wszystkie trzy, patrz LIMB_HAS_*.
#define SKINLESS_SURGERY_STATES (SURGERY_SKIN_OPEN)
#define BONELESS_SURGERY_STATES (SURGERY_BONE_DRILLED|SURGERY_BONE_SAWED)
#define VESSELLESS_SURGERY_STATES (SURGERY_VESSELS_CLAMPED|SURGERY_ORGANS_CUT)

/// tg liczy to z biological_state. U nas nie ma biological_state: każda kończyna (organiczna i robotyczna) ma skórę/obudowę, kość/szkielet i naczynia/kable.
#define LIMB_HAS_SKIN(limb) (!isnull(limb))
#define LIMB_HAS_BONES(limb) (!isnull(limb))
#define LIMB_HAS_VESSELS(limb) (!isnull(limb))

// --- Flagi operacji (operation_flags) ---

/// Zmienia nastrój pacjenta (początek, sukces, porażka)
#define OPERATION_AFFECTS_MOOD (1<<0)
/// Liczona w statystykach (blackbox)
#define OPERATION_NOTABLE (1<<1)
/// Powtarza się sama, dopóki można
#define OPERATION_LOOPING (1<<2)
/// tg: premia dla chirurga z TRAIT_MORBID i okrutnym narzędziem. U nas tylko znacznik (brak cechy).
#define OPERATION_MORBID (1<<3)
/// Niedostępna od ręki, trzeba ją odblokować (sygnał COMSIG_LIVING_OPERATING_ON / COMSIG_ATOM_BEING_OPERATED_ON)
#define OPERATION_LOCKED (1<<4)
/// Można ją zrobić na sobie
#define OPERATION_SELF_OPERABLE (1<<5)
/// Pacjent nie musi leżeć
#define OPERATION_STANDING_ALLOWED (1<<6)
/// Zawsze może się nie udać, nawet z TRAIT_IGNORE_SURGERY_MODIFIERS
#define OPERATION_ALWAYS_FAILABLE (1<<7)
/// Ubranie nie przeszkadza
#define OPERATION_IGNORE_CLOTHES (1<<8)
/// Podpowiadana jako następny krok (komputer operacyjny)
#define OPERATION_PRIORITY_NEXT_STEP (1<<9)
/// Chirurgia mechaniczna (protezy, IPC): dźwięk narzędzia, bez krzyku
#define OPERATION_MECHANIC (1<<10)
/// tg: ukryta przed autowiki. U nas tylko znacznik.
#define OPERATION_NO_WIKI (1<<11)
/// Działa na odciętej kończynie (u nas na razie bez punktu wejścia)
#define OPERATION_NO_PATIENT_REQUIRED (1<<12)

DEFINE_BITFIELD(operation_flags, list(
	"AFFECTS MOOD" = OPERATION_AFFECTS_MOOD,
	"NOTABLE" = OPERATION_NOTABLE,
	"LOOPING" = OPERATION_LOOPING,
	"MORBID" = OPERATION_MORBID,
	"LOCKED" = OPERATION_LOCKED,
	"SELF OPERABLE" = OPERATION_SELF_OPERABLE,
	"STANDING ALLOWED" = OPERATION_STANDING_ALLOWED,
	"ALWAYS FAILABLE" = OPERATION_ALWAYS_FAILABLE,
	"IGNORE CLOTHES" = OPERATION_IGNORE_CLOTHES,
	"PRIORITY NEXT STEP" = OPERATION_PRIORITY_NEXT_STEP,
	"MECHANIC" = OPERATION_MECHANIC,
))

// --- Nastrój ---
#define SURGERY_STATE_STARTED "surgery_started"
#define SURGERY_STATE_FAILURE "surgery_failed"
#define SURGERY_STATE_SUCCESS "surgery_success"
#define SURGERY_MOOD_CATEGORY "surgery"

/// "Narzędzie" dla operacji robionych gołymi rękami
#define IMPLEMENT_HAND "hands"

/// Modyfikator czasu powyżej tego progu nie wydłuża już operacji, tylko podnosi szansę porażki
#define SURGERY_MODIFIER_FAILURE_THRESHOLD 2.5
/// Procent szansy porażki na każdą sekundę ponad progiem
#define FAILURE_CHANCE_PER_SECOND 10
/// Szansa porażki z czasu bazowego i modyfikatora (np. 1 s i x4 -> 4 s - 2,5 s = 1,5 s * 10 = 15%)
#define GET_FAILURE_CHANCE(base_time, speed_mod) (FAILURE_CHANCE_PER_SECOND * (((speed_mod * (base_time)) - (SURGERY_MODIFIER_FAILURE_THRESHOLD * (base_time))) / (1 SECONDS)))

// Klucze listy operation_args (op_info)
/// Łączny modyfikator czasu/porażki
#define OPERATION_SPEED "speed_modifier"
/// Wybrana akcja, zwykle "default"
#define OPERATION_ACTION "action"
/// Operacja ma się nie udać (prawy klik)
#define OPERATION_FORCE_FAIL "force_fail"
/// Strefa ciała, na której operujemy
#define OPERATION_TARGET_ZONE "target_zone"
/// Konkretny cel operacji (kończyna, organ)
#define OPERATION_TARGET "target"
#define OPERATION_BRUTE_HEAL "brute_heal"
#define OPERATION_BURN_HEAL "burn_heal"
#define OPERATION_BRUTE_MULTIPLIER "brute_multiplier"
#define OPERATION_BURN_MULTIPLIER "burn_multiplier"

/// "lewą rękę Jana" albo nazwa odciętej kończyny. Pasuje do zdań typu "Zaczynasz nacinać [FORMAT_LIMB_OWNER(limb)]".
#define FORMAT_LIMB_OWNER(limb) (limb.owner ? "[strefa_pl(limb.body_zone, TRUE)] [limb.owner]" : "[limb]")
/// Gdzie jest organ: właściciel albo to, w czym leży
#define FORMAT_ORGAN_OWNER(organ) (organ.owner || organ.loc)

/// Pacjent leży. Moby bez kończyn (zwierzęta, szlamy) nie umieją się położyć, więc zawsze się liczą (jak w tg).
#define IS_LYING_OR_CANNOT_LIE(mob) (iscarbon(mob) ? !(mob.mobility_flags & MOBILITY_STAND) : TRUE)

/// Ballmer peak (code/modules/mob/living/carbon/life.dm)
#define BALLMER_PEAK_LOW_END 12.9
#define BALLMER_PEAK_HIGH_END 13.8

// --- Sygnały ---
/// Na chirurgu przy zbieraniu operacji: (atom/movable/operating_on, list/possible_operations). Dopisz typ do listy, żeby odblokować operację.
#define COMSIG_LIVING_OPERATING_ON "living_operating_on"
/// Na operowanym: (mob/living/surgeon, list/possible_operations)
#define COMSIG_ATOM_BEING_OPERATED_ON "atom_being_operated_on"
/// Na kończynie przy zmianie stanu: (old_state, new_state, changed_states)
#define COMSIG_BODYPART_UPDATING_SURGERY_STATE "bodypart_updating_surgery_state"
/// Na mobie przy zmianie stanu którejś kończyny albo basic_surgery_state: (old_state, new_state, changed_states)
#define COMSIG_LIVING_UPDATING_SURGERY_STATE "living_updating_surgery_state"
/// Na narzędziu przed operacją: (datum/surgery_operation/operation, atom/movable/operating_on, mob/living/surgeon). Zwróć ITEM_INTERACT_BLOCKING, żeby przerwać.
#define COMSIG_ITEM_USED_IN_SURGERY "item_used_in_surgery"
/// Na pacjencie: początek operacji (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_STARTED "atom_surgery_started"
/// Na pacjencie: koniec operacji (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_FINISHED "atom_surgery_finished"
/// Na chirurgu: operacja udana (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_SUCCESS "atom_surgery_success"
/// Na chirurgu: operacja nieudana (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_FAILED "atom_surgery_failed"

/// Organ był już naprawiany chirurgicznie (operacje naprawy organów, które można zrobić raz)
#define TRAIT_ORGAN_OPERATED_ON "organ_operated_on"

/// Na organie wyciętym operacją: (mob/living/surgeon, mob/living/carbon/old_owner, target_zone, obj/item/tool). Też w heretic/_compat/sacrifice.dm.
#ifndef COMSIG_ORGAN_SURGICALLY_REMOVED
#define COMSIG_ORGAN_SURGICALLY_REMOVED "organ_surgically_removed"
#endif
