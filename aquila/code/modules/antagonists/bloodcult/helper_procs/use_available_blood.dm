/*	use_available_blood
	user: the mob (generally a cultist) trying to spend blood
	amount_needed: the amount of blood required
	previous_result: the result of the previous call of this proc if any, to prevent the same flavor text from displaying every single call of this proc in a row
	tribute: set to 1 when called by a contributor to Blood Communion

	returns: a /list with information on the success/failure of the proc, and in the former case, information the blood that was used (color, type, dna)
*/
/proc/use_available_blood(mob/user, amount_needed = 0, previous_result = "", tribute = 0, feedback = TRUE)
	//Blood Communion
	var/communion = 0
	var/communion_data = null
	var/total_accumulated = 0
	var/total_needed = amount_needed
	if (!tribute && IS_CULTIST(user))
		var/datum/antagonist/cult/mycultist = user.mind?.has_antag_datum(/datum/antagonist/cult)
		if (mycultist?.blood_pool && (mycultist in GLOB.blood_communion))
			communion = 1
			amount_needed = max(1, round(amount_needed * 4 / 5))//saving 20% blood
			var/list/tributers = list()
			for (var/datum/antagonist/cult/cultist in GLOB.blood_communion)
				if (cultist.blood_pool && cultist.owner && cultist.owner.current && iscarbon(cultist.owner.current) && cultist.owner.current.stat != DEAD)
					var/mob/living/L = cultist.owner.current
					if (istype(L) && L != user)
						tributers.Add(L)
			var/total_per_tribute = max(1, round(amount_needed/max(1, tributers.len+1)))
			var/tributer_size = tributers.len
			for (var/i = 1 to tributer_size)
				var/mob/living/L = pick(tributers)//so it's not always the first one that pays the first blood unit.
				tributers.Remove(L)
				var/data = use_available_blood(L, total_per_tribute, "", 1)
				if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
					total_accumulated += data[BLOODCOST_TOTAL]
				if (total_accumulated >= amount_needed - total_per_tribute)//could happen if the cost is less than 1 per tribute
					communion_data = data//in which case, the blood will carry the data that paid for it
					break

	//Getting nearby blood sources
	var/list/data = get_available_blood(user, amount_needed-total_accumulated)

	var/datum/reagent/blood/blood

	//Flavour text and blood data transfer
	switch (data[BLOODCOST_RESULT])
		if (BLOODCOST_TRIBUTE)//if the drop of blood was paid for through blood communion, let's get the reference to the blood they used because we can
			blood = new()
			if (communion_data && communion_data[BLOODCOST_RESULT])
				switch(communion_data[BLOODCOST_RESULT])
					if (BLOODCOST_TARGET_HANDS)
						blood = cult_blood_reagent(communion_data[BLOODCOST_USER])

							//can't get virus data from bloody hands because it'd be a pain in the ass to code for minimal use
					if (BLOODCOST_TARGET_SPLATTER)
						blood = cult_blood_reagent_from_decal(communion_data[BLOODCOST_TARGET_SPLATTER])
					if (BLOODCOST_TARGET_GRAB)
						blood = cult_blood_reagent(communion_data[BLOODCOST_TARGET_GRAB])
					if (BLOODCOST_TARGET_BLEEDER)
						blood = cult_blood_reagent(communion_data[BLOODCOST_TARGET_BLEEDER])
					if (BLOODCOST_TARGET_HELD)
						var/obj/item/reagent_containers/G = communion_data[BLOODCOST_TARGET_HELD]
						blood = locate() in G.reagents.reagent_list
					if (BLOODCOST_TARGET_BLOODPACK)
						var/obj/item/reagent_containers/blood/B = communion_data[BLOODCOST_TARGET_BLOODPACK]
						blood = locate() in B.reagents.reagent_list
					if (BLOODCOST_TARGET_CONTAINER)
						var/obj/item/reagent_containers/G = communion_data[BLOODCOST_TARGET_CONTAINER]
						blood = locate() in G.reagents.reagent_list
					if (BLOODCOST_TARGET_USER)
						var/mob/living/CA = communion_data[BLOODCOST_USER]
						if (iscarbon(CA))
							blood = cult_blood_reagent(CA)
						if (isconstruct(CA))//constructs can't get the blood communion tattoo but just in case they do later
							blood.data["blood_colour"] = "#CC0E00"
			if (feedback && !tribute && previous_result != BLOODCOST_TRIBUTE)
				user.visible_message(span_warning("Wokół [user] z powietrza pojawiają się krople krwi i spadają na podłogę!") ,
									span_rose("Sojusznik użyczył ci kropli swojej krwi do rytuału.") ,
									span_warning("Słyszysz, jak płynie jakiś płyn.") )
		if (BLOODCOST_TARGET_HANDS)
			blood = cult_blood_reagent(user)
			//can't get virus data from bloody hands because it'd be a pain in the ass to code for minimal use
			if (feedback && !tribute && previous_result != BLOODCOST_TARGET_HANDS)
				user.visible_message(span_warning("Krew z rąk [user] kapie na podłogę!") ,
									span_rose("Pozwalasz, by krew z twoich rąk spłynęła do kałuży przywołania.") ,
									span_warning("Słyszysz, jak płynie jakiś płyn.") )
		if (BLOODCOST_TARGET_SPLATTER)
			blood = cult_blood_reagent_from_decal(data[BLOODCOST_TARGET_SPLATTER])
			if (feedback && !tribute && previous_result != BLOODCOST_TARGET_SPLATTER)
				user.visible_message(span_warning("Krew na podłodze pod [user] zaczyna się poruszać!") ,
									span_rose("Kierujesz krew z plam na podłodze do kałuży przywołania.") ,
									span_warning("Słyszysz, jak płynie jakiś płyn.") )
		if (BLOODCOST_TARGET_GRAB)
			var/mob/living/carbon/C = data[BLOODCOST_TARGET_GRAB]
			if (iscarbon(C))
				blood = cult_blood_reagent(C)
				if (feedback && !tribute && previous_result != BLOODCOST_TARGET_GRAB)
					user.visible_message(span_warning("[user] wbija paznokcie w [data[BLOODCOST_TARGET_GRAB]], upuszczając krwi!") ,
										span_rose("Wbijasz paznokcie w [data[BLOODCOST_TARGET_GRAB]], by upuścić trochę krwi.") ,
										span_warning("Słyszysz, jak płynie jakiś płyn.") )

		if (BLOODCOST_TARGET_BLEEDER)
			var/mob/living/carbon/C = data[BLOODCOST_TARGET_BLEEDER]
			if (iscarbon(C))
				blood = cult_blood_reagent(C)
				if (feedback && !tribute && previous_result != BLOODCOST_TARGET_BLEEDER)
					user.visible_message(span_warning("[user] zanurza palce w ranach [data[BLOODCOST_TARGET_BLEEDER]]!") ,
										span_rose("Zanurzasz palce w ranach [data[BLOODCOST_TARGET_BLEEDER]], by zaczerpnąć trochę krwi.") ,
										span_warning("Słyszysz, jak płynie jakiś płyn.") )
		if (BLOODCOST_TARGET_HELD)
			var/obj/item/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			blood = locate() in G.reagents.reagent_list
			if (!tribute && previous_result != BLOODCOST_TARGET_HELD)
				user.visible_message(span_warning("[user] przechyla [data[BLOODCOST_TARGET_HELD]], wylewając krew!") ,
									span_rose("Przechylasz [data[BLOODCOST_TARGET_HELD]], by wylać krew ze środka.") ,
									span_warning("Słyszysz, jak płynie jakiś płyn.") )
		if (BLOODCOST_TARGET_BLOODPACK)
			var/obj/item/reagent_containers/blood/B = data[BLOODCOST_TARGET_BLOODPACK]
			blood = locate() in B.reagents.reagent_list
			if (feedback && !tribute && previous_result != BLOODCOST_TARGET_BLOODPACK)
				user.visible_message(span_warning("[user] ściska [data[BLOODCOST_TARGET_BLOODPACK]], wylewając krew!") ,
									span_rose("Ściskasz [data[BLOODCOST_TARGET_BLOODPACK]], by wylać krew ze środka.") ,
									span_warning("Słyszysz, jak płynie jakiś płyn.") )
		if (BLOODCOST_TARGET_CONTAINER)
			var/obj/item/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			blood = locate() in G.reagents.reagent_list
			if (feedback && !tribute && previous_result != BLOODCOST_TARGET_CONTAINER)
				user.visible_message(span_warning("[user] zanurza palce w [data[BLOODCOST_TARGET_CONTAINER]], brudząc je krwią!") ,
									span_rose("Zanurzasz palce w [data[BLOODCOST_TARGET_CONTAINER]], brudząc je krwią.") ,
									span_warning("Słyszysz, jak płynie jakiś płyn.") )
		if (BLOODCOST_TARGET_USER)
			blood = new()
			if (!tribute)
				if (data[BLOODCOST_HOLES_BLOODPACK])
					to_chat(user, span_warning("Musisz najpierw przebić [data[BLOODCOST_TARGET_BLOODPACK]], żeby wycisnąć z niego krew!") )
				else if (data[BLOODCOST_LID_HELD])
					to_chat(user, span_warning("Najpierw zdejmij pokrywkę z [data[BLOODCOST_TARGET_HELD]]!") )
				else if (data[BLOODCOST_LID_CONTAINER])
					to_chat(user, span_warning("Najpierw zdejmij pokrywkę z [data[BLOODCOST_TARGET_CONTAINER]]!") )
			if (iscarbon(user))
				blood = cult_blood_reagent(user)

			if (isconstruct(user))
				blood.data["blood_colour"] = "#CC0E00"//not like constructs can write runes by themselves currently, but they might do at some point

			if (feedback && !tribute && (previous_result != BLOODCOST_TARGET_USER))
				if (iscarbon(user))//if the user is holding a sharp weapon, they get a custom message
					var/obj/item/W = user.get_active_held_item()
					if (!W?.is_sharp())
						W = user.get_inactive_held_item()
					if (W?.is_sharp())
						to_chat(user, span_rose("Nacinasz sobie palec za pomocą: [W], by puścić trochę krwi."))
					else
						to_chat(user, span_rose("Przygryzasz palec i pozwalasz kropli krwi wypłynąć."))
				else if (isconstruct(user))
					to_chat(user, span_rose("Więź twojej powłoki z tym, co za zasłoną, pozwala ci odprawić rytuał bez źródła krwi pod ręką.") )
		if (BLOODCOST_FAILURE)
			if (!tribute)
				if (data[BLOODCOST_HOLES_BLOODPACK])
					to_chat(user, span_danger("Musisz najpierw przebić [data[BLOODCOST_TARGET_BLOODPACK]], żeby wycisnąć z niego krew!") )
				else if (data[BLOODCOST_LID_HELD])
					to_chat(user, span_danger("Najpierw zdejmij pokrywkę z [data[BLOODCOST_TARGET_HELD]]!") )
				else if (data[BLOODCOST_LID_CONTAINER])
					to_chat(user, span_danger("Najpierw zdejmij pokrywkę z [data[BLOODCOST_TARGET_HELD]]!") )
				else
					to_chat(user, span_danger("Nie ma tu żadnej krwi. Nawet w twoim własnym ciele!") )

	//Blood is only consumed if there is enough of it
	if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
		if (data[BLOODCOST_TARGET_HANDS])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HANDS]
			var/mob/living/carbon/human/H = user
			H.blood_in_hands = max(0, H.blood_in_hands - data[BLOODCOST_AMOUNT_HANDS])
			if (!H.blood_in_hands)
				H.update_inv_gloves()
		if (data[BLOODCOST_TARGET_SPLATTER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_SPLATTER]
			var/obj/effect/decal/cleanable/blood/B = data[BLOODCOST_TARGET_SPLATTER]
			B.cult_use_blood(data[BLOODCOST_AMOUNT_SPLATTER])
		if (data[BLOODCOST_TARGET_GRAB])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_GRAB]
			if (ishuman(data[BLOODCOST_TARGET_GRAB]))
				var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_GRAB]
				H.blood_volume -= data[BLOODCOST_AMOUNT_GRAB]
				H.take_overall_damage(data[BLOODCOST_AMOUNT_GRAB] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_BLEEDER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_BLEEDER]
			var/mob/living/carbon/human/H = data[BLOODCOST_TARGET_BLEEDER]
			H.blood_volume -= data[BLOODCOST_AMOUNT_BLEEDER]
			H.take_overall_damage(data[BLOODCOST_AMOUNT_BLEEDER] ? 0.1 : 0)
		if (data[BLOODCOST_TARGET_HELD])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_HELD]
			var/obj/item/reagent_containers/G = data[BLOODCOST_TARGET_HELD]
			G.reagents.remove_reagent(/datum/reagent/blood, data[BLOODCOST_AMOUNT_HELD])
		if (data[BLOODCOST_TARGET_BLOODPACK])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_BLOODPACK]
			var/obj/item/reagent_containers/G = data[BLOODCOST_TARGET_BLOODPACK]
			G.reagents.remove_reagent(/datum/reagent/blood, data[BLOODCOST_AMOUNT_BLOODPACK])
		if (data[BLOODCOST_TARGET_CONTAINER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_CONTAINER]
			var/obj/item/reagent_containers/G = data[BLOODCOST_TARGET_CONTAINER]
			G.reagents.remove_reagent(/datum/reagent/blood, data[BLOODCOST_AMOUNT_CONTAINER])
		if (data[BLOODCOST_TARGET_USER])
			data[BLOODCOST_TOTAL] += data[BLOODCOST_AMOUNT_USER]
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				var/blood_before = H.blood_volume
				H.blood_volume -= data[BLOODCOST_AMOUNT_USER]
				var/blood_after = H.blood_volume
				if (blood_before > BLOOD_VOLUME_SAFE && blood_after < BLOOD_VOLUME_SAFE)
					to_chat(user, span_cult("Zaczynasz blednąć.") )
				else if (blood_before > BLOOD_VOLUME_OKAY && blood_after < BLOOD_VOLUME_OKAY)
					to_chat(user, span_cult("Zaraz zemdlejesz z braku krwi.") )
				else if (blood_before > BLOOD_VOLUME_BAD && blood_after < BLOOD_VOLUME_BAD)
					to_chat(user, span_cult("Trudno ci się skupić. Będzie źle, jeśli dalej będziesz używać własnej krwi.") )
				else if (blood_before > BLOOD_VOLUME_SURVIVE && blood_after < BLOOD_VOLUME_SURVIVE)
					to_chat(user, span_cult("Wkrótce będzie po wszystkim.") )
				H.take_overall_damage(data[BLOODCOST_AMOUNT_USER] ? 0.1 : 0)
			else if (ismonkey(user) || isalien(user))
				var/mob/living/carbon/C = user
				var/blood_before = C.health
				if (ismonkey(C))
					C.adjustOxyLoss(data[BLOODCOST_AMOUNT_USER])
				else if (isalien(C))
					C.adjustBruteLoss(data[BLOODCOST_AMOUNT_USER])
				C.updatehealth()
				var/blood_after = C.health
				if (blood_before > (C.maxHealth*5/6) && blood_after < (C.maxHealth*5/6))
					to_chat(user, span_cult("Zaczynasz blednąć.") )
				else if (blood_before > (C.maxHealth*4/6) && blood_after < (C.maxHealth*4/6))
					to_chat(user, span_cult("Czujesz się słabo z braku krwi.") )
				else if (blood_before > (C.maxHealth*3/6) && blood_after < (C.maxHealth*3/6))
					to_chat(user, span_cult("Zaraz zemdlejesz z braku krwi.") )
				else if (blood_before > (C.maxHealth*2/6) && blood_after < (C.maxHealth*2/6))
					to_chat(user, span_cult("Trudno ci się skupić. Będzie źle, jeśli dalej będziesz używać własnej krwi.") )
				else if (blood_before > (C.maxHealth*1/6) && blood_after < (C.maxHealth*1/6))
					to_chat(user, span_cult("Wkrótce będzie po wszystkim.") )


	if (communion && data[BLOODCOST_TOTAL] + total_accumulated >= amount_needed)
		data[BLOODCOST_TOTAL] = max(data[BLOODCOST_TOTAL], total_needed)
	data["blood"] = blood
	return data
