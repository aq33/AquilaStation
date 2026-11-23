// Rework amunicji: kuźnia zamiast protolathe, typy AP/HE/APHE, rdzeń i powłoka, pakowarka, podgląd kuźni railguna,
// ustawianie pocisków multitoolem, ciężka rakieta MS-1

/datum/test_chamber_kit/pr_665
	name = "PR 665: rework amunicji"
	pr = "aq33/AquilaStation#665"
	description = "1) Piec łukowy (pełny zapas materiałów): w oknie wybierz „korpus pocisku artylerii”. Wybierz rdzeń (uran) i powłokę (srebro): okno pokazuje liczby rdzenia, efekty powłoki (EMP, srebrzysta) i koszt obu materiałów plus 2,5 tytanu i 0,25 miedzi. Przełącz typ AP, HE, APHE i patrz na obrażenia i przebicie. Odlej, wykuj pod młotem, połóż sam korpus na stole montażowym (bez zapalnika) i złóż: pocisk ma w nazwie materiał i typ. Badania Zaawansowana balistyka i Makrobalistyka są w zestawie odblokowane. 2) Części fabryczne: odlej „ładunki burtowe ×5”; piec od razu wyrzuca 5 ładunków, bez młota i stołu. 3) Pakowarka burtówek: włóż 5 łusek (fabryczne AP z zestawu albo odlane w piecu), 5 ładunków i worek prochu, spakuj: każdy pocisk ma typ i materiał swojej łuski. 4) Fabryczne pociski artylerii AP/HE/APHE z zestawu: examine bez klasy, analizator pokazuje typ. W cargo są paczki AP, HE i APHE. 5) Protolathe uzbrojenia: nie ma już pocisku artylerii, łusek ani ładunków burtowych; worki prochu i głowice zostały. 6) Multitool na obudowie rakiety: ustaw silnik sprint i naprowadzanie podczerwień. Złóż w niej rakietę: examine pokazuje ustawienie. 7) Głowica MS-1 w obudowie rakiety daje Sparrowhawka. Wtocz go do VLS na okręcie: zajmuje całą tubę, druga rakieta już nie wejdzie. 8) Kuźnia railguna na okręcie z railgunem hybrydowym: po wybraniu materiałów obu zbiorników okno pokazuje obrażenia pocisku i kanistru oraz ostrzeżenie przy parze słabszej niż zwykły pocisk (np. żelazo w żelazie). 9) Pancerz okrętów AI: examine okrętu AI na overmapie pokazuje klasę pancerza. Okno pieca i examine pocisku AP, HE albo APHE pokazują skuteczność przeciw klasom. Ostrzelaj ciężki okręt AI (np. krążownik Syndykatu) pociskami HE i AP: HE prawie nic nie robi, AP zadaje pełne obrażenia. Myśliwiec AI: HE pełne, AP przelatuje na wylot (35%). Okręt gracza trafiany przez AI liczy się jak dotąd."
	items = list(
		/obj/item/munitions_analyzer = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/factory = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/factory/ap = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/factory/he = 1,
		/obj/item/ship_weapon/parts/broadside_casing/factory/ap = 5,
		/obj/item/powder_bag = 1,
		/obj/item/ship_weapon/ammunition/missile/missile_casing = 2,
		/obj/item/ship_weapon/parts/missile/propulsion_system = 2,
		/obj/item/ship_weapon/parts/missile/guidance_system = 2,
		/obj/item/ship_weapon/parts/missile/iff_card = 2,
		/obj/item/ship_weapon/parts/missile/warhead = 1,
		/obj/item/ship_weapon/parts/missile/warhead/cruise = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/weldingtool/largetank = 1,
	)

/datum/test_chamber_kit/pr_665/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Maszyny wielokaflowe stawiamy osobno, żeby nie lądowały na sobie
	var/obj/machinery/munitions_forge/arc_forge/forge = new(locate(center.x - 4, center.y + 1, center.z))
	new /obj/machinery/munitions_forge/anvil(locate(center.x, center.y + 2, center.z))
	new /obj/machinery/munitions_forge/assembly_bench(locate(center.x + 2, center.y + 2, center.z))
	new /obj/machinery/broadside_shell_packer(locate(center.x + 3, center.y - 2, center.z))
	var/datum/component/material_container/container = forge.get_container()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		container?.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 50, M.material_type)
	for(var/node in list("adv_ballistics", "macro_ballistics"))
		SSresearch.science_tech?.research_node_id(node, TRUE, FALSE, FALSE)
