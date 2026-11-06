
/datum/rune_spell/paraphernalia
	name = "Akcesoria"
	desc = "Tworzy różne przybory, na przykład talizmany."
	desc_talisman = "JAK, SERIO, ZAWOŁAJ ADMINA."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/join
	cost_invoke = 2
	cost_upkeep = 1
	remaining_cost = 5
	talisman_absorb = RUNE_CANNOT
	var/obj/item/tome/target = null
	var/obj/item/talisman/tool = null
	page = "Ta runa pozwala przywołać tajemne przedmioty starannie wykonane w królestwie Nar-Sie, jak księga, którą właśnie trzymasz, albo talizmany, dzięki którym moc runy zmieścisz w kieszeni.\
		<br><br>Każdy przywołany przedmiot kosztuje kroplę twojej krwi, więc pilnuj się.\
		<br><br>Gdy już wchłoniesz runę w talizman, możesz położyć go z powrotem na tej runie i uruchomić ją ponownie, by przesłać go do tajemnej księgi innego kultysty, jeśli taką nosi.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."


/datum/rune_spell/paraphernalia/cast()
	var/obj/effect/new_rune/R = spell_holder
	var/obj/item/talisman/AT = locate() in get_turf(spell_holder)
	if (AT)
		if (AT.spell_type)
			var/mob/living/user = activator
			var/list/valid_tomes = list()
			var/i = 0
			for (var/obj/item/tome/T in GLOB.arcane_tomes)
				var/mob/M = locate(/mob/living) in T.contents
				if (M && IS_CULTIST(M))
					i++
					valid_tomes["[i] - Księga, którą nosi [M.real_name] ([T.talismans.len]/[MAX_TALISMAN_PER_TOME])"] = T

			for (var/datum/action/cooldown/spell/cult/arcane_dimension/A in GLOB.arcane_pockets)
				if (A.owner && A.owner.loc && ismob(A.owner) && A.stored_tome)
					i++
					var/mob/M = A.owner
					valid_tomes["[i] - Księga w tajemnym wymiarze [M.real_name] ([A.stored_tome.talismans.len]/[MAX_TALISMAN_PER_TOME])"] = A.stored_tome

			if (valid_tomes.len <= 0)
				to_chat(user, span_warning("Żaden kultysta nie nosi teraz księgi.") )
				qdel(src)
				return

			var/datum/rune_spell/spell = AT.spell_type
			var/chosen_tome = tgui_input_list(user, "Wybierz księgę, do której trafi ten talizman ([initial(spell.name)]).", "Przesłanie talizmanu", valid_tomes)
			if (!chosen_tome || QDELETED(src))
				qdel(src)
				return

			target = valid_tomes[chosen_tome]
			tool = AT

			if (target.talismans.len >= MAX_TALISMAN_PER_TOME)
				to_chat(activator, span_warning("Ta księga nie pomieści więcej talizmanów.") )
				abort(RITUALABORT_FULL)
				return

			R.one_pulse()
			contributors.Add(user)
			update_progbar()
			if (user.client)
				user.client.images |= progbar
			spell_holder.overlays += image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")
			INVOKE_ASYNC(src, PROC_REF(payment))
		else
			to_chat(activator, span_warning("Przesłać możesz tylko talizman z wchłoniętą albo dostrojoną runą.") )
			qdel(src)
	else
		var/list/choices = list(
			list("Talizman", "radial_paraphernalia_talisman", "Może wchłaniać runy (albo w niektórych przypadkach się do nich dostroić), dzięki czemu nosisz ich moc w kieszeni. Ma też kilka innych zastosowań."),
			list("Krwawa świeca", "radial_paraphernalia_candle", "Świeca, która może płonąć nawet przez godzinę. Daje nastrojowe światło."),
			list("Kusząca czara", "radial_paraphernalia_goblet", "Elegancki pojemnik na ulubiony napój. Zrób psikusa wrogom, uderzając ich czarą pełną krwi."),
			list("Rytualny nóż", "radial_paraphernalia_knife", "Dawno temu pewien czarodziej zaczarował taki nóż, by przeniknąć do królestwa Nar-Sie i ukraść kilka odłamków kamieni dusz. Dziś to po prostu fajny nóż. Nie polegaj na nim w walce."),
			list("Tajemna księga", "radial_paraphernalia_tome", "Przywołuje tajemną księgę pełną wiedzy Nar-Sie. Zawiera mnóstwo informacji o każdej runie i wielu innych sprawach kultu."),
			)
		var/list/made_choices = list()
		for(var/list/choice in choices)
			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'aquila/icons/bloodcult/cult_radial3.dmi', icon_state = choice[2])
			option.info = span_boldnotice(choice[3])
			made_choices[choice[1]] = option
		var/task = show_radial_menu(activator, get_turf(spell_holder), made_choices, tooltips = TRUE, radial_icon = 'aquila/icons/bloodcult/cult_radial3.dmi')
		if (QDELETED(src) || !spell_holder || !spell_holder.Adjacent(activator) || !task)
			qdel(src)
			return
		if (pay_blood())
			R.one_pulse()
			var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
			cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "conjure_paraphernalia", task)
			var/obj/spawned_object
			var/turf/T = get_turf(spell_holder)
			switch (task)
				if ("Talizman")
					spawned_object = new /obj/item/talisman(T)
				if ("Krwawa świeca")
					spawned_object = new /obj/item/candle/blood(T)
				if ("Kusząca czara")
					spawned_object = new /obj/item/reagent_containers/glass/cult(T)
				if ("Rytualny nóż")
					spawned_object = new /obj/item/kitchen/knife/ritual(T)
				if ("Tajemna księga")
					spawned_object = new /obj/item/tome(T)
			spell_holder.visible_message(span_rose("Krople krwi wsiąkają w runę, a na niej materializuje się [spawned_object].") )
			anim(target = spawned_object, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "rune_imbue")
			new /obj/effect/afterimage/black(T, spawned_object)
		qdel(src)


/datum/rune_spell/paraphernalia/midcast(mob/add_cultist) // failsafe should someone be hogging the radial menu.
	var/obj/effect/new_rune/R = spell_holder
	R.active_spell = null
	R.trigger(add_cultist)
	qdel(src)

/datum/rune_spell/paraphernalia/abort(cause)
	spell_holder?.overlays -= image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")
	..()


/datum/rune_spell/paraphernalia/cast_talisman()//there should be no ways for this to ever proc
	return


/datum/rune_spell/paraphernalia/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		if (destroying_self)
			return

		if (tool && tool.loc != spell_holder.loc)
			abort(RITUALABORT_TOOLS)
			return

		//are our payers still here and about?
		for(var/mob/living/L in contributors)
			if (!IS_CULTIST(L) || !(L in range(spell_holder, 1)) || (L.stat != CONSCIOUS))
				if (L.client)
					L.client.images -= progbar
				contributors.Remove(L)
		//alright then, time to pay in blood
		var/amount_paid = 0
		for(var/mob/living/L in contributors)
			var/data = use_available_blood(L, cost_upkeep, contributors[L])
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[L] = data[BLOODCOST_RESULT]
				make_tracker_effects(L.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				abort(RITUALABORT_BLOOD)
				return


		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("Rytuał runy wykonał ponad 1000 iteracji płacenia krwią. Coś tu nie gra.")

/datum/rune_spell/paraphernalia/proc/success()
	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)
	if (progbar)
		progbar.loc = null
	spell_holder.overlays -= image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")

	if (target.talismans.len < MAX_TALISMAN_PER_TOME)
		target.talismans.Add(tool)
		tool.forceMove(target)
		to_chat(activator, span_notice("Wsuwasz [tool] do [target].") )
		if (target.state == TOME_OPEN && ismob(target.loc))
			var/mob/M = target.loc
			M << browse(target.tome_text(), "window=arcanetome;size=537x375")
	else
		to_chat(activator, span_warning("Ta księga nie pomieści więcej talizmanów.") )
	qdel(src)
