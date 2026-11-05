/datum/test_chamber_kit/pr_562
	name = "PR 562: ruch po pikselach"
	pr = "aq33/AquilaStation#562"
	description = "Zestaw włącza ruch po pikselach na Twojej postaci (wyłączysz go verbem Debug → „Przełącz ruch po pikselach”). \
		1) Chodź i biegaj w różne strony → postać rusza z krótkim rozpędem, po puszczeniu klawisza robi kilka pikseli wybiegu, kamera jedzie płynnie także przy zmianie kafelka. \
		2) Idź po skosie wzdłuż ściany → postać sunie wzdłuż niej i staje kilka pikseli przed ścianą, nie wchodzi w nią. \
		3) Stań przy ścianie przesunięty w bok i idź prosto w wąskie przejście lub drzwi → postać zsuwa się z narożnika i wchodzi, nie zaczepia o framugę. \
		4) Podejdź do drzwi komory → drzwi się otwierają jak przy zwykłym chodzie, przechodzisz. \
		5) Ustaw okno kierunkowe (śrubokręt/konstrukcja) i podejdź do niego z obu stron → od strony szyby postać staje, z boku przechodzi. \
		6) Wejdź w człowieka z zestawu → zamieniacie się miejscami jak zwykle. \
		7) Powiedz coś → dymek czatu jest nad głową, wyśrodkowany. \
		8) Weź skrzynię w ciągnięcie i przejdź kilka kafelków, także po skosie → skrzynia jedzie za Tobą. \
		9) Daj się pociągnąć człowiekowi po skosie (albo stań na taśmociągu) → przesuwasz się płynnie o cały kafelek, nie o kilka pikseli i bez skoku. \
		10) Usiądź na krześle stojąc z boku kafelka, potem wejdź do szafki i wyjdź → na krześle siedzisz na środku, po szafce stoisz na środku kafelka. \
		11) Sprint (Shift) po skosie przez kilka kafelków → chmurka kurzu tylko na starcie, kondycja spada jak przy zwykłym sprincie po skosie. \
		12) Krok negatywny: wyłącz verbem → postać wraca na środek kafelka i chodzi zwykłym ruchem."
	items = list(
		/obj/structure/closet/crate = 1,
		/obj/structure/chair = 1,
		/obj/structure/window = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_562/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(isliving(user) && !user.GetComponent(/datum/component/pixel_movement))
		user.AddComponent(/datum/component/pixel_movement)
		to_chat(user, span_notice("Ruch po pikselach włączony na Twojej postaci."))
