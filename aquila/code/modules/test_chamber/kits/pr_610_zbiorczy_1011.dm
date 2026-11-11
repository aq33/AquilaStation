/datum/test_chamber_kit/pr_610
	name = "Spray na hardsuitach, dźwięki, Beryl, Maggi i majonezy, blok i parowanie"
	pr = "aq33/AquilaStation#610"
	description = "1) Spray: zdejmij nakrętkę, wybierz jasny kolor i kliknij hardsuit z szafy (w ręce albo założony, przez slot w ekwipunku) → kombinezon i hełm mają ten sam kolor, a sprite na postaci zmienia się od razu. Załóż i zdejmij hełm → kolor zostaje. Prysznic zmywa kolor z obu części. Ciemny kolor spray odrzuca (negatyw). 2) Szafa na skafandry: otwórz i zamknij drzwi (osobne dźwięki), włącz dezynfekcję → start cyklu i skanowanie w pętli, na końcu sygnał i drzwi się otwierają. 3) Pisk: rzuć granat burzący i stań dokładnie 2 kratki od miejsca wybuchu (1 kratka = ciężkie obrażenia, 3 kratki = wybuch już nie sięga) → „W uszach mocno ci dzwoni!”, głuchota i pisk po huku. W nausznikach pisku nie ma (negatyw). 4) Dyszenie: sprintuj, aż pojawi się „Jesteś wyczerpany” → co kilka sekund ciężki oddech (męski albo żeński według płci). Po „Łapiesz oddech” cichnie. 5) Beryl ze zwykłą iglicą strzela poza abordażem; zwykły Beryl z iglicą abordażową odmawia (negatyw). Na Atlantisie zbrojownia ma same Beryle i magazynki 5.56. 6) Maggi nalewa po 1, 5 albo 10 j., smak lubczyku; oba majonezy działają w recepturach jak zwykły majonez. Wszystkie trzy są w automacie z zastawą. 7) Blok (potrzebny drugi gracz albo admin sterujący postacią, obiekt testowy sam nie bije): włącz tryb walki, weź szablę (oficerską albo jonową, ta także wyłączona) do aktywnej ręki i stań przodem do atakującego → błysk tarczy, „blok!” nad głową i brzęk. Drugi cios zaraz po nim przechodzi (2 s przerwy, tarcza jej nie ma). Szabla czasem kontratakuje, laska bo czasem przewraca atakującego. Miecz dwuostrzowy przechodzi przez blok szabli, a gaśnica nie blokuje wcale (negatywy). 8) Parowanie: z kataną w aktywnej ręce wciśnij Spację → świst, zamach i „paruję”; za szybko drugi raz → „za szybko”. Cios w ciągu ok. 1 s: błysk i „parowanie!” albo złote „idealne parowanie!”, z każdej strony i bez trybu walki. Po 1 s okno mija (negatyw). Ze skrzynką w aktywnej ręce, z toporem strażackim w jednej ręce albo z wyłączonym mieczem energetycznym Spacja włącza tryb rzucania. Tarcza w drugiej ręce paruje tylko przy pustej aktywnej ręce. Poza komorą: reconnect (zakończ rundę, gra sama łączy po starcie serwera) i bracia krwi w trybie zdrajcy (admin wymusza traitor przy kilku graczach z preferencjami zdrajcy i brata; z szansą 25% dwóch zdrajców zostaje braćmi krwi, nigdy jako SI)."
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
