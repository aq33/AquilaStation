// AQUILA - nastroje przy operacjach z tg (generic_negative_events.dm). /datum/mood_event/surgery jest w rdzeniu (Bee, dotąd nieużywany).

/datum/mood_event/surgery
	/// Operacja się skończyła (sukces albo porażka). Śpiący pacjent dostaje nastrój tylko, gdy zasnął w trakcie.
	var/surgery_completed = FALSE

/datum/mood_event/surgery/success
	description = "<span class='warning'>Ta operacja nieźle bolała... Ale chyba się udała.</span>\n"
	timeout = 3 MINUTES
	surgery_completed = TRUE

/datum/mood_event/surgery/failure
	description = "<span class='boldwarning'>AAAAAA! POKROILI MNIE ŻYWCEM!</span>\n"
	timeout = 10 MINUTES
	surgery_completed = TRUE
