// Meatball Soup
/datum/reagent/consumable/nutriment/soup/meatball_soup
	bowl_icon_state = "meatballsoup"
	name = "Zupa z klopsikami"
	description = "Masz jaja, młody, JAJA!"
	data = list("mięso" = 1)
	color = "#FFFDCF"

/obj/item/reagent_containers/glass/bowl/soup/meatball_soup
	initial_reagent = /datum/reagent/consumable/nutriment/soup/meatball_soup

/datum/chemical_reaction/food/soup/meatballsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/potato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/meatball_soup = 30,
		/datum/reagent/water = 9,
	)

// Vegetable Soup
/datum/reagent/consumable/nutriment/soup/vegetable_soup
	bowl_icon_state = "vegetablesoup"
	name = "Zupa jarzynowa"
	description = "Prawdziwie wegański posiłek."
	data = list("warzywa" = 1)
	color = "#FAA810"

/datum/chemical_reaction/food/soup/vegetable_soup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/potato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/vegetable_soup = 30,
		/datum/reagent/water = 9,
	)

// Nettle soup - gains some omnizine to offset the acid damage
/datum/reagent/consumable/nutriment/soup/nettle
	bowl_icon_state = "nettlesoup"
	name = "Zupa pokrzywowa"
	description = "Pomyśleć, że botanik mógł cię zatłuc na śmierć jedną z nich."
	data = list("pokrzywy" = 1)
	color = "#C1E212"

/obj/item/reagent_containers/glass/bowl/soup/nettle
	initial_reagent = /datum/reagent/consumable/nutriment/soup/nettle

/datum/chemical_reaction/food/soup/nettlesoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/nettle = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/boiledegg = 1
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/nettle = 30,
		/datum/reagent/water = 9,
		/datum/reagent/medicine/omnizine = 6,
	)
	ingredient_reagent_multiplier = 0.2 // Too much acid
	percentage_of_nutriment_converted = 0

// Wing Fang Chu
/datum/reagent/consumable/nutriment/soup/wingfangchu
	bowl_icon_state = "wingfangchu"
	name = "Wing fang chu"
	description = "Pikantne danie z obcego wing wanga w soi."
	data = list("soja" = 1)
	color = "#C1E212"

/datum/chemical_reaction/food/soup/wingfangchu
	required_reagents = list(
		/datum/reagent/water = 50,
		/datum/reagent/consumable/soysauce = 5,
	)
	required_ingredients = list(
		/obj/item/food/meat/cutlet/xeno = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/wingfangchu = 30,
		/datum/reagent/consumable/soysauce = 10,
	)

// Chili (Hot, not cold)
/datum/reagent/consumable/nutriment/soup/hotchili
	bowl_icon_state = "hotchili"
	name = "Ostre chili"
	description = "Teksańskie chili na pięć alarmów pożarowych!"
	data = list("ostre papryki" = 1)
	color = "#E23D12"

/obj/item/reagent_containers/glass/bowl/soup/hotchili
	initial_reagent = /datum/reagent/consumable/nutriment/soup/hotchili

/datum/chemical_reaction/food/soup/hotchili
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/hotchili = 30,
		/datum/reagent/consumable/tomatojuice = 10,
		// Capsaicin comes from the chillis, meaning you can make tame chili.
		/*
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4
		*/
	)
	ingredient_reagent_multiplier = 0.33 // Chilis have a TON of capsaicin naturally
	percentage_of_nutriment_converted = 0

// Chili (Cold)
/datum/reagent/consumable/nutriment/soup/coldchili
	bowl_icon_state = "coldchili"
	name = "Zimne chili"
	description = "Ta breja ledwo jest płynna!"
	data = list("pomidor" = 1, "mięta" = 1)
	color = "#3861C2"

/datum/chemical_reaction/food/soup/coldchili
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/icepepper = 1,
		/obj/item/food/grown/tomato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/coldchili = 30,
		/datum/reagent/consumable/tomatojuice = 10,
		// Frost Oil comes from the chilis
	)
	ingredient_reagent_multiplier = 0.33 // Chilis have a TON of frost oil naturally
	percentage_of_nutriment_converted = 0

// Chili (Clownish)
/datum/reagent/consumable/nutriment/soup/clownchili
	bowl_icon_state = "clownchili"
	name = "Chili con carnival"
	description = "Pyszny gulasz z mięsa, papryczek chili i słonych, bardzo słonych łez klauna."
	data = list(
		"pomidor" = 1,
		"ostre papryki" = 2,
		"stopy klauna" = 2,
		"coś śmiesznego" = 2,
		"czyichś rodziców" = 2,
	)
	color = "#FF0000"

/datum/chemical_reaction/food/soup/clownchili
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/clothing/shoes/clown_shoes = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/clownchili = 30,
		/datum/reagent/consumable/tomatojuice = 8,
		/datum/reagent/consumable/laughter = 4,
		/datum/reagent/consumable/banana = 4,
	)
	percentage_of_nutriment_converted = 0.15

// Vegan Chili
/datum/reagent/consumable/nutriment/soup/chili_sin_carne
	bowl_icon_state = "hotchili"
	name = "Chili sin carne"
	description = "Dla hombres, którzy nie chcą carne."
	data = list("gorycz" = 1, "kwaśność" = 1)
	color = "#E23D12"

/datum/chemical_reaction/food/soup/chili_sin_carne
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/sodiumchloride = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/chili_sin_carne = 30,
		/datum/reagent/consumable/tomatojuice = 10,
	)

// Tomato soup
/datum/reagent/consumable/nutriment/soup/tomato
	bowl_icon_state = "tomatosoup"
	name = "Zupa pomidorowa"
	description = "Picie tego to jak bycie wampirem! Pomidorowym wampirem..."
	data = list("pomidor" = 1)
	color = "#FF0000"

/datum/chemical_reaction/food/soup/tomatosoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/tomato = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/tomato = 30,
		/datum/reagent/consumable/tomatojuice = 20,
		/*
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/tomatojuice = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3
		*/
	)
	percentage_of_nutriment_converted = 0.1

// Tomato-eyeball soup
/datum/reagent/consumable/nutriment/soup/eyeball
	bowl_icon_state = "eyeballsoup"
	name = "Zupa z oczu"
	description = "Ona też na ciebie patrzy..."
	data = list("pomidor" = 1, "wicie się" = 1)
	color = "#FF1C1C"

/datum/chemical_reaction/food/soup/eyeballsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/tomato = 2,
		/obj/item/organ/eyes = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/eyeball = 20,
		// Logically this would be more but we wouldn't get the eyeball icon state if it was.
		/datum/reagent/consumable/nutriment/soup/tomato = 10,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/liquidgibs = 6,
	)
	percentage_of_nutriment_converted = 0.1

// Miso soup
/datum/reagent/consumable/nutriment/soup/miso
	bowl_icon_state = "misosoup"
	name = "Zupa miso"
	description = "Najlepsza zupa we wszechświecie! Mniam!!!"
	data = list("miso" = 1)
	color = "#E2BD12"

/datum/chemical_reaction/food/soup/misosoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/soydope = 2,
		/obj/item/food/tofu = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/miso = 30,
		/datum/reagent/water = 10,
	)
	percentage_of_nutriment_converted = 0 // Soy has very low nutrients.

// Blood soup
// Fake tomato soup.
// Can also appear by pouring blood into a bowl!
/datum/chemical_reaction/food/soup/bloodsoup
	required_reagents = list(
		/datum/reagent/water = 10,
		/datum/reagent/blood = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/tomato/blood = 2,
	)
	results = list(
		// Blood tomatos will give us like 30u blood, so just add in the 10 from the recipe
		/datum/reagent/blood = 10,
		/datum/reagent/water = 8,
		/datum/reagent/consumable/nutriment/protein = 7,
	)
	percentage_of_nutriment_converted = 0.1

// Slime soup
// Made with a slime extract, toxic to non-slime-people.
// Can also be created by mixing water and slime jelly.
/datum/reagent/consumable/nutriment/soup/slime
	bowl_icon_state = "slimesoup"
	name = "Zupa ze szlamu"
	description = "Jeśli nie masz wody, możesz użyć łez."
	data = list("szlam" = 1)
	color = "#41C0C0"

/datum/chemical_reaction/food/soup/slimesoup
	required_reagents = list(
		/datum/reagent/water = 40,
	)
	required_ingredients = list(
		/obj/item/slime_extract = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/slime = 30,
		/datum/reagent/toxin/slimejelly = 20,
		// Comes out of thin air, as none of our ingredients contain nutrients naturally.
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/water = 6,
	)

/datum/chemical_reaction/food/soup/slimesoup/alt
	// Alt recipe that allows you to create a slime soup by just mixing slime jelly and water.
	// Pretty much just a normal chemical reaction.
	// This also creates nutrients out of thin air.

	required_other = FALSE
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/toxin/slimejelly = 20,
	)
	required_ingredients = null

// Clown Tear soup
/datum/reagent/consumable/nutriment/soup/clown_tears
	bowl_icon_state = "clownstears"
	name = "Zupa z łez klauna"
	description = "Smutek i melancholia tysiąca osieroconych klaunów, którym na zawsze odmówiono ich Honkmechów."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	ph = 9.2
	data = list("kiepski żart" = 1, "żałobne trąbienie" = 1)
	color = "#EEF442"

/datum/chemical_reaction/food/soup/clownstears
	required_reagents = list(
		/datum/reagent/lube = 30,
	)
	required_ingredients = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/stack/sheet/mineral/bananium = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/clown_tears = 30,
		/datum/reagent/consumable/banana = 8,
		/datum/reagent/consumable/nutriment/vitamin = 12,
		/datum/reagent/lube = 5,
	)
	percentage_of_nutriment_converted = 0 // Bananas have a small amount of nutrition naturally

// Mystery soup
// Acts a little funny, because when it's mixed it gains a new random reagent as well
/datum/reagent/consumable/nutriment/soup/mystery
	bowl_icon_state = "mysterysoup"
	name = "Zupa-zagadka"
	description = "Zagadka brzmi: czemu jej jeszcze nie jesz?"
	data = list("chaos" = 1)
	color = "#4C2A18"

/datum/chemical_reaction/food/soup/mysterysoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/badrecipe = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/mystery = 30,
	)
	percentage_of_nutriment_converted = 0.33 // Full of garbage

	/// A list of reagent types we can randomly gain in the soup on creation
	var/list/extra_reagent_types = list(
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

/datum/chemical_reaction/food/soup/mysterysoup/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	. = ..()
	holder.add_reagent(pick(extra_reagent_types), 10)

// Monkey Soup
/datum/reagent/consumable/nutriment/soup/monkey
	bowl_icon_state = "monkeysdelight"
	name = "Małpia rozkosz"
	description = "Pyszna zupa z kluskami i kawałkami mięsa małpy duszonymi do perfekcji w bulionie, który lekko pachnie bananami."
	data = list("dżungla" = 1, "banan" = 1)
	color = "#4C2A18"

/obj/item/reagent_containers/glass/bowl/soup/monkey
	initial_reagent = /datum/reagent/consumable/nutriment/soup/monkey

/datum/chemical_reaction/food/soup/monkey
	required_reagents = list(
		/datum/reagent/water = 25,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/sodiumchloride = 5,
		/datum/reagent/consumable/blackpepper = 5,
	)
	required_ingredients = list(
		/obj/item/food/monkeycube = 1, // This will make a monkey if a batch of 2 is made
		/obj/item/food/grown/banana = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/monkey = 30,
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/sodiumchloride = 4,
		/datum/reagent/consumable/blackpepper = 4,
	)

// Cream of mushroom soup
/datum/reagent/consumable/nutriment/soup/mushroom
	bowl_icon_state = "mushroomsoup"
	name = "Zupa kurkowa"
	description = "Pyszna i sycąca zupa grzybowa."
	data = list("grzyb" = 1)
	color = "#CEB1B0"

/datum/chemical_reaction/food/soup/mushroomsoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/milk = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/chanterelle = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/mushroom = 30,
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/milk = 2,
	)

// Beet soup (Borscht)
// This has a gimmick where it randomizes its name based on common mispellings on Borsch
/datum/reagent/consumable/nutriment/soup/white_beet
	bowl_icon_state = "beetsoup"
	name = "Zupa buraczana"
	description = "Zaraz, jak to się właściwie pisze..?"
	data = list("burak" = 1)
	color = "#E00000"

/obj/item/reagent_containers/glass/bowl/soup/white_beet
	initial_reagent = /datum/reagent/consumable/nutriment/soup/white_beet

/datum/chemical_reaction/food/soup/beetsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/whitebeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/white_beet = 30,
		/datum/reagent/water = 10,
	)
	percentage_of_nutriment_converted = 0.1

// Stew
/datum/reagent/consumable/nutriment/soup/stew
	bowl_icon_state = "stew"
	name = "Gulasz"
	description = "Przyjemny, ciepły gulasz. Zdrowy i treściwy."
	data = list("pomidor" = 1, "marchewka" = 1)
	color = "#EB7C82"

/obj/item/reagent_containers/glass/bowl/soup/stew
	initial_reagent = /datum/reagent/consumable/nutriment/soup/stew

/datum/chemical_reaction/food/soup/stew
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/cutlet = 3,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/mushroom = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/stew = 30,
		/datum/reagent/consumable/tomatojuice = 10,
		// Gains a ton of nutriments from the variety of ingredients.
	)

// Sweet potato soup
/datum/reagent/consumable/nutriment/soup/sweetpotato
	bowl_icon_state = "sweetpotatosoup"
	name = "Zupa z batatów"
	description = "Pyszne bataty w postaci zupy."
	data = list("batat" = 1)
	color = "#903E22"

/obj/item/reagent_containers/glass/bowl/soup/sweetpotato
	initial_reagent = /datum/reagent/consumable/nutriment/soup/sweetpotato

/datum/chemical_reaction/food/soup/sweetpotatosoup
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/milk = 10, // Coconut milk, but, close enough
	)
	required_ingredients = list(
		/obj/item/food/grown/potato/sweet = 2,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/sweetpotato = 30,
		/datum/reagent/water = 10,
	)

// Red beet soup
/datum/reagent/consumable/nutriment/soup/red_beet
	bowl_icon_state = "redbeetsoup"
	name = "Barszcz czerwony"
	description = "Niezły przysmak."
	data = list("burak" = 1)
	color = "#851127"

/datum/chemical_reaction/food/soup/redbeetsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/red_beet = 30,
		/datum/reagent/water = 10,
	)
	percentage_of_nutriment_converted = 0.1

// French Onion soup
/datum/reagent/consumable/nutriment/soup/french_onion
	bowl_icon_state = "onionsoup"
	name = "Francuska zupa cebulowa"
	description = "Tak dobra, że dorosły mim by się popłakał."
	data = list("karmelizowana cebula" = 1)
	color = "#E1C47F"

/datum/chemical_reaction/food/soup/onionsoup
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/onion = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/french_onion = 30,
		/datum/reagent/consumable/nutriment/protein = 8, // No idea where this comes from
		/datum/reagent/consumable/tomatojuice = 8, // No idea where this comes from
	)
	ingredient_reagent_multiplier = 0.5 // Onions are very reagent heavy
	percentage_of_nutriment_converted = 0.1

// Bisque / Crab soup
/datum/reagent/consumable/nutriment/soup/bisque
	bowl_icon_state = "bisque"
	name = "Biskwit"
	description = "Klasyczne danie z Kosmo-Francji."
	data = list("kremowa konsystencja" = 1, "krab" = 4)
	color = "#C8682F"

/datum/chemical_reaction/food/soup/bisque
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/meat/crab = 1,
		/obj/item/food/boiledrice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/bisque = 30,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/water = 5,
	)

// Bungo Tree Curry
/datum/reagent/consumable/nutriment/soup/bungo
	bowl_icon_state = "bungocurry"
	name = "Curry z bungo"
	description = "Pikantne warzywne curry ze skromnego owocu bungo. Egzotyka!"
	data = list("bungo" = 2, "ostre curry" = 4, "tropikalna słodycz" = 1)
	color = "#E6BC32"

/datum/chemical_reaction/food/soup/bungocurry
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/cream = 10,
	)
	required_ingredients = list(
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/bungofruit = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/bungo = 30,
		/datum/reagent/consumable/bungojuice = 15,
	)
	percentage_of_nutriment_converted = 0.1

// Electron Soup.
// Special soup for Ethereals to consume to gain nutrition (energy) from.
/datum/reagent/consumable/nutriment/soup/electrons
	bowl_icon_state = "electronsoup"
	name = "Zupa elektronowa"
	description = "Kulinarna ciekawostka pochodzenia eteryckiego. Słynie z miniaturowego układu pogodowego, który tworzy się nad dobrze przyrządzoną zupą."
	data = list("grzyb" = 1, "elektrony" = 4)
	color = "#E60040"

/datum/chemical_reaction/food/soup/electron
	required_reagents = list(
		/datum/reagent/water = 45,
		/datum/reagent/consumable/sodiumchloride = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/mushroom/jupitercup = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/electrons = 30,
		// Jupiter cups obviously contain a fair amount of LE naturally,
		// but to make it "worthwhile" for Ethereals to eat we add a bit extra
		/datum/reagent/consumable/liquidelectricity = 10,
	)
	percentage_of_nutriment_converted = 0.10

// Pea Soup
// Indian curry
/datum/reagent/consumable/nutriment/soup/indian_curry
	bowl_icon_state = "indian_curry"
	name = "Indyjskie curry z kurczakiem"
	description = "Łagodne, kremowe curry ze starego subkontynentu. Kosmo-Brytyjczycy je lubią, bo przypomina im Radż."
	data = list("kurczak" = 2, "kremowe curry" = 4, "ziemisty żar" = 1)
	color = "#BB2D1A"

/datum/chemical_reaction/food/soup/indian_curry
	required_reagents = list(
		/datum/reagent/water = 50,
		/datum/reagent/consumable/cream = 5,
	)
	required_ingredients = list(
		/obj/item/food/meat/slab/chicken = 1,
		/obj/item/food/grown/onion = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/butter = 1,
		/obj/item/food/boiledrice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/indian_curry = 30,
		// Gains a ton of other reagents from ingredients.
	)

// Oatmeal (Soup like)
/datum/reagent/consumable/nutriment/soup/oatmeal
	bowl_icon_state = "oatmeal"
	name = "Owsianka"
	description = "Porządna miska owsianki."
	data = list("owies" = 1, "mleko" = 1)
	color = "#FFD7B4"

/datum/chemical_reaction/food/soup/oatmeal
	required_reagents = list(
		/datum/reagent/consumable/milk = 20,
	)
	required_ingredients = list(
		/obj/item/food/grown/oat = 2,
	)
	results =  list(
		/datum/reagent/consumable/nutriment/soup/oatmeal = 20,
		/datum/reagent/consumable/milk = 12,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	percentage_of_nutriment_converted = 0 // Oats have barely any nutrients

// Zurek, a Polish soup
/datum/reagent/consumable/nutriment/soup/zurek
	bowl_icon_state = "zurek"
	name = "Żurek"
	description = "Tradycyjna polska zupa na zakwasie, z warzywami, kiełbasą i jajkiem. Najlepiej smakuje z chlebem."
	data = list("kremowe warzywa" = 2, "kiełbasa" = 1)
	color = "#F1CB6D"

/datum/chemical_reaction/food/soup/zurek
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/flour = 10,
	)
	required_ingredients = list(
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/onion = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/zurek = 30,
	)
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0.1

// Cullen Skink, a Scottish soup with a funny name
/datum/reagent/consumable/nutriment/soup/cullen_skink
	bowl_icon_state = "cullen_skink"
	name = "Cullen skink"
	description = "Gęsta szkocka zupa z wędzonej ryby, ziemniaków i cebuli."
	data = list("kremowy bulion" = 1, "ryba" = 1, "warzywa" = 1)
	color = "#F6F664"

/datum/chemical_reaction/food/soup/cullen_skink
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/milk = 10,
		/datum/reagent/consumable/blackpepper = 4,
	)
	required_ingredients = list(
		/obj/item/food/fishmeat = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/potato = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/cullen_skink = 30,
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/water = 6,
	)
	ingredient_reagent_multiplier = 0.5
	percentage_of_nutriment_converted = 0

// Chicken Noodle Soup
/datum/reagent/consumable/nutriment/soup/chicken_noodle_soup
	bowl_icon_state = "chicken_noodle_soup"
	name = "Rosół z makaronem"
	description = "Pożywna miska rosołu z kurczaka z makaronem, idealna, kiedy siedzisz chory w domu."
	data = list("bulion" = 1, "kurczak" = 1, "makaron" = 1, "marchewka" = 1)
	color = "#DDB23E"

/datum/chemical_reaction/food/soup/chicken_noodle_soup
	required_reagents = list(/datum/reagent/water = 30)
	required_ingredients = list(
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/meat/slab/chicken = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/chicken_noodle_soup = 30,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)

// Corn Cowder
/datum/reagent/consumable/nutriment/soup/corn_chowder
	bowl_icon_state = "corn_chowder"
	name = "Zupa kukurydziana"
	description = "Kremowa zupa kukurydziana z kawałkami bekonu i warzywami. Jedna miska to zawsze za mało."
	data = list("kremowy bulion" = 1, "bekon" = 1, "mieszanka warzyw" = 1)
	color = "#FFF200"

/datum/chemical_reaction/food/soup/corn_chowder
	required_reagents = list(
		/datum/reagent/water = 40,
		/datum/reagent/consumable/cream = 5,
	)
	required_ingredients = list(
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/meat/bacon = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/corn_chowder = 30,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment = 2,
	)

// Lizard stuff

// Atrakor Dumpling soup
// Meatball Soup, but lizard-like
// Black Broth
// Jellyfish Stew
// Rootbread Soup
// Moth stuff

// Cotton Soup
// Cheese Soup
/datum/reagent/consumable/nutriment/soup/cheese
	bowl_icon_state = "moth_cheese_soup"
	name = "Ælosterrmæsch" //ælo = cheese, sterr = melt, mæsch = soup
	description = "Prosta i sycąca zupa z domowego sera i batatów. Twaróg daje konsystencję, serwatka objętość, a oba razem smak!"
	data = list("ser" = 1, "śmietana" = 1, "batat" = 1)
	color = "#F3CE3A"

/datum/chemical_reaction/food/soup/cheese
	required_reagents = list(
		/datum/reagent/water = 30,
		/datum/reagent/consumable/flour = 10,
		/datum/reagent/consumable/milk = 10,
	)
	required_ingredients = list(
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/butter = 1,
		/obj/item/food/grown/potato/sweet = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/cheese = 30,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/milk = 2,
	)

// Seed Soup
// Bean Soup
// Oat Soup, but not oatmeal
/datum/reagent/consumable/nutriment/soup/moth_oats
	bowl_icon_state = "moth_oat_stew"
	name = "Häfmisklhaskl" //häfmiskl = oat (häf from German hafer meaning oat, miskl meaning seed), haskl = stew
	description = "Pikantny gulasz z dużą ilością warzyw, często podawany we flocie z ryżem albo chlebem jako sycący posiłek."
	data = list("owies" = 1, "batat" = 1, "marchewka" = 1, "pasternak" = 1, "dynia" = 1)
	color = "#CAA94E"

/datum/chemical_reaction/food/soup/moth_oats
	required_reagents = list(/datum/reagent/water = 50)
	required_ingredients = list(
		/obj/item/food/grown/oat = 1,
		/obj/item/food/grown/potato/sweet = 1,
		/obj/item/food/grown/parsnip = 1,
		/obj/item/food/grown/carrot = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/moth_oats = 30,
	)
	percentage_of_nutriment_converted = 0.1

// Fire Soup
// Rice Porridge (Soup-ish)
/datum/reagent/consumable/nutriment/soup/rice_porridge
	bowl_icon_state = "rice_porridge"
	name = "Kleik ryżowy"
	description = "Talerz kleiku ryżowego. Prawie bez smaku, ale zapycha. Chińczycy mówią na to congee, a ćmy höllflöfmisklsløsk." //höllflöfmiskl = rice (höllflöf = cloud, miskl = seed), sløsk = porridge
	data = list("nic" = 1)
	color = "#EDE3E3"

/datum/chemical_reaction/food/soup/rice_porridge
	required_reagents = list(
		/datum/reagent/water = 30,
		/datum/reagent/consumable/sodiumchloride = 5,
	)
	required_ingredients = list(
		/obj/item/food/boiledrice = 1,
	)
	results = list(
		/datum/reagent/consumable/nutriment/soup/rice_porridge = 20,
		/datum/reagent/consumable/sodiumchloride = 5,
	)
	percentage_of_nutriment_converted = 0.15

// Cornmeal Porridge (Soup-ish)
// Also, pretty much just a normal chemical reaction. Used in other stuff
// Cheese Porridge (Soup-ish)
// Rice Porridge again but with Toechtause
// Red Porridge
