// AQUILA - defines for the basic mining mobs (tgstation code/__DEFINES/ai/ai_blackboard.dm, basic_mobs.dm and the lavaland
// mob files, tg 926bf40c5a). Description in aquila/LEGACY_OVERRIDES.md "Mining mobs".

// --- shared AI keys (tg code/__DEFINES/ai/ai_blackboard.dm)
/// How long a mob has had its current target (ai_target_timer component)
#define BB_BASIC_MOB_HAS_TARGET_TIME "BB_basic_mob_has_target_time"
/// Minimum distance a ranged mob keeps to its target (maintain_distance)
#define BB_RANGED_SKIRMISH_MIN_DISTANCE "BB_ranged_skirmish_min_distance"
/// Maximum distance a ranged mob keeps to its target (maintain_distance)
#define BB_RANGED_SKIRMISH_MAX_DISTANCE "BB_ranged_skirmish_max_distance"

// --- legion
/// The mob that made this legion skull (it does not heal its creator's kind with its own skulls)
#define BB_LEGION_BROOD_CREATOR "BB_legion_brood_creator"
/// The corpse inside a legion
#define BB_LEGION_CORPSE "BB_legion_corpse"

// --- goliath
/// The goliath's ranged tentacle ability
#define BB_GOLIATH_TENTACLES "BB_goliath_tentacles"
