/datum/mood_event/drankblood
	description = span_nicegreen("Pożywiam się łapczywie tym, co daje mi siłę.")
	mood_change = 10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = span_boldwarning("Piłem krew pośledniejszej istoty. Obrzydliwe.")
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = span_boldwarning("Piłem martwą krew. Stać mnie na więcej.")
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = span_boldwarning("Piłem syntetyczną krew. Co jest ze mną nie tak?")
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = span_boldwarning("Wyssałem śmiertelnika na śmierć. Czuję się... nieludzko.")
	mood_change = -15
	timeout = 10 MINUTES

/datum/mood_event/coffinsleep
	description = span_nicegreen("Przespałem dzień w trumnie. Znów czuję się sobą.")
	mood_change = 10
	timeout = 6 MINUTES

///Candelabrum's mood event to non Vampire/Vassals
/datum/mood_event/vampcandle
	description = span_boldwarning("Czujesz, jak coś pełza ci po umyśle...")
	mood_change = -15
	timeout = 5 MINUTES
