// aq33/AquilaStation#517 - wypróżnienie na miejscu po kliknięciu w alert, nagrody w aquilosach

/datum/test_chamber_kit/pr_517
	name = "PR 517: wypróżnienie na miejscu"
	pr = "aq33/AquilaStation#517"
	description = "Działa tylko z SHITTING_ENABLED w configu (jeśli wyłączone, zestaw o tym napisze). Zestaw ustawia pilną potrzebę tobie (jeśli jesteś człowiekiem) i człowiekowi „test wypróżnienia” obok (przejmij go, gdy jesteś duchem lub adminem). Obok leżą mydło, sedes i zlew. Alert z sedesem pojawia się w prawym górnym rogu po chwili. \
	1) Kliknij alert w ubraniu (mundur zakrywa krocze) → oczekiwane: komunikat „Załatwiasz się w ubraniu... będzie śmierdzieć”, po 3 s „popuścił/a w spodnie”, pod tobą kupa, higiena na „okropny smród” (examine opisuje smród). \
	2) Umyj się: mydło w ręce albo zlew → oczekiwane: smród znika z examine. \
	3) Zdejmij kombinezon, ustaw sobie VV defecation = 150 i kliknij alert nago → oczekiwane: „Kucasz w miejscu...”, po 3 s „załatwia się na podłogę”, kupa na podłodze, bez smrodu (higiena bez zmian). Osoby w pobliżu dostają odrazę. \
	4) Stań na kafelku z sedesem, defecation = 150 i kliknij alert → oczekiwane: po 3 s skorzystanie z ubikacji jak z verbu sedesu, bez kupy na podłodze. \
	5) Negatywy: ustaw defecation = 0 i kliknij alert (albo użyj go zaraz po wypróżnieniu) → „Nie potrzebujesz skorzystać z ubikacji.”; ogłusz się (stun) i kliknij → „Nie jesteś teraz w stanie.”; ruszenie się w trakcie 3 s przerywa czynność bez efektu; z wyłączonym SHITTING_ENABLED komunikat o wyłączeniu w configu."
	items = list(
		/obj/item/soap = 1,
		/obj/structure/toilet = 1,
		/obj/structure/sink = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_517/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!CONFIG_GET(flag/shitting_enabled) && user)
		to_chat(user, span_warning("SHITTING_ENABLED jest wyłączone w configu: kliknięcie alertu pokaże tylko komunikat o wyłączeniu."))
	for(var/mob/living/carbon/human/dummy in spawned)
		dummy.name = "test wypróżnienia"
		dummy.real_name = dummy.name
		dummy.set_defecation(DEFECATION_SHIT_YOURSELF)
	var/mob/living/carbon/human/H = user
	if(istype(H))
		H.set_defecation(DEFECATION_SHIT_YOURSELF)
	else if(user)
		to_chat(user, span_notice("Nie jesteś człowiekiem, więc potrzebę ma tylko „test wypróżnienia”: przejmij go (admin: Possess)."))
