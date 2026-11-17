/*
	AQUILA - rośliny dające surowce zamiast jedzenia (port: Goon, Bubberstation, Monkestation)
	- syntetyczne mięso i syntetyczne narządy z Goona (mutacje od odczynnika z syntetycznego mięsa),
	- drzewa papierowe, pieniężne i kauczukowe z Goona,
	- łańcuch roślin-rud z Bubberstation (modular_zubbers/code/modules/hydroponics/grown/rocks.dm),
	- liście koki z Monkestation.
	Wszystkie poza koką to rzadkie mutacje z drogim piecem i małym plonem (najwyżej harvest_cap sztuk z jednego zbioru).
	Grafiki: torebki rud z Bubberstation, liść koki z Monkestation, worki nasion z Goona, owoce na roślinie
	to pomniejszone sprite'y plonów albo przekolorowane kształty z features/fruit.dmi.
*/

/*
	Wspólna baza: plon to surowiec (ruda, narząd, banknot, papier), a nie owoc.
*/
/datum/plant_feature/fruit/surowce
	abstract_type = /datum/plant_feature/fruit/surowce
	icon_state = "potato-2"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_surowce_seeds.dmi'
	plant_traits = list()
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	/// Najwięcej sztuk plonu z jednego zbioru, niezależnie od tego, ile owoców wisi na roślinie
	var/harvest_cap = 2

/datum/plant_feature/fruit/surowce/build_fruit()
	// Stos (ruda, banknoty) rośnie w roślinie razem z poprzednim owocem i scaliłby się z nim jeszcze w trakcie tworzenia; kolejne owoce dokładają mu sztuki
	var/obj/item/stack/grown_stack = locate(/obj/item/stack) in fruits
	if(grown_stack)
		if(grown_stack.amount < harvest_cap)
			grown_stack.add(1)
		return grown_stack
	if(length(fruits) >= harvest_cap)
		return null
	return ..()

/// Dopiski mutacji do roślin, które już mamy
/datum/plant_mutation_set/surowce
	mutations = list(
		/datum/plant_feature/fruit/wheat/meat = list(/datum/plant_feature/fruit/surowce/synthmeat = 25),
		/datum/plant_feature/fruit/apple = list(/datum/plant_feature/fruit/surowce/paper = 25, /datum/plant_feature/fruit/surowce/rubber = 25),
		/datum/plant_feature/fruit/cactus = list(/datum/plant_feature/fruit/surowce/rockfruit = 25),
	)

/*
	Syntetyczne mięso (Goon: synthmeat). Z niego odczynnikami w tacy wyrastają syntetyczne narządy.
*/
/datum/plant_feature/fruit/surowce/synthmeat
	species_name = "caro synthetica"
	name = "syntetyczne mięso"
	icon = 'aquila/icons/obj/hydroponics/ported_surowce_fruit.dmi'
	icon_state = "synthmeat"
	seed_icon_state = "seed-synthmeat"
	fruit_product = /obj/item/food/meat/slab/synthmeat
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/synthflesh = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	reagent_mutations = list(
		/datum/plant_feature/fruit/surowce/synth_organ/butt = list(/datum/reagent/drug/fartium = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/brain = list(/datum/reagent/medicine/mannitol = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/heart = list(/datum/reagent/blood = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/eyes = list(/datum/reagent/medicine/oculine = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/limb = list(/datum/reagent/medicine/synthflesh = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/liver = list(/datum/reagent/consumable/ethanol = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/lungs = list(/datum/reagent/medicine/salbutamol = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/stomach = list(/datum/reagent/medicine/charcoal = 10),
		/datum/plant_feature/fruit/surowce/synth_organ/appendix = list(/datum/reagent/ammonia/urine = 10),
	)

/datum/plant_feature/fruit/surowce/synth_organ
	abstract_type = /datum/plant_feature/fruit/surowce/synth_organ
	icon = 'aquila/icons/obj/hydroponics/ported_surowce_fruit.dmi'
	seed_icon_state = "seed-synthmeat"
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	reagent_mutations = list()

/datum/plant_feature/fruit/surowce/synth_organ/butt
	species_name = "podex syntheticus"
	name = "syntetyczny tyłek"
	icon_state = "synth_butt"
	fruit_product = /obj/item/organ/butt/synthgrown
	reagent_mutations = list(/datum/plant_feature/fruit/surowce/synth_organ/buttbot = list(/datum/reagent/nanomachines = 10))

/datum/plant_feature/fruit/surowce/synth_organ/buttbot
	species_name = "podex roboticus"
	name = "syntetyczny tyłkobot"
	icon_state = "synth_buttbot"
	fruit_product = /mob/living/simple_animal/bot/buttbot
	harvest_cap = 1

/datum/plant_feature/fruit/surowce/synth_organ/buttbot/catch_attackby(datum/source, obj/item/storage/bag/plants/item, mob/living/user, params)
	// Tyłkobot to mob i nie wejdzie do torby na rośliny, zbiera się go ręką
	return

/datum/plant_feature/fruit/surowce/synth_organ/brain
	species_name = "cerebrum syntheticum"
	name = "syntetyczny mózg"
	icon_state = "synth_brain"
	fruit_product = /obj/item/organ/brain/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/heart
	species_name = "cor syntheticum"
	name = "syntetyczne serce"
	icon_state = "synth_heart"
	fruit_product = /obj/item/organ/heart/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/eyes
	species_name = "oculus syntheticus"
	name = "syntetyczne oczy"
	icon_state = "synth_eyes"
	fruit_product = /obj/item/organ/eyes/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/limb
	species_name = "membrum syntheticum"
	name = "syntetyczna kończyna"
	icon = 'icons/obj/hydroponics/features/fruit.dmi'
	icon_state = "parsnip"
	colour_override = "#f0c0a0"
	fruit_product = /obj/item/bodypart/l_arm
	/// Każdy owoc to losowa ręka albo noga, jak w Goonie
	var/list/limb_types = list(/obj/item/bodypart/l_arm, /obj/item/bodypart/r_arm, /obj/item/bodypart/l_leg, /obj/item/bodypart/r_leg)

/datum/plant_feature/fruit/surowce/synth_organ/limb/build_fruit()
	fruit_product = pick(limb_types)
	return ..()

/datum/plant_feature/fruit/surowce/synth_organ/liver
	species_name = "iecur syntheticum"
	name = "syntetyczna wątroba"
	icon_state = "synth_liver"
	fruit_product = /obj/item/organ/liver/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/lungs
	species_name = "pulmo syntheticus"
	name = "syntetyczne płuca"
	icon_state = "synth_lungs"
	fruit_product = /obj/item/organ/lungs/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/stomach
	species_name = "stomachus syntheticus"
	name = "syntetyczny żołądek"
	icon_state = "synth_stomach"
	fruit_product = /obj/item/organ/stomach/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/appendix
	species_name = "appendix synthetica"
	name = "syntetyczny wyrostek robaczkowy"
	icon_state = "synth_appendix"
	fruit_product = /obj/item/organ/appendix/synthgrown

// Narządy z rośliny: słabsze od zwykłych (3/4 wytrzymałości), mózg, oczy i tyłek bez zmian
/obj/item/organ/butt/synthgrown
	name = "syntetyczny tyłek"
	desc = "Tyłek wyhodowany w tacy hydroponicznej. Pachnie lekko nawozem."

/obj/item/organ/brain/synthgrown
	name = "syntetyczny mózg"
	desc = "Mózg wyhodowany w tacy hydroponicznej. Pusty jak świeżo wyprana kartka."

/obj/item/organ/heart/synthgrown
	name = "syntetyczne serce"
	desc = "Serce wyhodowane w tacy hydroponicznej. Bije trochę słabiej niż prawdziwe."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/eyes/synthgrown
	name = "syntetyczne oczy"
	desc = "Oczy wyhodowane w tacy hydroponicznej. Patrzą trochę roślinnie."

/obj/item/organ/liver/synthgrown
	name = "syntetyczna wątroba"
	desc = "Wątroba wyhodowana w tacy hydroponicznej. Znosi mniej niż prawdziwa."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/lungs/synthgrown
	name = "syntetyczne płuca"
	desc = "Płuca wyhodowane w tacy hydroponicznej. Lekko pachną chlorofilem."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/stomach/synthgrown
	name = "syntetyczny żołądek"
	desc = "Żołądek wyhodowany w tacy hydroponicznej. Trawi trochę gorzej niż prawdziwy."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/appendix/synthgrown
	name = "syntetyczny wyrostek robaczkowy"
	desc = "Wyrostek wyhodowany w tacy hydroponicznej. Nikt nie wie po co, ale jest."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

/*
	Drzewa z Goona: papierowe (z jabłoni), pieniężne (z papierowego) i kauczukowe (z jabłoni)
*/
/datum/plant_feature/fruit/surowce/paper
	species_name = "arbor papyracea"
	name = "drzewo papierowe"
	icon = 'aquila/icons/obj/hydroponics/ported_surowce_fruit.dmi'
	icon_state = "paper_leaf"
	seed_icon_state = "seed-papertree"
	fruit_product = /obj/item/paper
	mutations = list(/datum/plant_feature/fruit/surowce/money = 50)

/datum/plant_feature/fruit/surowce/money
	species_name = "arbor pecuniaria"
	name = "drzewo pieniężne"
	icon = 'aquila/icons/obj/hydroponics/ported_surowce_fruit.dmi'
	icon_state = "banknote"
	seed_icon_state = "seed-moneytree"
	fruit_product = /obj/item/stack/spacecash/c10

/datum/plant_feature/fruit/surowce/rubber
	species_name = "hevea elastica"
	name = "drzewo kauczukowe"
	icon_state = "pod"
	colour_override = "#efe6c8"
	seed_icon_state = "seed-rubbertree"
	// Goon daje lateks; najbliższy nasz materiał to plastik
	fruit_product = /obj/item/stack/sheet/plastic

/*
	Łańcuch roślin-rud z Bubberstation. Kaktus popielny -> owoc skalny -> owoc piaskowy, a z niego cztery gałęzie:
	żelazo -> tytan; uran -> plazma -> bluespace; srebro -> złoto -> diament; adamantyt -> miedź -> bananium.
	Wszystkie na bulwie kaktusa: jeden owoc na zbiór, dwa lub trzy zbiory.
*/
/datum/plant_feature/fruit/surowce/rockfruit
	species_name = "saxum fructus"
	name = "owoc skalny"
	colour_override = "#8a8580"
	seed_icon_state = "seed-rockfruit"
	fruit_product = /obj/item/food/grown/rockfruit
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/surowce/sandfruit = 25)

/obj/item/food/grown/rockfruit
	name = "owoc skalny"
	desc = "Przysmak golemów: w środku owocowy, z wierzchu skalna skorupa."
	icon = 'aquila/icons/obj/hydroponics/ported_surowce_harvest.dmi'
	icon_state = "rockfruit"
	force = 5
	throwforce = 10
	foodtypes = FRUIT
	tastes = list("góry" = 1)

/datum/plant_feature/fruit/surowce/sandfruit
	species_name = "arena fructus"
	name = "owoc piaskowy"
	colour_override = "#e3c98f"
	seed_icon_state = "seed-sandfruit"
	fruit_product = /obj/item/stack/ore/glass
	mutations = list(
		/datum/plant_feature/fruit/surowce/ferrotuber = 25,
		/datum/plant_feature/fruit/surowce/uraniberry = 50,
		/datum/plant_feature/fruit/surowce/agbergine = 50,
		/datum/plant_feature/fruit/surowce/adamapple = 100,
	)

/datum/plant_feature/fruit/surowce/ferrotuber
	species_name = "ferrum tuber"
	name = "żelazna bulwa"
	colour_override = "#9a5b3c"
	seed_icon_state = "seed-ferrotuber"
	fruit_product = /obj/item/stack/ore/iron
	mutations = list(/datum/plant_feature/fruit/surowce/titanituber = 50)

/datum/plant_feature/fruit/surowce/titanituber
	species_name = "titanium tuber"
	name = "tytanowa bulwa"
	colour_override = "#dfe4ea"
	seed_icon_state = "seed-titanituber"
	fruit_product = /obj/item/stack/ore/titanium

/datum/plant_feature/fruit/surowce/uraniberry
	species_name = "uranium bacca"
	name = "uranowa jagoda"
	icon_state = "grapes"
	colour_override = "#6bdc4a"
	seed_icon_state = "seed-uraniberry"
	fruit_product = /obj/item/stack/ore/uranium
	mutations = list(/datum/plant_feature/fruit/surowce/plasmaplum = 50)

/datum/plant_feature/fruit/surowce/plasmaplum
	species_name = "plasma prunum"
	name = "plazmowa śliwka"
	icon_state = "apple-2"
	colour_override = "#a53fd6"
	seed_icon_state = "seed-plasmaplum"
	fruit_product = /obj/item/stack/ore/plasma
	mutations = list(/datum/plant_feature/fruit/surowce/bluegemdrupe = 100)

/datum/plant_feature/fruit/surowce/bluegemdrupe
	species_name = "gemma caerulea"
	name = "niebieski klejnot"
	icon_state = "cherry"
	colour_override = "#3d74ff"
	seed_icon_state = "seed-bluegemdrupe"
	fruit_product = /obj/item/stack/ore/bluespace_crystal
	harvest_cap = 1

/datum/plant_feature/fruit/surowce/agbergine
	species_name = "argentum melongena"
	name = "agberżyna"
	icon_state = "eggplant-2"
	colour_override = "#c9ced6"
	seed_icon_state = "seed-agbergine"
	fruit_product = /obj/item/stack/ore/silver
	mutations = list(/datum/plant_feature/fruit/surowce/aubergine = 50)

/datum/plant_feature/fruit/surowce/aubergine
	species_name = "aurum melongena"
	name = "oberżyna złota"
	icon_state = "eggplant-2"
	colour_override = "#f5c542"
	seed_icon_state = "seed-aubergine"
	fruit_product = /obj/item/stack/ore/gold
	mutations = list(/datum/plant_feature/fruit/surowce/dimantis = 100)

/datum/plant_feature/fruit/surowce/dimantis
	species_name = "adamas fructus"
	name = "dimantis"
	icon_state = "orb"
	colour_override = "#aef3ff"
	seed_icon_state = "seed-dimantis"
	fruit_product = /obj/item/stack/ore/diamond
	harvest_cap = 1

/datum/plant_feature/fruit/surowce/adamapple
	species_name = "malum adamantinum"
	name = "jabłko adamowe"
	icon_state = "apple-2"
	colour_override = "#3fb5a5"
	seed_icon_state = "seed-adamapple"
	// Nie mamy rudy adamantytu, owoc daje od razu arkusz
	fruit_product = /obj/item/stack/sheet/mineral/adamantine
	harvest_cap = 1
	mutations = list(/datum/plant_feature/fruit/surowce/runescooper = 50)

/datum/plant_feature/fruit/surowce/runescooper
	species_name = "globulus runicus"
	name = "runiczna gałka"
	icon_state = "tomato-2"
	colour_override = "#4fb3c9"
	seed_icon_state = "seed-runescooper"
	// Nie mamy runitu z Bubbera; zamiast niego miedź z NSV
	fruit_product = /obj/item/stack/ore/copper
	mutations = list(/datum/plant_feature/fruit/surowce/bananiumberry = 100)

/datum/plant_feature/fruit/surowce/bananiumberry
	species_name = "bacca bananii"
	name = "bananiowa jagoda"
	icon_state = "grapes"
	colour_override = "#ffe34a"
	seed_icon_state = "seed-bananiumberry"
	fruit_product = /obj/item/stack/ore/bananium
	harvest_cap = 1

/*
	Liście koki (Monkestation: coca leaf). U Monke kokaina; u nas najbliższy roślinny stymulant, efedryna.
*/
/datum/plant_feature/fruit/coca
	species_name = "erythroxylum coca"
	name = "liście koki"
	icon_state = "tea"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_surowce_seeds.dmi'
	seed_icon_state = "seed-cocaleaf"
	fruit_product = /obj/item/food/grown/cocaleaf
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/ephedrine = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/coca
	name = "nasiona: liście koki (ziemia)"
	name_override = "liście koki"
	icon = 'aquila/icons/obj/hydroponics/ported_surowce_seeds.dmi'
	icon_state = "seed-cocaleaf"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tea, /datum/plant_feature/fruit/coca)

/obj/item/food/grown/cocaleaf
	seed = /obj/item/plant_seeds/preset/coca
	name = "liść koki"
	desc = "Liść krzewu koki, pełen pobudzającego alkaloidu."
	icon = 'aquila/icons/obj/hydroponics/ported_surowce_harvest.dmi'
	icon_state = "cocaleaf"
	foodtypes = FRUIT
	tastes = list("liście" = 1)

/obj/machinery/vending/hydroseeds/Initialize(mapload)
	contraband[/obj/item/plant_seeds/preset/coca] = 2
	return ..()
