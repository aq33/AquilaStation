/// Make the holder move by adding a movement element. Signal is for aestethic interactions mostly
/datum/gizmodes/mover
	guaranteed_active_gizmodes = list(/datum/gizpulse/start_moving = 1, /datum/gizpulse/stop_moving = 1)

/datum/gizpulse/start_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.AddElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_START_MOVING, src)

/datum/gizpulse/stop_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.RemoveElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_STOP_MOVING, src)

/// Start glowing
/datum/gizmodes/lights
	guaranteed_active_gizmodes = list(/datum/gizpulse/lights_on, /datum/gizpulse/lights_off)
	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
		/datum/gizpulse/mode_controle/cycle_mode/activate,
	)

/datum/gizpulse/lights_on/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_ON_STATE)

	holder.set_light(
		l_range = 3,
		l_power = 2,
		l_color = "#FF0000", // tg LIGHT_COLOR_INTENSE_RED
		l_on = TRUE,
	)

/datum/gizpulse/lights_off/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_OFF_STATE)
	holder.set_light_on(FALSE)

/// Gives a voice hint or changes the voices language for use with a voice interface (i mean you give this to a wire interface or other but it then gives you
/// the info to use a voice interface)
/datum/gizmodes/voice
	guaranteed_active_gizmodes = list(/datum/gizpulse/voice_hint, /datum/gizpulse/language_change)
	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
	)

/// Spit out a hint for using the voice interface
/datum/gizpulse/voice_hint/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/component/gizmo_voice/voice = holder.GetComponent(/datum/component/gizmo_voice)
	if(!voice)
		return

	holder.say(voice.active_words.Join(" "))

/// Pick a different language
/datum/gizpulse/language_change/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	gizmo_grant_random_uncommon_language(holder)

/// AQUILA: odpowiednik tg /atom/movable/proc/grant_random_uncommon_language(). Nie mamy GLOB.uncommon_roundstart_languages, więc lista jest tutaj.
/proc/gizmo_grant_random_uncommon_language(atom/movable/holder)
	var/static/list/uncommon_languages = list(
		/datum/language/uncommon,
		/datum/language/beachbum,
		/datum/language/draconic,
		/datum/language/moffic,
		/datum/language/sylvan,
		/datum/language/calcic,
		/datum/language/voltaic,
		/datum/language/apidite,
		/datum/language/terrum,
		/datum/language/piratespeak,
	)
	var/picked = pick(uncommon_languages)
	holder.grant_language(picked, TRUE, TRUE, LANGUAGE_ATOM)
	var/datum/language_holder/language_holder = holder.get_language_holder()
	if(language_holder)
		language_holder.selected_language = picked
	return TRUE
