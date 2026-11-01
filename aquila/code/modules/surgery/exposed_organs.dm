// AQUILA - tgstation#98023 "Moving during heavy surgery will now make your organs fall out" (open PR, adapted).
// The chest or head is exposed while its skin is open and the bone is sawed or drilled or the organs are cut
// (bodypart surgery_state, aquila/code/modules/surgery_tg/). It lasts until the operations close it again.
// Running around in that state spills the organs. Lying, crawling, walking, being buckled or pulled is safe.

/// Chance per step to spill an organ
#define EXPOSED_ORGANS_SPILL_PROB 5
/// Chance per step to stop in pain instead
#define EXPOSED_ORGANS_PAIN_PROB 10

/mob/living/carbon
	/// Body zones whose organs are exposed by an open operation
	var/list/exposed_organ_zones

/atom/movable/screen/alert/exposed_organs
	name = "Odsłonięte organy"
	desc = "Masz otwartą ranę, przez którą widać organy! Bieganie w tym stanie jest skrajnie niebezpieczne - idź powoli albo się połóż."
	icon = 'aquila/icons/hud/exposed_organs.dmi'
	icon_state = "exposed_organs"

/// Starts or stops tracking movement of a patient with an open chest or head
/mob/living/carbon/proc/update_exposed_organs()
	var/list/zones = list()
	// odciągnięta skóra i przepiłowana, nawiercona kość albo nacięte organy (stan kończyny z surgery_tg)
	for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		var/obj/item/bodypart/limb = get_bodypart(zone)
		if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN) && LIMB_HAS_ANY_SURGERY_STATE(limb, SURGERY_BONE_SAWED|SURGERY_ORGANS_CUT))
			zones |= zone
	var/was_exposed = length(exposed_organ_zones)
	exposed_organ_zones = length(zones) ? zones : null
	if(!was_exposed && length(zones))
		throw_alert(ALERT_EXPOSED_ORGANS, /atom/movable/screen/alert/exposed_organs)
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(exposed_organs_moved), override = TRUE)
	else if(was_exposed && !length(zones))
		clear_alert(ALERT_EXPOSED_ORGANS)
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/// Tracks if the mob is moving while heavy surgery is taking place
/mob/living/carbon/proc/exposed_organs_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(forced || stat == DEAD || !length(exposed_organ_zones))
		return
	if(buckled || pulledby || throwing)
		return
	if(!(mobility_flags & MOBILITY_STAND) || (movement_type & (FLYING|FLOATING)) || m_intent == MOVE_INTENT_WALK || !has_gravity())
		return

	var/feels_pain = feels_exposed_organs_pain()
	if(!prob(EXPOSED_ORGANS_SPILL_PROB))
		if(feels_pain && prob(EXPOSED_ORGANS_PAIN_PROB))
			to_chat(src, "<span class='warning'>Otwarta rana ([strefa_pl(pick(exposed_organ_zones))]) pulsuje bólem przy każdym kroku! Lepiej idź bardzo ostrożnie...</span>")
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "grimace")
			Stun(2 SECONDS)
		return

	var/zone = pick(exposed_organ_zones)
	var/list/possible_drop = list()
	for(var/obj/item/organ/organ as anything in getorganszone(zone))
		if(organ.organ_flags & (ORGAN_UNREMOVABLE|ORGAN_VITAL))
			continue
		possible_drop += organ
	var/obj/item/bodypart/chest/chest = get_bodypart(BODY_ZONE_CHEST)
	if(zone == BODY_ZONE_CHEST && chest?.cavity_item)
		possible_drop += chest.cavity_item
	if(!length(possible_drop))
		return

	var/obj/item/dropped = pick(possible_drop)
	if(isorgan(dropped))
		var/obj/item/organ/organ = dropped
		organ.Remove(src)
		organ.applyOrganDamage(organ.maxHealth * 0.5)
	else
		chest.cavity_item = null
	dropped.forceMove(drop_location())
	visible_message("<span class='danger'>Z otwartej rany [src] ([strefa_pl(zone)]) wypada [dropped.name]!</span>",
		"<span class='userdanger'>Z otwartej rany ([strefa_pl(zone)]) wypada ci [dropped.name]!</span>")
	var/obj/item/bodypart/limb = get_bodypart(zone)
	if(!limb || IS_ORGANIC_LIMB(limb))
		playsound(src, 'sound/misc/splort.ogg', 50, TRUE, -1)
	log_combat(src, dropped, "spilled from an open operation ([zone])")
	if(feels_pain)
		Stun(2 SECONDS)

/// Same rule as the surgery pain messages: morphine numbs it
/mob/living/carbon/proc/feels_exposed_organs_pain()
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return FALSE
	return !reagents?.has_reagent(/datum/reagent/medicine/morphine)

#undef EXPOSED_ORGANS_SPILL_PROB
#undef EXPOSED_ORGANS_PAIN_PROB
