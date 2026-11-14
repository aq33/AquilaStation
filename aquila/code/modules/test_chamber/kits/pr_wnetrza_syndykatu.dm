/datum/test_chamber_kit/pr_wnetrza_syndykatu
	name = "Wnętrza Syndykatu: Barracuda, fregata przeciwlotnicza, Kadesh"
	pr = "aq33/AquilaStation (numer po założeniu PR)"
	description = "Jako admin zespawnuj na overmapie przy okręcie: /obj/structure/overmap/syndicate/ai/cruiser (Barracuda), /obj/structure/overmap/syndicate/ai/gunboat (fregata przeciwlotnicza) albo /obj/structure/overmap/syndicate/ai/kadesh. \
		Wnętrze wczytasz konsolą odzysku (zakłócanie celu) albo przez Call Proc ai_load_interior(główny okręt) na okręcie Syndykatu. \
		Sprawdź: wejście śluzą i dokowanie promem, czy każde pomieszczenie jest osiągalne, światło, KNPC chodzą po punktach patrolu, konsole na mostku i IFF działają. \
		Barracuda i Kadesh mają działo MAC z lufą przez dziób (wylot zamknięty grodzią), fregata ma hangar z wyrzutnią myśliwca od północy."
	items = list(
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 1,
		/obj/item/ammo_box/magazine/smgm45 = 2,
		/obj/item/flashlight/seclite = 1,
		/obj/item/multitool = 1,
	)
