/datum/test_chamber_kit/pr_471
	name = "PR 471: poprawki z logów rund"
	pr = "aq33/AquilaStation#471"
	description = "Zlewka/toolbox: VV obj_integrity ma być > 0, granat obok ma je niszczyć. Kroplówka: kliknij pustą ręką, tryb ma się przełączyć. \
	Recykler: włóż worek z rzeczami (emaguj albo zwykły), zawartość nie może wracać na kafel. Experimentor: włóż przedmiot, okno pokazuje dane wzmocnienia. \
	Różdżka ognistej kuli strzela bez runtime'u. Kromka + kotlet = kanapka bez runtime'u. Mikrofala na prawy klik. Larwa: brak runtime'u null.species. \
	Spryskiwacz: psiknij kilka razy i po 5 min sprawdź runtime.log (GC move_towards_budget – nieustalone). Pomódl się – admin ma dostać wiadomość. \
	Menu radialne (np. Alt-klik na przedmiotach z radialem) wielokrotnie – brak GC-faili radial/slice w runtime.log."
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
	)
