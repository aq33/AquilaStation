/datum/rune_spell/raisestructure
	name = "Wzniesienie Budowli"
	desc = "Ściąga plugawe budowle z królestwa Nar-Sie."
	desc_talisman = "Użyj, by zacząć wznosić budowlę tam, gdzie stoisz."
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/join
	cost_upkeep = 1
	remaining_cost = 300
	accumulated_blood = 0
	page = "Skup się na tej runie, by stworzyć Ołtarz, Kuźnię albo Iglicę. Rytuał przyspieszysz, jeśli inni kultyści dotkną runy albo jeśli nosisz szaty kultu. \
		<br><br>Ołtarze pozwalają porozumiewać się z Nar-Sie, przywoływać klejnoty dusz i śledzić członków kultu i ich działania na stacji.\
		<br><br>Kuźnie pozwalają wykuwać zbroje, potężne ostrza i skorupy konstruktów. Ostrza i skorupy można łączyć z klejnotami dusz z wielkim skutkiem, \
		ale pamiętaj, że kuźnie parzą tych, którzy stoją przy nich zbyt długo. Pomagają szaty kultu albo runa Zapału, która przywraca ci normalną temperaturę.\
		<br><br>Iglice zapewniają kultowi łatwą łączność w całym regionie. Po zbudowaniu jednej używaj :f (albo .f lub #f), by mówić na kanale kultu."
	var/turf/loc_memory = null
	var/spawntype = /obj/structure/cult/altar
	var/structure

/datum/rune_spell/raisestructure/proc/proximity_check()
	var/obj/effect/new_rune/R = spell_holder
	if (locate(/obj/structure/cult) in range(R.loc, 0))
		abort(RITUALABORT_BLOCKED)
		return FALSE

	if (locate(/obj/machinery/door/airlock/cult) in range(R.loc, 1))
		abort(RITUALABORT_NEAR)
		return FALSE

	else return TRUE

/datum/rune_spell/raisestructure/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	var/mob/living/user = activator

	if (!proximity_check()) //See above
		return

	var/list/choices = list(
		list("Ołtarz", "radial_altar", "Serce bazy kultu. Pozwala porozumiewać się z Nar-Sie, przywoływać klejnoty dusz i śledzić członków kultu i ich działania na stacji."),
		list("Iglica", "radial_spire", "Pozwala wszystkim kultystom na poziomie porozumiewać się ze sobą przez :f"),
		list("Kuźnia", "radial_forge", "Służy do wykuwania ostrzy i zbroi kultu oraz skorup konstruktów. Zbyt długie stanie obok bez odpowiedniego stroju kultu może być parzącym doświadczeniem."),
		list("Pylon", "radial_pylon", "Daje trochę światła w okolicy.")
	)

	var/list/made_choices = list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'aquila/icons/bloodcult/cult_radial3.dmi', icon_state = choice[2])
		option.info = span_boldnotice(choice[3])
		made_choices[choice[1]] = option

	structure = show_radial_menu(user, R.loc, made_choices ,tooltips = TRUE, radial_icon = 'aquila/icons/bloodcult/cult_radial3.dmi')

	if(QDELETED(src) || !spell_holder)
		return

	if(!R.Adjacent(user) || !structure )
		abort()
		return

	// AQUILA - po menu radialnym rune.active_spell to już my (trigger przypisał), więc pomijamy siebie
	if(R.active_spell && R.active_spell != src)
		to_chat(user, span_rose("Z tej runy wznosi się już budowla, więc dokładasz się do niej.") )
		R.active_spell.midcast(user)
		qdel(src)
		return

	switch(structure)
		if("Ołtarz")
			spawntype = /obj/structure/cult/altar
		if("Iglica")
			spawntype = /obj/structure/cult/spire
		if("Kuźnia")
			spawntype = /obj/structure/cult/forge
		if("Pylon")
			spawntype = /obj/structure/cult/pylon

	loc_memory = spell_holder.loc
	contributors.Add(user)
	update_progbar()
	if(user.client)
		user.client.images |= progbar
	spell_holder.overlays += image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")
	to_chat(activator, span_rose("Ten rytuał przyspieszysz, jeśli dołączą do niego inni kultyści albo jeśli założysz strój kultu.") )
	INVOKE_ASYNC(src, PROC_REF(payment))

/datum/rune_spell/raisestructure/cast_talisman() //Raise structure talismans create an invisible summoning rune beneath the caster's feet.
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	new type(activator, R) // przypisuje R.active_spell w New()
	qdel(src)

/datum/rune_spell/raisestructure/midcast(mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/raisestructure/abort(cause)
	spell_holder?.overlays -= image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")
	..()

/datum/rune_spell/raisestructure/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		if (destroying_self || !spell_holder)
			return
		//are our payers still here and about?
		var/summoners = 2//the higher, the easier it is to perform the ritual without many cultists. default = 2
		for(var/mob/living/L in contributors)
			if (IS_CULTIST(L) && (L in range(spell_holder, 1)) && (L.stat == CONSCIOUS))
				summoners++
				summoners += round(L.get_cult_power()/30)	//For every 30 cult power, you count as one additional cultist. So with Robes and Shoes, you already count as 3 cultists.
			else											//This makes using the rune alone hard at roundstart, but fairly easy later on.
				if (L.client)
					L.client.images -= progbar
				contributors.Remove(L)
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

		if(amount_paid) //3 seconds without blood and the ritual fails.
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				if(accumulated_blood && !(locate(/obj/effect/decal/cleanable/blood/splatter) in loc_memory))
					new /obj/effect/decal/cleanable/blood/splatter(loc_memory)//splash
				abort(RITUALABORT_BLOOD)
				return

		switch(summoners)
			if (1)
				remaining_cost = 300
			if (2)
				remaining_cost = 120
			if (3)
				remaining_cost = 18
			if (4 to INFINITY)
				remaining_cost = 0

		if(accumulated_blood >= remaining_cost )
			if (proximity_check())
				success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/raisestructure/proc/success()
	for(var/mob/living/L in contributors)
		var/datum/antagonist/cult/cult_datum = IS_CULTIST(L)
		cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "raise_structure", structure)
	new spawntype(spell_holder.loc)
	qdel(spell_holder) //Deletes the datum as well.
