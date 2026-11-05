/datum/language/mouse
	name = "Mysi"
	desc = "Dość prosty język, którym mówią i który rozumieją myszy. Rozwinęły go i rozpowszechniły genetycznie ulepszone myszy."
	speech_verb = "piszczy"
	ask_verb = "piszczy"
	exclaim_verb = "piszczy"
	key = "m"
	flags = NO_STUTTER | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD | LANGUAGE_HIDE_ICON_IF_UNDERSTOOD

/datum/language/mouse/scramble(input)
	. = "Pisk"
	. += (copytext(input, length(input)) == "?") ? "?" : "!"
