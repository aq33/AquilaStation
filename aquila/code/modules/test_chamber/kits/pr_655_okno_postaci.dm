// aq33/AquilaStation#655 - okno postaci: głosy mowy, fryzury, quirki, markingi i nowe rasy

/datum/test_chamber_kit/pr_655
	name = "PR 655: okno postaci i nowe rasy"
	pr = "aq33/AquilaStation#655"
	description = "Zestaw stawia po jednym przedstawicielu każdej nowej rasy i rzeczy do testu Akwarianina. \
	1) Okno postaci: zakładka Markingi (do 3 wzorów na część ciała, kolory, podgląd), nowe fryzury i zarost, Głos mowy (Głos 1-4 z podglądem dźwięku), \
	cechy nowych ras (Akwarianin: ryba, woda, pancerz). Postać z markingami: utnij kończynę → marking znika razem z nią. \
	2) Mowa: powiedz coś głosem z Goona, zadaj pytanie i krzyknij → trzy różne nagrania. W Ustawieniach gry wyłącz „Dźwięki mowy postaci” → cisza, także nasze „hmmm”. \
	3) Krzyk i śmiech jako felinid, ćma, jaszczur, eteryk, oozeling, IPC i człowiek; pierdnięcie → nowe dźwięki. Mops szczeka, Żaba rechocze, Akwarianin bulgocze. \
	4) Rasy: wejdź w ciało (admin: Aghost → posiądź) i sprawdź ubrania na Mopsie i Żabie (kombinezon, hełm, maska, rękawice, buty), \
	nakładki Psyfozy (widzenie psychiczne), kończynę Mięsoczłowieka po odcięciu. \
	5) Akwarianin: uderzaj go w głowę → woda w kloszu ubywa, bez wody ryba się dusi; dolej wodę zlewką; nakarm karmą dla ryb albo wlej zmielone jedzenie (blender w kuchni). \
	Bij w tułów → wgnieciony pancerz przecieka wodą, a spawarka zatrzymuje wyciek. \
	Zniszcz pancerz (gib) → zostaje klosz z rybą, włóż go do MMI; zestaw pancerza złóż w dłoni. \
	Rozbij klosz (skrzynką w głowę albo w leżący klosz w trybie walki, albo rzuć nim) → rybka rzuca się na podłodze; wpuść ją do zlewki z wodą, \
	wylej (użyj w ręce), przełóż do pustego klosza z wodą i zamocuj na pancerzu. Drugą rybkę rozgnieć w trybie walki, trzecią pokrój nożem na sushi (poza trybem walki). \
	6) Quirki: wybierz kilka nowych w oknie postaci i zespawnuj się (Łysina z peruką, Kolorysta ze sprayem do włosów, Właściciel zwierzaka)."
	items = list(
		/mob/living/carbon/human/species/beefman = 1,
		/mob/living/carbon/human/species/psyphoza = 1,
		/mob/living/carbon/human/species/pug = 1,
		/mob/living/carbon/human/species/amphibian = 1,
		/mob/living/carbon/human/species/aquarian = 1,
		/obj/item/aquarian_shell_kit = 1,
		/obj/item/fish_feed = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/reagent_containers/glass/aquarian_dome = 1,
		/obj/item/mmi = 1,
		/obj/item/dyespray = 1,
		/obj/item/clothing/under/color/grey = 3,
		/obj/item/clothing/head/helmet/space/eva = 1,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/clothing/shoes/sneakers/black = 1,
		/obj/item/circular_saw = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/weldingtool = 1,
		/obj/item/kitchen/knife = 1,
	)
