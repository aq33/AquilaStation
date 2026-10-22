/datum/action/cooldown/spell/pointed/cleave
	name = "Cleave"
	desc = "Wywołuje ciężkie krwawienie u celu i kilku osób wokół niego."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cleave"
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "CL'VE!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4

	/// The radius of the cleave effect
	var/cleave_radius = 1
	/// Severity of the slash wound we apply (AQUILA - lekkie rany Aquili)
	var/wound_severity = WOUND_SEVERITY_CRITICAL

/datum/action/cooldown/spell/pointed/cleave/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/cleave/cast(mob/living/carbon/human/cast_on)
	. = ..()
	for(var/mob/living/carbon/human/victim in range(cleave_radius, cast_on))
		if(victim == owner || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
			victim.visible_message(
				span_danger("Ciało [victim] rozbłyska ognistą poświatą, ale odpiera płomienie!"),
				span_danger("Twoje ciało rozbłyska ognistą poświatą, ale jesteś chroniony!")
			)
			continue

		if(HAS_TRAIT(victim, TRAIT_NO_BLOOD) || (NOBLOOD in victim.dna?.species?.species_traits))
			continue

		victim.visible_message(
			span_danger("Żyły [victim] rozrywają się od środka, a z krwi wybucha nieświęty płomień!"),
			span_danger("Twoje żyły pękają od środka, a z krwi wybucha nieświęty płomień!")
		)

		var/obj/item/bodypart/bodypart = pick(victim.get_bodyparts())
		bodypart?.aq_force_wound(WOUND_SLASH, wound_severity)
		victim.apply_damage(20, BURN)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE

/datum/action/cooldown/spell/pointed/cleave/long
	name = "Lesser Cleave"
	cooldown_time = 60 SECONDS
	wound_severity = WOUND_SEVERITY_SEVERE

/obj/effect/temp_visual/cleave
	icon = 'aquila/icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
