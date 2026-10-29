/obj/item/food/soup
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/soupsalad.dmi'
	trash_type = /obj/item/reagent_containers/glass/bowl
	bite_consumption = 5
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bezsmakowa zupa" = 1)
	foodtypes = VEGETABLES
	eatverbs = list("siorbie", "popija", "wciąga", "pije")

/obj/item/food/soup/wish
	name = "zupa życzeń"
	desc = "Życzę sobie, żeby to była zupa."
	icon_state = "wishsoup"
	food_reagents = list(
		/datum/reagent/water = 10
	)
	tastes = list("życzenia" = 1)

/obj/item/food/soup/wish/Initialize(mapload)
	. = ..()
	var/wish_true = prob(25)
	if(wish_true)
		desc = "Życzenie się spełniło!"
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 9)
		reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 1)

/obj/item/food/soup/meatball
	name = "zupa z klopsikami"
	desc = "Masz jaja, młody, JAJA!"
	icon_state = "meatballsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/water = 5
	)
	tastes = list("mięso" = 1)
	foodtypes = MEAT

/obj/item/food/soup/slime
	name = "zupa ze szlamu"
	desc = "Jeśli nie masz wody, możesz użyć łez."
	icon_state = "slimesoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/slimejelly = 10,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/water = 5
	)
	tastes = list("szlam" = 1)
	foodtypes = TOXIC | SUGAR

/obj/item/food/soup/blood
	name = "zupa pomidorowa"
	desc = "Pachnie miedzią."
	icon_state = "tomatosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/blood = 10,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("żelazo" = 1)
	foodtypes = GORE //its literally blood

/obj/item/food/soup/wingfangchu
	name = "wing fang chu"
	desc = "Pikantne danie z obcego wing wanga w soi."
	icon_state = "wingfangchu"
	trash_type = /obj/item/reagent_containers/glass/bowl
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/soysauce = 10,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	tastes = list("soja" = 1)
	foodtypes = MEAT

/obj/item/food/soup/clownstears
	name = "łzy klauna"
	desc = "Niezbyt zabawne."
	icon_state = "clownstears"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/banana = 10,
		/datum/reagent/lube = 5,
		/datum/reagent/consumable/nutriment/vitamin = 16,
		/datum/reagent/consumable/clownstears = 10
	)
	tastes = list("kiepski żart" = 1)
	foodtypes = FRUIT | SUGAR

/obj/item/food/soup/vegetable
	name = "zupa jarzynowa"
	desc = "Prawdziwie wegański posiłek."
	icon_state = "vegetablesoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 8
	)
	tastes = list("warzywa" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/nettle
	name = "zupa pokrzywowa"
	desc = "Pomyśleć, że botanik mógł cię zatłuc na śmierć jedną z nich."
	icon_state = "nettlesoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/medicine/omnizine = 5
	)
	tastes = list("pokrzywy" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/mystery
	name = "zupa-zagadka"
	desc = "Zagadka brzmi: czemu jej jeszcze nie jesz?"
	icon_state = "mysterysoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5
	)
	tastes = list("chaos" = 1)

/obj/item/food/soup/mystery/Initialize(mapload)
	. = ..()
	var/extra_reagent = null
	extra_reagent = pick(
		/datum/reagent/blood,
		/datum/reagent/carbon,
		/datum/reagent/consumable/banana,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/oculine,
		/datum/reagent/medicine/omnizine,
		/datum/reagent/toxin,
		/datum/reagent/toxin/slimejelly,
		)
	reagents.add_reagent(extra_reagent, 10)
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 6)

/obj/item/food/soup/hotchili
	name = "ostre chili"
	desc = "Teksańskie chili na pięć alarmów pożarowych!"
	icon_state = "hotchili"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/capsaicin = 3,
		/datum/reagent/consumable/tomatojuice = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("ostre papryki" = 1)
	foodtypes = VEGETABLES | MEAT

/obj/item/food/soup/coldchili
	name = "zimne chili"
	desc = "Ta breja ledwo jest płynna!"
	icon_state = "coldchili"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/frostoil = 3,
		/datum/reagent/consumable/tomatojuice = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("pomidor" = 1, "mięta" = 1)
	foodtypes = VEGETABLES | MEAT

/obj/item/food/soup/monkeysdelight
	name = "małpia rozkosz"
	desc = "Pyszna zupa z kluskami i kawałkami mięsa małpy duszonymi do perfekcji w bulionie, który lekko pachnie bananami."
	icon_state = "monkeysdelight"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("dżungla" = 1, "banan" = 1)
	foodtypes = FRUIT

/obj/item/food/soup/tomato
	name = "zupa pomidorowa"
	desc = "Picie tego to jak bycie wampirem! Pomidorowym wampirem..."
	icon_state = "tomatosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	tastes = list("pomidor" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/tomato/eyeball
	name = "zupa z oczu"
	desc = "Ona też na ciebie patrzy..."
	icon_state = "eyeballsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/liquidgibs = 3
	)
	tastes = list("pomidor" = 1, "wicie się" = 1)
	foodtypes = MEAT | GORE

/obj/item/food/soup/miso
	name = "zupa miso"
	desc = "Najlepsza zupa we wszechświecie! Mniam!!!"
	icon_state = "misosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("miso" = 1)
	foodtypes = VEGETABLES | BREAKFAST

/obj/item/food/soup/mushroom
	name = "zupa kurkowa"
	desc = "Pyszna i sycąca zupa grzybowa."
	icon_state = "mushroomsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("grzyb" = 1)
	foodtypes = VEGETABLES | DAIRY

/obj/item/food/soup/beet
	name = "barszcz"
	desc = "Zaraz, jak to się właściwie pisze..?"
	icon_state = "beetsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = VEGETABLES

/obj/item/food/soup/beet/Initialize(mapload)
	. = ..()
	name = pick("barszcz", "barszczyk", "barszc", "barsz", "borszcz", "barszczz")
	tastes = list(name = 1)


/obj/item/food/soup/spacylibertyduff
	name = "kosmiczny deser wolności"
	desc = "Galaretka z książki kucharskiej Alfreda Hubbarda."
	icon_state = "spacylibertyduff"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/drug/mushroomhallucinogen = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("galaretka" = 1, "grzyb" = 1)
	foodtypes = VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/soup/amanitajelly
	name = "galaretka z muchomorów"
	desc = "Wygląda podejrzanie toksycznie."
	icon_state = "amanitajelly"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/drug/mushroomhallucinogen = 3,
		/datum/reagent/toxin/amatoxin = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("galaretka" = 1, "grzyb" = 1)
	foodtypes = VEGETABLES | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/soup/stew
	name = "gulasz"
	desc = "Przyjemny, ciepły gulasz. Zdrowy i treściwy."
	icon_state = "stew"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	bite_consumption = 7
	max_volume = 100
	tastes = list("pomidor" = 1, "marchewka" = 1)
	foodtypes = VEGETABLES | MEAT

/obj/item/food/soup/sweetpotato
	name = "zupa z batatów"
	desc = "Pyszne bataty w postaci zupy."
	icon_state = "sweetpotatosoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("batat" = 1)
	foodtypes = VEGETABLES | SUGAR

/obj/item/food/soup/beet/red
	name = "zupa z czerwonych buraków"
	desc = "Niezły przysmak."
	icon_state = "redbeetsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	tastes = list("burak" = 1)
	foodtypes = VEGETABLES

/obj/item/food/soup/bisque
	name = "biskwit"
	desc = "Klasyczne danie z Kosmo-Francji."
	icon_state = "bisque"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("kremowa konsystencja" = 1, "krab" = 4)
	foodtypes = MEAT

/obj/item/food/soup/electron
	name = "zupa elektronowa"
	desc = "Kulinarna ciekawostka pochodzenia eteryckiego. Słynie z miniaturowego układu pogodowego, który tworzy się nad dobrze przyrządzoną zupą."
	icon_state = "electronsoup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/liquidelectricity = 12
	)
	tastes = list("grzyb" = 1, "elektrony" = 4)
	foodtypes = VEGETABLES | TOXIC

/obj/item/food/soup/bungocurry
	name = "curry z bungo"
	desc = "Pikantne warzywne curry ze skromnego owocu bungo. Egzotyka!"
	icon_state = "bungocurry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/bungojuice = 9,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("bungo" = 2, "ostre curry" = 4, "tropikalna słodycz" = 1)
	foodtypes = VEGETABLES | FRUIT | DAIRY

/obj/item/food/soup/mammi
	name = "mämmi"
	desc = "Miska rozmokłego chleba z mlekiem. Przypomina ci, niezbyt miło, wizytę w toalecie."
	icon_state = "mammi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/soup/oatmeal
	name = "owsianka"
	desc = "Gęstsza niż miska owsianki."
	icon_state = "oatmeal"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/milk = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("owies" = 1, "mleko" = 1)
	foodtypes = DAIRY | GRAIN | BREAKFAST
