// Fermichem — mechanika reakcji z tg (tgstation@b3949ec362), dopasowana do naszej chemii.
// Opis działania: aquila/code/modules/reagents/chemistry/fermi_readme.md

/// the minimum volume a reagent can have in a holder outside of an ongoing reaction (smaller amounts get deleted)
#define CHEMICAL_VOLUME_ROUNDING 0.01
/// pH of pure water, the default of every reagent and holder
#define CHEMICAL_NORMAL_PH 7.000
/// the lowest possible pH
#define CHEMICAL_MIN_PH 0
/// the highest possible pH
#define CHEMICAL_MAX_PH 14
/// the highest temperature a reagent holder can reach
#define CHEMICAL_MAXIMUM_TEMPERATURE 99999

/// fire priority of SSreagents, which processes ongoing reactions (same as tg)
#define FIRE_PRIORITY_REAGENTS 26

/// how strongly the acidic/basic buffers move the pH, scaled by the fraction of the solution they make up
#define BUFFER_IONIZING_STRENGTH 30

/// purity of reagents from dispensers and other "industrial" sources that aren't made by a reaction (tg default for medicines)
#define REAGENT_STANDARD_PURITY 0.75

// Holder flags (next to NO_REACT etc. in code/__DEFINES/reagents.dm)
/// every reaction in this holder happens instantly, e.g. grenades, smoke and foam
#define REAGENT_HOLDER_INSTANT_REACT (1<<9)
/// this holder is inside a living mob: impure reagents get split into their inverse when added
#define REAGENT_HOLDER_ALIVE (1<<10)

// chemical_reaction.reaction_flags
/// at the end of the reaction, products below their inverse_chem_val purity are converted into their inverse_chem
#define REACTION_CLEAR_INVERSE (1<<0)
/// the reaction happens instantly like the old chemistry instead of over time
#define REACTION_INSTANT (1<<1)
/// thermic_constant changes the temperature directly instead of being divided by the heat capacity of the holder
#define REACTION_HEAT_ARBITARY (1<<2)
/// the reaction competes with other reactions for the same reagents
#define REACTION_COMPETITIVE (1<<3)
/// H_ion_release is relative to the whole volume of the reaction instead of per unit
#define REACTION_PH_VOL_CONSTANT (1<<4)
/// the reaction reacts in real time even when the server lags
#define REACTION_REAL_TIME_SPLIT (1<<5)

/// for RoundGauge alertAfter in the heater UI: always flash
#define ENABLE_FLASHING -1
/// for RoundGauge alertAfter in the heater UI: never flash
#define DISABLE_FLASHING 14

///from base of [/datum/reagents/proc/process]: (num_reactions, delta_time)
#define COMSIG_REAGENTS_REACTION_STEP "reagents_time_step"

/// overheat_temp value meaning "this reaction never overheats"
#define NO_OVERHEAT 99999
/// returned from chemical_reaction/reaction_step() to stop the reaction
#define END_REACTION "end_reaction"

// Reaction tags used by the recipe catalog (same bits as tg)
#define REACTION_TAG_BRUTE (1<<0)
#define REACTION_TAG_BURN (1<<1)
#define REACTION_TAG_TOXIN (1<<2)
#define REACTION_TAG_OXY (1<<3)
#define REACTION_TAG_HEALING (1<<4)
#define REACTION_TAG_DAMAGING (1<<5)
#define REACTION_TAG_EXPLOSIVE (1<<6)
#define REACTION_TAG_OTHER (1<<7)
#define REACTION_TAG_DANGEROUS (1<<8)
#define REACTION_TAG_EASY (1<<9)
#define REACTION_TAG_MODERATE (1<<10)
#define REACTION_TAG_HARD (1<<11)
#define REACTION_TAG_ORGAN (1<<12)
#define REACTION_TAG_DRINK (1<<13)
#define REACTION_TAG_FOOD (1<<14)
#define REACTION_TAG_SLIME (1<<15)
#define REACTION_TAG_DRUG (1<<16)
#define REACTION_TAG_UNIQUE (1<<17)
#define REACTION_TAG_CHEMICAL (1<<18)
#define REACTION_TAG_PLANT (1<<19)
#define REACTION_TAG_COMPETITIVE (1<<20)
#define REACTION_TAG_COMPONENT (1<<21)
#define REACTION_TAG_ACTIVE (1<<22)

// reagent.fermi_flags (tg names them chemical_flags, ours is already taken by chem_flags)
/// the reagent shows the name of the reagent it was split from instead of its own
#define REAGENT_SNEAKYNAME (1<<0)
/// the reagent never splits into its inverse when it enters a mob
#define REAGENT_DONOTSPLIT (1<<1)
/// the reagent keeps reacting in dead bodies
#define REAGENT_DEAD_PROCESS (1<<2)
