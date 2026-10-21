/datum/action/cooldown/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "Zaklęcie celowane, które leczy twoje rany, raniąc wroga. \
		Może przenieść twoje rany na przeciwnika."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "blood_siphon"
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "FL'MS O' 'T'RN'TY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6

/datum/action/cooldown/spell/pointed/blood_siphon/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/blood_siphon/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/blood_siphon/cast(mob/living/cast_on)
	. = ..()
	playsound(owner, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		owner.balloon_alert(owner, "zaklęcie zablokowane!")
		cast_on.visible_message(
			span_danger("Zaklęcie odbija się od [cast_on]!"),
			span_danger("Zaklęcie odbija się od ciebie!"),
		)
		return FALSE

	cast_on.visible_message(
		span_danger("[cast_on] blednie, gdy otacza go czerwona poświata!"),
		span_danger("Bledniesz, gdy otacza cię czerwona poświata!"),
	)

	var/mob/living/living_owner = owner
	cast_on.adjust_brute_loss(20)
	living_owner.adjust_brute_loss(-20)

	// AQUILA - tg: transfer_blood_to bez sprawdzania zgodności i wirusów. U nas przelewamy samą objętość krwi.
	var/blood_taken = min(20, cast_on.blood_volume)
	if(blood_taken > 0 && !HAS_TRAIT(living_owner, TRAIT_NO_BLOOD))
		cast_on.blood_volume -= blood_taken
		living_owner.blood_volume = min(living_owner.blood_volume + blood_taken, BLOOD_VOLUME_MAXIMUM)

	if(!iscarbon(cast_on) || !iscarbon(owner))
		return TRUE

	// AQUILA - ran z tg u nas nie ma; z szansą 50% przenosimy krwawienie rzucającego na cel
	var/mob/living/carbon/carbon_target = cast_on
	var/mob/living/carbon/carbon_user = owner
	var/our_bleeding = carbon_user.get_bleed_rate()
	if(our_bleeding > 0 && prob(50))
		carbon_user.cauterise_wounds(our_bleeding)
		carbon_target.add_bleeding(our_bleeding)

	return TRUE
