// aq33/AquilaStation#577 - dźwięk przestrzenny: wygłuszanie przez ściany, pogłos z kształtu, śledzenie źródła (aquila/code/game/sound_occlusion.dm)

/datum/test_chamber_kit/pr_577
	name = "Dźwięk przestrzenny (ściany, pogłos, panorama)"
	pr = "aq33/AquilaStation#577"
	description = "Zestaw stawia ścianę z drzwiami 3 pola na wschód od środka areny, a obok kładzie pistolet z magazynkiem i trąbkę. Potrzebny drugi gracz albo opętany mob (Admin > Possess). \
	1) Niech druga osoba strzela albo trąbi za ścianą: dźwięk ma być cichszy i głuchy. \
	2) Otwórz drzwi: przez otwarte drzwi ma być czysto i głośno. \
	3) Stań 1-2 pola obok źródła: dźwięk wyraźnie z boku, ale słyszalny w obu uszach. \
	4) Przejdź obok źródła w trakcie dłuższego dźwięku: dźwięk przesuwa się z ucha do ucha. \
	5) Pogłos: strzał w małym pokoju, na korytarzu i w hangarze statku brzmi inaczej (komora ma własny obszar, tam pogłos jest ogólny). \
	6) Jako duch nic nie jest wygłuszone."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/bikehorn = 1,
	)

/datum/test_chamber_kit/pr_577/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!center)
		return
	// Ściana z północy na południe, drzwi pośrodku
	for(var/offset in -2 to 2)
		var/turf/T = locate(center.x + 3, center.y + offset, center.z)
		if(!(T in turfs))
			continue
		if(offset == 0)
			new /obj/machinery/door/airlock(T)
		else
			new /obj/structure/falsewall(T)
