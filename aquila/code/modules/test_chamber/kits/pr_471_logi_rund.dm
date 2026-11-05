/datum/test_chamber_kit/pr_471
	name = "PR 471: poprawki z logów rund"
	pr = "aq33/AquilaStation#471"
	description = "Kroki 1-8 mają widoczny efekt w grze, kroki 9-10 da się ocenić tylko po wpisach w logach (runtime.log, qdel.log). \
		1) Zlewka i skrzynka z narzędziami: VV obj_integrity → oczekiwane: wartość większa od 0; granat z zestawu rzucony obok → oczekiwane: zlewka i skrzynka da się zniszczyć. \
		2) Kroplówka: kliknij ją pustą ręką → oczekiwane: tryb (wstrzykiwanie/pobieranie) się przełącza, z komunikatem. \
		3) Recykler: wsyp rzeczy do worka na śmieci i wrzuć worek na recykler → oczekiwane: zawartość nie wraca na kafel. Potem emaguj recykler kartą emag z zestawu i powtórz → oczekiwane: tak samo. \
		4) Experimentor: włóż do niego zlewkę → oczekiwane: okno pokazuje dane wzmocnienia włożonego przedmiotu (nie samej maszyny). \
		5) Różdżka ognistej kuli: strzel → oczekiwane: leci kula ognia. Kromka + kotlet → oczekiwane: powstaje kanapka. Mikrofala: prawy klik → oczekiwane: reaguje bez błędu. \
		6) Pomódl się (menu modlitwy) → oczekiwane: admin dostaje wiadomość z modlitwą. \
		7) Menu kołowe: weź skrzynkę z narzędziami do jednej ręki (druga pusta) i kliknij przedmiot → oczekiwane: pojawia się menu narzędzi; otwórz i zamknij je kilka razy. \
		8) Larwa ksenomorfa: poklikaj ją i uderz → oczekiwane: żyje i reaguje normalnie. \
		9) Tylko log: po krokach 5, 7 i 8 w runtime.log nie ma nowych wpisów (null.species, spell_level, radial/slice). \
		10) Tylko log: spryskaj kilka razy spryskiwaczem i po kilku minutach sprawdź qdel.log pod kątem GC move_towards_budget; wynik nie jest ustalony."
	items = list(
		/obj/item/reagent_containers/glass/beaker/large = 2,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/grenade/syndieminibomb/concussion = 1,
		/obj/machinery/iv_drip = 1,
		/obj/machinery/recycler = 1,
		/obj/item/storage/bag/trash = 1,
		/obj/machinery/rnd/experimentor = 1,
		/obj/item/gun/magic/wand/fireball = 1,
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/meat/cutlet/plain = 1,
		/obj/machinery/microwave = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/mob/living/carbon/alien/larva = 1,
		/obj/item/card/emag = 1,
	)
