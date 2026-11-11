// aq33/AquilaStation#399 - przebranie za kwiatek: animacja chodu i znikanie po zabiciu myszy

/datum/test_chamber_kit/pr_399
	name = "PR 399: przebranie za kwiatek"
	pr = "aq33/AquilaStation#399"
	description = "1) Weź kwiatek w doniczce do rąk i pochodź → oczekiwane: postać wygląda jak sam kwiatek także w ruchu (bez ruszających się kończyn i przedmiotów z dłoni). \
	2) Weź klucz do drugiej ręki → oczekiwane: klucza nie widać na postaci, dalej widać tylko kwiatek. \
	3) Włącz tryb walki (F) i bij mysz do śmierci → oczekiwane: po zabiciu myszy przebranie zostaje, dalej widać tylko kwiatek (wcześniej znikało). \
	4) Negatyw: odłóż kwiatek na podłogę → oczekiwane: przebranie znika, postać wygląda normalnie i animacja chodu (kończyny) wraca."
	items = list(
		/obj/item/kirbyplants = 1,
		/mob/living/basic/mouse = 3,
		/obj/item/wrench = 1,
	)
