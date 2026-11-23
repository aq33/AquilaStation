// AQUILA - blackboard keys of the cheap tg basic mobs (tg 926bf40c5a, mobabilities part 2: deer and the P1 mobs)
// Kept apart from aquila/code/__DEFINES/basic_mobs.dm: only aquila/ code uses them, so this file is included from aquila/aquila.dm.

// Stopping and staring (stare_at_thing subtree, stop_and_stare behaviour, complete_stop movement)
/// The thing that made us stop and stare
#define BB_STATIONARY_CAUSE "BB_thing_that_made_us_stationary"
/// How long we stay stationary
#define BB_STATIONARY_SECONDS "BB_stationary_time_in_seconds"
/// Do we walk up to the thing after staring at it
#define BB_STATIONARY_MOVE_TO_TARGET "BB_stationary_move_to_target"
/// Typecache of things that make us stop and stare
#define BB_STATIONARY_TARGETS "BB_stationary_targets"
/// Cooldown between two stares
#define BB_STATIONARY_COOLDOWN "BB_stationary_cooldown"
/// world.time when the mob may stop and stare again
#define BB_STATIONARY_NEXT_STARE "BB_stationary_next_stare"

// Deer
/// Water turf we want to drink from
#define BB_DEER_WATER_TARGET "deer_water_target"
/// Grass turf we want to graze on
#define BB_DEER_GRASS_TARGET "deer_grass_target"
/// Tree we want to mark as our home
#define BB_DEER_TREE_TARGET "deer_tree_target"
/// Another deer we want to play with
#define BB_DEER_PLAYFRIEND "deer_playfriend"
/// The tree we call home
#define BB_DEER_TREEHOME "deer_home"
/// Until when we rest at home
#define BB_DEER_RESTING "deer_resting"
/// When we may rest at home again
#define BB_DEER_NEXT_REST_TIMER "deer_next_rest_timer"
