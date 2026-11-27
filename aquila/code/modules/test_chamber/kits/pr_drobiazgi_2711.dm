// Drobiazgi 27.11: pot, kupa rozdeptana w plamę, nieśmiertelniki i tablica pamięci, SOP alarmów, pager w kieszeni, kamera Sabre, naprawa w depocie

/datum/test_chamber_kit/pr_drobiazgi_2711
	name = "Drobiazgi 27.11: pot, nieśmiertelniki, SOP"
	pr = "aq33/AquilaStation#PR_NUMBER"
	description = "1) Sprintuj do zadyszki: nad głową mignie kropla potu, oględziny pokażą „spocona” albo „zlana potem”. Szmatą poza combat mode otrzyj pot z siebie i z kogoś: szmata nasiąka potem. Wylej go do zlewki i podgrzej (ponad 374 K): zostaje sól. Prysznic zmywa pot. \
		2) Postaw kupę (Fion albo admin spawn odchodów) i wejdź na nią: grudka zmienia się w nieśliską plamę, buty zostawiają brązowe ślady. Biegunka zostaje śliska. \
		3) Załóż człowiekowi z zestawu kombinezon i identyfikator, zabij go (admin: Kill), przeciągnij go na siebie i w oknie przeszukiwania kliknij przy identyfikatorze „Zdejmij nieśmiertelnik”. Zbuduj tablicę pamięci (10 arkuszy żelaza, spawarka, menu tworzenia → Misc) i przyłóż do niej nieśmiertelnik: imię jest w opisie tablicy. Drugi raz z tego identyfikatora nieśmiertelnika nie zdejmiesz. \
		4) Zmień stan alarmu (konsola komunikacji albo admin): pod ogłoszeniem w czacie jest blok SOP. W PDA program „SOP” pokazuje ściągę z zaznaczonym obecnym stanem. \
		5) Włóż pager drużyny do kieszeni albo PDA i poproś kogoś o wiadomość na kanale drużyny: nad postacią pojawia się napis w kolorze drużyny. W ręce: tylko czat. \
		6) Spess.tv w PDA albo telewizor rozrywkowy: kanał „Kamera pokładowa: Su-437 Sabre” pokazuje wnętrze Sabre, także w locie. \
		7) Admin: uszkodź okręt i przeskocz do układu z sojuszniczym depotem (mapa FTL): w czacie załogi pojawia się komunikat o darmowej naprawie, kadłub i pancerz rosną co 10 s."
	items = list(
		/obj/item/reagent_containers/glass/rag = 2,
		/obj/item/reagent_containers/glass/beaker = 1,
		/obj/item/stack/sheet/iron/ten = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/card/id = 1,
		/obj/item/clothing/under/color/grey = 1,
		/mob/living/carbon/human = 1,
		/obj/item/squad_pager = 2,
		/obj/item/modular_computer/tablet/pda = 1,
		/obj/effect/decal/cleanable/feces = 2,
	)
