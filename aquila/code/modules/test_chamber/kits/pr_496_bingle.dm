/datum/test_chamber_kit/pr_496
	name = "PR 496: bingle"
	pr = "aq33/AquilaStation#496"
	description = "Bingle Lord i bingiel do przejęcia przez duchy. Lord stawia Dół akcją na wolnym obszarze 3x3. Wrzucaj przedmioty na Dół: kredka to 1 punkt, \
		stos tyle, ile ma sztuk (cztery stosy po 50 dają 200 punktów). Przed 100 punktami Dół odrzuca ludzi, potem połyka ich (10 punktów) do osobnego wymiaru. \
		Co 50 punktów ankieta duchów na bingla, co 100 Dół rośnie (od 4x4 zjada ściany i struktury i ogłasza alarm). Pancerz bingli: VV na Dole, item_value_consumed = 500. \
		Bingle leczą się przy Dole, ciosy zabierają staminę i mieszają, po śmierci bingiel wybucha dymem. Zniszcz Dół (500 HP): zawartość wraca, bingle giną."
	items = list(
		/mob/living/simple_animal/hostile/bingle/lord/test_chamber = 1,
		/mob/living/simple_animal/hostile/bingle/test_chamber = 1,
		/mob/living/carbon/human = 2,
		/obj/item/toy/crayon/red = 5,
		/obj/item/fireaxe = 1,
	)

/datum/test_chamber_kit/pr_496/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]
	for(var/i in 1 to 4)
		new /obj/item/stack/sheet/iron/fifty(drop) // tu, bo test komory liczy podtypy z items

/// Bingle z komory: do przejęcia przez duchy, antagonista dochodzi sam przy pierwszym umyśle
/mob/living/simple_animal/hostile/bingle/lord/test_chamber/Initialize(mapload, obj/structure/bingle_hole/origin_pit)
	. = ..()
	set_playable(ROLE_BINGLE)

/mob/living/simple_animal/hostile/bingle/test_chamber/Initialize(mapload, obj/structure/bingle_hole/origin_pit)
	. = ..()
	set_playable(ROLE_BINGLE)
