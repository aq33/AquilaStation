#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_LETHALITY 0.01 //lower values lower how harmful toxins are to the liver

/obj/item/organ/liver
	name = "wątroba"
	icon_state = "liver"
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	desc = "Sugerowane połączenie: chianti i bób."

	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5)

	var/alcohol_tolerance = ALCOHOL_RATE//affects how much damage the liver takes from alcohol
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE//maximum amount of toxins the liver can just shrug off
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY//affects how much damage toxins do to the liver
	var/filterToxins = TRUE //whether to filter toxins

#define HAS_SILENT_TOXIN 0 //don't provide a feedback message if this is the only toxin present
#define HAS_NO_TOXIN 1
#define HAS_PAINFUL_TOXIN 2

/obj/item/organ/liver/on_life()
	if(HAS_TRAIT(owner, TRAIT_NOMETABOLISM))
		return

	var/mob/living/carbon/C = owner
	..()	//perform general on_life()
	if(istype(C))
		if(!(organ_flags & ORGAN_FAILING))//can't process reagents with a failing liver

			var/provide_pain_message = HAS_NO_TOXIN
			if(filterToxins && !HAS_TRAIT(owner, TRAIT_TOXINLOVER))
				//handle liver toxin filtration
				for(var/datum/reagent/toxin/T in C.reagents.reagent_list)
					var/thisamount = C.reagents.get_reagent_amount(T.type)
					if (thisamount && thisamount <= toxTolerance)
						C.reagents.remove_reagent(T.type, 1)
					else
						damage += (thisamount*toxLethality)
						if(provide_pain_message != HAS_PAINFUL_TOXIN)
							provide_pain_message = T.silent_toxin ? HAS_SILENT_TOXIN : HAS_PAINFUL_TOXIN

			//metabolize reagents
			C.reagents.metabolize(C, can_overdose=TRUE)

			if(provide_pain_message && damage > 10 && prob(damage/3))//the higher the damage the higher the probability
				to_chat(C, "<span class='warning'>Czujesz tępy ból w brzuchu.</span>")

		else	//for when our liver's failing
			C.reagents.end_metabolization(C, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
			C.reagents.metabolize(C, can_overdose=FALSE, liverless = TRUE)
			if(HAS_TRAIT(C, TRAIT_STABLELIVER))
				return
			C.adjustToxLoss(4, TRUE,  TRUE)
			if(prob(30))
				to_chat(C, "<span class='warning'>Czujesz kłujący ból w brzuchu!</span>")

	if(damage > maxHealth)//cap liver damage
		damage = maxHealth

#undef HAS_SILENT_TOXIN
#undef HAS_NO_TOXIN
#undef HAS_PAINFUL_TOXIN

/obj/item/organ/liver/fly
	name = "owadzia wątroba"
	icon_state = "liver-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "Zmutowana wątroba przystosowana do wyjątkowej diety muchoczłowieka."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/plasmaman
	name = "kryształ przetwarzający reagenty"
	icon_state = "liver-p"
	desc = "Duży kryształ, który w jakiś sposób metabolizuje chemikalia. Występuje u plazmaludzi."

/obj/item/organ/liver/alien
	name = "wątroba obcego" // doesnt matter for actual aliens because they dont take toxin damage
	icon_state = "liver-x" // Same sprite as fly-person liver.
	desc = "Wątroba, która należała kiedyś do zabójczego obcego. Kto wie, co jadał."
	toxLethality = LIVER_DEFAULT_TOX_LETHALITY * 2.5 // rejects its owner early after too much punishment
	toxTolerance = 15 // complete toxin immunity like xenos have would be too powerful

/obj/item/organ/liver/cybernetic
	name = "cybernetyczna wątroba"
	icon_state = "liver-c"
	desc = "Urządzenie elektroniczne, które naśladuje funkcje ludzkiej wątroby. Radzi sobie z toksynami nieco lepiej niż organiczna wątroba."
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	maxHealth = 1.1 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 3.3
	toxLethality = 0.009

/obj/item/organ/liver/cybernetic/upgraded
	name = "ulepszona cybernetyczna wątroba"
	icon_state = "liver-c-u"
	desc = "Ulepszona wersja cybernetycznej wątroby, jeszcze lepsza od organicznych. Jest odporna na zatrucie alkoholem i bardzo skutecznie filtruje toksyny."
	alcohol_tolerance = 0.001
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 15 //can shrug off up to 15u of toxins
	toxLethality = 0.008 //20% less damage than a normal liver

/obj/item/organ/liver/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			damage+=100
		if(2)
			damage+=50

/obj/item/organ/liver/cybernetic/upgraded/ipc
	name = "procesor substancji"
	icon_state = "substance_processor"
	attack_verb = list("przetwarza")
	desc = "Podzespół maszyny montowany w klatce piersiowej. Pozwala maszynie przetwarzać chemikalia, które dostają się do jej systemów."
	alcohol_tolerance = 0
	toxTolerance = -1
	toxLethality = 0
	status = ORGAN_ROBOTIC

/obj/item/organ/liver/cybernetic/upgraded/ipc/emp_act(severity)
	to_chat(owner, "<span class='warning'>Alarm: twój procesor substancji został uszkodzony. Wewnętrzny wyciek chemiczny wpływa na wydajność.</span>")
	switch(severity)
		if(1)
			owner.toxloss += 15
		if(2)
			owner.toxloss += 5
