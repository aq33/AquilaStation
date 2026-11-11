/datum/test_chamber_kit/pr_610
	name = "Spray na hardsuitach, dźwięki, Beryl, Maggi i majonezy, blok i parowanie"
	pr = "aq33/AquilaStation#610"
	description = "1) Spray: zdejmij nakrętkę, wybierz jasny kolor i kliknij hardsuit z szafy (w ręce albo założony, przez slot w ekwipunku) → kombinezon i hełm mają ten sam kolor, a sprite na postaci zmienia się od razu, bez zdejmowania. Załóż hełm i zdejmij → kolor zostaje. Umyj w prysznicu → kolor schodzi z obu części. Ciemny kolor spray odrzuca (negatyw). \
	2) Szafa na skafandry: otwórz i zamknij drzwi (osobne dźwięki), włącz dezynfekcję → start cyklu i skanowanie w pętli, na końcu sygnał i drzwi się otwierają. \
	3) Pisk: odbezpiecz granat burzący, rzuć go i stań dokładnie 2 kratki od miejsca wybuchu (1 kratka = ciężkie obrażenia, 3 kratki = wybuch już nie sięga) → „W uszach mocno ci dzwoni!”, głuchota i pisk po huku. W nausznikach pisku nie ma (negatyw). \
	4) Dyszenie: sprintuj, aż pojawi się „Jesteś wyczerpany” → co kilka sekund ciężki oddech (męski albo żeński według płci). Po „Łapiesz oddech” cichnie. \
	5) Beryl ze zwykłą iglicą strzela poza abordażem; zwykły Beryl z iglicą abordażową odmawia (negatyw). Na Atlantisie zbrojownia ma same Beryle i magazynki 5.56. \
	6) Maggi nalewa po 1, 5 albo 10 j., smak lubczyku; oba majonezy dają zwykły majonez (działa w recepturach). Wszystkie trzy są w automacie z zastawą. \n	7) Blok (potrzebny drugi gracz albo admin sterujący postacią, obiekt testowy sam nie bije): włącz tryb walki, weź szablę do aktywnej ręki i stań przodem do atakującego → udany blok: błysk tarczy na tobie, napis „blok!” nad głową i brzęk. Drugi cios zaraz po nim przechodzi (2 s przerwy, tarcza jej nie ma). Szabla po bloku czasem kontratakuje, laska bo czasem przewraca atakującego. Szabla jonowa MK-1 blokuje i paruje tak samo, także wyłączona. Miecz dwuostrzowy przechodzi przez blok szabli (negatyw), gaśnica w ręce nie blokuje wcale (negatyw). 	8) Parowanie: z kataną w ręce wciśnij Spację → świst, zamach i „paruję” nad głową; zbyt szybko drugi raz → „za szybko”. Gdy cios trafi w ciągu ok. 1 s: błysk, „parowanie!” albo złote „idealne parowanie!” i brzęk, z każdej strony i bez trybu walki. Po 1 s okno mija (negatyw). Topór strażacki trzymany jedną ręką → „chwyć oburącz”, miecz energetyczny wyłączony → „włącz broń”. Ze skrzynką w ręce Spacja działa jak dawniej (tryb rzucania). 	Poza komorą: reconnect (zakończ rundę, gra sama łączy po starcie serwera) i bracia krwi w trybie zdrajcy (admin wymusza traitor przy kilku graczach z preferencjami zdrajcy i brata; z szansą 25% dwóch zdrajców dostaje braci krwi)."
	items = list(
		/obj/machinery/suit_storage_unit/engine = 1,
		/obj/item/toy/crayon/spraycan = 1,
		/obj/item/grenade/syndieminibomb/concussion = 1,
		/obj/item/clothing/ears/earmuffs = 1,
		/obj/item/gun/ballistic/automatic/marine_rifle/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/marine_rifle = 1,
		/obj/item/ammo_box/magazine/m556 = 2,
		/obj/item/reagent_containers/food/condiment/maggi = 1,
		/obj/item/reagent_containers/food/condiment/mayonnaise/kielecki = 1,
		/obj/item/reagent_containers/food/condiment/mayonnaise/winiary = 1,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/melee/sabre = 1,
		/obj/item/melee/classic_baton/telescopic/stunsword = 1,
		/obj/item/katana = 1,
		/obj/item/staff/bostaff = 1,
		/obj/item/dualsaber = 1,
		/obj/item/fireaxe = 1,
		/obj/item/storage/toolbox/mechanical = 1,
	)
