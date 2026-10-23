// aq33/AquilaStation#399 - przebranie za kwiatek: animacja chodu i znikanie po zabiciu myszy

/datum/test_chamber_kit/pr_399
	name = "PR 399: przebranie za kwiatek"
	pr = "aq33/AquilaStation#399"
	description = "Weź kwiatek w doniczce do rąk - postać ma wyglądać jak sam kwiatek, także w ruchu (bez ruszających się kończyn i przedmiotów z dłoni). \
	Uderz mysz na harm aż zginie - przebranie ma zostać (wcześniej znikało). Odłóż kwiatek - animacja chodu ma wrócić."
	items = list(
		/obj/item/kirbyplants = 1,
		/mob/living/simple_animal/mouse = 3,
		/obj/item/wrench = 1,
	)
