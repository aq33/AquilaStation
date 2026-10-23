// aq33/AquilaStation#342 - łzy po *cry i płacz przy krojeniu cebuli

/datum/test_chamber_kit/pr_342
	name = "PR 342: łzy - *cry i cebula"
	pr = "aq33/AquilaStation#342"
	description = "Wpisz *cry - na twarzy mają się pojawić animowane łzy na ok. 13 s, kolejny *cry przedłuża czas. \
	Pokrój cebulę nożem bez osłony oczu - postać sama płacze i ma łzy. Załóż gogle spawalnicze (opuszczone) i pokrój kolejną - bez płaczu. \
	Łzy powinny być też widać na człowieku testowym, jeśli go opętasz i użyjesz *cry."
	items = list(
		/obj/item/food/grown/onion = 3,
		/obj/item/food/grown/onion/red = 2,
		/obj/item/kitchen/knife = 1,
		/obj/item/clothing/glasses/welding = 1,
		/obj/structure/table = 1,
		/mob/living/carbon/human = 1,
	)
