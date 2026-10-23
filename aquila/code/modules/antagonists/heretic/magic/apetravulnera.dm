/datum/action/cooldown/spell/pointed/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Wywołuje silne krwawienie z każdej kończyny celu, która ma ponad 15 obrażeń fizycznych. \
		Jeśli żadna kończyna nie jest dość poraniona, rozcina losową."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "apetra_vulnera"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "AP'TRA VULN'RA!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4
	/// Severity of the slash wound applied to every bruised limb (AQUILA - lekkie rany Aquili)
	var/wound_severity = WOUND_SEVERITY_CRITICAL

/datum/action/cooldown/spell/pointed/apetra_vulnera/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/apetra_vulnera/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(IS_HERETIC_OR_MONSTER(cast_on))
		return FALSE

	if(HAS_TRAIT(cast_on, TRAIT_NO_BLOOD) || (NOBLOOD in cast_on.dna?.species?.species_traits))
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags))
		cast_on.visible_message(
			span_danger("Siniaki [cast_on] na chwilę rozbłyskują, ale coś odpiera efekt!"),
			span_danger("Twoje siniaki lekko szczypią, ale jesteś chroniony!")
		)
		return FALSE

	var/a_limb_got_damaged = FALSE
	for(var/obj/item/bodypart/bodypart as anything in cast_on.bodyparts)
		if(bodypart.brute_dam < 15)
			continue
		a_limb_got_damaged = TRUE
		bodypart.aq_force_wound(WOUND_SLASH, wound_severity)

	if(!a_limb_got_damaged)
		var/obj/item/bodypart/random_limb = pick(cast_on.bodyparts)
		random_limb.aq_force_wound(WOUND_SLASH, wound_severity)

	cast_on.visible_message(
		span_danger("Zadrapania i siniaki [cast_on] rozrywa nieświęta siła!"),
		span_danger("Twoje zadrapania i siniaki rozrywa jakaś straszliwa, nieświęta siła!")
	)

	new /obj/effect/temp_visual/cleave(get_turf(cast_on))

	return TRUE
