/datum/test_chamber_kit/pr_562
	name = "PR 562: ruch po pikselach"
	pr = "aq33/AquilaStation#562"
	description = "Zestaw włącza ruch po pikselach na Twojej postaci (wyłączysz go verbem Debug → „Przełącz ruch po pikselach”). \
		1) Chodź i biegaj w różne strony → postać przesuwa się płynnie także wewnątrz kafelka, kamera jedzie razem z nią bez szarpania przy zmianie kafelka. \
		2) Idź po skosie wzdłuż ściany i w narożnik → postać staje kilka pikseli przed ścianą, nie wchodzi w nią. \
		3) Podejdź do drzwi komory → drzwi się otwierają jak przy zwykłym chodzie, przechodzisz. \
		4) Powiedz coś → dymek czatu jest nad głową, wyśrodkowany. \
		5) Weź skrzynię w ciągnięcie i przejdź kilka kafelków → skrzynia jedzie za Tobą. \
		6) Zatrzymaj się na sekundę i daj się pociągnąć człowiekowi po skosie (albo stań na taśmociągu) → przesuwasz się o cały kafelek, nie o kilka pikseli. \
		7) Krok negatywny: wyłącz verbem → postać wraca na środek kafelka i chodzi zwykłym ruchem."
	items = list(
		/obj/structure/closet/crate = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_562/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(isliving(user) && !user.GetComponent(/datum/component/pixel_movement))
		user.AddComponent(/datum/component/pixel_movement)
		to_chat(user, span_notice("Ruch po pikselach włączony na Twojej postaci."))
