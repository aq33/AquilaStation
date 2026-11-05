// aq33/AquilaStation#329 - Demony Grzechu: synchronizacja z Yogstation i poprawki portu

/// Typ pośredni (bez nazwy) - podtypy robią z testera demona danego grzechu
/datum/test_chamber_kit/pr_329
	pr = "aq33/AquilaStation#329"
	items = list(
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 1,
		/obj/item/nullrod = 1,
		/obj/item/card/id/captains_spare = 1,
		/mob/living/carbon/human = 2,
		/obj/item/food/burger/plain = 3,
	)
	/// Grzech nadawany testerowi (wartości jak SIN_* z demons.dm)
	var/sin

/datum/test_chamber_kit/pr_329/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Pierwszy człowiek z areny jest ranny (cel dla Mend/Uleczenie), drugi zdrowy (cel dla pozostałych mocy i ściany)
	var/mob/living/carbon/human/victim = locate() in spawned
	if(victim)
		victim.adjustBruteLoss(30)
		victim.adjustFireLoss(15)
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
	description = "Robi z ciebie demona obżarstwa. Na arenie są dwaj ludzie (jeden ranny) i burgery. \
	1) Zjedz kilka burgerów pod rząd → oczekiwane: TRAIT_EAT_MORE i bezdenny żołądek, jesz bez limitu. \
	2) Postaw Ścianę obżarstwa i przejdź przez nią → oczekiwane: ciebie nie blokuje. \
	3) Przeciągnij drugiego człowieka przez ścianę → oczekiwane: jego blokuje. \
	4) Użyj ściany ponownie od razu → oczekiwane: odmowa (cooldown ok. 15 s). \
	5) Forma demona → oczekiwane: szybkość, 200 HP, powolna utrata HP; Demonic Jaunt działa. \
	6) Negatyw: oblej się wodą świeconą → oczekiwane: boli. Kaplica (sygnał life) nie istnieje w komorze - sprawdzać tylko na statku."
	sin = "gluttony"

/datum/test_chamber_kit/pr_329/greed
	name = "PR 329: demon chciwości"
	description = "Robi z ciebie demona chciwości. \
	1) Summon Greed Slots → oczekiwane: pojawia się automat. \
	2) Użyj go ponownie przed upływem 60 s → oczekiwane: odmowa (cooldown). \
	3) Summon Cursed Item (Yog#19417) → oczekiwane: losowy przeklęty przedmiot; kolejne wywołanie odmawia (cooldown 180 s). \
	4) Forma demona i Demonic Jaunt → oczekiwane: działają. \
	5) Negatyw: woda święcona ma ranić."
	sin = "greed"

/datum/test_chamber_kit/pr_329/wrath
	name = "PR 329: demon gniewu"
	description = "Robi z ciebie demona gniewu. Jeden z dwóch ludzi dostaje nullroda (podnieś go z areny). \
	1) Ignite na człowieku bez nullroda → oczekiwane: płonie. \
	2) Ignite na człowieku z nullrodem w ręce → oczekiwane: anti-magic blokuje, nie płonie. \
	3) Ignite ponownie od razu → oczekiwane: odmowa (cooldown 60 s). \
	4) Torment dotykiem → oczekiwane: ból celu. \
	5) Forma demona → oczekiwane: obrażenia 24; Demonic Jaunt (wersja wrath) działa. \
	6) Negatyw: woda święcona ma ranić."
	sin = "wrath"

/datum/test_chamber_kit/pr_329/envy
	name = "PR 329: demon zazdrości"
	description = "Robi z ciebie demona zazdrości. \
	1) Załóż jednemu człowiekowi kapitańskie ID, użyj ręki envy → oczekiwane: zabierasz wygląd i dostęp z ID (Yog#16649); sprawdź dostęp na śluzie. \
	2) Kliknij ręką envy w zwykły obiekt (np. burger, ścianę) → oczekiwane: brak runtime'u i brak efektu. \
	3) Użyj ręki ponownie od razu → oczekiwane: odmowa (cooldown). \
	4) Torment, forma demona, Demonic Jaunt → oczekiwane: działają."
	sin = "envy"

/datum/test_chamber_kit/pr_329/pride
	name = "PR 329: demon pychy"
	description = "Robi z ciebie demona pychy. Pierwszy człowiek na arenie jest ranny (30 brute, 15 burn), drugi zdrowy. \
	1) Mend dotykiem na rannym → oczekiwane: leczy (Yog#18954). \
	2) Mend na zdrowym drugim → oczekiwane: nic do leczenia, brak błędu. \
	3) Mend ponownie od razu → oczekiwane: odmowa (cooldown 12 s). \
	4) Summon Mirror, potem natychmiast ponownie → oczekiwane: za drugim razem odmowa (cooldown 60 s). \
	5) Forma demona, Demonic Jaunt → oczekiwane: działają; woda święcona ma ranić."
	sin = "pride"
