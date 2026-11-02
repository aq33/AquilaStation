/mob/living/carbon/human/death(gibbed)
	var/was_dead = (stat == DEAD)
	. = ..()
	if(was_dead || stat != DEAD || !client || !IS_CULTIST(src))
		return
	var/mob/living/simple_animal/shade/shade = new (get_turf(src))
	shade.name = "Cień [real_name]"
	shade.real_name = "[real_name]"
	mind.transfer_to(shade)

	to_chat(shade, span_cult("Mroczne energie rozdzierają twoje umierające ciało, kotwicząc twoją duszę w postaci Cienia. Zachowujesz wspomnienia i oddanie kultowi."))
	// AQUILA - przy rozerwaniu ciało i tak znika, więc cień go nie zabiera
	if(!gibbed)
		shade.body = src
		src.forceMove(shade)

/datum/rune_spell/reincarnation
	name = "Reinkarnacja"
	desc = "Daje cieniom replikę ich pierwotnego ciała."
	desc_talisman = "Daje cieniom replikę ich pierwotnego ciała."
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/join
	word3 = /datum/rune_word/hell
	page = "Ta runa pozwala dać cieniowi ciało odtworzone z tego, które miał pierwotnie (a przynajmniej z tego, które jego dusza pamięta).\
		<br><br>Cień musi stać na runie, by rytuał się zaczął. Pamiętaj jednak, że koszt krwi jest bardzo wysoki: 300u płaconych przez 60 sekund skupienia. \
		Inni kultyści mogą dołączyć do rytuału i podzielić się ciężarem, możesz też poprosić konstrukt, by dzięki więzi z tamtą stroną całkiem ominął koszt krwi.\
		<br><br>Pamiętaj, że nowe ciało może być znacznie bledsze niż oryginał. To niefortunny efekt uboczny, z którym musisz poradzić sobie sam.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."
	cost_upkeep = 5
	remaining_cost = 300
	var/obj/effect/cult_ritual/resurrect/husk = null
	var/mob/living/simple_animal/shade/shade = null

/datum/rune_spell/reincarnation/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	shade = locate(/mob/living/simple_animal/shade) in R.loc
	if (!shade)
		to_chat(activator, span_warning("Na runie musi stać cień.") )
		qdel(src)
		return

	husk = new (R.loc)
	flick("rune_resurrect_start", husk)
	shade.forceMove(husk)

	contributors.Add(activator)
	update_progbar()
	if (activator.client)
		activator.client.images |= progbar
	spell_holder.overlays += image('aquila/icons/bloodcult/cult.dmi', "build")
	to_chat(activator, span_rose("Ten rytuał ma bardzo wysoki koszt krwi na sekundę, ale pójdzie szybciej, jeśli dołączą do niego inni kultyści.") )
	INVOKE_ASYNC(src, PROC_REF(payment))

/datum/rune_spell/reincarnation/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	new type(activator, R) // przypisuje R.active_spell w New()
	qdel(src)

/datum/rune_spell/reincarnation/midcast(mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/reincarnation/abort(cause)
	spell_holder?.overlays -= image('aquila/icons/bloodcult/cult.dmi', "build")
	if (shade && husk)
		shade.forceMove(get_turf(husk))
	if (husk)
		qdel(husk)
	if (spell_holder?.loc && (!cause || cause != RITUALABORT_MISSING))
		new /obj/effect/gibspawner/human(spell_holder.loc)
	..()

/datum/rune_spell/reincarnation/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		if (destroying_self || !spell_holder)
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
				make_tracker_effects(L.loc, spell_holder, 1, "soul2", 3, /obj/effect/tracker/drain, 1)//visual feedback

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

/datum/rune_spell/reincarnation/proc/success()
	spell_holder.overlays -= image('aquila/icons/bloodcult/cult.dmi', "build")
	var/resurrector = activator?.real_name
	if (shade && husk && shade.mind)
		shade.forceMove(get_turf(husk))
		var/mob/living/carbon/human/M
		if(shade.body && !QDELETED(shade.body))
			M = shade.body
			M.forceMove(shade.loc)
			shade.mind.transfer_to(M)
			M.revive(full_heal = TRUE, admin_revive = TRUE)
		else
			M = new(get_turf(shade))
			shade.client?.prefs.active_character.copy_to(M)
			shade.mind.transfer_to(M)

		// make them deathly white, afterall they dont have a soul anymore
		if(M.dna?.species?.use_skintones)
			M.skin_tone = "albino"
		else if(M.dna)
			M.dna.features["mcolor"] = "FFF"
		shade.body = null
		qdel(husk)
		husk = null
		qdel(shade)
		shade = null
		playsound(M, 'aquila/sound/bloodcult/spawn.ogg', 50, 0, 0)
		var/datum/antagonist/cult/newCultist = IS_CULTIST(M)
		if (!newCultist && M.mind)
			newCultist = new
			M.mind.add_antag_datum(newCultist)
			var/datum/team/cult/cult = locate_team(/datum/team/cult)
			cult?.HandleRecruitedRole(newCultist)
			newCultist.conversion["resurrected"] = resurrector

		/*
		if (ishuman(M))
			// purely cosmetic tattoos. giving cultists some way to have tattoos until those get reworked
			newCultist.tattoos[TATTOO_POOL] = new /datum/cult_tattoo/bloodpool()
			newCultist.tattoos[TATTOO_HOLY] = new /datum/cult_tattoo/holy()
			newCultist.tattoos[TATTOO_MANIFEST] = new /datum/cult_tattoo/manifest()
		*/

		M.regenerate_icons()
		M.update_body()
		newCultist?.update_cult_hud()

		for(var/mob/living/L in contributors)
			var/datum/antagonist/cult/cult_datum = IS_CULTIST(L)
			cult_datum?.gain_devotion(200, DEVOTION_TIER_3, "reincarnation", M)

	else
		for(var/mob/living/L in contributors)
			to_chat(L, span_warning("Coś poszło nie tak z rytuałem, cień chyba zniknął.") )


	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/obj/effect/cult_ritual/resurrect
	anchored = 1
	icon_state = "rune_resurrect"
	plane = ABOVE_GAME_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/resurrect/New(turf/loc)
	..()
	overlays += "summoning"
