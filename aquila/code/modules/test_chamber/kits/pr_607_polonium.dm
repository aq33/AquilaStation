// aq33/AquilaStation#607 - polska broń, jedzenie i szyld z Polonium Station

/datum/test_chamber_kit/pr_607_polonium
	name = "Polonium: VIS, Alexis-BOR, kabanosy, parówki, Żabka Cafe"
	pr = "aq33/AquilaStation#607"
	description = "1) Broń: VIS MPS (ochrona i cywilny) w ręce i na pasku, strzel aż do pustego magazynka (odsunięty zamek), przeładuj, zmień tryb ognia. Makarow, pistolet kolekcjonerski i Winona mają stare sprite'y. Alexis-BOR: w rękach, na plecach, z magazynkiem i bez, celownik. \
	2) Jedzenie: kabanosy z automatu z przekąskami (zostaje opakowanie). Z mięsa i kartki ulep pęto parówek, pokrój je nożem na stole na 4 parówki, zrób hot doga (bułka, parówka, keczup). Dla ćmy: ćmoparówka z kawałka tkaniny i ćmodog (bułka, ćmoparówka, keczup), ćma je chętnie. \
	3) Szyldy: kliknij szyld baru z zapasowym ID kapitana w ręce i wybierz Żabka Cafe (animacja)."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol/glock/security = 1,
		/obj/item/gun/ballistic/automatic/pistol/glock = 1,
		/obj/item/gun/ballistic/automatic/pistol/glock/makarov = 1,
		/obj/item/gun/ballistic/automatic/pistol/glock/command = 1,
		/obj/item/ammo_box/magazine/glock/lethal = 2,
		/obj/item/gun/ballistic/automatic/sniper_rifle = 1,
		/obj/item/ammo_box/magazine/sniper_rounds = 1,
		/obj/machinery/vending/snack = 1,
		/obj/item/food/meat/slab = 2,
		/obj/item/paper = 2,
		/obj/item/stack/sheet/cotton/cloth/ten = 1,
		/obj/item/food/bun = 2,
		/obj/item/reagent_containers/food/condiment/ketchup = 1,
		/obj/item/kitchen/knife = 1,
		/obj/structure/table = 1,
		/obj/structure/sign/barsign = 1,
		/obj/item/card/id/captains_spare = 1,
	)
