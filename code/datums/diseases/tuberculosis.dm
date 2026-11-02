/datum/disease/tuberculosis
	form = "Choroba"
	name = "Gruźlica grzybicza"
	max_stages = 5
	spread_text = "Drogą powietrzną"
	cure_text = "Spacyklina i salbutamol"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/salbutamol)
	agent = "Grzybicze prątki gruźlicy Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 5//like hell are you getting out of hell
	desc = "Rzadki, wysoce zakaźny, zjadliwy wirus. Istnieje niewiele próbek, podobno starannie hodowanych przez tajnych specjalistów od broni biologicznej. Powoduje gorączkę, wymioty krwią, uszkodzenie płuc, utratę wagi i zmęczenie."
	required_organs = list(/obj/item/organ/lungs)
	danger = DISEASE_BIOHAZARD
	bypasses_immunity = TRUE // TB primarily impacts the lungs; it's also bacterial or fungal in nature; viral immunity should do nothing.

/datum/disease/tuberculosis/stage_act() //it begins
	..()
	switch(stage)
		if(2, 3)
			if(prob(2))
				affected_mob.emote("cough")
				to_chat(affected_mob, "<span class='danger'>Boli cię klatka piersiowa.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Twój żołądek gwałtownie burczy!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Oblewa cię zimny pot.</span>")
		if(4, 5)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>Widzisz wszystko poczwórnie!</span>")
				affected_mob.Dizzy(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Czujesz ostry ból w dolnej części klatki piersiowej!</span>")
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Czujesz, jak powietrze boleśnie ucieka ci z płuc.</span>")
				affected_mob.adjustOxyLoss(25)
				affected_mob.emote("gasp")
			if(stage >= 5)
				if(prob(2))
					to_chat(affected_mob, "<span class='userdanger'>[pick("Czujesz, jak twoje serce zwalnia.", "Rozluźniasz się i spowalniasz bicie serca.")]</span>")
					affected_mob.adjustStaminaLoss(70)
				if(prob(10))
					affected_mob.adjustStaminaLoss(100)
					affected_mob.visible_message("<span class='warning'>[affected_mob] mdleje!</span>", "<span class='userdanger'>Poddajesz się i czujesz spokój.</span>")
					affected_mob.AdjustSleeping(100)
				if(prob(2))
					to_chat(affected_mob, "<span class='userdanger'>Czujesz, jak twój umysł się rozluźnia, a myśli dryfują!</span>")
					affected_mob.confused = min(100, affected_mob.confused + 8)
				if(prob(10))
					affected_mob.vomit(20)
				if(prob(3))
					to_chat(affected_mob, "<span class='warning'><i>[pick("Cicho burczy ci w brzuchu.", "Żołądek ci się zaciska, a potem wiotczeje, mięśnie są martwe i bez życia.", "Zjadłbyś kredkę.")]</i></span>")
					affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
					affected_mob.adjust_nutrition(-100)
				if(prob(15))
					to_chat(affected_mob, "<span class='danger'>[pick("Jest ci nieprzyjemnie gorąco.", "Masz ochotę rozpiąć kombinezon.", "Masz ochotę zdjąć trochę ubrań.")]</span>")
					affected_mob.adjust_bodytemperature(40)
	return

