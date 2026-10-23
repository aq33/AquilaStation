// AQUILA - u nas nie było zaklęcia EMP z tg (spell_types/self/emp.dm), więc baza jest tutaj.
/datum/action/cooldown/spell/emp
	name = "Emplosion"
	desc = "To zaklęcie wywołuje impuls elektromagnetyczny wokół rzucającego."
	button_icon_state = "emp"
	sound = 'sound/weapons/zapbang.ogg'

	school = SCHOOL_EVOCATION

	/// The heavy radius of the EMP
	var/emp_heavy = 2
	/// The light radius of the EMP
	var/emp_light = 3

/datum/action/cooldown/spell/emp/cast(atom/cast_on)
	. = ..()
	empulse(get_turf(cast_on), emp_heavy, emp_light, TRUE, magic = TRUE)

// Given to heretic monsters.
/datum/action/cooldown/spell/emp/eldritch
	name = "Energetic Pulse"
	desc = "Zaklęcie wywołujące wokół ciebie potężny impuls elektromagnetyczny, który wyłącza elektronikę."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "E'P."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	emp_heavy = 6
	emp_light = 10
