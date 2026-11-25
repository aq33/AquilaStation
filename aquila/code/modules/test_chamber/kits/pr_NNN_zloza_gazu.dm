/datum/test_chamber_kit/pr_NNN
	name = "Maszynownia: złoża gazu i ekstraktor"
	pr = "aq33/AquilaStation#NNN"
	description = "Zestaw: dwa złoża gazu (wulkaniczne z plazmą i księżycowe z podtlenkiem azotu), na pierwszym gotowy ekstraktor gazu podłączony rurą do portu z pustym kanistrem, drugie wolne do budowy. Do tego płytka ekstraktora z częściami, kablem, plastalą i żelazem na ramę, pojemne ogniwo, RPD, georadarowy skaner górniczy, analizator i skrzynka z narzędziami. \
	1) Skaner przyłożony do złoża → klasa, łączna liczba moli i skład w procentach. Skaner w trybie podziemia wskazuje złoża jak żyły rudy. \
	2) Gotowy ekstraktor: włączenie ręką → syfon się zapala, kanister na porcie się napełnia (ok. 50 mol/s, analizator na kanistrze pokazuje plazmę, CO2 i czasem ślad trytu), a co 45 s wokół złoża otwierają się wyrwy z fauną planety wulkanicznej (trzy fale, potem przerwa). Oględziny ekstraktora pokazują stan, wydajność, gaz w złożu i ogniwo. \
	3) Komora ma zasilanie, więc ekstraktor bierze prąd z sieci. Wyjęcie ogniwa (śrubokręt, łom) nic nie zmienia; w obszarze bez zasilania (planeta) bez ogniwa staje ze stanem „brak zasilania” (negatyw). \
	4) Przy 4500 kPa w rurze staje ze stanem „rura pełna” i wyrwy przestają się otwierać; po zmianie kanistra rusza dalej. \
	5) Budowa: rama z żelaza na drugim złożu, kable, płytka, części, plastal, śrubokręt → ekstraktor na złożu. Przy otwartym panelu klucz obraca wylot, multitool na płytce zmienia warstwę rury. Rama poza złożem → ekstraktor ze stanem „brak złoża gazu pod spodem” (negatyw). \
	6) Wiertło rudy kluczem na złożu gazu → odmowa (negatyw). \
	7) Złoże wyczerpane → ekstraktor mówi, że się wyłącza, a złoże zapada się z hukiem. \
	8) Na planetach (zestaw planet z AQ#639): złoża gazu leżą na planecie wulkanicznej, lodowej, księżycu, polu asteroid, wysypisku i planecie skalistej; projekt płytki jest w węźle „Inżynieria przemysłowa”, a skrzynia „Ekstraktor gazu” w dziale inżynierii cargo."
	items = list(
		/obj/item/circuitboard/machine/gas_extractor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/plasteel/five = 1,
		/obj/item/stack/sheet/iron/ten = 1,
		/obj/item/stock_parts/cell/high = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/pinpointer/mineral = 1,
		/obj/item/analyzer = 1,
		/obj/item/storage/toolbox/mechanical = 1,
	)

/datum/test_chamber_kit/pr_NNN/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Złoże z ekstraktorem, a pole na południe od niego na port z kanistrem
	var/turf/extractor_turf
	var/turf/port_turf
	var/turf/free_vein_turf
	for(var/turf/open/T in turfs)
		if(is_blocked_turf(T, TRUE) || (locate(/obj/structure/vein) in T))
			continue
		var/turf/open/below = get_step(T, SOUTH)
		if(!extractor_turf && (below in turfs) && !is_blocked_turf(below, TRUE))
			extractor_turf = T
			port_turf = below
			continue
		if(extractor_turf && T != port_turf && get_dist(T, extractor_turf) > 2)
			free_vein_turf = T
			break
	if(!extractor_turf)
		return
	spawned += new /obj/structure/vein/gas/lava(extractor_turf)
	var/obj/machinery/atmospherics/components/unary/gas_extractor/extractor = new(extractor_turf, TRUE, SOUTH)
	extractor.on_construction()
	spawned += extractor
	var/obj/machinery/atmospherics/components/unary/portables_connector/visible/port = new(port_turf, TRUE, NORTH)
	port.on_construction(null, PIPING_LAYER_DEFAULT)
	spawned += port
	var/obj/machinery/portable_atmospherics/canister/canister = new(port_turf)
	canister.connect(port)
	spawned += canister
	if(free_vein_turf)
		spawned += new /obj/structure/vein/gas/moon(free_vein_turf)
