/// Uncomment this to enable testing of Vampire features (such as vassalizing people with a mind instead of a client).
//#define VAMPIRE_TESTING
#if defined(VAMPIRE_TESTING) && defined(CIBUILDING)
	#error VAMPIRE_TESTING is enabled, disable this!
#endif

// Blood-level defines
/// Determines Vampire regeneration rate
#define BS_BLOOD_VOLUME_MAX_REGEN 700
/// Cost to torture someone halfway, in blood. Called twice for full cost
#define TORTURE_BLOOD_HALF_COST 8
/// Cost to convert someone after successful torture, in blood
#define TORTURE_CONVERSION_COST 50
/// Once blood is this low, will enter a Frenzy
#define FRENZY_THRESHOLD_ENTER 25
/// Once blood is this high, will exit the Frenzy.
#define FRENZY_THRESHOLD_EXIT 250
/// How much the frenzy thresholds increase per point of humanity below 10. A 0-humanity vampire gets +250 to both enter/exit thresholds.
#define FRENZY_HUMANITY_MODIFIER_PER_POINT 25
/// How much blood drained from the vampire each lifetick
#define VAMPIRE_PASSIVE_BLOOD_DRAIN 0.1
/// The number that incoming levels are divided by when comitting the Amaranth. Example: 2 would divide the victims level by 2, and give that to the diablerist
#define DIABLERIE_DIVISOR 1.5
/// Amount of vitae drunk from another player required to level up.
#define VITAE_GOAL_STANDARD 250

/// How many starting levels do we want each one to have?
#define VAMPIRE_STARTING_LEVELS 3
/// Vampire's default stamina resist. Tuned to withstand one taser and not more.
#define VAMPIRE_INHERENT_STAMINA_RESIST 0.45

/// When do we warn them about their low blood?
#define VAMPIRE_LOW_BLOOD_WARNING 300

/// How much blood drained from the vampire each tick during sol
#define VAMPIRE_SOL_BURN 15
/// We don't go below this threshold when in a shielded area during sol
#define VAMPIRE_SOL_SHIELD_THRESHOLD 500

// vassal defines
/// If someone passes all checks and can be vassalized
#define VASSALIZATION_ALLOWED 0
/// If someone has to accept vassalization
#define VASSALIZATION_DISLOYAL 1
/// If someone is not allowed under any circimstances to become a vassal
#define VASSALIZATION_BANNED 2

// Humanity gains (The actual tracking lists and such are in the datum duh)
// These are supposed to be somewhat nontrivial, to the point of sometimes not being viable.
/// Hugging of separate people
#define HUMANITY_HUGGING_TYPE "hug"

/// Petting of separate animals
#define HUMANITY_PETTING_TYPE "pet"

/// Watching of art
#define HUMANITY_ART_TYPE "art"

#define HUMANITY_GAIN_TYPES list(HUMANITY_HUGGING_TYPE, HUMANITY_PETTING_TYPE, HUMANITY_ART_TYPE)

/// Default Humanity
#define VAMPIRE_DEFAULT_HUMANITY 7

// List of areas that are shielded from sol.
#define VAMPIRE_SOL_SHIELDED list(/area/maintenance, /area/medical/morgue, /area/security/prison, /area/ai_monitored, /area/holodeck/prison, /area/shuttle)

// Cooldown defines
// Used to prevent spamming vampires
/// Spam prevention for healing messages.
#define VAMPIRE_SPAM_HEALING 15 SECONDS
/// Spam prevention for Sol Masquerade messages.
#define VAMPIRE_SPAM_MASQUERADE 60 SECONDS

/// Spam prevention for Sol messages.
#define VAMPIRE_SPAM_SOL 30 SECONDS

// Clan defines
#define CLAN_BRUJAH "Klan Brujah"
#define CLAN_TOREADOR "Klan Toreador"
#define CLAN_NOSFERATU "Klan Nosferatu"
#define CLAN_TREMERE "Klan Tremere"
#define CLAN_GANGREL "Klan Gangrel"
#define CLAN_VENTRUE "Klan Ventrue"
#define CLAN_MALKAVIAN "Klan Malkavian"
#define CLAN_TZIMISCE "Klan Tzimisce"
#define CLAN_HECATA "Klan Hecata"
#define CLAN_LASOMBRA "Klan Lasombra"

// Power defines
/// This Power can't be used in Torpor
#define BP_CANT_USE_IN_TORPOR (1<<0)
/// This Power can't be used in Frenzy.
#define BP_CANT_USE_IN_FRENZY (1<<1)
/// This Power can't be used with a stake in you
#define BP_CANT_USE_WHILE_STAKED (1<<2)
/// This Power can't be used while incapacitated
#define BP_CANT_USE_WHILE_INCAPACITATED (1<<3)
/// This Power can't be used while unconscious
#define BP_CANT_USE_WHILE_UNCONSCIOUS (1<<4)
/// This Power can't be used during Sol
#define BP_CANT_USE_DURING_SOL (1<<5)

/// This is a Default Power that all Vampires get.
#define VAMPIRE_DEFAULT_POWER (1<<1)

/// This Power is a Toggled Power
#define BP_AM_TOGGLE (1<<0)
/// This Power is a Single-Use Power
#define BP_AM_SINGLEUSE (1<<1)
/// This Power has a Static cooldown
#define BP_AM_STATIC_COOLDOWN (1<<2)
/// This Power doesn't cost bloot to run while unconscious
#define BP_AM_COSTLESS_UNCONSCIOUS (1<<3)
/// This Power has a cooldown that is more dynamic than a typical power
#define BP_AM_VERY_DYNAMIC_COOLDOWN (1<<4)

///Called when a Vampire reaches Final Death.
#define COMSIG_VAMPIRE_FINAL_DEATH "vampire_final_death"
	///Whether the vampire should not be dusted when arriving Final Death
	#define DONT_DUST (1<<0)

// Vampire Signals
/// Called when a Vampire breaks the Masquerade
#define COMSIG_VAMPIRE_BROKE_MASQUERADE "comsig_vampire_broke_masquerade"

// Signals & Defines
/// Sent every Sol tick
#define COMSIG_SOL_RISE_TICK "comsig_sol_rise_tick"
/// Sent 90 seconds before Sol begins
#define COMSIG_SOL_NEAR_START "comsig_sol_near_start"
/// Sent at the end of Sol
#define COMSIG_SOL_END "comsig_sol_end"
/// Sent 15 seconds before Sol ends
#define COMSIG_SOL_NEAR_END "comsig_sol_near_end"
/// Sent when a warning for Sol is meant to go out: (danger_level, vampire_warning_message, vassal_warning_message)
#define COMSIG_SOL_WARNING_GIVEN "comsig_sol_warning_given"
/// Sent when tracking humanity gain progress: (type, subject)
#define COMSIG_VAMPIRE_TRACK_HUMANITY_GAIN "comsig_vampire_track_humanity_gain"

#define DANGER_LEVEL_FIRST_WARNING 1
#define DANGER_LEVEL_SECOND_WARNING 2
#define DANGER_LEVEL_THIRD_WARNING 3
#define DANGER_LEVEL_SOL_ROSE 4
#define DANGER_LEVEL_SOL_ENDED 5

// Clan defines
/// Drinks blood the normal Vampire way.
#define VAMPIRE_DRINK_NORMAL "vampire_drink_normal"
/// Drinks blood but is snobby, refusing to drink from mindless
#define VAMPIRE_DRINK_SNOBBY "vampire_drink_snobby"
// Masquerade ability given at this point or above
#define VAMPIRE_HUMANITY_MASQUERADE_POWER 7

// Traits
// TRAIT_MASQUERADE jest w code/__DEFINES/traits.dm (używa go skaner zdrowia)
// AQUILA - TRAIT_COLDBLOODED jest już w code/__DEFINES/traits.dm (NSV13, ciało nie stabilizuje temperatury)
/// For people in the middle of being staked
#define TRAIT_BEINGSTAKED "trait_beingstaked"
/// Mind trait used to see if you're a vampire or an ally of one.
/// Check this instead of doing `IS_VAMPIRE(x) || IS_VASSAL(x)`
#define TRAIT_VAMPIRE_ALIGNED "trait_vampire_aligned"

// Trait sources
/// Source trait for all vampire traits
#define TRAIT_VAMPIRE "trait_vampire"
/// Source trait while Feeding
#define TRAIT_FEED "trait_feed"
/// Source trait for vampires in torpor.
#define TRAIT_TORPOR "trait_torpor"

// Macros

// AQUILA - definicje z nowego BeeStation potrzebne wampirowi, przepięte na nasze odpowiedniki

/// Sprawdza, czy mob jest wampirem
#define IS_VAMPIRE(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vampire))
/// Sprawdza, czy mob jest wasalem
#define IS_VASSAL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vassal))

#define FACTION_VAMPIRE "Vampire"
#define LANGUAGE_VAMPIRE "vampire"

#define HAS_MIND_TRAIT(target, trait) (HAS_TRAIT(target, trait) || (target.mind ? HAS_TRAIT(target.mind, trait) : FALSE))
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"
// TRAIT_WHISPER_ONLY jest w code/__DEFINES/traits.dm (obsługa w code/modules/mob/living/say.dm)
#define TRAIT_NO_TRANSFORM "block_transformations"

// Bee: incapacitated jako maska bitów; u nas incapacitated(ignore_restraints, ignore_grab)
#define INCAPABLE_RESTRAINTS (1<<1)
#define INCAPABLE_STASIS (1<<2)
#define INCAPABLE_GRAB (1<<3)
#define INCAPACITATED_IGNORING(mob, flags) (mob.incapacitated(((flags) & INCAPABLE_RESTRAINTS) ? TRUE : FALSE, ((flags) & INCAPABLE_GRAB) ? TRUE : FALSE))

// Bee: zawód jako datum; u nas assigned_role to tekst
#define is_curator_job(job_to_check) ((job_to_check) == JOB_NAME_CURATOR || istype(job_to_check, /datum/job/curator))
#define is_unassigned_job(job_to_check) (isnull(job_to_check) || (job_to_check) == "" || (job_to_check) == "Unassigned")

#define IS_FINITE(a) (isnum(a) && !isinf(a) && !isnan(a))
#define NIGHTVISION_FOV_RANGE 8
#define STATUS_EFFECT_PERMANENT -1
#define STATUS_EFFECT_NO_TICK -1
#define IGNORE_USER_LOC_CHANGE (1<<0)

#define span_awe(str) ("<span class='awe'>" + (str) + "</span>")

// Sygnały pod nowymi nazwami (COMSIG_ATOM_EXAMINE, COMSIG_QDELETING i COMSIG_ATOM_ATTACKBY są w aquila/code/__DEFINES/botany.dm, ładowanym wcześniej)
#define COMSIG_LIVING_DEATH COMSIG_MOB_DEATH
// COMSIG_LIVING_PET_ANIMAL, COMSIG_LIVING_HUG_CARBON i COMSIG_LIVING_APPRAISE_ART są w code/__DEFINES/dcs/signals/signals_mob/signals_living.dm

// Cechy z Bee, które u nas nic nie robią (zostają, żeby lista cech wampira była jak w Bee)
#define TRAIT_OOZELING_NO_CANNIBALIZE "oozeling_no_cannibalize"
#define TRAIT_NO_MIRROR_REFLECTION "no_mirror_reflection"

// do_after z Bee (flagi timed_action_flags)
#define IGNORE_TARGET_LOC_CHANGE (1<<1)
#define IGNORE_HELD_ITEM (1<<2)
#define IGNORE_INCAPACITATED (1<<3)
#define IGNORE_SLOWDOWNS (1<<4)

// Bee: body_position na mobie; u nas get_body_position() z mobility_flags
#define STANDING_UP 0
#define LYING_DOWN 1

#define INJECT_CHECK_PENETRATE_THICK (1<<0)
#define BLOOD_COLOR_RED "#a10808"
#define ICON_SIZE_X 32
#define ICON_SIZE_Y 32
/// Bee: poniżej tej jasności kafel liczy się jako ciemny
#define LIGHTING_TILE_IS_DARK 0.2
