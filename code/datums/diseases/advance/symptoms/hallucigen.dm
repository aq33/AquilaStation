/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmission.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen
	name = "Halucygen"
	desc = "Wirus stymuluje mózg, powodując okazjonalne halucynacje."
	stealth = 1
	resistance = -1
	stage_speed = 1
	transmission = 1
	level = 3
	severity = 1
	base_message_chance = 25
	symptom_delay_min = 10
	symptom_delay_max = 70
	prefixes = list("Narcotic ", "Narco", "Psycho-")
	suffixes = list(" Psychosis")
	var/fake_healthy = FALSE
	threshold_desc = "<b>Szybkość stadiów 7:</b> zwiększa liczbę halucynacji.<br><b>Ukrycie 2:</b> wirus naśladuje pozytywne objawy.."

/datum/symptom/hallucigen/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 7)
		severity += 1

/datum/symptom/hallucigen/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2) //fake good symptom messages
		fake_healthy = TRUE
		base_message_chance = 50
	if(A.stage_rate >= 7) //stronger hallucinations
		power = 2

/datum/symptom/hallucigen/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/list/healthy_messages = list("Twoje płuca czują się świetnie.", "Uświadamiasz sobie, że nie oddychałeś.", "Nie czujesz potrzeby oddychania.",\
					"Twoje oczy czują się świetnie.", "Mrugasz teraz ręcznie.", "Nie czujesz potrzeby mrugania.")
	switch(A.stage)
		if(1, 2)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, "<span class='notice'>[pick("Coś pojawia się na skraju twojego pola widzenia i znika.", "Słyszysz cichy szept znikąd.", "Boli cię głowa.")]</span>")
				else
					to_chat(M, "<span class='notice'>[pick(healthy_messages)]</span>")
		if(3, 4)
			if(prob(base_message_chance))
				if(!fake_healthy)
					to_chat(M, "<span class='danger'>[pick("Coś za tobą idzie.", "Ktoś cię obserwuje.", "Słyszysz szept w uchu.", "Znikąd zbliżają się do ciebie dudniące kroki.")]</span>")
				else
					to_chat(M, "<span class='notice'>[pick(healthy_messages)]</span>")
		else
			if(prob(base_message_chance))
				to_chat(M, "<span class='userdanger'>[pick("Och, twoja głowa...", "Łupie cię w głowie.", "Są wszędzie! Uciekaj!", "Coś w cieniu...")]</span>")
			M.hallucination += (45 * power)
