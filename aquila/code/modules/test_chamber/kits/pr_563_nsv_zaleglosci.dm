/datum/test_chamber_kit/pr_563
	name = "PR 563: zaległości z NSV13 (abordaże, pigułki)"
	pr = "aq33/AquilaStation#563"
	description = "1) Moby Syndykatu z abordaży: włącz combat mode i podejdź → oczekiwane: majtek bije wręcz, wersje z bronią strzelają, wyważacz w skafandrze tnie mieczem; po śmierci znikają z gibami, bez runtime'ów. \
	2) Protolathe medyczny: włóż szkło i żelazo, otwórz kategorię Medical → oczekiwane: Pojemnik na pigułki do wydruku od razu, bez badań; wydruk daje pusty pojemnik. \
	3) Płytka działowego techfabu leży obok: poza Shrike nic się nie dzieje; na Shrike (zmiana mapy przez admina) płytki techfabu działowego w szafkach znikają, ale zbudowany wcześniej techfab działowy dalej się rozkręca i oddaje płytkę. \
	Poza komorą: admin zmienia mapę na Shrike i Von Neumann (obie poza losową rotacją) → zasilanie, kanalizacja, prom zaopatrzeniowy, spawn detektywa na Shrike, policyjne dywany w brygu VN; misja abordażu okrętu Syndykatu ma nowe moby."
	items = list(
		/mob/living/simple_animal/hostile/nsv/syndicate = 1,
		/mob/living/simple_animal/hostile/nsv/syndicate/ranged/smg = 1,
		/mob/living/simple_animal/hostile/nsv/syndicate/space/sword = 1,
		/obj/machinery/rnd/production/protolathe/department/medical = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/circuitboard/machine/techfab/department/service = 1,
	)
