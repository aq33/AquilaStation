/datum/bounty/item/botany
	reward = 5000
	var/datum/bounty/item/botany/multiplier = 0 //adds bonus reward money; increased for higher tier or rare mutations
	var/datum/bounty/item/botany/bonus_desc //for adding extra flavor text to bounty descriptions
	var/datum/bounty/item/botany/foodtype = "posiłek" //same here
	var/datum/bounty/item/botany/format_exception = FALSE //Set to true if the bounty uses a custom format from the one below

/datum/bounty/item/botany/New()
	..()

	if (format_exception == FALSE)
		description = "Szef kuchni Centrali chce przygotować wyborne danie ([foodtype]) z: [name]. [bonus_desc]"
		reward += multiplier * 1000
		required_count = rand(5, 10)

/datum/bounty/item/botany/ambrosia_vulgaris
	name = "Liście ambrozji pospolitej"
	wanted_types = list(/obj/item/food/grown/ambrosia/vulgaris)
	foodtype = "gulasz"

/datum/bounty/item/botany/ambrosia_gaia
	name = "Liście ambrozji Gai"
	wanted_types = list(/obj/item/food/grown/ambrosia/gaia)
	multiplier = 4
	foodtype = "gulasz"

/datum/bounty/item/botany/apple_golden
	name = "Złote jabłka"
	wanted_types = list(/obj/item/food/grown/apple/gold)
	multiplier = 4
	foodtype = "deser"

/datum/bounty/item/botany/banana
	name = "Banany"
	wanted_types = list(/obj/item/food/grown/banana)
	exclude_types = list(/obj/item/food/grown/banana/bluespace)
	foodtype = "deser bananowy"

/datum/bounty/item/botany/banana_bluespace
	name = "Bluespace'owe banany"
	wanted_types = list(/obj/item/food/grown/banana/bluespace)
	multiplier = 2
	foodtype = "deser bananowy"

/datum/bounty/item/botany/beans_koi
	name = "Fasola koi"
	wanted_types = list(/obj/item/food/grown/koibeans)
	multiplier = 2

/datum/bounty/item/botany/berries_death
	name = "Jagody śmierci"
	wanted_types = list(/obj/item/food/grown/berries/death)
	multiplier = 2
	bonus_desc = "Upiera się, że „wie, co robi”."
	foodtype = "sorbet"

/datum/bounty/item/botany/berries_glow
	name = "Świecące jagody"
	wanted_types = list(/obj/item/food/grown/berries/glow)
	multiplier = 2
	foodtype = "sorbet"

/datum/bounty/item/botany/cannabis
	name = "Liście konopi"
	wanted_types = list(/obj/item/food/grown/cannabis)
	exclude_types = list(/obj/item/food/grown/cannabis/white, /obj/item/food/grown/cannabis/death, /obj/item/food/grown/cannabis/ultimate)
	multiplier = 4 //hush money
	bonus_desc = "Nie wspominajcie o tej przesyłce ochronie."
	foodtype = "porcja „muffinek”"
	
/datum/bounty/item/botany/cannabis_white
	name = "Białe liście konopi"
	wanted_types = list(/obj/item/food/grown/cannabis/white)
	multiplier = 6
	bonus_desc = "Nie wspominajcie o tej przesyłce ochronie."
	foodtype = "„posiłek”"

/datum/bounty/item/botany/cannabis_death
	name = "Liście konopi śmierci"
	wanted_types = list(/obj/item/food/grown/cannabis/death)
	multiplier = 6
	bonus_desc = "Nie wspominajcie o tej przesyłce ochronie."
	foodtype = "„posiłek”"

/datum/bounty/item/botany/cannabis_ultimate
	name = "Liście konopi omega"
	wanted_types = list(/obj/item/food/grown/cannabis/ultimate)
	multiplier = 6
	bonus_desc = "Pod żadnym pozorem nie wspominajcie o tej przesyłce ochronie."
	foodtype = "porcja „brownies”"

/datum/bounty/item/botany/wheat
	name = "Ziarna pszenicy"
	wanted_types = list(/obj/item/food/grown/wheat)

/datum/bounty/item/botany/rice
	name = "Ziarna ryżu"
	wanted_types = list(/obj/item/food/grown/rice)

/datum/bounty/item/botany/chili
	name = "Papryczki chili"
	wanted_types = list(/obj/item/food/grown/chili)

/datum/bounty/item/botany/chili
	name = "Lodowe papryki"
	wanted_types = list(/obj/item/food/grown/icepepper)
	multiplier = 2

/datum/bounty/item/botany/chili
	name = "Upiorne papryczki chili"
	wanted_types = list(/obj/item/food/grown/ghost_chili)
	multiplier = 2

/datum/bounty/item/botany/citrus_lime
	name = "Limonki"
	wanted_types = list(/obj/item/food/grown/citrus/lime)
	foodtype = "sorbet"

/datum/bounty/item/botany/citrus_lemon
	name = "Cytryny"
	wanted_types = list(/obj/item/food/grown/citrus/lemon)
	foodtype = "sorbet"

/datum/bounty/item/botany/citrus_oranges
	name = "Pomarańcze"
	wanted_types = list(/obj/item/food/grown/citrus/orange)
	bonus_desc = "Nie wysyłajcie cytryn ani limonek." //I vanted orahnge!
	foodtype = "sorbet"

/datum/bounty/item/botany/eggplant
	name = "Bakłażany"
	wanted_types = list(/obj/item/food/grown/eggplant)
	bonus_desc = "Nie mylić z bakłażanami."

/datum/bounty/item/botany/eggplant_eggy
	name = "Bakłażany jajeczne"
	wanted_types = list(/obj/item/food/grown/shell/eggy)
	bonus_desc = "Nie mylić z jajkami."
	multiplier = 2

/datum/bounty/item/botany/kudzu
	name = "Strąki kudzu"
	wanted_types = list(/obj/item/food/grown/kudzupod)
	bonus_desc = "Przechowywać w suchym, ciemnym miejscu."
	multiplier = 4

/datum/bounty/item/botany/watermelon
	name = "Arbuzy"
	wanted_types = list(/obj/item/food/grown/watermelon)
	foodtype = "deser"

/datum/bounty/item/botany/watermelon_holy
	name = "Święte arbuzy"
	wanted_types = list(/obj/item/food/grown/holymelon)
	multiplier = 2
	foodtype = "deser"

/datum/bounty/item/botany/glowshroom
	name = "Świecące grzyby"
	wanted_types = list(/obj/item/food/grown/mushroom/glowshroom)
	exclude_types = list(/obj/item/food/grown/mushroom/glowshroom/glowcap, /obj/item/food/grown/mushroom/glowshroom/shadowshroom)
	foodtype = "omlet"

/datum/bounty/item/botany/glowshroom_cap
	name = "Świecące kapelusze"
	wanted_types = list(/obj/item/food/grown/mushroom/glowshroom/glowcap)
	multiplier = 2
	foodtype = "omlet"

/datum/bounty/item/botany/glowshroom_shadow
	name = "Cieniste grzyby"
	wanted_types = list(/obj/item/food/grown/mushroom/glowshroom/shadowshroom)
	multiplier = 2
	foodtype = "omlet"

/datum/bounty/item/botany/nettles_death
	name = "Pokrzywy śmierci"
	wanted_types = list(/obj/item/food/grown/nettle/death)
	multiplier = 2
	bonus_desc = "Przy obchodzeniu się z nimi noście ochronę."
	foodtype = "ser"

/datum/bounty/item/botany/pineapples
	name = "Ananasy"
	wanted_types = list(/obj/item/food/grown/pineapple)
	bonus_desc = "Nie do spożycia przez ludzi."
	foodtype = "popielniczka"

/datum/bounty/item/botany/tomato
	name = "Pomidory"
	wanted_types = list(/obj/item/food/grown/tomato)
	exclude_types = list(/obj/item/food/grown/tomato/blue)

/datum/bounty/item/botany/tomato_bluespace
	name = "Bluespace'owe pomidory"
	wanted_types = list(/obj/item/food/grown/tomato/blue/bluespace)
	multiplier = 4

/datum/bounty/item/botany/oatz
	name = "Owies"
	wanted_types = list(/obj/item/food/grown/oat)
	multiplier = 2
	foodtype = "porcja owsianki"
	bonus_desc = "Przysiady i owies. Skończył nam się owies."

/datum/bounty/item/botany/forgetmenot
	name = "Niezapominajki"
	description = "Komandor Zot ma oko na kwatermistrzynię Mayę. Wyślijcie niezapominajki – jej ulubione kwiaty – a chętnie was wynagrodzi."
	reward = 7000
	required_count = 3
	wanted_types = list(/obj/item/food/grown/poppy/geranium/forgetmenot)
	format_exception = TRUE

/datum/bounty/item/botany/geranium
	name = "Pelargonie"
	description = "Komandor Zot ma chrapkę na komandor Zenę. Wyślijcie pelargonie – jej ulubione kwiaty – a chętnie was wynagrodzi."
	reward = 6000
	required_count = 3
	wanted_types = list(/obj/item/food/grown/poppy/geranium)
	format_exception = TRUE

/datum/bounty/item/botany/rainbowflowercrown
	name = "Tęczowe wianki"
	description = "Centrala martwi się wskaźnikiem samobójstw wśród stażystów. Przesyłka tęczowych wianków powinna poprawić morale."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/clothing/head/rainbowbunchcrown)
	format_exception = TRUE
