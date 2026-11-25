// aq33/AquilaStation#706 - Akwarianin: goły metal, wzory na ramionach, szara woda i ukleja (paczka Fish People)

/datum/test_chamber_kit/pr_706
	name = "PR 706: Akwarianin z gołego metalu"
	pr = "aq33/AquilaStation#706"
	description = "Stawia dwóch Akwarian: pierwszy w gołym metalu z niebieskimi rękawami, żółtą ukleją i różową wodą, \
	drugi w czerwonym pancerzu przemalowanym na żółto, z paskami na ramionach w tym samym kolorze, i ze złotą rybką. \
	1) Obejrzyj obu ze wszystkich stron: kończyny, dłonie i stopy gołego metalu, rękawy i paski na obu ramionach, woda w kolorze z okna postaci. \
	2) Okno postaci (rasa Akwarianin): Pancerz (Czerwony pancerz / Goły metal), Wzór na ramionach, Kolor pancerza barwi wzór. \
	Wybierz rybę Ukleja → pojawia się Kolor ryby, przy innych rybach go nie ma. \
	3) Utnij pierwszemu rękę (piła) → rękaw odpada razem z ręką, ręka na podłodze zostaje z gołego metalu. \
	4) Rozbij pierwszemu klosz (skrzynką w głowę do skutku) → ukleja rzuca się na podłodze w swoim kolorze, krople wody są niebieskie; \
	po śmierci leży żółta, bez kropli."
	items = list(
		/mob/living/carbon/human/species/aquarian = 2,
		/obj/item/circular_saw = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/reagent_containers/glass/aquarian_dome = 1,
	)

/datum/test_chamber_kit/pr_706/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/list/looks = list(
		list(AQUARIAN_BODY_METAL, "sleeves", "3366ff", "bleak", "ffcc00", "ff66cc"),
		list(AQUARIAN_BODY_RED, "stripes", "e0c040", "goldfish", AQUARIAN_DEFAULT_FISH_COLOR, AQUARIAN_DEFAULT_WATER),
	)
	var/turf/first_turf
	for(var/mob/living/carbon/human/H in spawned)
		if(!isaquarian(H) || !length(looks))
			continue
		// Obie sztuki lądują na jednym polu: drugi staje obok, żeby porównać warianty
		if(!first_turf)
			first_turf = get_turf(H)
		else if(get_turf(H) == first_turf)
			for(var/turf/free in turfs)
				if(free != first_turf && !(locate(/mob/living) in free))
					H.forceMove(free)
					break
		var/list/look = looks[1]
		looks.Cut(1, 2)
		H.dna.features[FEATURE_AQUARIAN_BODY] = look[1]
		H.dna.features[FEATURE_AQUARIAN_PATTERN] = look[2]
		H.dna.features[FEATURE_AQUARIAN_ARMOR] = look[3]
		H.dna.features[FEATURE_AQUARIAN_FISH] = look[4]
		H.dna.features[FEATURE_AQUARIAN_FISH_COLOR] = look[5]
		H.dna.features[FEATURE_AQUARIAN_WATER] = look[6]
		// Nowy klosz bierze rybę i kolory z wyglądu postaci
		H.set_species(/datum/species/human)
		H.set_species(/datum/species/aquarian)
