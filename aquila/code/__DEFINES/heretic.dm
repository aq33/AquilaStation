// AQUILA - definicje heretyka z tgstation i to, czego heretyk z tg potrzebuje, a czego u nas nie ma.
// Wygenerowane z tg (tools: gen_defines.py) i przejrzane ręcznie. Flagi bitowe kolidujące z naszymi są dopisane
// niżej ręcznie z wartościami pasującymi do naszego kodu (albo 0, gdy u nas nie ma odpowiednika).
// --- z tg: code/__DEFINES/_flags.dm
/// If a turf can't be jaunted through.
/// Blocks this turf from being rusted
/// Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
/// This area prevents Bag of Holding rifts from being opened.
/// Allows you to pass over vehicles, ie. mecha, secways, the pimpin' ride, etc.
/// Allows you to pass over dense items.
/// Allows you to pass over windows and window-adjacent stuff, like windows and windoors. Does not include airlocks with glass in them.
/// Can do the action even if mob moves location
/// Can do the action even if the target moves location
/// Can do the action even if the mob is incapacitated (ex. handcuffed)

// --- z tg: code/__DEFINES/access.dm
/// HERETIC
#define ACCESS_HERETIC "heretic"
/// Used in ID card access adding procs. Will forcefully add all accesses.

// --- z tg: code/__DEFINES/actions.dm
///Action button checks if user is incapacitated
/// Takes in a typepath of a `/datum/action` and adds it to `src`.
/// Only useful if you want to add the action and never desire to reference it again ever.
#define GRANT_ACTION(typepath) do {\
	var/datum/action/_ability = new typepath(src);\
	_ability.Grant(src);\
} while (FALSE)

// --- z tg: code/__DEFINES/ai/ai.dm
/// Continue processing while in stasis

// --- z tg: code/__DEFINES/ai/ai_blackboard.dm
#define BB_TARGETING_STRATEGY "targeting_strategy"
/// Key for the minimum status at which we want to target mobs (does not need to be specified if STABLE)
#define BB_TARGET_MINIMUM_STAT "BB_target_minimum_stat"
/// Generic key for a non-specific targeted action
#define BB_TARGETED_ACTION "BB_TARGETED_action"
/// Generic key for a non-specific action
#define BB_GENERIC_ACTION "BB_generic_action"
/// Generic key for a shapeshifting action
#define BB_SHAPESHIFT_ACTION "BB_shapeshift_action"

// --- z tg: code/__DEFINES/ai/pet_commands.dm
/// Blackboard field for how we target things, as usually we want to be more permissive than normal
#define BB_PET_TARGETING_STRATEGY "BB_pet_targeting"

// --- z tg: code/__DEFINES/antagonists.dm
#define PATH_START "Start Path"
#define PATH_ASH "Ash Path"
#define PATH_RUST "Rust Path"
#define PATH_FLESH "Flesh Path"
#define PATH_VOID "Void Path"
#define PATH_BLADE "Blade Path"
#define PATH_COSMIC "Cosmic Path"
#define PATH_LOCK "Lock Path"
#define PATH_MOON "Moon Path"
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_PURCHASED_DEPTH "purchased_depth"
#define HKT_ROUTE "route"
#define HKT_UI_BGR "ui_bgr"
#define HKT_COST "cost"
#define HKT_CATEGORY "category"
/// Only present for already researched knowledge.
#define HKT_INSTANCE "instance"
/// unique identifier most commonly used for identifying what knowledge is researchable
#define HKT_ID "id"
#define BGR_SIDE "node_side"
#define MAGIC_RESISTANCE_MOON (MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND)
#define HERETIC_DRAFT_TIER_MAX 5
/// The default drain speed for heretic rift's, anything below this will be considered a fast drain, and be very noticeable and cause a overlay
#define HERETIC_RIFT_DEFAULT_DRAIN_SPEED 10 SECONDS
/// Sources of knowledge purchased for heretics, used for positioning in the UI
#define HERETIC_KNOWLEDGE_TREE "tree"
#define HERETIC_KNOWLEDGE_SHOP "shop"
#define HERETIC_KNOWLEDGE_DRAFT "draft"
#define HERETIC_KNOWLEDGE_START "start"
/// defines for the depths of the heretic knowledge tree nodes
#define HKT_DEPTH_START 2
#define HKT_DEPTH_TIER_1 3
#define HKT_DEPTH_DRAFT_1 4
#define HKT_DEPTH_TIER_2 5
#define HKT_DEPTH_DRAFT_2 6
#define HKT_DEPTH_ROBES 7
#define HKT_DEPTH_TIER_3 8
#define HKT_DEPTH_DRAFT_3 9
#define HKT_DEPTH_ARMOR 10
#define HKT_DEPTH_TIER_4 11
#define HKT_DEPTH_DRAFT_4 12
#define HKT_DEPTH_ASCENSION 13
#define HERETIC_CAN_ASCEND "can_ascend"
/// Checks if the passed mob can become a heretic ghoul.
/// - Must be a human (type, not species)
/// - Skeletons cannot be husked (they are snowflaked instead of having a trait)
/// - Monkeys are monkeys, not quite human (balance reasons)
#define IS_VALID_GHOUL_MOB(mob) (ishuman(mob) && !isskeleton(mob) && !HAS_TRAIT(mob, TRAIT_LESSER_HUMANOID))
/// Checks if the given mob is a blood cultist and is guaranteed to return the datum if possible - will cause issues with above trait
#define GET_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult))
/// Checks if the mob is a sentient or non-sentient cultist
/// Checks if the given mob is a heretic and is guaranteed to return the datum if possible - will cause issues with above trait
#define GET_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))
/// Check if the given mob is a  lunatic
#define IS_LUNATIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/lunatic))
/// CHecks if the given mob is in the mansus realm
#define IS_IN_MANSUS(mob) (istype(get_area(mob), /area/centcom/heretic_sacrifice))
#define ANTAG_GROUP_HORRORS "Eldritch Horrors"
/// Antag's panel action button and the UI therein is viewable by observers
#define ANTAG_OBSERVER_VISIBLE_PANEL (1 << 2)

// --- z tg: code/__DEFINES/assert.dm
/// Override BYOND's native ASSERT to optionally specify a message

// --- z tg: code/__DEFINES/basic_mobs.dm
/// Delete mob upon death

// --- z tg: code/__DEFINES/blood.dm
/// Mobs will drop a brain
/// Mobs will drop organs
/// Mobs will drop bodyparts (arms, legs, etc.)
/// Mobs will drop items
/// Mobs will drop everything
/// The DNA within the blood, either a DNA string or some arbitrary string if the DNA is unknown
#define BLOOD_DATA_DNA "blood_DNA"

// --- z tg: code/__DEFINES/bodyparts.dm
/// Has metal - allows the victim to suffer robotic blunt and burn wounds
/// Is wired internally - allows the victim to suffer electrical wounds (robotic T1-T3 slash/pierce)
/// Robotic - can suffer all metal/wired wounds, such as: UNIMPLEMENTED PLEASE UPDATE ONCE SYNTH WOUNDS 9/5/2023 ~Niko

// --- z tg: code/__DEFINES/cleaning.dm
/// Cleans blood off of the cleanable atom.
/// Cleans fingerprints off of the cleanable atom.
/// Cleans fibres off of the cleanable atom.
/// Cleans diseases off of the cleanable atom.
/// Cleans acid off of the cleanable atom.
/// Cleans decals such as dirt and oil off the floor
/// Cleans decals such as cobwebs off the floor

// --- z tg: code/__DEFINES/click.dm
/// Action has succeeded, preventing further alt click interaction
/// Action failed, preventing further alt click interaction

// --- z tg: code/__DEFINES/colors.dm
#define COLOR_CULT_RED "#960000"
#define COLOR_VERY_PALE_LIME_GREEN "#DDFFD3"
#define COLOR_HERETIC_GREEN COLOR_VERY_PALE_LIME_GREEN // i am co-opting this as heretic glow.
#define COLOR_ADMIN_PINK "#D100D1"
#define EYE_COLOR_CULTLIKE_PRIORITY 49

// --- z tg: code/__DEFINES/combat.dm
/// Involves a melee attack or a thrown object.
#define MELEE "melee"
/// We're being attacked with an oversized object, perhaps a road roller. Not that anyone use such a thing as a waepon. So only relevant for certain mech based attacks.
#define OVERWHELMING_ATTACK 6
/// Animation for blunt attacks
#define ATTACK_ANIMATION_BLUNT "blunt"
///ammo box will have a different state for each bullet; <icon_state>-<bullets left>
#define AMMO_BOX_PER_BULLET 1
/// Flat addition or subtration to the weapon's force. Set via [MODIFY_ATTACK_FORCE]
#define FORCE_MODIFIER "force_modifier"
/// Set towards the end of an attack with how much actual damage was dealt
#define DAMAGE_DONE "damage_done"

// --- z tg: code/__DEFINES/construction/material.dm
/// The amount of materials you get from a sheet of mineral like iron/diamond/glass etc. 100 Units.
#define SHEET_MATERIAL_AMOUNT 100

// --- z tg: code/__DEFINES/cooldowns.dm
#define COOLDOWN_STARTED(cd_source, cd_index) (cd_source.cd_index != 0)

// --- z tg: code/__DEFINES/cult.dm
/// The maximum number of cult spell slots each cultist is allowed to scribe at once.
#define ENHANCED_BLOODCHARGE 5

// --- z tg: code/__DEFINES/dcs/signals/signals_action.dm
/// From base of /datum/action/cooldown/mob_cooldown/charge/proc/do_charge(): ()
#define COMSIG_FINISHED_CHARGE "mob_ability_charge_finished"
/// From /datum/action/update_button_status (atom/movable/screen/movable/action_button/current_button, force)
#define COMSIG_ACTION_STATUS_UPDATE "action_status_update"

// --- z tg: code/__DEFINES/dcs/signals/signals_atom/signals_atom_attack.dm
///from relay_attackers element: (atom/attacker, attack_flags, direction)
#define COMSIG_ATOM_WAS_ATTACKED "atom_was_attacked"
/// Called on the atom being hit, from /datum/component/anti_magic/on_attack() : (obj/item/weapon, mob/user, antimagic_flags)
#define COMSIG_ATOM_HOLYATTACK "atom_holyattacked"
/// Called from [/mob/living/proc/send_item_attack_message()]: (obj/item/weapon, /mob/living/victim, mob/living/attacker)
#define COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT "send_item_attack_message_object"
/// Called from [/mob/living/proc/send_item_attack_message()]: (mob/living/victim, obj/item/weapon, mob/living/user)
#define COMSIG_SEND_ITEM_ATTACK_MESSAGE_CARBON "send_item_attack_message_carbon"
	/// Return value if the hitby messages are changed.
	#define SIGNAL_MESSAGE_MODIFIED (1<<0)

// --- z tg: code/__DEFINES/dcs/signals/signals_atom/signals_atom_main.dm

// --- z tg: code/__DEFINES/dcs/signals/signals_atom/signals_atom_movable.dm
///Called before a movable is being teleported from `check_teleport_valid()`: (destination, channel)
#define COMSIG_MOVABLE_TELEPORTING "movable_teleporting"

// --- z tg: code/__DEFINES/dcs/signals/signals_atom/signals_atom_x_act.dm
///from base of atom/bullet_act(): (/obj/proj, def_zone, piercing_hit)
#define COMSIG_ATOM_PRE_BULLET_ACT "pre_atom_bullet_act"
	/// Forces bullet act to return [BULLET_ACT_FORCE_PIERCE], takes priority over above
	#define COMPONENT_BULLET_PIERCED (1<<2)
/// Sent from [atom/proc/item_interaction], when this atom is left-clicked on by a mob with an item
/// Sent from the very beginning of the click chain, intended for generic atom-item interactions
/// Args: (mob/living/user, obj/item/tool, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_ITEM_INTERACTION "atom_item_interaction"
/// Sent from [atom/proc/item_interaction], to a mob clicking on an atom with an item
#define COMSIG_USER_ITEM_INTERACTION "user_item_interaction"

// --- z tg: code/__DEFINES/dcs/signals/signals_datum.dm

// --- z tg: code/__DEFINES/dcs/signals/signals_fish.dm
/// From /datum/fish_source/proc/dispense_reward(), not set if the reward is a dud: (reward, user)
#define COMSIG_FISHING_ROD_CAUGHT_FISH "fishing_rod_caught_fish"

// --- z tg: code/__DEFINES/dcs/signals/signals_food.dm
/// From datum/component/edible/proc/TakeBite: (atom/owner, foodtypes)
#define COMSIG_LIVING_EAT_FOOD "food_bit"

// --- z tg: code/__DEFINES/dcs/signals/signals_heretic.dm
	/// Default behavior is to use the hand, so return this to blocks the mansus fist from being consumed after use.
	#define COMPONENT_BLOCK_HAND_USE (1<<0)
	/// Default behavior is to continue attack chain and do nothing else, so return this to use up the hand after use.
	#define COMPONENT_USE_HAND (1<<0)
/// From /obj/item/melee/sickly_blade/preattack : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_BLADE_PREATTACK "blade_preattack"
/// For [/datum/status_effect/protective_blades] to signal when it is triggered
#define COMSIG_BLADE_BARRIER_TRIGGERED "blade_barrier_triggered"
/// For [/datum/status_effect/protective_blades] to the mob after triggering a blade
#define COMSIG_MOB_BLADE_BARRIER_TRIGGERED "mob_blade_barrier_triggered"
/// at the end of determine_drafted_knowledge
#define COMSIG_HERETIC_SHOP_SETUP "heretic_shop_finished"
/// called on the antagonist datum, upgrades the passive to level 2
#define COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST "heretic_passive_upgrade_first"
/// called on the antagonist datum, upgrades the passive to level 3
#define COMSIG_HERETIC_PASSIVE_UPGRADE_FINAL "heretic_passive_upgrade_final"
/// Sent to a heretic datum when an influence is drained
#define COMSIG_HERETIC_INFLUENCE_DRAINED "heretic_influence_drained"
/// Send to a mob after they apply the moonlight amulet to another mob
#define COMSIG_MOB_APPLIED_MOONLIGHT_AMULET "mob_applied_moonlight_amulet"
/// Sent from a mob as they invoke rust_heretic_act
#define COMSIG_MOB_RUST_HERETIC_ACT "living_rust_heretic_act"
/// Sent to a heretic datum on a successful sacrifice: (mob/living/sacrificed, high_value)
#define COMSIG_HERETIC_SACRIFICE "heretic_sacrifice"
/// Sent to a mob when they summon a heretic monster
#define COMSIG_HERETIC_SUMMONED_MOB "heretic_summoned_mob"
/// Sent to a heretic when they successfully research a piece of heretic knowledge
#define COMSIG_HERETIC_RESEARCHED_KNOWLEDGE "heretic_researched_knowledge"

// --- z tg: code/__DEFINES/dcs/signals/signals_light_intercept.dm
/// from base of [/datum/light_middleman/proc/light_modified] : ()
#define COMSIG_LIGHT_MIDDLEMAN_UPDATED "light_middleman_updated"

// --- z tg: code/__DEFINES/dcs/signals/signals_mob/signals_mob_carbon.dm
#define COMSIG_CARBON_GAIN_WOUND "carbon_gain_wound" //from /datum/wound/proc/apply_wound() (/mob/living/carbon/C, /datum/wound/W, /obj/item/bodypart/L)
///from /obj/item/bodypart/proc/receive_damage, sent from the limb owner (limb, brute, burn)
#define COMSIG_CARBON_LIMB_DAMAGED "carbon_limb_damaged"
	#define COMPONENT_PREVENT_LIMB_DAMAGE (1 << 0)
	#define COMSIG_CARBON_CUFF_PREVENT (1<<0)
/// Before a mob starts dreaming - you can add dream datums to the dream pool to override the selection: (list/dream_pool)
#define COMSIG_PRE_DREAMING "pre_dreaming"
/// A mob has started dreaming: (datum/dream/current_dream)
#define COMSIG_START_DREAMING "start_dreaming"

// --- z tg: code/__DEFINES/dcs/signals/signals_mob/signals_mob_living.dm
/// Called on the organ when it is removed from someone (mob/living/carbon/old_owner)
#define COMSIG_ORGAN_REMOVED "organ_removed"
/// Called when an organ is being regenerated with a new copy in species regenerate_organs (obj/item/organ/replacement)
#define COMSIG_ORGAN_BEING_REPLACED "organ_being_replaced"
/// Called when a organ's damage is adjusted apply_organ_damage (damage_amount, maximum, required_organ_flag)
#define COMSIG_ORGAN_ADJUST_DAMAGE "organ_adjust_damage"
///from base of mob/living/set_body_position(): (new_position, old_position)
#define COMSIG_LIVING_SET_BODY_POSITION  "living_set_body_position"
/// Returned from all the following messages if you actually aren't going to apply any change
#define COMPONENT_IGNORE_CHANGE (1<<0)
/// Send when bruteloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_BRUTE_DAMAGE "living_adjust_brute_damage"
/// Send when fireloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_BURN_DAMAGE "living_adjust_burn_damage"
/// Send when oxyloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_OXY_DAMAGE "living_adjust_oxy_damage"
/// Send when toxloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_TOX_DAMAGE "living_adjust_tox_damage"
/// Send when staminaloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_STAMINA_DAMAGE "living_adjust_stamina_damage"
/// from base of mob/living/updatehealth()
#define COMSIG_LIVING_HEALTH_UPDATE "living_health_update"
///from base of mob/living/death(): (gibbed)
	#define ZIMPACT_CANCEL_DAMAGE (1<<0)
	/// Do not show default z-impact message
	#define ZIMPACT_NO_MESSAGE (1<<1)
	/// Do not do the spin animation when landing
	#define ZIMPACT_NO_SPIN (1<<2)
///From /obj/effect/rune/convert/do_sacrifice() : (list/invokers)
#define COMSIG_LIVING_CULT_SACRIFICED "living_cult_sacrificed"
	/// Don't send a message for sacrificing this thing, we have our own
	#define SILENCE_SACRIFICE_MESSAGE (1<<1)
	/// Dusts the target instead of gibbing them (no soulstone)
	#define DUST_SACRIFICE (1<<3)
///from /mob/living/proc/check_block(): (atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
#define COMSIG_LIVING_CHECK_BLOCK "living_check_block"
	#define SUCCESSFUL_BLOCK (1<<0)
/// From /obj/item/stack/ore/bluespace_crystal/attack_self() : (obj/item/crushed_crystal)
#define COMSIG_MOB_CRUSHED_BLUESPACE_CRYSTAL "living_crushed_bluespace_crystal"

// --- z tg: code/__DEFINES/dcs/signals/signals_mob/signals_mob_main.dm
/// From /mob/proc/ghostize() Called when a mob successfully ghosts
#define COMSIG_MOB_GHOSTIZED "mob_ghostized"
///from base of obj/allowed(mob/M): (/obj) returns ACCESS_ALLOWED if mob has id access to the obj
#define COMSIG_MOB_TRIED_ACCESS "tried_access"
	#define ACCESS_DISALLOWED (1<<1)
/// from /mob/living/proc/apply_damage(): (list/damage_mods, damage, damagetype, def_zone, sharpness, attack_direction, attacking_item)
/// allows you to add multiplicative damage modifiers to the damage mods argument to adjust incoming damage
/// not sent if the apply damage call was forced
#define COMSIG_MOB_APPLY_DAMAGE_MODIFIERS "mob_apply_damage_modifiers"
/// from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone, blocked, wound_bonus, exposed_wound_bonus, sharpness, attack_direction, attacking_item)
#define COMSIG_MOB_APPLY_DAMAGE "mob_apply_damage"
///Called on the mob being stripped, accepts COMPONENT_CANT_STRIP (mob/user, obj/item/unequipping)
#define COMSIG_BEING_STRIPPED "try_strip"
	#define COMPONENT_CANT_STRIP (1<<0)

// --- z tg: code/__DEFINES/dcs/signals/signals_object.dm
#define COMSIG_LIONHUNTER_ON_HIT "lionhunter_on_hit"
/// From closet_teleporter_controller when something is teleporting through a closet
#define COMSIG_CLOSET_TELEPORTER_PRE_SENDING "closet_teleporter_pre_sending"
	/// Blocks the item from teleporting
	#define CLOSET_TELEPORT_BLOCKED (1<<0)
	/// Ignores the can_teleport check
	#define CLOSET_TELEPORT_FORCED (1<<1)
///from base of obj/item/pre_attack(): (obj/item/weapon, atom/target, list/modifiers, list/attack_modifiers)
#define COMSIG_USER_PRE_ITEM_ATTACK "user_pre_item_attack"
/// Sent from /obj/item/bodypart/limb/proc/apply_item(): (obj/item/bodypart/limb)
#define COMSIG_ITEM_APPLIED_TO_LIMB "item_applied_to_limb"

// --- z tg: code/__DEFINES/dcs/signals/signals_screentips.dm
/// A "Type-A" contextual screentip interaction.
/// These are used for items that are defined by their behavior. They define their contextual text within *themselves*,
/// not in their targets.
/// Examples include syringes (LMB to inject, RMB to draw) and health analyzers (LMB to scan health/wounds, RMB for chems)
/// Items can override `add_item_context()`, and call `register_item_context()` in order to easily connect to this.
/// Called on /obj/item with a mutable screentip context list, the hovered target, and the mob hovering.
/// A screentip context list is a list that has context keys (SCREENTIP_CONTEXT_*, from __DEFINES/screentips.dm)
/// that map to the action as text.
/// If you mutate the list in this signal, you must return CONTEXTUAL_SCREENTIP_SET.
#define COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET "item_requesting_context_for_target"
/// Tells the contextual screentips system that the list context was mutated.
#define CONTEXTUAL_SCREENTIP_SET (1 << 0)

// --- z tg: code/__DEFINES/dcs/signals/signals_spell.dm
/// Sent from /datum/action/cooldown/spell/before_cast() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_BEFORE_SPELL_CAST "mob_spell_pre_cast"
/// Sent from /datum/action/cooldown/spell/can_cast_check() to the spell: (feedback)
#define COMSIG_SPELL_CAN_CAST_CHECK "can_cast_spell"
/// Sent from /datum/action/cooldown/spell/set_click_ability() to the caster: (datum/action/cooldown/spell/spell)
#define COMSIG_MOB_SPELL_ACTIVATED "mob_spell_active"
#define COMSIG_MOB_AFTER_SPELL_CAST "mob_after_spell_cast"
#define COMSIG_MOB_SPELL_PROJECTILE "mob_spell_projectile"
/// Sent from /datum/action/cooldown/spell/touch/cast: (mob/living/carbon/cast_on)
#define COMSIG_TOUCH_HANDLESS_CAST "spell_touch_handless_cast"
	/// Return this to prevent the hand spawning/unspawning
	#define COMPONENT_CAST_HANDLESS (1<<0)
/// "Casting" a touch spell brings it into your hand, so this is for actually hitting someone with it
/// Sent from /datum/action/cooldown/spell/touch/do_hand_hit: (atom/hit, mob/living/carbon/caster, obj/item/melee/touch_attack/hand)
#define COMSIG_SPELL_TOUCH_SPELL_ACTUALLY_CAST "spell_touch_spell_actually_cast"
/// Sent from /datum/action/cooldown/spell/aoe/knock/cast(), to every nearby turf (for connect loc): (datum/action/cooldown/spell/aoe/knock/spell, mob/living/caster)
#define COMSIG_ATOM_MAGICALLY_UNLOCKED "atom_magic_unlock"

// --- z tg: code/__DEFINES/dcs/signals/signals_status_effect.dm
/// From /datum/status_effect/fire_handler/fire_stacks/tick()
#define COMSIG_FIRE_STACKS_UPDATED "fire_stacks_updated"

// --- z tg: code/__DEFINES/fish.dm
///Used in the dimensional rift fishing spot to define influence gain
#define FISHING_INFLUENCE "Influence"

// --- z tg: code/__DEFINES/footsteps.dm
#define FOOTSTEP_MOB_SHOE "footstep_shoe"
#define FOOTSTEP_MOB_RUST "footstep_rust"

// --- z tg: code/__DEFINES/generators.dm
#define GEN_VECTOR "vector"
#define GEN_SPHERE "sphere"

// --- z tg: code/__DEFINES/hud.dm
/// Info display HUD elements
/// Change the icon to user's current hud's ui_style

// --- z tg: code/__DEFINES/injection.dm

// --- z tg: code/__DEFINES/inventory.dm
/// Items placed into the left pocket.
#define LOCATION_LPOCKET "in your left pocket"
/// Items placed into the right pocket
#define LOCATION_RPOCKET "in your right pocket"
/// Items placed into the backpack.
#define LOCATION_BACKPACK "in your backpack"
/// Items placed into the hands.
#define LOCATION_HANDS "in your hands"
/// Items placed in the neck slot.
#define LOCATION_NECK "around your neck"

// --- z tg: code/__DEFINES/jobs.dm
/// This job is a head of staff.

// --- z tg: code/__DEFINES/layers.dm
#define LOWER_RUNE_LAYER (16 + TOPDOWN_LAYER)
#define RUNE_LAYER (17 + TOPDOWN_LAYER)
#define HIGH_PIPE_LAYER 2.54
#define LOW_MOB_LAYER 3.75

// --- z tg: code/__DEFINES/lazy_templates.dm
#define LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE "LT_HERETICSACRIFICE"

// --- z tg: code/__DEFINES/lighting.dm
/// Light made with the lighting datums, applying a matrix.
#define COMPLEX_LIGHT 1
/// Light made by masking the lighting darkness plane.
#define OVERLAY_LIGHT 2
/// Light made by masking the lighting darkness plane, and is directional.
#define OVERLAY_LIGHT_DIRECTIONAL 3
///Light made by masking the lighting darkness plane, and is a directionally focused beam.
#define OVERLAY_LIGHT_BEAM 4
#define IS_OVERLAY_LIGHT_SYSTEM(system) (system == OVERLAY_LIGHT || system == OVERLAY_LIGHT_DIRECTIONAL || system == OVERLAY_LIGHT_BEAM)

// --- z tg: code/__DEFINES/living.dm
/// This mob can have blood, cached value of [proc/can_have_blood]
/// Checks if the mob can have blood
///Default value for physiology coefficients. It should be an identity for multiplication, so basically 1
/// Multiplied aplpied to just knockdowns, stacks with above multiplicatively

// --- z tg: code/__DEFINES/logging.dm

// --- z tg: code/__DEFINES/magic.dm
/// Evocation school, usually involves killing or destroy stuff, usually out of thin air
#define SCHOOL_EVOCATION "evocation"
/// Other forbidden magics, such as heretic spells
#define SCHOOL_FORBIDDEN "forbidden"
#define ALL_MAGIC_RESISTANCE (MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND|MAGIC_RESISTANCE_HOLY)

// --- z tg: code/__DEFINES/maps.dm
/// boolean - does this z prevent phasing
#define ZTRAIT_NOPHASE "No Phase"

// --- z tg: code/__DEFINES/maths.dm
/// Converts a probability/second chance to probability/seconds_per_tick chance
/// For example, if you want an event to happen with a 10% per second chance, but your proc only runs every 5 seconds, do `if(prob(100*SPT_PROB_RATE(0.1, 5)))`
#define SPT_PROB_RATE(prob_per_second, seconds_per_tick) (1 - (1 - (prob_per_second)) ** (seconds_per_tick))
/// Like SPT_PROB_RATE but easier to use, simply put `if(SPT_PROB(10, 5))`
#define SPT_PROB(prob_per_second_percent, seconds_per_tick) (prob(100*SPT_PROB_RATE((prob_per_second_percent)/100, (seconds_per_tick))))

// --- z tg: code/__DEFINES/mecha.dm

// --- z tg: code/__DEFINES/mobfactions.dm
/// Acts as a default faction for most violent creatures
#define FACTION_HOSTILE "hostile"
/// Cultists and their constructs
#define FACTION_CULT "cult"

// --- z tg: code/__DEFINES/mobs.dm
#define MOB_SIZE_HUGE 4 // Use this for things you don't want bluespace body-bagged
///The mob is of a rocky make, most likely a golem. Iron within, iron without!
///The mob is some kind of a creature that should be exempt from certain **fun** interactions for balance reasons, i.e. megafauna or a headslug.
///The mob is fish or water-related.
#define FLASH_PROTECTION_HYPER_SENSITIVE -2
#define FLASH_PROTECTION_SENSITIVE -1
#define FLASH_PROTECTION_NONE 0
#define FLASH_PROTECTION_FLASH 1
#define FLASH_PROTECTION_WELDER 2
#define FLASH_PROTECTION_WELDER_SENSITIVE 3
#define FLASH_PROTECTION_WELDER_HYPER_SENSITIVE 4
///Soundbang strength for most things like flashbangs, honkblasts and harm control modules
#define SOUNDBANG_NORMAL 1
///Soundbang strength for anything that cannot be stopped unless you're stacked on multiple effects and equipment to counter it (or are simply deaf)
#define SOUNDBANG_OVERWHELMING 4
/// Returns whether or not the given mob can succumb
#define CAN_SUCCUMB(target) ((target.stat == SOFT_CRIT || target.stat == HARD_CRIT) && !HAS_TRAIT(target, TRAIT_NODEATH))
/// Flag which makes a message send about the vomiting.
#define MOB_VOMIT_MESSAGE (1<<0)
/// Flag which makes the mob get stunned upon vomiting.
#define MOB_VOMIT_STUN (1<<1)
/// Flag which makes the mob incur damage upon vomiting.
#define MOB_VOMIT_HARM (1<<2)
/// Flag which makes the mob vomit blood
#define MOB_VOMIT_BLOOD (1<<3)
/// Flag which will make the proc skip certain checks when it comes to forcing a vomit.
#define MOB_VOMIT_FORCE (1<<5)
/// The default. Gives you might typically expect to happen when you vomit.
#define VOMIT_CATEGORY_DEFAULT (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM | MOB_VOMIT_STUN)
/// The vomit you've all come to know and love, but with a little extra "spice" (blood)
#define VOMIT_CATEGORY_BLOOD (VOMIT_CATEGORY_DEFAULT | MOB_VOMIT_BLOOD)
/// Special flag that means this heal is an admin heal and goes above and beyond
/// Note, this includes things like removing suicide status and handcuffs / legcuffs, use with slight caution.
/// replaces any organ with ORGAN_HAZARDOUS in organ_flags with species defaults
/// Deletes any restraints on the mob (handcuffs / legcuffs)
/// Full heal that isn't admin forced
/// Heals everything and is as strong as / is an admin heal
/// Checks if the mob is unconscious (or in other words, has [TRAIT_KNOCKEDOUT]) - note dead mobs are considered unconscious
/// Checks if the mob is in soft crit, hard crit, dead, or is otherwise unconscious (which hard crit and death apply anyways)

// --- z tg: code/__DEFINES/mood.dm
#define SANITY_LEVEL_INSANE 6
/// Threshold for desensitization effects to start applying
#define DESENSITIZED_THRESHOLD 0.5

// --- z tg: code/__DEFINES/obj_flags.dm
/// Can this object conduct electricity
/// Has contextual screentips when HOVERING OVER OTHER objects
/// Prevents plasmamen from igniting when wearing this
/// Flags for sharpness in obj/item

// --- z tg: code/__DEFINES/paper.dm

// --- z tg: code/__DEFINES/projectiles.dm
/// The caliber used by bolt action rifles.
#define CALIBER_STRILKA310 ".310 strilka"
/// The caliber used by laser guns.
#define CALIBER_LASER "laser"
/// The caliber used by most energy guns.
#define CALIBER_ENERGY "energy"
/// The acliber used by foam force and donksoft toy guns.
#define CALIBER_FOAM "foam force"
/// The caliber used by the bow and arrow.
#define CALIBER_ARROW "arrow"
/// The caliber used by the harpoon gun.
#define CALIBER_HARPOON "harpoon"
/// The caliber used by the meat hook.
#define CALIBER_HOOK "hook"

// --- z tg: code/__DEFINES/qdel.dm
#define QDEL_IN_STOPPABLE(item, time) addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), item), time, TIMER_STOPPABLE)

// --- z tg: code/__DEFINES/reagents.dm
/// Used by smoke or inhaling from a source. Smoke, cigarettes, and inhalers.

// --- z tg: code/__DEFINES/research.dm
#define CELL_LINE_ORGAN_HEART_CURSED "cell_line_organ_heart_cursed"

// --- z tg: code/__DEFINES/role_preferences.dm
#define ROLE_SOULTRAPPED_HERETIC "Soultrapped Heretic"

// --- z tg: code/__DEFINES/screentips.dm
/// Context applied to LMB actions
#define SCREENTIP_CONTEXT_LMB "LMB"
/// Context applied to RMB actions
#define SCREENTIP_CONTEXT_RMB "RMB"

// --- z tg: code/__DEFINES/sound.dm
#define SFX_SHATTER "shatter"
#define SFX_SPARKS "sparks"
#define SFX_SEAR "sear"
#define SFX_HALLUCINATION_I_SEE_YOU "hallucination_i_see_you"
#define SFX_VOID_DEFLECT "void_deflect"

// --- z tg: code/__DEFINES/stat.dm

// --- z tg: code/__DEFINES/status_effects.dm
/// If the incapacitated status effect is being caused by stasis (stasis beds)
/// If the incapacitated status effect is being caused by being agressively grabbed
/// Checks to see if a mob would be incapacitated even while ignoring some types
/// Does this by inverting the passed in flags and seeing if we're still incapacitated
#define STASIS_ELDRITCH_ETHER "stasis_eldritch_ether"

// --- z tg: code/__DEFINES/subsystems.dm
#define DELTA_WORLD_TIME(ss) ((world.time - ss.last_fire) * 0.1)

// --- z tg: code/__DEFINES/surgery.dm
/// Helper to figure out if an organ is organic
/// Helper to figure out if an organ is robotic
/// An organ that is ostensibly dangerous when inside a body
/// The organ has been chomped or otherwise rendered unusable.
/// Helper to figure out if a limb is robotic
/// Bodypart is a pseudopart (like a chainsaw arm)

// --- z tg: code/__DEFINES/text.dm
/// Small size. (ie: context subtooltips, spell delays) - Size options: 12pt 24pt.
/// Removes everything enclose in < and > inclusive of the bracket, and limits the length of the message.

// --- z tg: code/__DEFINES/time.dm
///Returns the time that has passed since the game started
#define STATION_TIME_PASSED(...) (world.time - SSticker.round_start_time)

// --- z tg: code/__DEFINES/tools.dm
/// e.g. crowbar_act()
/// Return when an item interaction is successful.
/// This cancels the rest of the chain entirely and indicates success.
#define ITEM_INTERACT_SUCCESS (1<<0) // Same as TRUE, as most tool (legacy) tool acts return TRUE on success
/// Return to prevent the rest of the attack chain from being executed / preventing the item user from thwacking the target.
/// Similar to [ITEM_INTERACT_SUCCESS], but does not necessarily indicate success.
#define ITEM_INTERACT_BLOCKING (1<<1)
	/// Only for people who get confused by the naming scheme
	#define ITEM_INTERACT_FAILURE ITEM_INTERACT_BLOCKING
/// Return to skip the rest of the interaction chain, going straight to attack.
#define ITEM_INTERACT_SKIP_TO_ATTACK (1<<2)

// --- z tg: code/__DEFINES/traits/_traits.dm

// --- z tg: code/__DEFINES/traits/declarations.dm
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT "knockedout"
/// Makes the mob immune to damage and several other ailments.
#define TRAIT_GODMODE "godmode"
/// Softspoken. Always whisper.
#define TRAIT_FORCE_WHISPER "softspoken"
/// If you are fat, you no longer get the slowdown from it
#define TRAIT_FAT_IGNORE_SLOWDOWN "fat_ignore_slowdown"
/// Always hungry. They can eat as much as they want without eating slowdown.
#define TRAIT_GLUTTON "glutton"
#define TRAIT_DISCOORDINATED_TOOL_USER "discoordinated_tool_user"
#define TRAIT_BATON_RESISTANCE "baton_resistance"
/// can't be kicked to the side
#define TRAIT_NO_SIDE_KICK "no_side_kick"
/// Trait for when you can no longer gain body heat
#define TRAIT_HYPOTHERMIC "body_hypothermic"
/// This human is immune to the effects of being exploded. (ex_act)
#define TRAIT_BOMBIMMUNE "bomb_immunity"
/// Stepping on ants wont cause damage
#define TRAIT_SPACE_ANT_IMMUNITY "space_ant_immunity"
#define TRAIT_HARDLY_WOUNDED "hard_limb_wound"
#define TRAIT_NEVER_WOUNDED "never_wounded"
/// Species with this trait have 50% extra chance of bleeding from piercing and slashing wounds
#define TRAIT_EASYBLEED "easybleed"
/// The user can do things like use magic staffs without penalty
#define TRAIT_MAGICALLY_GIFTED "magically_gifted"
/// Stops the mob from slipping on water, or banana peels, or pretty much anything that doesn't have [GALOSHES_DONT_HELP] set
#define TRAIT_NO_SLIP_WATER "noslip_water"
/// Stops the mob from slipping on permafrost ice (not any other ice) (but anything with [SLIDE_ICE] set)
#define TRAIT_NO_SLIP_ICE "noslip_ice"
/// Stop the mob from sliding around from being slipped, but not the slip part.
/// DOES NOT include ice slips.
#define TRAIT_NO_SLIP_SLIDE "noslip_slide"
/// Stops all slipping and sliding from occurring
#define TRAIT_NO_SLIP_ALL "noslip_all"
/// Stops the mob from leaving prints in the snow
#define TRAIT_NO_SNOWPRINTS "no_snowprints"
/// Makes it impossible for someone to be converted by cult/revs/etc.
#define TRAIT_UNCONVERTABLE "unconvertable"
/// Unable to gain any brain trauma whatsoever
#define TRAIT_BRAIN_TRAUMA_IMMUNITY "brain_trauma_immunity"
/// Prevents death from having too much brain damage
#define TRAIT_BRAIN_DAMAGE_NODEATH "brain_damage_nodeath"
#define TRAIT_SPACEWALK "spacewalk"
///Gives the movable free hyperspace movement without being pulled during shuttle transit
#define TRAIT_FREE_HYPERSPACE_MOVEMENT "free_hyperspace_movement"
/// from heparin and nitrous oxide, makes open bleeding wounds rapidly spill more blood
#define TRAIT_BLOOD_FOUNTAIN "bloody_fountain"
/// from coagulant reagents, this doesn't affect the bleeding itself but does affect the bleed warning messages
#define TRAIT_COAGULATING "coagulating"
/// Their eyes glow an unnatural red colour. Currently used to set special examine text on humans. Does not guarantee the mob's eyes are coloured red, nor that there is any visible glow on their character sprite.
#define TRAIT_UNNATURAL_RED_GLOWY_EYES "unnatural_red_glowy_eyes"
/// This atom is a secluded location, which is counted as out of bounds.
/// Anything that enters this atom's contents should react if it wants to stay in bounds.
#define TRAIT_SECLUDED_LOCATION "secluded_loc"
/// The person with this trait always appears as 'unknown'.
#define TRAIT_UNKNOWN_APPEARANCE "unknown_appearance"
/// The person with this trait always talks as 'unknown'
#define TRAIT_UNKNOWN_VOICE "unknown_voice"
/// Mobs with this trait can never be hit by laser projectiles, meaning the projectiles will just go through.
#define TRAIT_UNHITTABLE_BY_LASERS "unhittable_by_lasers"
/// This mob is phased out of reality from magic, either a jaunt or rod form
#define TRAIT_MAGICALLY_PHASED "magically_phased"
#define TRAIT_MOVE_FLOATING "move_floating"
/// Mind trait that allows you to see blessed tiles.
#define TRAIT_SEE_BLESSED_TILES "sees_blessed_tiles"
/// Weather immunities, also protect mobs inside them.
#define TRAIT_LAVA_IMMUNE "lava_immune" //Used by lava turfs and The Floor Is Lava.
#define TRAIT_ASHSTORM_IMMUNE "ashstorm_immune"
/// Can't be catched when thrown
#define TRAIT_UNCATCHABLE "uncatchable"
/// An item that, if it has contents, will ignore its contents when scanning for contraband.
#define TRAIT_CONTRABAND_BLOCKER "contraband_blocker"
/// Items with this trait will not have their worn icon overlayed.
#define TRAIT_NO_WORN_ICON "no_worn_icon"
/// Items with this trait will not appear when examined.
#define TRAIT_EXAMINE_SKIP "examine_skip"
/// An item is ALWAYS considered baseline reachable and will pipe into CanBeReached().
#define TRAIT_SKIP_BASIC_REACH_CHECK "skip_basic_reach_check"
/// Hides the heretic overlay that outs them as the heretic
#define TRAIT_HERETIC_AURA_HIDDEN "heretic_aura_hidden"
/// This rod was infused by a heretic, making it awesome and improving influence gain
#define TRAIT_ROD_MANSUS_INFUSED "rod_infused"
/// Trait given to all participants in a heretic arena
#define TRAIT_ELDRITCH_ARENA_PARTICIPANT "eldritch_arena_participant"
/// Lock heretic grasp no longer goes on cooldown when opening things
#define TRAIT_LOCK_GRASP_UPGRADED "lock_grasp_upgraded"
/// Used to prevent multiple floating blades from triggering over the same target
#define TRAIT_BEING_BLADE_SHIELDED "being_blade_shielded"
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
/// Trait given to a living mob to prevent wizards from making it immortal
#define TRAIT_PERMANENTLY_MORTAL "permanently_mortal"
/// Trait given if the mob has a cranial fissure.
#define TRAIT_HAS_CRANIAL_FISSURE "has_cranial_fissure"
/// Trait determines if this mob has examined an eldritch painting
#define TRAIT_ELDRITCH_PAINTING_EXAMINE "eldritch_painting_examine"
/// Trait used by the /obj/item/wallframe/painting/eldritch/desire status effect to change their preferences of what they eat
#define TRAIT_FLESH_DESIRE "flesh_desire"
/// Trait given to anything linked to, not necessarily allied to, the mansus
#define TRAIT_MANSUS_TOUCHED "mansus_touched"
/// Trait which means that this item is considered illegal contraband, and valid for the contraband bounty or when scanned by an nspect scanner.
#define TRAIT_CONTRABAND "illegal_contraband"
#define TRAIT_COMBAT_MODE_SKIP_INTERACTION "combat_mode_skip_interaction"
/// Apply to movables to say "hey, this movable is technically flat on the floor, so it'd be mopped up by a mop"
#define TRAIT_MOPABLE "mopable"
/// Trait that allows an item to perform holy rites akin to a nullrod
#define TRAIT_NULLROD_ITEM "nullrod_item"
/// Mobs that are of a lesser species, like monkeys, compared to other humanoid species
#define TRAIT_LESSER_HUMANOID "lesser_humanoid"

// --- z tg: code/__DEFINES/traits/macros.dm

// --- z tg: code/__DEFINES/turfs.dm
#define RUST_RESISTANCE_TITANIUM 3
#define RUST_RESISTANCE_ORGANIC 4

// --- z tg: code/__DEFINES/visual_helpers.dm
/// Use this to set the base and ACTUAL pixel offsets of an object at the same time
/// You should always use this for pixel setting in typepaths, unless you want the map display to look different from in game
#define SET_BASE_PIXEL(x, y) \
	pixel_x = x; \
	base_pixel_x = x; \
	pixel_y = y; \
	base_pixel_y = y;

// --- z tg: code/__DEFINES/wounds.dm
/// set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

// --- z tg: code/__HELPERS/_lists.dm
///Like LAZYCOPY - copies an input list if the list has entries, If it doesn't the assigned list is nulled
#define LAZYLISTDUPLICATE(L) (L ? L.Copy() : null )

// --- z tg: code/__HELPERS/forensics.dm
/// Returns the fingerprints on this atom
/// Returns the blood dna on this atom
/// Returns the number of unique blood dna sources on this atom

// --- z tg: code/__HELPERS/traits.dm
#define TRAIT_CALLBACK_REMOVE(target, trait, source) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___TraitRemove), ##target, ##trait, ##source)

// --- z tg: code/_globalvars/lists/poll_ignore.dm
#define POLL_IGNORE_ASH_SPIRIT "ash_spirit"
#define POLL_IGNORE_FIRE_SHARK "fire_shark"
#define POLL_IGNORE_HERETIC_MONSTER "heretic_monster"
#define POLL_IGNORE_MAID_IN_MIRROR "maid_in_mirror"
#define POLL_IGNORE_RAW_PROPHET "raw_prophet"
#define POLL_IGNORE_RUST_SPIRIT "rust_spirit"
#define POLL_IGNORE_STALKER "stalker"

// --- Ręczne odpowiedniki (u nas inne nazwy lub brak)
/// U nas ciężki stan to UNCONSCIOUS
#define HARD_CRIT UNCONSCIOUS
/// Nieprzytomny (u nas bez TRAIT_KNOCKEDOUT)
#define IS_UNCONSCIOUS(mob) (mob.stat >= UNCONSCIOUS || mob.IsUnconscious() || mob.IsSleeping())
#define IS_UNCONSCIOUS_OR_CRIT(mob) (mob.stat >= SOFT_CRIT || mob.IsUnconscious() || mob.IsSleeping())
/// Długopis albo kredka
#define IS_WRITING_UTENSIL(thing) (istype(thing, /obj/item/pen) || istype(thing, /obj/item/toy/crayon))
/// Kultysta albo mob kultu
#define IS_CULTIST_OR_CULTIST_MOB(mob) (iscultist(mob) || ("cult" in mob.faction))
/// Przedmiot tnący (u nas sharpness = IS_SHARP)
#define SHARP_EDGED IS_SHARP
#define SHARP_POINTY IS_SHARP_ACCURATE
/// Przejście przez okna (u nas PASSGLASS)
#define PASSWINDOW PASSGLASS
/// Przewodzi prąd (u nas flaga flags_1 CONDUCT_1, nie obj_flags)
#define CONDUCTS_ELECTRICITY CONDUCT_1
/// Brak odpowiednika - flagi wyłączone
#define PASSVEHICLE 0
#define PASSITEM 0
#define PEPPERPROOF 0
#define ALLOW_SURGERY_THROUGH 0
#define PLASMAMAN_PREVENT_IGNITION 0
#define ITEM_HAS_CONTEXTUAL_SCREENTIPS 0
#define ORGAN_HAZARDOUS 0
#define ORGAN_UNUSABLE 0
#define MOB_MINERAL 0
#define MOB_SPECIAL 0
#define MOB_AQUATIC 0
#define LOG_VICTIM 0
#define INHALE 0
/// Leczenie (fully_heal u nas bierze admin_revive)
#define HEAL_ADMIN (1<<0)
#define HEAL_REFRESH_ORGANS (1<<8)
#define HEAL_ALL ~HEAL_ADMIN
#define ADMIN_HEAL_ALL ALL
/// Wynik alt-kliknięcia
#define CLICK_ACTION_SUCCESS (1<<0)
#define CLICK_ACTION_BLOCKING (1<<1)
/// Usuwanie po śmierci (dla mobów heretyka z del_on_death)
#define DEL_ON_DEATH (1<<0)

// --- Zaklęcia z tg (spell_types_tg.dm)
#define SCHOOL_UNSET "unset"
#define SCHOOL_TRANSMUTATION "transmutation"
#define SCHOOL_CONJURATION "conjuration"
#define SCHOOL_HOLY "holy"
#define SCHOOL_MIME "mime"
#define SCHOOL_RESTORATION "restoration"
#define SCHOOL_NECROMANCY "necromancy"
#define SCHOOL_PSYCHIC "psychic"
#define SCHOOL_TRANSLOCATION "translocation"
#define SCHOOL_SANGUINE "sanguine"
/// Z zaklęcia-pocisku, gdy pocisk trafi: (obj/item/projectile/source, mob/firer, atom/target, angle, hit_limb)
#define COMSIG_SPELL_PROJECTILE_HIT "spell_projectile_hit"
/// Do moba po wejściu w przenikanie: (datum/action/cooldown/spell/spell, obj/effect/dummy/phased_mob/jaunt)
#define COMSIG_MOB_ENTER_JAUNT "spell_mob_enter_jaunt"
/// Do moba po wyjściu z przenikania: (datum/action/cooldown/spell/spell)
#define COMSIG_MOB_AFTER_EXIT_JAUNT "spell_mob_after_exit_jaunt"
/// Z pojemnika przenikania, gdy ktoś z niego wyjdzie: (mob/living/jaunter)
#define COMSIG_MOB_EJECTED_FROM_JAUNT "spell_mob_eject_jaunt"
/// Z pojemnika przenikania przed ruchem: (mob/living/user, turf/new_loc)
#define COMSIG_MOB_PHASED_CHECK "mob_phased_check"
	#define COMPONENT_BLOCK_PHASED_MOVE (1 << 0)
/// Przed przenikaniem
#define COMSIG_MOB_PRE_JAUNT "spell_mob_pre_jaunt"
	#define COMPONENT_BLOCK_JAUNT (1<<0)
#define TRAIT_SHAPESHIFTED "shapeshifted"
#define SHAPESHIFT_TRAIT "shapeshift_trait"
/// Do rzucającego po przemianie: (mob/living/new_form)
#define COMSIG_LIVING_SHAPESHIFTED "living_shapeshifted"
/// Do formy po powrocie: (mob/living/caster)
#define COMSIG_LIVING_UNSHAPESHIFTED "living_unshapeshifted"
/// Z zaklęcia przy rzuceniu: (atom/cast_on)
#define COMSIG_SPELL_CAST "spell_cast"
/// Do rzucającego przy rzuceniu: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_CAST_SPELL "mob_cast_spell"
/// Z zaklęcia dotyku przy trafieniu dłonią: (atom/hit, mob/living/carbon/caster, obj/item/melee/spell_hand/hand)
#define COMSIG_SPELL_TOUCH_HAND_HIT "spell_touch_hand_cast"
/// Z zaklęcia przy cofnięciu odnowienia
#define COMSIG_SPELL_CAST_RESET "spell_cast_reset"

// --- Statusy z tg (tg_status_effects.dm)
#define STATUS_EFFECT_FAST_PROCESS 0
#define STATUS_EFFECT_NORMAL_PROCESS 1
#define STATUS_EFFECT_PRIORITY 2
#define STATUS_EFFECT_AUTO_TICK 0
#define HEAL_STATUS (1<<16)

// --- Spany z tg (u nas klasy kultu bez podkreślnika)
#define span_mansus(str) ("<span class='mansus'>" + str + "</span>")
#define span_cult_large(str) ("<span class='cultlarge'>" + str + "</span>")
#define span_cult_italic(str) ("<span class='cultitalic'>" + str + "</span>")
#define span_cult_bold(str) ("<span class='cultbold'>" + str + "</span>")
#define span_boldbig(str) ("<span class='big bold'>" + str + "</span>")
