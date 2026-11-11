// aq33/AquilaStation#579 - trwała struktura statku (aquila/code/modules/persistence/ship_structure.dm)

/datum/test_chamber_kit/pr_579
	name = "Trwała struktura statku"
	pr = "aq33/AquilaStation#579"
	description = "Zmiany trzeba robić na samym statku, nie w komorze (komora nie leży na poziomie statku). \
	1) Na statku: zburz kilka ścian, w tym ścianę z alarmem albo interkomem i ścianę kadłuba do próżni, wybij okno przy kosmosie, postaw nową ścianę na polu z przedmiotem, połóż kabel i rurę, przepal albo połam kawałek podłogi. \
	Maszyny: rozbierz jedną maszynę albo działo, przenieś i przykręć automat lub konsolę w inne miejsce, obróć konsolę, zbuduj nową maszynę z ulepszonymi częściami. Usuń też ster albo konsolę komunikacyjną (maszyny krytyczne). \
	2) Admin > Server > Ship Structure: zapis po tej rundzie ma być TAK. Zakończ rundę zwykłym końcem rundy (nie twardym restartem). \
	3) Następna runda, ta sama mapa: ściany, okna, kable, rury i uszkodzenia podłogi wracają. Dziura w kadłubie i wybite okno są zalane pianką, alarm lub interkom wisi na sąsiedniej ścianie, przedmiot z nowej ściany leży obok. \
	Rozebrana maszyna nie wraca, przeniesiona stoi tam, gdzie ją zostawiono (bez dubla na starym miejscu), obrót i przykręcenie zostają, nowa i ulepszona maszyna ma swoje części. Wentylacja albo pompa obrócona przez załogę dalej jest podłączona do rur. Ster lub konsola komunikacyjna stoi na swoim miejscu z mapy. Przedmioty w szafkach i automatach są jak z mapy, a kroplówki i kanistry wracają na swoje miejsca. \
	Kanister albo inna gęsta rzecz z mapy, która stała tam, gdzie przeniesiono maszynę, stoi na sąsiednim polu. \
	4) Ship Structure pokazuje, ile pól odtworzono i ile pominięto. Skasuj zapis: kolejna runda zaczyna się na statku prosto z mapy. \
	Głosowanie: po końcu rundy w oknie głosowania na mapę jest panel „Statek w następnej rundzie”. Przewaga „Zacznij na nowym statku” kasuje zapis tej mapy przy restarcie (także gdy wygra inna mapa), remis albo brak głosów = „Kontynuuj granie na obecnym statku”. Stan głosów widać w Ship Structure. \
	5) Zniszczenie statku kasuje zapis (także przy wyłączonym zapisie rundy), a Twardy restart + nowa kampania kasuje zapisy wszystkich statków."
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
