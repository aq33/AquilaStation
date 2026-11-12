/datum/test_chamber_kit/pr_625_rest
	name = "Basic moby: mimiki, muchołówka, Netherworld, fugu, smok (wrogie)"
	pr = "aq33/AquilaStation#625"
	description = "Zestaw: skrzynia-mimik, ludzka muchołówka, pąk kwiatu z kudzu, istota, mi-go, puste ciało, wumboriańska fugu, kosmiczny smok, a do tego mimik-skrzynka z narzędziami i mimik-laser (z setup()). Wszystkie atakują same, nie zrzucaj razem ze spokojnymi. Sprawdzaj w obu trybach sterowania (combat mode i stare intencje). \
	1) Skrzynia stoi bez ruchu; spróbuj ją otworzyć pustą ręką bez combat mode / na intencji pomocy → „zaczyna się ruszać”, gryzie i otwiera wieko. Po śmierci zostaje zwykła skrzynia z zawartością. \
	2) Mimik-skrzynka goni i bije, bez celu powoli traci zdrowie; po śmierci zostaje skrzynka. Mimik-laser strzela z dystansu, po rozładowaniu baterii podchodzi i bije. \
	3) Muchołówka łapie winoroślą z odległości do 4 pól (powalenie na 2 s, smycz), gryzie i leczy się każdym ugryzieniem. Pąk po 2 minutach wydaje nową muchołówkę. Przejmij muchołówkę (Possess): klik poza zasięgiem w combat mode / na intencji harm oplata cel, bez combat mode nie. \
	4) Istota, mi-go i puste ciało biją mocniej (istota i mi-go są też szybsze) przy niskim zdrowiu; mi-go robi uniki na boki i wydaje losowe dźwięki. Przejmij istotę: „Niesamowity ruch” działa tylko wtedy, gdy nikt cię nie widzi (6 s stania), potem przenikasz przez ściany. \
	5) Fugu ucieka, przy celu nadyma się na 10 s: duża, nieśmiertelna, gryzie i rozrywa zwykłe ściany. Gruczoł z martwej fugu użyty na innym zwierzęciu (także basic mobie) powiększa je i wzmacnia. \
	6) Smok: przejmij go (Possess). Kolor wybierasz przy wejściu. Klik poza zasięgiem → ogniste tchnienie (30 obrażeń od ognia, staje na ścianach, oknach i zamkniętych drzwiach); prawy klik poza zasięgiem / intencja rozbrajania → atak podmuchem (odrzuca i powala, kolejne użycia męczą dłużej); przycisk akcji robi to samo. Klik na ścianę → rozrywa ją (4 s, wzmocnioną 12 s). Klik na zwłoki → połyka w 3 s i leczy się; ożywione zwłoki wypluwa, po śmierci smoka wszystko wypada. Ogień smoka na karpiach przyspiesza je na 8 s. \
	7) Antag: nadaj smokowi rolę „Kosmiczny smok” z panelu gracza, wejdź na jeden z obszarów z celu i użyj „Przywołaj szczelinę” → szczelina karpi (10 s). Duchy mogą z niej wejść jako karpie, a smok leczy się, stojąc przy niej."
	items = list(
		/mob/living/basic/mimic/crate = 1,
		/mob/living/basic/venus_human_trap = 1,
		/obj/structure/alien/resin/flower_bud_enemy = 1,
		/mob/living/basic/creature = 1,
		/mob/living/basic/migo = 1,
		/mob/living/basic/blankbody = 1,
		/mob/living/basic/wumborian_fugu = 1,
		/mob/living/basic/space_dragon = 1,
	)

/datum/test_chamber_kit/pr_625_rest/setup(list/spawned, list/turfs, turf/center, mob/user)
	new /mob/living/basic/mimic/copy(center, new /obj/item/storage/toolbox/mechanical(center))
	new /mob/living/basic/mimic/copy/ranged(center, new /obj/item/gun/energy/laser(center))

/datum/test_chamber_kit/pr_625_rest_spokojne
	name = "Basic moby: klauni i świetliki (spokojne)"
	pr = "aq33/AquilaStation#625"
	description = "Zestaw: 2 świetliki, klaun, klaunan, honkuś, żywy smar, mięsoklaun, coś, co kiedyś było klaunem, gruczoł wumboriańskiej fugu, kij animacji, laser, nóż i człowiek bez gracza. Nie zrzucaj razem z wrogimi. Sprawdzaj w obu trybach sterowania (combat mode i stare intencje). \
	1) Zrań człowieka nożem → świetlik podlatuje i leczy go dotykiem (zielony błysk). Przejmij świetlika (Possess): klik na rannego leczy w combat mode i bez, na każdej intencji. \
	2) Klauni chodzą, trąbią i gadają po polsku, nikogo nie atakują. Uderz jednego → wszyscy klauni w pobliżu biją napastnika. Honkuś wstrzykuje śmiech. \
	3) Żywy smar zostawia śliską podłogę, klaunan sam rozrzuca skórki od banana co kilka sekund. \
	4) Coś, co kiedyś było klaunem: słabe ciosy (nóż z siłą do 10) nic mu nie robią, mocniejsze ranią. \
	5) Gruczoł fugu na klaunie: klaun rośnie, ma więcej zdrowia, bije mocniej i rozrywa ściany. \
	6) Kij animacji: strzał w przedmiot ożywia go jako mimika, który nie atakuje strzelającego; strzał w laser daje mimika, który strzela."
	items = list(
		/mob/living/basic/lightgeist = 2,
		/mob/living/basic/clown = 1,
		/mob/living/basic/clown/banana = 1,
		/mob/living/basic/clown/honkling = 1,
		/mob/living/basic/clown/lube = 1,
		/mob/living/basic/clown/fleshclown = 1,
		/mob/living/basic/clown/mutant/glutton = 1,
		/obj/item/fugu_gland = 1,
		/obj/item/gun/magic/staff/animate = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/kitchen/knife = 1,
		/mob/living/carbon/human = 1,
	)
