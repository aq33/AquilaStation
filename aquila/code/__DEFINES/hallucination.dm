// AQUILA - halucynacje jako efekt statusu (BeeStation/BeeStation-Hornet#13095 + tgstation/tgstation#89865).
// Dołączany na początku nsv13.dme (obok span.dm), bo kod core woła cause_hallucination().

// Hallucination tiers
/// Very common hallucinations, minor stuff that'll make you double-take but is otherwise very subtle.
#define HALLUCINATION_TIER_COMMON 1
/// Uncommon hallucinations, more noticeable and potentially more impactful (causing temporary stuns or stamina damage).
#define HALLUCINATION_TIER_UNCOMMON 2
/// Rarer hallucinations which are usually pretty obvious, but also pretty impactful.
#define HALLUCINATION_TIER_RARE 3
/// Hallucinations which are generally just for laughs and are obviously fake
#define HALLUCINATION_TIER_VERYSPECIAL 4
/// Hallucinations which are never picked, only forced
#define HALLUCINATION_TIER_NEVER 5

/// Biotypes which cannot hallucinate for balance and logic reasons (not code). U nas mob_biotypes to lista.
#define CANNOT_HALLUCINATE(living) ((MOB_ROBOTIC in living.mob_biotypes) || (MOB_SPIRIT in living.mob_biotypes))

// Macro wrapper for _cause_hallucination so we can cheat in named arguments, like AddComponent.
/**
 * Causes a hallucination of a certain type to the mob.
 *
 * First argument is always the type of halllucination, a /datum/hallucination, required.
 * second argument is always the key source of the hallucination, used for admin logging, required.
 *
 * Additionally, named arguments are supported for passing them forward to the created hallucination's new().
 */
#define cause_hallucination(arguments...) _cause_hallucination(list(##arguments))

/// Z /mob/living/carbon/human/update_health_hud() dla każdej kończyny ludzika zdrowia: (mob/living/carbon/human/owner)
#define COMSIG_BODYPART_UPDATING_HEALTH_HUD "bodypart_updating_health_hud"
	/// Zwróć, żeby zamiast obrażeń kończyny pokazać własną nakładkę
	#define COMPONENT_OVERRIDE_BODYPART_HEALTH_HUD (1<<0)
/// Z /mob/living/carbon/human/check_self_for_injuries() dla każdej kończyny: (mob/living/carbon/examiner, list/check_list, list/limb_damage)
#define COMSIG_BODYPART_CHECKED_FOR_INJURY "bodypart_injury_checked"
