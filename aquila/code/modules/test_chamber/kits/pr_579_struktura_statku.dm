// aq33/AquilaStation#579 - trwała struktura statku (aquila/code/modules/persistence/ship_structure.dm)

/datum/test_chamber_kit/pr_579
	name = "Trwała struktura statku"
	pr = "aq33/AquilaStation#579"
	description = "Zmiany trzeba robić na samym statku, nie w komorze (komora nie leży na poziomie statku). \
	1) Na statku: zburz kilka ścian, w tym ścianę z alarmem albo interkomem i ścianę kadłuba do próżni, wybij okno przy kosmosie, postaw nową ścianę na polu z przedmiotem, połóż kabel i rurę, przepal albo połam kawałek podłogi. \
	2) Admin > Server > Ship Structure: zapis po tej rundzie ma być TAK. Zakończ rundę zwykłym końcem rundy (nie twardym restartem). \
	3) Następna runda, ta sama mapa: ściany, okna, kable, rury i uszkodzenia podłogi wracają, przedmioty i maszyny są jak z mapy. Dziura w kadłubie i wybite okno są zalane pianką, alarm lub interkom wisi na sąsiedniej ścianie, przedmiot z nowej ściany leży obok. \
	4) Ship Structure pokazuje, ile pól odtworzono i ile pominięto. Skasuj zapis: kolejna runda zaczyna się na statku prosto z mapy. \
	5) Zniszczenie statku albo Twardy restart + nowa kampania też kasuje zapis."
	items = list(
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/weldingtool/experimental = 1,
		/obj/item/crowbar = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wirecutters = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/rods/fifty = 1,
		/obj/item/grenade/chem_grenade/metalfoam = 2,
	)
