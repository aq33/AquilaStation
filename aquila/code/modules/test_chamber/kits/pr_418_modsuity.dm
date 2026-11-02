// aq33/AquilaStation#418 - MODsuity z BeeStation (+ proximity monitor i skan RCD)

/datum/test_chamber_kit/pr_418
	name = "PR 418: MODsuity i moduły"
	pr = "aq33/AquilaStation#418"
	description = "1) Załóż jednostkę sterującą na plecy, rozłóż części (panel albo przyciski akcji) i aktywuj → oczekiwane: części się zamykają i zmieniają sprite. \
	2) W panelu TGUI włącz moduły i przypnij je do paska akcji → oczekiwane: przyciski modułów na pasku. Luźne moduły włóż śrubokrętem przy otwartym panelu, wyjmij łomem. Farbą zmień wygląd (MODpaint). \
	3) Sprawdź: latarkę, jetpack, magnetyczne buty, wizjery (meson, medhud), magazyn, holster, kinesis (prawy/alt klik = akcja dodatkowa), zaczep, defibrylator → oczekiwane: każdy moduł robi to, co w opisie. \
	4) Ninja: niewidzialność, hacker, przywołanie katany. Zbroja battlemage czarodzieja to zaczarowany MODsuit. \
	5) pAI (jest w zestawie, z umysłem): włóż kartę pAI do kombinezonu → oczekiwane: pAI zostaje w jednostce i może nim sterować. \
	6) Negatyw: do pustego MODsuita (ten bez modułów) włóż po kolei wszystkie luźne moduły → oczekiwane: w końcu komunikat „przekroczona maksymalna złożoność!”, moduł nie wchodzi (limit 15). \
	7) Negatyw: pusty MODsuit ma rozładowany rdzeń → oczekiwane: aktywacja nie działa (brak ładunku), po wyjęciu rdzenia (łom przy otwartej pokrywie) komunikat „brak rdzenia”."
	items = list(
		/obj/item/mod/control/pre_equipped/engineering = 1,
		/obj/item/mod/control/pre_equipped/medical = 1,
		/obj/item/mod/control/pre_equipped/security = 1,
		/obj/item/mod/control/pre_equipped/safeguard = 1,
		/obj/item/mod/control/pre_equipped/ninja = 1,
		/obj/item/energy_katana = 1,
		/obj/item/mod/control/pre_equipped/enchanted = 1,
		/obj/item/mod/control/pre_equipped/empty = 1,
		/obj/item/mod/module/flashlight = 1,
		/obj/item/mod/module/jetpack = 1,
		/obj/item/mod/module/magboot = 1,
		/obj/item/mod/module/visor/meson = 1,
		/obj/item/mod/module/visor/medhud = 1,
		/obj/item/mod/module/storage/large_capacity = 1,
		/obj/item/mod/module/holster = 1,
		/obj/item/mod/module/anomaly_locked/kinesis/prebuilt = 1,
		/obj/item/mod/module/tether = 1,
		/obj/item/mod/module/defibrillator = 1,
		/obj/item/mod/paint = 1,
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_418/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/mod/control/pre_equipped/empty/empty_suit in spawned)
		// Rozładowany rdzeń do kroku negatywnego (aktywacja bez ładunku)
		var/obj/item/mod/core/standard/standard_core = empty_suit.core
		if(istype(standard_core) && standard_core.cell)
			standard_core.cell.charge = 0
		// Karta pAI z umysłem, bo bez niego kombinezon odrzuca pAI („pAI nie reaguje”)
		var/turf/suit_turf = get_turf(empty_suit)
		var/obj/item/paicard/card = new(suit_turf)
		var/mob/living/silicon/pai/pai = new(card)
		pai.name = "pAI testowe"
		pai.real_name = pai.name
		pai.mind_initialize()
		card.setPersonality(pai)
		break

/datum/test_chamber_kit/pr_418_budowa
	name = "PR 418: MODsuit - budowa, SSU i skan RCD"
	pr = "aq33/AquilaStation#418"
	description = "1) Złóż MODsuit z części: na skorupę po kolei rdzeń, hełm, napierśnik, rękawice, buty i poszycie (kluczem i śrubokrętem między krokami) → oczekiwane: gotowy MODsuit inżynieryjny. Negatyw: część przyłożona poza kolejnością (np. hełm przed rdzeniem) nie przyjmie się. \
	2) Jednostka magazynowa (SSU) → oczekiwane: ma w środku MODsuit inżynieryjny i go ładuje. \
	3) Fabrykator egzoszkieletów (ma wsadzone materiały, odblokowane projekty MOD): kategorie „MOD Construction” i „MOD Modules” → oczekiwane: da się wydrukować skorupę, hełm i moduły. Negatyw: skorupa dwa razy pod rząd → materiały się kończą (plazma) i drugi druk nie wystartuje. \
	4) RCD: postaw ścianę, rozbierz ją, potem przycisk skanu RCD → oczekiwane: hologram zniszczonej ściany, a odbudowa jest szybsza i tańsza."
	items = list(
		/obj/item/mod/construction/shell = 1,
		/obj/item/mod/core/standard = 1,
		/obj/item/mod/construction/helmet = 1,
		/obj/item/mod/construction/chestplate = 1,
		/obj/item/mod/construction/gauntlets = 1,
		/obj/item/mod/construction/boots = 1,
		/obj/item/mod/construction/plating/engineering = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/machinery/suit_storage_unit/engine = 1,
		/obj/machinery/modular_fabricator/exosuit_fab = 1,
		/obj/item/construction/rcd/loaded = 1,
	)

/datum/test_chamber_kit/pr_418_budowa/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/machinery/modular_fabricator/exosuit_fab/fab in spawned)
		// Projekty MOD (reszta fabrykatora zostaje bez zmian) i materiały na kilka druków
		if(fab.stored_research)
			for(var/design_id in SSresearch.techweb_designs)
				var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
				if((design.build_type & MECHFAB) && (("MOD Construction" in design.category) || ("MOD Modules" in design.category)))
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
