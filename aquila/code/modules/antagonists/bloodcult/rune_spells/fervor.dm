
/datum/rune_spell/fervor
	name = "Zapał"
	desc = "Natchnij pobliskich kultystów, by otrząsnęli się z ogłuszenia i ruszali się szybciej."
	desc_talisman = "Użyj, by natchnąć pobliskich kultystów, żeby otrząsnęli się z ogłuszenia i ruszali się szybciej."
	invocation = "Khari'd! Gual'te nikka!"
	word1 = /datum/rune_word/travel
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/other
	page = "Za 20u krwi ta runa od razu wzmacnia wszystkich kultystów w promieniu 7 pól, zdejmując z nich ogłuszenie, obrażenia od niedotlenienia, wodę święconą i różne inne przypadłości.\
		<br><br>Dodatkowo wstrzykuje im 3u efedryny, która przyspiesza ruch mimo ran czy ciężkiego ubrania. To bardzo silna runa w walce, zwłaszcza tuż po granacie hukowym albo przed starciem. Najlepiej używać jej z talizmanu. "
	cost_invoke = 20
	var/effect_range = 7

/datum/rune_spell/fervor/cast()
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
		for(var/mob/living/L in range(effect_range, get_turf(spell_holder)))
			if (iscarbon(L))
				var/mob/living/carbon/carbon = L
				if (carbon.occult_muted())
					continue
			if(L.stat != DEAD && IS_CULTIST(L))
				if (L != activator)
					cult_datum?.gain_devotion(50, DEVOTION_TIER_1, "fervor", L)
				playsound(L, 'aquila/sound/bloodcult/fervor.ogg', 50, 0, -2)
				anim(target = L, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "rune_fervor", plane = ABOVE_LIGHTING_PLANE, direction = L.dir)
				L.setOxyLoss(0)
				L.SetParalyzed(0)
				L.SetStun(0)
				L.SetKnockdown(0)
				L.SetUnconscious(0)
				L.bodytemperature = BODYTEMP_NORMAL
				// AQUILA - u nas nie ma determination z tg, efedryna jak hyperzine w vg
				L.reagents?.add_reagent(/datum/reagent/medicine/ephedrine, 3)
				L.setStaminaLoss(0)

				L.set_stat(CONSCIOUS)
				if (L.reagents)
					L.reagents.del_reagent(/datum/reagent/water/holywater)
		qdel(spell_holder)
	qdel(src)
