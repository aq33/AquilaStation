// AQUILA - port z tgstation (code/datums/mood_events/dna_infuser_events.dm + nomad z carp_organs)

/datum/mood_event/infuser_gondola_serenity
	description = "<span class='nicegreen'>Tyle mogłoby teraz zaprzątać ci głowę. Ale zalewa cię to uczucie zadowolenia, uniwersalne wezwanie, by po prostu usiąść i obserwować...</span>\n"
	mood_change = 10

/datum/mood_event/infuser_unsatisfied_nomad
	description = "<span class='warning'>Za długo siedzę w jednym miejscu. Muszę gdzieś popłynąć!</span>\n"
	mood_change = -3

/datum/mood_event/infuser_cheesed
	description = "<span class='nicegreen'>Hehe. \"Ser-decznie witam\". Co za gra słów.</span>\n"
	mood_change = 1
	timeout = 2 MINUTES
