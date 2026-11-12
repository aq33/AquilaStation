/datum/test_chamber_kit/pr_450
	name = "Specjalne szlamy"
	pr = "aq33/AquilaStation#450"
	description = "Są cztery szlamy (zielony na trawie z małpą, różowy, czerwony, złoty) i gotowe ekstrakty z butelkami odczynników (earthsblood, krew, czarny proch; plazma i woda w osobnych butelkach). Wstrzykuj strzykawką do ekstraktu. \
		1) Zielony szlam na trawie zjada małpę (stoi obok, na kafelku trawy) → oczekiwane: komunikat o ciemnieniu błony; po podziale (VV: is_adult=1, amount_grown=10, potem wywołaj proc Reproduce) młode są ciemnozielone. \
		2) Różowemu szlamowi daj rdzeń regeneracyjny (uderz nim w szlam) → oczekiwane: szarzeje, po podziale młode są ciemnoszare. \
		3) Czerwonemu zadaj ponad 160 obrażeń od ognia w jednym ticku (VV: wywołaj proc adjustFireLoss z 200) → oczekiwane: komunikat o karmazynie, młode po podziale karmazynowe; pojedynczy strzał z lasera ze stojaka nie wystarcza. \
		4) Złotemu szlamowi wywołaj proc update_gravity z wartością 2 (silniejsza niż standardowa grawitacja) → oczekiwane: komunikat o kobalcie, młode po podziale kobaltowe. \
		5) Ekstrakty: ciemnozielony + earthsblood → losowe nasiono, + woda → Żywy nawóz; kobaltowy + plazma → sorium, + krew → liquid dark matter; ciemnoszary + krew → po 5 s legion, + plazma → steryd z Lavalandu (użyj go na goliacie z zestawu → oczekiwane: staje się starożytnym goliatem); karmazynowy + czarny proch (5 j.) → losowy nabój do strzelby, + plazma → pyroxadone. \
		6) Negatyw: uderz szlam specjalnym ekstraktem → oczekiwane: „Rdzeń szlamu nie reaguje”, ekstrakt nie znika, szlam nie zjada 10 sztuk."
	items = list(
		/obj/item/slime_extract/darkgreen = 2,
		/obj/item/slime_extract/cobalt = 2,
		/obj/item/slime_extract/darkgrey = 2,
		/obj/item/slime_extract/crimson = 2,
		/obj/item/reagent_containers/syringe = 4,
		/obj/item/reagent_containers/glass/bottle/plasma = 2,
		/obj/item/reagent_containers/glass/bottle/water = 1,
		/obj/item/organ/regenerative_core = 1,
		/obj/item/food/monkeycube = 3,
		/obj/item/stack/tile/grass = 1,
		/mob/living/basic/mining/goliath = 1
	)

/datum/test_chamber_kit/pr_450/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/stack/tile/grass/G in spawned)
		G.add(4) // stos 5 płytek; osobne sztuki na jednym turfie same by się połączyły
	var/index = length(items) + 1
	for(var/colour in list("green", "pink", "red", "gold"))
		var/turf/T = turfs[min(index++, length(turfs))]
		if(colour == "green")
			// Zielony szlam i małpa do zjedzenia stoją na trawie, bo dark green wymaga trawy pod ofiarą
			T = T.PlaceOnTop(/turf/open/floor/grass)
			spawned += new /mob/living/carbon/monkey(T)
		spawned += new /mob/living/simple_animal/slime(T, colour, TRUE)
	var/turf/T = turfs[min(index++, length(turfs))]
	for(var/reagent in list(/datum/reagent/medicine/earthsblood, /datum/reagent/blood, /datum/reagent/blackpowder))
		var/obj/item/reagent_containers/glass/bottle/B = new(T)
		B.reagents.add_reagent(reagent, 30)
		B.name = "[initial(B.name)] ([B.reagents.get_master_reagent_name()])"
		spawned += B
