// AQUILA - defines for the Bee AI core, basic mobs and pets (port of BeeStation/BeeStation-Hornet basic mobs).
// Included early in nsv13.dme (AQ EDIT), because the synced core AI files (monkey, dog) use them.
// Sources (bee/master 0adf0fe9ae): code/__DEFINES/ai/pets.dm, ai_pet_commands.dm, basic_mobs.dm,
// signals_ai_controller.dm, signals_mob_basic.dm and parts of signals_mob.dm, signals_atom_attack.dm, traits.

// --- code/__DEFINES/ai/pets.dm
///Dog AI controller blackboard keys
#define BB_SIMPLE_CARRY_ITEM "BB_SIMPLE_CARRY_ITEM"
#define BB_FETCH_IGNORE_LIST "BB_FETCH_IGNORE_LISTlist"
#define BB_FETCH_DELIVER_TO "BB_FETCH_DELIVER_TO"
#define BB_DOG_HARASS_TARGET "BB_DOG_HARASS_TARGET"
#define BB_DOG_HARASS_HARM "BB_DOG_HARASS_HARM"
#define BB_DOG_IS_SLOW "BB_DOG_IS_SLOW"

/// Basically, what is our vision/hearing range for picking up on things to fetch/
#define AI_DOG_VISION_RANGE	10
/// What are the odds someone petting us will become our friend?
#define AI_DOG_PET_FRIEND_PROB 15
/// After this long without having fetched something, we clear our ignore list
#define AI_FETCH_IGNORE_DURATION (30 SECONDS)

///Baby-making blackboard
///Types of animal we can make babies with.
#define BB_BABIES_PARTNER_TYPES "BB_babies_partner"
///Types of animal that we make as a baby.
#define BB_BABIES_CHILD_TYPES "BB_babies_child"
///Current partner target
#define BB_BABIES_TARGET "BB_babies_target"
///Timeout for finding partners when theres too many of us in 1 location
#define BB_PARTNER_SEARCH_TIMEOUT "BB_partner_search_timeout"

///the name of our trick
#define BB_TRICK_NAME "trick_name"
///the sequence of our trick
#define BB_TRICK_SEQUENCE "trick_sequence"

// Cultist pet keys
///our ability to summon runes
#define BB_RUNE_ABILITY "rune_ability"
///the cult team we serve
#define BB_CULT_TEAM "cult_team"
///our dead cultist we revive
#define BB_DEAD_CULTIST "dead_cultist"
///nearby runes
#define BB_NEARBY_RUNE "nearby_rune"
///occupied runes
#define BB_OCCUPIED_RUNE "occupied_rune"
///friendly cultists we befriend
#define BB_FRIENDLY_CULTIST "friendly_cultist"

//cat AI keys
/// key that holds the target we will battle over our turf
#define BB_TRESSPASSER_TARGET "tresspasser_target"
/// key that holds angry meows
#define BB_HOSTILE_MEOWS "hostile_meows"
/// key that holds the mouse target
#define BB_MOUSE_TARGET "mouse_target"
/// key that holds our dinner target
#define BB_CAT_FOOD_TARGET "cat_food_target"
/// key that holds the food we must deliver
#define BB_FOOD_TO_DELIVER "food_to_deliver"
/// key that holds things we can hunt
#define BB_HUNTABLE_PREY "huntable_prey"
/// key that holds target kitten to feed
#define BB_KITTEN_TO_FEED "kitten_to_feed"
/// key that holds our hungry meows
#define BB_HUNGRY_MEOW "hungry_meows"
/// key that holds maximum distance food is to us so we can pursue it
#define BB_MAX_DISTANCE_TO_FOOD "max_distance_to_food"
/// key that holds the stove we must turn off
#define BB_STOVE_TARGET "stove_target"
/// key that holds the donut we will decorate
#define BB_DONUT_TARGET "donut_target"
/// key that holds our home...
#define BB_CAT_HOME "cat_home"
/// key that holds the human we will beg
#define BB_HUMAN_BEG_TARGET "human_beg_target"

// --- code/__DEFINES/ai_pet_commands.dm
/// Blackboard field for the most recent command the pet was given
#define BB_ACTIVE_PET_COMMAND "BB_active_pet_command"

/// Blackboard field for what we actually want the pet to target
#define BB_CURRENT_PET_TARGET "BB_current_pet_target"
/// Blackboard field for how we target things, as usually we want to be more permissive than normal
#define BB_PET_TARGETING_STRATEGY "BB_pet_targeting"
/// Typecache of weakrefs to mobs this mob is friends with, will follow their instructions and won't attack them
#define BB_FRIENDS_LIST "BB_friends_list"
/// List of strings we might say to encourage someone to make better choices.
#define BB_OWNER_SELF_HARM_RESPONSES "BB_self_harm_responses"

// --- code/__DEFINES/basic_mobs.dm
#define BASIC_MOB_MAX_STAMINALOSS 200

/// Delete mob upon death
#define DEL_ON_DEATH (1<<0)
/// Rotate mob 180 degrees while it is dead
#define FLIP_ON_DEATH (1<<1)
/// Mob remains dense while dead
#define REMAIN_DENSE_WHILE_DEAD (1<<2)
/// Mob can be set on fire
#define FLAMMABLE_MOB (1<<3)
/// Mob is immune to getting wet
#define IMMUNE_TO_GETTING_WET (1<<4)

///hunger cooldown for basic mobs
#define EAT_FOOD_COOLDOWN 45 SECONDS

// --- signals_ai_controller.dm
///sent from ai controllers when they possess a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_POSSESSED_PAWN "ai_controller_possessed_pawn"
///sent from ai controllers when they stop possessing a pawn: (datum/ai_controller/source_controller)
#define COMSIG_AI_CONTROLLER_UNPOSSESSED_PAWN "ai_controller_unpossessed_pawn"
///sent from ai controllers when they pick behaviors: (list/datum/ai_behavior/old_behaviors, list/datum/ai_behavior/new_behaviors)
#define COMSIG_AI_CONTROLLER_PICKED_BEHAVIORS "ai_controller_picked_behaviors"
///sent from ai controllers when a behavior is inserted into the queue: (list/new_arguments)
#define AI_CONTROLLER_BEHAVIOR_QUEUED(type) "ai_controller_behavior_queued_[type]"

// --- signals_mob_basic.dm
/// Sent from /mob/living/basic/proc/look_dead() : ()
#define COMSIG_BASICMOB_LOOK_DEAD "basicmob_look_dead"
/// Sent from /mob/living/basic/proc/look_alive() : ()
#define COMSIG_BASICMOB_LOOK_ALIVE "basicmob_look_alive"

///from the ranged_attacks component for basic mobs: (mob/living/basic/firer, atom/target, modifiers)
#define COMSIG_BASICMOB_PRE_ATTACK_RANGED "basicmob_pre_attack_ranged"
	#define COMPONENT_CANCEL_RANGED_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //! Cancel to prevent the attack from happening

///from the ranged_attacks component for basic mobs: (mob/living/basic/firer, atom/target, modifiers)
#define COMSIG_BASICMOB_POST_ATTACK_RANGED "basicmob_post_attack_ranged"

// --- signals_mob.dm (Bee)
/// Sent from /proc/do_after if someone starts a do_after action bar.
#define COMSIG_DO_AFTER_BEGAN "mob_do_after_began"
/// Sent from /proc/do_after once a do_after action completes, whether via the bar filling or via interruption.
#define COMSIG_DO_AFTER_ENDED "mob_do_after_ended"
/// From the end of /mob/living/proc/update_mobility() (AQ EDIT, we keep the incapacitated() proc): ()
#define COMSIG_MOB_INCAPACITATE_CHANGED "mob_incapacitated"
/// Signal sent when a blackboard key is set to a new value
#define COMSIG_AI_BLACKBOARD_KEY_SET(blackboard_key) "ai_blackboard_key_set_[blackboard_key]"
///Signal sent before a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_PRECLEAR(blackboard_key) "ai_blackboard_key_pre_clear_[blackboard_key]"
/// Signal sent when a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_CLEARED(blackboard_key) "ai_blackboard_key_clear_[blackboard_key]"

// --- relay_attackers (moved here from aquila/code/__DEFINES/heretic.dm and heretic/_compat/sacrifice.dm)
///from relay_attackers element: (atom/attacker, attack_flags, direction)
#define COMSIG_ATOM_WAS_ATTACKED "atom_was_attacked"
/// Mob has the relay_attackers element applied
#define TRAIT_RELAYING_ATTACKER "relaying_attacker"
/// The attack was a stamina attack
#define ATTACKER_STAMINA_ATTACK (1<<0)
/// The attack was a shove
#define ATTACKER_SHOVING (1<<1)
/// The attack dealt damage
#define ATTACKER_DAMAGING_ATTACK (1<<2)
/// The attack was ranged
#define ATTACK_RANGED (1<<3)

// --- traits
/// Pauses AI processing of the mob
#define TRAIT_AI_PAUSED "TRAIT_AI_PAUSED"
/// Trait source for elements/components a planning subtree needs (checked by unit tests)
#define TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM "element-required"

// --- movement loop results (our move() returns TRUE/FALSE, which matches these values)
#define MOVELOOP_FAILURE 0
#define MOVELOOP_SUCCESS 1

// --- songs played by AI pawns (code/__DEFINES/song.dm in Bee)
#define MONKEY_SONG "BPM: 200\nC4/0,14,C,A4-F2,F3,A3,F-F2,A-F,F4,G4,F,D4-Bb2-G2\nD3,G3,D-G2,G3-G2,D,D4-G3,D,B4-B2,G,B3,G-B2,B3-B2\nG4,A4,G,E4-C3,E3,G3,E-C,G-C,E,E4-G,E,C5-E-A3,C4\nA-E3,C,E4-C3,A4-C4,B4-A3-A2,C5-C4,D5-F-B3,D4,B-F3\nD,F4-D3,D4,F-B-B2,G4-D,A4-C-F3,F,C/2,B3/2,A3-C3/2\nB/2,C4,E-C3,F4,G-C,F-F3,F-C,C4/2,B/2,A-A2/2,G3/2\nF/I"
#define MOUSE_SONG "BPM: 250\nD4/0,03,Eb4,C-En,C5,E3-G,E4,E3-C/0,5,Bb-C4-E4,C5\nF/0,5,A-C4/0,5,E3,C5,G-C4-D5,Eb5,G-En,C5,C4-E4-D\nE5,G,Bn4,B3-D/0,5,C-C5/0,5,G/0,5,C3/0,5,D4,Eb4\nC-En,C5,E3-G,E4,E3-C/0,5,Bb-C4-E4,C5,F/0,5\nA-C4/0,5,E3/0,5,Eb-A4,G4,D3-Gb,A,G3-A3-C5,En5,D,D5\nG-A-C,A4,Gn-Bn-D/0,5,G2/0,5,A2/0,5,B2-D4,Eb4,C3-En\nC5,E3-G3,E4,E3-C/0,5,Bb3-C4-E4,C5,F/0,5,A3-C4/0,5\nE3,C5,G-C4-D5,Eb5,G-En,C5,C4-E4-D,E5,G,Bn4\nB3-D/0,5,C-C5/0,5,G/0,5,C3/0,5,C5,D,C3-E3-G-E5,C5\nD,E,E3-Bb-C4,C5,D,C,F-A-C4-E5,C5,D,E,F-Ab-C4,C5,D\nC,G-C4-E4-E5,C5,D,E,G,Bn4,D/0,5,C4-C5/0,5,G/0,5,C3\nE4,F4,Gb4,C-Gn/0,5,G3-An4,G4,G2,E,G3-F,Gb4\nC-Gn/0,5,G3-A,G4,G2,E5,G3-C5,G4,F3-A,B,A3-C4-C5,D\nF-E,D,Ab-C4-C5,D,E3-G/0,5,G3-C4-E4,F4,D3-An4,G4\nB3-E,F,C3-G/0,5,G3-A,G4,G2,E,G3-F,Gb4,C-Gn/0,5\nG3-A,G4,E3,G,Eb-A,Bb4,D-Bn,B,B3,B4,D,A,A3-Gb,D4\nGn3-G4/0,5,F3/0,5,En,E4,D3-F4,Gb,C-Gn/0,5,G3-A4,G4\nG2,E,G3-F,Gb4,C-Gn/0,5,G3-A,G4,G2,E5,G3-C5,G4,F3-A\nB,A3-C4-C5,D5,F-E,D,Ab-C4-C5,D,E3-C/0,5,G3-C4/0,5\nE,G4,G3-C-Gb4,Gn,F-An-C-C5/0,5,A4,C,Gb3-A3-C4,A4\nC5,A,Gn-C4-E4-G4,C5,E5,G5,G3-C4-E4,E5,C5,G4\nD3-A/0,5,Gb3-C4-C5/0,5,Gn-B3-E,D5/0,5,C,C4/0,5\nG/0,5,C3/0,5,D4,Eb4,C-En,C5,E3-G,E4,E3-C/0,5\nBb-C4-E4,C5,F/0,5,A3-C4/0,5,E3,C5,G-C4-D5,Eb5,G-En\nC5,C4-E4-D,E5,G,Bn4,B3-D/0,5,C-C5/0,5,G/0,5,C3/0,5\nC5,D,C3-E3-G-E5,C5,D,E,E3-Bb-C4,C5,D,C,F-A-C4-E5\nC5,D,E,F-Ab-C4,C5,D,C,G-C4-E4-E5,C5,D,E,G,Bn4\nD/0,5,C4-C5/0,5,G/0"

// --- moved here from aquila/code/__DEFINES/vampires.dm, because the synced AI core uses them
#define HAS_MIND_TRAIT(target, trait) (HAS_TRAIT(target, trait) || (target.mind ? HAS_TRAIT(target.mind, trait) : FALSE))
#define TRAIT_NO_TRANSFORM "block_transformations"
// Bee: incapacitated as a bitmask; ours is incapacitated(ignore_restraints, ignore_grab)
#define INCAPABLE_RESTRAINTS (1<<1)
#define INCAPABLE_STASIS (1<<2)
#define INCAPABLE_GRAB (1<<3)
#define INCAPACITATED_IGNORING(mob, flags) (mob.incapacitated(((flags) & INCAPABLE_RESTRAINTS) ? TRUE : FALSE, ((flags) & INCAPABLE_GRAB) ? TRUE : FALSE))

// --- AI subsystems (code/__DEFINES/MC.dm and subsystems.dm in Bee)
#define AI_CONTROLLER_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/ai_controllers/##X);\
/datum/controller/subsystem/ai_controllers/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
	ss_id=#X;\
}\
/datum/controller/subsystem/ai_controllers/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/ai_controllers/##X

#define UNPLANNED_CONTROLLER_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/unplanned_controllers/##X);\
/datum/controller/subsystem/unplanned_controllers/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
	ss_id=#X;\
}\
/datum/controller/subsystem/unplanned_controllers/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/unplanned_controllers/##X

#define FIRE_PRIORITY_UNPLANNED_NPC 3

// --- basic mob signals (signals_atom_attack.dm, signals_living.dm, signals_simplemob.dm in Bee)
///from base of atom/attack_basic_mob(): (/mob/user)
#define COMSIG_ATOM_ATTACK_BASIC_MOB "attack_basic_mob"
/// From /mob/living/basic/handle_breathing() (Bee: base of /mob/living/Life()): (seconds_per_tick, times_fired)
#define COMSIG_LIVING_HANDLE_BREATHING "living_handle_breathing"
///from base of /mob/living/basic/proc/update_basic_mob_varspeed(): ()
#define POST_BASIC_MOB_UPDATE_VARSPEED "post_basic_mob_update_varspeed"
/// From /mob/living/befriend() : (mob/living/new_friend)
#define COMSIG_LIVING_MADE_NEW_FRIEND "made_new_friend"
/// From /mob/living/befriend() : (mob/living/new_friend)
#define COMSIG_LIVING_BEFRIENDED "living_befriended"
/// From /mob/living/unfriend() : (mob/living/old_friend)
#define COMSIG_LIVING_UNFRIENDED "living_unfriended"
/// From /datum/element/basic_eating and friends: (atom/eaten)
#define COMSIG_MOB_ATE "mob_ate"
///before a basic mob attacks its target: (atom/target), return COMPONENT_HOSTILE_NO_ATTACK to cancel
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
///after a basic mob attacked its target: (atom/target, result)
#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"

/// Simple animal or basic mob
#define isanimal_or_basicmob(A) (istype(A, /mob/living/simple_animal) || istype(A, /mob/living/basic))

// --- mob factions used by the basic mobs (code/__DEFINES/mobfactions.dm in Bee; FACTION_HOSTILE and FACTION_CULT are in heretic.dm)
#define FACTION_NEUTRAL "neutral"
#define FACTION_CAT "cat"
#define FACTION_GONDOLA "gondola"
#define FACTION_LIZARD "lizard"
#define FACTION_MAINT_CREATURES "maint_creatures"
#define FACTION_RAT "rats"

/// From /datum/element/basic_eating/try_eating(): (atom/food, mob/living/feeder, list/effect_mult)
#define COMSIG_MOB_PRE_EAT "mob_pre_eat"
	///cancel eating
	#define COMSIG_MOB_CANCEL_EAT (1<<0)
	///from basic_eating finish_eating(): stop the food from being consumed
	#define COMSIG_MOB_TERMINATE_EAT (1<<0)
/// Mob has the basic_eating element
#define TRAIT_MOB_EATER "mob_eater"

// --- pet commands keybinding (code/__DEFINES/keybinding.dm and signals_atom_mouse.dm in Bee)
#define COMSIG_KB_LIVING_VIEW_PET_COMMANDS "keybinding_living_view_pet_commands"
/// Sent when a held keybinding is released
#define DEACTIVATE_KEYBIND(A) "[A]_DEACTIVATED"
// COMSIG_ATOM_MOUSE_ENTERED is in aquila/code/__DEFINES/screentips.dm (sent from the screentips hover)
/// Beast empathy (Bee quirk, makes taming easier); nothing gives it here yet
#define TRAIT_BEAST_EMPATHY "beast_empathy"
/// Trait source of a basic mob playing dead
#define BASIC_MOB_DEATH_TRAIT "basic_mob_death"
/// Mob can breed (breed component)
#define TRAIT_MOB_BREEDER "mob_breeder"

// --- squashable component flags (code/__DEFINES/mobs.dm in Bee; both are 1<<0 there too)
///Squashing will not occur if the mob is not lying down (bodyposition is LYING_DOWN)
#define SQUASHED_SHOULD_BE_DOWN (1<<0)
///If this flag is on, squashing will deal no damage but gib the mob instead
#define SQUASHED_SHOULD_BE_GIBBED (1<<0)

/// Strip menu slot of a pet collar (wears_collar element), the TGUI strip menu already knows it
#define STRIPPABLE_ITEM_PET_COLLAR "pet_collar"

/// Dogs growl at and attack mobs with this trait (dog AI from BeeStation/BeeStation-Hornet). Bee gives it to felinids and mailman clothes; we give it to no one yet (our clothing has no clothing_traits).
#define TRAIT_HATED_BY_DOGS "hated_by_dogs"

// Garden gnome colours (code/__DEFINES/colors.dm in Bee)
#define COLOR_GNOME_RED_ONE "#f10b0b"
#define COLOR_GNOME_RED_TWO "#bc5347"
#define COLOR_GNOME_RED_THREE "#b40f1a"
#define COLOR_GNOME_BLUE_ONE "#2e8ff7"
#define COLOR_GNOME_BLUE_TWO "#312bd6"
#define COLOR_GNOME_BLUE_THREE "#4e409a"
#define COLOR_GNOME_GREEN_ONE "#28da1c"
#define COLOR_GNOME_GREEN_TWO "#50a954"
#define COLOR_GNOME_YELLOW "#f6da3c"
#define COLOR_GNOME_ORANGE "#d56f2f"
#define COLOR_GNOME_BROWN_ONE "#874e2a"
#define COLOR_GNOME_BROWN_TWO "#543d2e"
#define COLOR_GNOME_PURPLE "#ac1dd7"
#define COLOR_GNOME_WHITE "#e8e8e8"
#define COLOR_GNOME_GREY "#a9a9a9"
#define COLOR_GNOME_BLACK "#303030"
#define COLOR_PALE_GREEN "#20e28e"
