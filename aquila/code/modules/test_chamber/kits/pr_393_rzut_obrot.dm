// aq33/AquilaStation#393 - port Yogstation#12789: obrót i rozrzut rzuconych przedmiotów

/datum/test_chamber_kit/pr_393
	name = "PR 393: obrót rzuconych przedmiotów"
	pr = "aq33/AquilaStation#393"
	description = "Rzucaj przedmiotami: mają lądować obrócone o 90/180 stopni i przesunięte do 12 px, a po podniesieniu (ręka, plecak) obrót ma znikać. \
	Przedmiot złapany w locie nie obraca się w ręce. Strzel z pistoletu w ścianę - łuski mają leżeć pod dowolnym kątem. Rzuć butelką/kartonikiem w ścianę - rozbita butelka obrócona, \
	odłamki szkła też. Załóż gogle barmana (beer goggles) i rzuć pełną szklanką na stół - ma wylądować prosto, bez rozlania."
	items = list(
		/obj/item/storage/box/donkpockets = 2,
		/obj/item/screwdriver = 3,
		/obj/item/wrench = 2,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 2,
		/obj/item/reagent_containers/food/drinks/sillycup/smallcarton = 2,
		/obj/item/shard = 3,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 3,
		/obj/item/clothing/glasses/sunglasses/advanced/reagent = 1,
		/obj/structure/table = 2,
	)

/datum/test_chamber_kit/pr_393/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/reagent_containers/food/drinks/drinkingglass/glass in spawned)
		glass.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, 20)
