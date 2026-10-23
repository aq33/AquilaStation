/datum/test_chamber_kit/pr_487
	name = "PR 487: rynek ekstraktów i kompresor szlamów"
	pr = "aq33/AquilaStation#487"
	description = "Sprzedaj ekstrakty z torby na padzie rynku: cena sprzedanego koloru ma spaść, inne mają lekko wzrosnąć (konsola rynku, zakładka Ceny). \
	Kup coś w sklepie za 10000 punktów doliczonych przez zestaw. Pad zamówień: zamów ekstrakt kartą, włóż taki ekstrakt do padu rynku (wybierz zamówienie), odbierz pudełko kartą. \
	Kompresor: kliknij, wybierz burning i blue, przeciągnij na niego dorosłego niebieskiego i dwa dorosłe pomarańczowe szlamy. Po 40 s ma wypaść burning blue. Młody szlam i zły kolor mają być odrzucone. \
	Strzykawka losowej mutacji zmienia kolor szlama."
	items = list(
		/obj/machinery/slime_market_pad = 1,
		/obj/machinery/computer/slime_market = 1,
		/obj/machinery/slime_extract_requestor = 1,
		/obj/machinery/slime_compressor = 1,
		/obj/item/slime_mutation_syringe/random_color = 1,
		/obj/item/slime_scanner = 1,
	)

/datum/test_chamber_kit/pr_487/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]
	var/obj/item/storage/bag/bio/bag = new(drop) // tu, bo test komory liczy podtypy z items
	for(var/extract_type in list(/obj/item/slime_extract/grey, /obj/item/slime_extract/grey, /obj/item/slime_extract/grey, /obj/item/slime_extract/orange, /obj/item/slime_extract/gold))
		new extract_type(bag)
	new /mob/living/simple_animal/slime(drop, "blue", TRUE)
	new /mob/living/simple_animal/slime(drop, "orange", TRUE)
	new /mob/living/simple_animal/slime(drop, "orange", TRUE)
	new /mob/living/simple_animal/slime(drop, "orange", FALSE)
	for(var/mob/living/simple_animal/slime/slime in drop)
		slime.docile = TRUE
	GLOB.slime_market.points += 10000
	var/obj/machinery/computer/slime_market/console = locate() in spawned
	var/obj/machinery/slime_extract_requestor/request_pad = locate() in spawned
	if(console && request_pad)
		request_pad.link_console(console)
