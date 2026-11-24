// Drzewa zachowań z tgstation (code/__DEFINES/ai/behavior_trees.dm), wariant hybrydowy:
// kontroler z ustawionym behavior_tree_json albo behavior_nodes idzie drzewem, reszta planning subtrees jak dotąd.
// Opis: nagłówek aquila/code/datums/ai/behavior_tree/bt_controller.dm i sekcja „Drzewa zachowań” w aquila/LEGACY_OVERRIDES.md

/// Maksymalna liczba indeksów w dzienniku wykonania podglądu drzewa między odczytami
#define BT_EXECUTION_LOG_MAX 250

// Wyniki węzłów
/// Węzeł osiągnął cel
#define BT_SUCCESS 1
/// Węzeł zawiódł
#define BT_FAILURE 2
/// Węzeł nadal pracuje
#define BT_RUNNING 3

// Zasady węzła parallel
#define BT_PARALLEL_SUCCESS_CHILD_ONE 0
#define BT_PARALLEL_SUCCESS_ALL 1
#define BT_PARALLEL_FAILURE_CHILD_ONE 0
#define BT_PARALLEL_FAILURE_ANY 1

// Zasady węzła subplan
#define BT_SUBPLAN_SUCCEED_ON_SUCCESS 0
#define BT_SUBPLAN_LOOP_ON_SUCCESS 1
#define BT_SUBPLAN_FAIL_ON_FAILURE 0
#define BT_SUBPLAN_LOOP_ON_FAILURE 1

// Przerwania obserwatorów dekoratorów
#define BT_ABORT_NONE 0
#define BT_ABORT_SELF (1<<0)
#define BT_ABORT_LOWER_PRIORITY (1<<1)
#define BT_ABORT_BOTH (BT_ABORT_SELF | BT_ABORT_LOWER_PRIORITY)

// Rodzaje węzłów (podgląd)
#define BT_NODE_SELECTOR 0
#define BT_NODE_SEQUENCE 1
#define BT_NODE_PARALLEL 2
#define BT_NODE_DECORATOR 3
#define BT_NODE_LEAF 4
#define BT_NODE_SUBTREE 5
#define BT_NODE_SUBPLAN 6

// Klucze opisu węzła w skompilowanym JSON-ie
#define BT_DESC_TYPE "type"
#define BT_DESC_CHILDREN "children"
#define BT_DESC_OVERRIDE_ID "override_id"
#define BT_DESC_BINDINGS "__bindings"

/// Ścieżka skompilowanego drzewa dla źródłowego .bt.json (ścieżka względna od repo), np.
/// "aquila/code/modules/mob/living/basic/bots/bot.bt.json" -> "aquila/behavior_trees/aquila/code/modules/mob/living/basic/bots/bot.bt.compiled.json".
/// AQUILA: tg trzyma je w build/behavior_trees/ i czyta z dysku obok .dmb; u nas pliki są dołączane do .rsc przez
/// wygenerowany indeks GLOB.bt_compiled_trees (tools/build_bt.py), więc działają też w kopiach świata w CI.
#define BT_COMPILED_PATH(json_path) (replacetext("aquila/behavior_trees/" + json_path, ".json", ".compiled.json"))

/// Id miejsca na podmianę poddrzewa w czasie gry (komendy zwierząt itp.)
#define SUBPLAN_ID_PET_COMMAND "pet_command"

/// Wysyłany do pionka, gdy zmienia się podmiana poddrzewa o danym id: (override_type)
#define COMSIG_AI_OVERRIDE_SLOT_CHANGED(id) "ai_override_slot_changed_[id]"
/// Wysyłany do pionka, gdy ruch AI się poddał (za dużo nieudanych kroków)
#define COMSIG_MOB_AI_MOVEMENT_FAILED "mob_ai_movement_failed"
/// Wysyłany do pionka, gdy AI zaczyna iść do celu: (atom/target)
#define COMSIG_MOB_AI_MOVEMENT_STARTED "mob_ai_movement_started"

#ifndef LAZYSETLEN
/// Ustawia długość listy, tworząc ją w razie potrzeby (tg)
#define LAZYSETLEN(L, V) if (!L) { L = list(); } L.len = V;
#endif
