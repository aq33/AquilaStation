/*
	Mobs
*/

/mob/living/simple_animal/holodeck_monkey
	name = "małpa"
	desc = "Holograficzne stworzenie, które uwielbia banany."
	icon = 'icons/mob/monkey.dmi'
	icon_state = "monkey1"
	icon_living = "monkey1"
	icon_dead = "monkey1_dead"
	speak_emote = list("pokrzykuje")
	emote_hear = list("pokrzykuje.")
	emote_see = list("drapie się.", "rozgląda się.")
	speak_chance = 1
	turns_per_move = 2
	butcher_results = list()
	response_help = "głaszcze"
	response_disarm = "odsuwa na bok"
	response_harm = "kopie"
