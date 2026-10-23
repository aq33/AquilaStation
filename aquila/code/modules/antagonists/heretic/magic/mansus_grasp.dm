/datum/action/cooldown/spell/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "Zaklęcie dotyku, które pozwala przelać moc Starych Bogów przez twój uścisk."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_grasp"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 10 SECONDS

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT
	// Mimes can cast it. Chaplains can cast it. Anyone can cast it, so long as they have a hand.
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	hand_path = /obj/item/melee/spell_hand/mansus_fist

/datum/action/cooldown/spell/touch/mansus_grasp/is_valid_target(atom/cast_on)
	return TRUE // This baby can hit anything

/datum/action/cooldown/spell/touch/mansus_grasp/can_cast_spell(feedback = TRUE)
	return ..() && (!!IS_HERETIC(owner) || !!IS_LUNATIC(owner))

/datum/action/cooldown/spell/touch/mansus_grasp/on_antimagic_triggered(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("Zaklęcie odbija się od [victim]!"),
		span_danger("Zaklęcie odbija się od ciebie!"),
	)

/datum/action/cooldown/spell/touch/mansus_grasp/cast_on_hand_hit(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	if(!isliving(victim))
		return FALSE

	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim) & COMPONENT_BLOCK_HAND_USE)
		return FALSE

	var/mob/living/living_hit = victim
	living_hit.apply_damage(10, BRUTE)
	if(!iscarbon(victim))
		return TRUE

	var/mob/living/carbon/carbon_hit = victim

	// Cultists are momentarily disoriented by the stunning aura. Enough for both parties to go 'oh shit' but only a mild combat ability.
	// Cultists have an identical effect on their stun hand. The heretic's faster spell charge time is made up for by their lack of teammates.
	if(IS_CULTIST(carbon_hit))
		carbon_hit.AdjustKnockdown(0.5 SECONDS)
		carbon_hit.set_confusion_if_lower(3 SECONDS)
		carbon_hit.set_dizzy_if_lower(3 SECONDS)

		var/old_color = carbon_hit.color
		carbon_hit.color = COLOR_CULT_RED
		animate(carbon_hit, color = old_color, time = 4 SECONDS, easing = SINE_EASING|EASE_IN)
		carbon_hit.mob_light(1.5, 2.5, COLOR_CULT_RED, 0.5 SECONDS)
		playsound(carbon_hit, 'sound/magic/curse.ogg', 50, TRUE)

		to_chat(caster, span_warning("Nieświęta siła wtrąca się, gdy chwytasz [carbon_hit], pochłaniając większość efektów!"))
		to_chat(carbon_hit, span_warning("Gdy [caster] chwyta cię pradawnymi mocami, twoja magia krwi pochłania większość efektów!"))
		carbon_hit.balloon_alert_to_viewers("pochłonięte!")
		return TRUE

	// AQUILA - tg: specjalny bełkot heretyka (speech/slurring/heretic) i daze, u nas zwykły bełkot i powalenie
	carbon_hit.adjust_slurring(4 SECONDS)
	carbon_hit.AdjustKnockdown(5 SECONDS)
	carbon_hit.adjust_stamina_loss(80)

	return TRUE

/datum/action/cooldown/spell/touch/mansus_grasp/cast_on_secondary_hand_hit(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	if(isliving(victim)) // if it's a living mob, go with our normal afterattack
		return SECONDARY_ATTACK_CALL_NORMAL

	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim) & COMPONENT_USE_HAND)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/melee/spell_hand/mansus_fist
	name = "Mansus Grasp"
	desc = "Złowroga aura zniekształcająca bieg rzeczywistości wokół siebie. \
		Powala, zostawia drobne siniaki i mocno męczy. \
		Zyskuje dodatkowe efekty, gdy poszerzasz swoją wiedzę o Mansusie."
	icon_state = "mansus_grasp"
	item_state = "mansus_grasp"

/obj/item/melee/spell_hand/mansus_fist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "Usuwasz %THEEFFECT.", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune))

/*
 * Callback for effect_remover component.
 */
/obj/item/melee/spell_hand/mansus_fist/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, target.greyscale_colors)
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = spell_which_made_us?.resolve()
	grasp?.spell_feedback()

	remove_hand_with_no_refund(user)

/obj/item/melee/spell_hand/mansus_fist/ignition_effect(atom/to_light, mob/user)
	. = span_rose("[user] bez wysiłku pstryka palcami przy [to_light], podpalając to pradawną energią. Ale to było zajebiste!")
	remove_hand_with_no_refund(user)

/obj/item/melee/spell_hand/mansus_fist/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] zakrywa twarz chorobliwie wyglądającą dłonią! Wygląda na to, że próbuje popełnić samobójstwo!"))
	var/mob/living/carbon/carbon_user = user //iscarbon already used in spell's parent
	var/datum/action/cooldown/spell/touch/mansus_grasp/source = spell_which_made_us?.resolve()
	if(QDELETED(source) || !IS_HERETIC(user))
		return SHAME

	if(user.can_block_magic(source.antimagic_flags))
		return SHAME

	var/escape_our_torment = 0
	while(!IS_UNCONSCIOUS_OR_CRIT(carbon_user))
		if(QDELETED(src) || QDELETED(user))
			return SHAME
		if(escape_our_torment > 20) //Stops us from infinitely stunning ourselves if we're just not taking the damage
			return FIRELOSS

		if(prob(70))
			carbon_user.adjust_fire_loss(20)
			playsound(carbon_user, 'aquila/sound/effects/wounds/sizzle1.ogg', 70, vary = TRUE)
			if(prob(50))
				carbon_user.emote("scream")
				carbon_user.adjust_stutter(26 SECONDS)

		source.cast_on_hand_hit(src, user, user)

		escape_our_torment++
		stoplag(0.4 SECONDS)
	return FIRELOSS
