/datum/language/drone
	name = "Dronowy"
	desc = "Mocno zakodowany strumień koordynacji napraw, ze specjalnymi flagami dla czapek."
	speech_verb = "terkocze"
	ask_verb = "terkocze pytająco"
	exclaim_verb = "terkocze głośno"
	sing_verb = "dzwoni"
	spans = list(SPAN_ROBOT)
	key = "d"
	flags = NO_STUTTER
	syllables = list(".", "|")
	// ...|..||.||||.|.||.|.|.|||.|||
	space_chance = 0
	sentence_chance = 0
	default_priority = 20

	icon_state = "drone"
