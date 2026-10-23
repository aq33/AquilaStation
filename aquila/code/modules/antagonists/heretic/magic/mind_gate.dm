/datum/action/cooldown/spell/pointed/mind_gate
	name = "Mind Gate"
	desc = "Zadaje ci 20 punktów uszkodzeń mózgu, a cel doznaje halucynacji, \
			na 10 sekund traci orientację, dusi się i doznaje uszkodzeń mózgu. \
			Oślepia, ucisza i ogłusza cel, a jeśli jego poczytalność jest dość niska, także go przewraca."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mind_gate"

	sound = 'sound/magic/curse.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "Op'n y'r m'd."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "Szykujesz się, by otworzyć swój umysł..."
	antimagic_flags = MAGIC_RESISTANCE_MOON

/datum/action/cooldown/spell/pointed/mind_gate/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/mind_gate/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/mind_gate/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Czujesz, że twój umysł jest zamknięty."))
		to_chat(owner, span_warning("Ich umysł się nie otwiera, ale twój też nie."))
		return FALSE

	var/mob/living/living_owner = owner
	living_owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 20, 140)

	cast_on.adjust_confusion(10 SECONDS)
	cast_on.adjust_oxy_loss(30)
	cast_on.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), "Mind gate, cast by [owner]")
	cast_on.cause_hallucination(/datum/hallucination/delusion/preset/heretic/gate, "Caused by mindgate")
	cast_on.adjust_organ_loss(ORGAN_SLOT_BRAIN, 30)

	/// The duration of these effects are based on sanity, mainly for flavor but also to make it a weaker alpha strike
	var/maximum_duration = 15 SECONDS
	// AQUILA - nastrój to u nas komponent; bez niego liczymy jak przy neutralnej poczytalności
	var/datum/component/mood/target_mood = cast_on.get_mood()
	var/target_sanity = target_mood ? target_mood.sanity : SANITY_NEUTRAL
	var/mind_gate_duration = ((SANITY_MAXIMUM - target_sanity) / (SANITY_MAXIMUM - SANITY_INSANE)) * maximum_duration  + 1 SECONDS
	to_chat(cast_on, span_warning("Twoje oczy krzyczą z bólu, uszy krwawią, a usta się zasklepiają! KSIĘŻYC SIĘ DO CIEBIE UŚMIECHA!"))
	cast_on.adjust_temp_blindness(mind_gate_duration)
	cast_on.set_eye_blur_if_lower(mind_gate_duration + 1 SECONDS)

	// AQUILA - tg sound_damage(0, czas): u nas głuchota w uszach liczona w tyknięciach Life() (~2 s)
	var/obj/item/organ/ears/target_ears = cast_on.getorganslot(ORGAN_SLOT_EARS)
	target_ears?.minimumDeafTicks(CEILING(mind_gate_duration / 20, 1))

	cast_on.adjust_silence(mind_gate_duration)
	cast_on.add_mood_event("moon_smile", /datum/mood_event/moon_smile)

	// Only knocksdown if the target has a low enough sanity
	if(target_sanity < 40)
		cast_on.AdjustKnockdown(2 SECONDS)
	//Lowers sanity
	cast_on.adjust_sanity(-20)

	//If our moon heretic has their level 3 passive, we channel the amulet effect
	var/datum/status_effect/heretic_passive/moon/our_passive = living_owner.has_status_effect(/datum/status_effect/heretic_passive/moon)
	if(our_passive?.amulet)
		our_passive.amulet.channel_amulet(owner, cast_on)

	return TRUE
