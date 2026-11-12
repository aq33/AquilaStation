/datum/test_chamber_kit/pr_625_mining
	name = "Moby górnicze (basic moby)"
	pr = "aq33/AquilaStation#625"
	description = "Wrogie moby górnicze jako basic moby z tg. Ustaw się kilka pól od nich (najlepiej z kinetycznym miażdżycielem albo laserem). \
		1) Władca roju trzyma dystans i wypuszcza pomioty, które gryzą; uderzony wypuszcza pomiot od razu; po śmierci zostawia rdzeń regeneracyjny i trzy pomioty. \
		2) Legion trzyma dystans 4-6 pól i wystrzeliwuje czaszki (znacznik celu na ziemi, czaszka spada z góry); czaszka leczy rannego sojusznika z frakcji górniczej, a człowieka nieprzytomnego zamienia w nowego legiona z ciałem w środku. Zabity legion wypuszcza ciało i rdzeń legionu; legion bez ciała zostawia zwłoki górnika. \
		3) Karłowaty legion jest mniejszy i szybszy. \
		4) Duch może przejąć władcę roju (klik duchem); w obu trybach sterowania klik w coś daleko wypuszcza pomiot, a przycisk zdolności celuje nim. \
		5) Goliat po kilku sekundach z tym samym celem wbija pod niego macki (przed atakiem zmienia wygląd); macki chwytają i ogłuszają, a złapanego goliat bije wręcz. Uderzony z bliska wypuszcza macki dookoła siebie, uderzony z daleka sięga linią macek. Z każdym ciosem macki odnawiają się szybciej. Nakarmiony popielną florą (kilka prób) daje się oswoić, dostaje siodło i można na nim jeździć. Zabity kinetycznym miażdżycielem może zostawić trofeum (macka) przy rozbieraniu; zawsze ma skórę goliata. \
		6) Pradawny goliat (stary wygląd) wypuszcza macki dookoła siebie bez przerwy. \
		7) Obserwator trzyma dystans 3-5 pól i strzela mroźnymi podmuchami; po kilku sekundach z tym samym celem jego oko świeci na czerwono, a po chwili oślepia i ogłupia każdego, kto na niego patrzy (odwróć się, żeby uniknąć). Ogniskrzydły podpala i powala, lodoskrzydły zamraża i odrzuca. Zabity daje diamenty i ścięgna przy rozbieraniu. \
		8) Bazyliszek strzela z daleka, a z bliska gryzie; po śmierci zostawia dwa diamenty."
	items = list(
		/mob/living/basic/mining/hivelord = 1,
		/mob/living/basic/mining/legion = 1,
		/mob/living/basic/mining/legion/dwarf = 1,
		/mob/living/basic/mining/goliath = 1,
		/mob/living/basic/mining/goliath/ancient/immortal = 1,
		/obj/item/food/grown/ash_flora/shavings = 5,
		/mob/living/basic/mining/watcher = 1,
		/mob/living/basic/mining/watcher/magmawing = 1,
		/mob/living/basic/mining/watcher/icewing = 1,
		/mob/living/basic/mining/basilisk = 1,
	)

/datum/test_chamber_kit/pr_625_mining_peaceful
	name = "Pokojowe moby górnicze (basic moby)"
	pr = "aq33/AquilaStation#625"
	description = "Pokojowe moby górnicze jako basic moby z tg, z rudą i flakami. 		1) Złoty pędrak zjada leżącą obok rudę złota i srebra, ucieka przed tobą i po 10 s pościgu zakopuje się na dobre; pociski się od niego odbijają, zabity wypluwa połkniętą rudę. 		2) Żarłoczki (samiec i samica) zjadają flaki; potem żarłoczkę można wydoić zlewką (śmietanka, sól fizjologiczna). Żarłoczka z pełnym workiem i samcem obok rodzi młodego żarłoczka, który po chwili dorasta."
	items = list(
		/mob/living/basic/mining/goldgrub = 1,
		/obj/item/stack/ore/gold = 1,
		/obj/item/stack/ore/silver = 1,
		/mob/living/basic/mining/gutlunch/gubbuck = 1,
		/mob/living/basic/mining/gutlunch/guthen = 1,
		/obj/effect/decal/cleanable/blood/gibs = 1,
		/obj/item/reagent_containers/glass/beaker = 1,
	)
