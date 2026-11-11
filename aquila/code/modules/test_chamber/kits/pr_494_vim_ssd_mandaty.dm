/datum/test_chamber_kit/pr_494
	name = "PR 494: VIM, wskaźnik SSD, Citationinator"
	pr = "aq33/AquilaStation#494"
	description = "Zestaw: gotowy VIM z butlą, corgi i kot, części do złożenia drugiego VIM-a, dwa Citationinatory, emag, HUD ochrony, zapasowa karta kapitana (dostęp ochrony), czysta karta Majtka (bez dostępu) i człowiek „Testowy Obywatel” wpisany do manifestu z ustawionym znacznikiem SSD. \
	1) VIM: przejmij corgi albo kota (admin: Possess na moba; gracz-duch: Nawiedź) i przeciągnij się na gotowego Vima (wymaga gracza w roli zwierzaka) → oczekiwane: wsiadasz, VIM jedzie szybko, serwa słychać, „nominal” przy pełnym HP. Akcje: Dzyń! i Bzzz. (odnawianie), reflektory dają stożek światła, wyjście wyrzuca cię na zewnątrz. \
	2) Złóż drugiego z części: hełm EVA na ziemi, potem noga robota, druga noga, latarka, śrubokręt, moduł głosowy, śrubokręt, butla → oczekiwane: po ostatnim kroku powstaje VIM. Uszkodź go i napraw spawarką poza combat mode → oczekiwane: +20 HP co ok. 2,5 s. Negatyw: spawarka w combat mode go bije zamiast naprawiać; zniszczony VIM nie wybucha, zostają olej i iskry, butla wypada. \
	3) SSD: „Testowy Obywatel” ma nad głową znacznik, a examine mówi „Jest nieobecny od 3 min.” → oczekiwane: znacznik i minuty widać. Prawdziwy test (rozłączenie się postacią, znacznik znika po powrocie, wyjściu duchem i śmierci) wymaga drugiego klienta; bez niego sprawdź tylko śmierć: zabij Obywatela → znacznik znika. \
	4) Citationinator z kartą kapitana w ręce (albo na sobie), użyj go w ręce → Z manifestu załogi → wybierz „Testowy Obywatel (Majtek)”, kwota 50, powód „test” → oczekiwane: wypada różowy kwit z tabelką (ukarany, kwota, wystawił), a mandat trafia do akt (HUD ochrony na oczach Obywatela albo konsola akt). Wariant Spoza manifestu: wpisz dowolne imię → kwit bez wpisu do akt. \
	5) Negatyw: weź czystą kartę Majtka (bez dostępu) i użyj Citationinatora → „brak dostępu!”; bez żadnej karty → „brak identyfikatora!”. Emag na urządzeniu → iskry, „blokada dostępu obejścia”, po tym działa bez karty."
	items = list(
		/obj/vehicle/sealed/car/vim/with_tank = 1,
		/mob/living/basic/pet/dog/corgi = 1,
		/mob/living/basic/pet/cat = 1,
		/obj/item/clothing/head/helmet/space/eva = 1,
		/obj/item/bodypart/l_leg/robot = 1,
		/obj/item/bodypart/r_leg/robot = 1,
		/obj/item/flashlight = 1,
		/obj/item/assembly/voice = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/screwdriver = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/citationinator = 2,
		/obj/item/card/emag = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/clothing/glasses/hud/security = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_494/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Czysta karta bez dostępu do kroku z odmową (typ spoza items, więc test jej nie liczy)
	new /obj/item/card/id/job/assistant(turfs[min(length(items) + 1, length(turfs))])
	for(var/mob/living/carbon/human/dummy in spawned)
		dummy.name = "Testowy Obywatel"
		dummy.real_name = dummy.name
		dummy.lastclienttime = world.time - 3 MINUTES
		dummy.set_ssd_indicator(TRUE)
		// Do manifestu trafiają tylko postacie z umysłem i stanowiskiem
		dummy.mind_initialize()
		dummy.mind.assigned_role = JOB_NAME_ASSISTANT
		GLOB.data_core.manifest_inject(dummy)
