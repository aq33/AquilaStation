// aq33/AquilaStation#577 - dźwięk przestrzenny: wygłuszanie przez ściany, pogłos, śledzenie źródła, szum maszyn (aquila/code/game/sound_occlusion.dm, aquila/code/controllers/subsystem/ambient_emitters.dm)

/datum/test_chamber_kit/pr_577
	name = "Dźwięk przestrzenny (ściany, drzwi, pogłos, szum maszyn)"
	pr = "aq33/AquilaStation#577"
	description = "Zestaw stawia 3 pola na wschód od środka areny ścianę z drzwiami na środku i drugimi drzwiami 2 pola wyżej, kładzie pistolet z magazynkiem, trąbkę, hełm kosmiczny i automat z napojami. Potrzebny drugi gracz albo opętany mob (Admin > Possess). \
	1) Niech druga osoba strzela albo trąbi za ścianą: dźwięk ma być cichszy i głuchy. \
	2) Otwórz drzwi: przez otwarte drzwi ma być czysto. Gdy otwarte są tylko boczne drzwi, strzał ma dochodzić od ich strony i być mniej stłumiony niż przez samą ścianę. \
	3) Stań 1-2 pola obok źródła: dźwięk wyraźnie z boku, ale słyszalny w obu uszach. Przejdź obok w trakcie dłuższego dźwięku: ma się przesuwać. \
	4) Automat szumi z 4 pól, coraz ciszej z odległością i prawie wcale za ścianą (wymaga włączonych dźwięków statku w preferencjach). \
	5) Załóż hełm kosmiczny: wszystko słychać przytłumione. \
	6) Mowa zza ściany: słychać mamrotanie, ale nie tekst. \
	7) Strzał z daleka (ponad 10 pól) brzmi głucho nawet bez ściany. Pogłos: mały pokój, korytarz i hangar statku brzmią inaczej (komora ma ogólny pogłos). \
	8) Jako duch nic nie jest wygłuszone."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/bikehorn = 1,
		/obj/item/clothing/head/helmet/space = 1,
		/obj/machinery/vending/cola = 1,
	)

/datum/test_chamber_kit/pr_577/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!center)
		return
	// Ściana z północy na południe: drzwi na wprost i boczne drzwi do obejścia
	for(var/offset in -3 to 3)
		var/turf/T = locate(center.x + 3, center.y + offset, center.z)
		if(!(T in turfs))
			continue
		if(offset == 0 || offset == 2)
			new /obj/machinery/door/airlock(T)
		else
			new /obj/structure/falsewall(T)
