// aq33/AquilaStation#418 - moduły MODsuitów z BeeStation (+ proximity monitor i skan RCD). MODsuity usunięto, moduły działają w hardsuitach.

/datum/test_chamber_kit/pr_418
	name = "PR 418: hardsuity z modułami"
	pr = "aq33/AquilaStation#418"
	description = "1) Załóż inżynieryjny hardsuit z modułami i hełm (przycisk akcji) → oczekiwane: na pasku akcje panelu, wyboru modułu i „Wbudowana butla”, w panelu (TGUI) lista modułów i ładunek ogniwa. \
	2) Włącz moduły z panelu albo radialem → oczekiwane: latarka, magnetyczne buty, wizjery (meson, medhud), magazyn, holster, lina i defibrylator robią to, co w opisie, a ładunek ogniwa spada, gdy moduł jest aktywny. \
	3) Zdejmij kombinezon, włóż luźny moduł ręką (klik modułem w kombinezon), wyjmij go łomem (wybór z listy) → oczekiwane: moduł wchodzi i wychodzi. Negatyw: w noszony kombinezon moduł nie wchodzi („najpierw zdejmij kombinezon!”). \
	4) Wbudowana butla: w hełmie włącz „Wbudowana butla” i wyjdź w próżnię → oczekiwane: oddychasz bez maski. Negatyw: bez hełmu i maski → „potrzebny hełm albo maska!”. Butla tlenowa użyta na zdjętym kombinezonie napełnia wbudowaną. \
	5) Ninja: niewidzialność, hacker, przywołanie katany. Zbroja maga bitewnego: tarcza i niwelator magii. \
	6) Negatyw: do pustego hardsuitu (bez modułów) wkładaj po kolei luźne moduły → oczekiwane: w końcu „przekroczona maksymalna złożoność!”, moduł nie wchodzi (limit 15). \
	7) Negatyw: pusty hardsuit ma rozładowane ogniwo → oczekiwane: moduły się nie włączają. Po wyjęciu rdzenia łomem i założeniu kombinezonu z modułem → alert „brak rdzenia”."
	items = list(
		/obj/item/clothing/suit/space/hardsuit/engine/loaded = 1,
		/obj/item/clothing/suit/space/hardsuit/medical/loaded = 1,
		/obj/item/clothing/suit/space/hardsuit/security/head_of_security/loaded = 1,
		/obj/item/clothing/suit/space/hardsuit/ninja = 1,
		/obj/item/energy_katana = 1,
		/obj/item/clothing/suit/space/hardsuit/wizard/battlemage = 1,
		/obj/item/clothing/suit/space/hardsuit = 1,
		/obj/item/mod/module/flashlight = 1,
		/obj/item/mod/module/magboot = 1,
		/obj/item/mod/module/visor/meson = 1,
		/obj/item/mod/module/visor/medhud = 1,
		/obj/item/mod/module/storage/large_capacity = 1,
		/obj/item/mod/module/holster = 1,
		/obj/item/mod/module/tether = 1,
		/obj/item/mod/module/defibrillator = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/crowbar = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_418/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/clothing/suit/space/hardsuit/empty_suit in spawned)
		if(empty_suit.type != /obj/item/clothing/suit/space/hardsuit)
			continue
		// Rozładowane ogniwo do kroku negatywnego (moduły bez ładunku)
		var/obj/item/stock_parts/cell/cell = empty_suit.get_charge_source()
		if(istype(cell))
			cell.charge = 0
		break

/datum/test_chamber_kit/pr_418_budowa
	name = "PR 418: hardsuit w szafie, fabrykator modułów i skan RCD"
	pr = "aq33/AquilaStation#418"
	description = "1) Szafa na skafandry (inżynieryjna) ma w środku hardsuit z modułami, z rozładowanym ogniwem i pustą wbudowaną butlą. Zamknij szafę i odczekaj chwilę → oczekiwane: po otwarciu oględziny kombinezonu pokazują rosnący ładunek i pełną butlę. Negatyw: przy otwartej szafie nic się nie ładuje. \
	2) Fabrykator egzoszkieletów (ma wsadzone materiały i odblokowane projekty modułów): kategoria „MOD Modules” → oczekiwane: da się wydrukować moduły. \
	3) RCD: postaw ścianę, rozbierz ją, potem przycisk skanu RCD → oczekiwane: hologram zniszczonej ściany, a odbudowa jest szybsza i tańsza."
	items = list(
		/obj/machinery/suit_storage_unit/engine = 1,
		/obj/machinery/modular_fabricator/exosuit_fab = 1,
		/obj/item/construction/rcd/loaded = 1,
	)

/datum/test_chamber_kit/pr_418_budowa/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/machinery/suit_storage_unit/unit in spawned)
		// Rozładowany kombinezon w szafie, żeby było widać ładowanie i uzupełnianie tlenu
		var/obj/item/clothing/suit/space/hardsuit/stored_suit = unit.suit
		if(!istype(stored_suit))
			continue
		var/obj/item/stock_parts/cell/cell = stored_suit.get_charge_source()
		if(istype(cell))
			cell.charge = 0
		stored_suit.integrated_tank?.air_contents.set_moles(GAS_O2, 0)
	for(var/obj/machinery/modular_fabricator/exosuit_fab/fab in spawned)
		// Projekty modułów (reszta fabrykatora zostaje bez zmian) i materiały na kilka druków
		if(fab.stored_research)
			for(var/design_id in SSresearch.techweb_designs)
				var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
				if((design.build_type & MECHFAB) && ("MOD Modules" in design.category))
					fab.stored_research.add_design_by_id(design_id)
		var/datum/component/material_container/materials = fab.get_material_container()
		if(materials)
			materials.insert_amount_mat(40000, /datum/material/iron)
			materials.insert_amount_mat(10000, /datum/material/glass)
			materials.insert_amount_mat(7500, /datum/material/plasma)
			materials.insert_amount_mat(5000, /datum/material/gold)
			materials.insert_amount_mat(5000, /datum/material/silver)
			materials.insert_amount_mat(5000, /datum/material/diamond)
			materials.insert_amount_mat(5000, /datum/material/uranium)
			materials.insert_amount_mat(5000, /datum/material/titanium)
		break
