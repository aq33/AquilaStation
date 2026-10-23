// aq33/AquilaStation#329 - Demony Grzechu: synchronizacja z Yogstation i poprawki portu

/// Typ pośredni (bez nazwy) - podtypy robią z testera demona danego grzechu
/datum/test_chamber_kit/pr_329
	pr = "aq33/AquilaStation#329"
	items = list(
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 1,
		/obj/item/nullrod = 1,
		/obj/item/card/id/captains_spare = 1,
		/mob/living/carbon/human = 1,
		/obj/item/food/burger/plain = 3,
	)
	/// Grzech nadawany testerowi (wartości jak SIN_* z demons.dm)
	var/sin

/datum/test_chamber_kit/pr_329/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind || !sin)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby zostać demonem. Przedmioty i tak leżą na arenie.</span>")
		return
	if(H.mind.has_antag_datum(/datum/antagonist/sinfuldemon))
		to_chat(user, "<span class='warning'>Już jesteś demonem - zdejmij antaga w Traitor Panel, żeby zmienić grzech.</span>")
		return
	var/datum/antagonist/sinfuldemon/demon = new
	demon.demonsin = sin
	H.mind.add_antag_datum(demon)

/datum/test_chamber_kit/pr_329/gluttony
	name = "PR 329: demon obżarstwa"
	description = "Robi z ciebie demona obżarstwa. Jedz burgery: TRAIT_EAT_MORE i bezdenny żołądek mają działać. Ściana obżarstwa NIE może blokować ciebie, ma blokować innych. \
	Forma demona: szybkość, 200 HP, powolna utrata HP. Demonic Jaunt działa. Woda święcona ma ranić, kaplica pali (sygnał life)."
	sin = "gluttony"

/datum/test_chamber_kit/pr_329/greed
	name = "PR 329: demon chciwości"
	description = "Robi z ciebie demona chciwości. Summon Greed Slots (cooldown 60 s) i Summon Cursed Item (Yog#19417) - przeklęte przedmioty. Forma demona i Demonic Jaunt. \
	Woda święcona ma ranić."
	sin = "greed"

/datum/test_chamber_kit/pr_329/wrath
	name = "PR 329: demon gniewu"
	description = "Robi z ciebie demona gniewu. Ignite na człowieku (z nullrodem w ręce celu - anti-magic ma blokować), Torment dotykiem, forma demona z obrażeniami 24, \
	Demonic Jaunt (wersja wrath). Woda święcona ma ranić."
	sin = "wrath"

/datum/test_chamber_kit/pr_329/envy
	name = "PR 329: demon zazdrości"
	description = "Robi z ciebie demona zazdrości. Załóż człowiekowi kapitańskie ID, użyj ręki envy: zabierasz wygląd i dostęp z ID (Yog#16649) - sprawdź na śluzie. \
	Kliknięcie ręką w obiekt nie może dawać runtime'u. Torment, forma demona, Demonic Jaunt."
	sin = "envy"

/datum/test_chamber_kit/pr_329/pride
	name = "PR 329: demon pychy"
	description = "Robi z ciebie demona pychy. Summon Mirror (cooldown 60 s), Mend dotykiem leczy (Yog#18954), forma demona, Demonic Jaunt. Woda święcona ma ranić."
	sin = "pride"
