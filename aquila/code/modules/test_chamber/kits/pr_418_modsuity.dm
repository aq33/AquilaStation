// aq33/AquilaStation#418 - MODsuity z BeeStation (+ proximity monitor i skan RCD)

/datum/test_chamber_kit/pr_418
	name = "PR 418: MODsuity i moduły"
	pr = "aq33/AquilaStation#418"
	description = "Załóż jednostkę sterującą na plecy, rozłóż części (panel albo przyciski akcji) i aktywuj - części się zamykają i zmieniają sprite. \
	W panelu TGUI włącz moduły i przypnij je do paska akcji. Luźne moduły włóż śrubokrętem przy otwartym panelu, wyjmij łomem. Farbą zmień wygląd (MODpaint). \
	Sprawdź: latarkę, jetpack, magnetyczne buty, wizjery (meson, medhud), magazyn, holster, kinesis (prawy/alt klik = akcja dodatkowa), zaczep, defibrylator. \
	Ninja: niewidzialność, hacker, przywołanie katany. Zbroja battlemage czarodzieja to zaczarowany MODsuit. Włóż pAI do kombinezonu - ma móc nim sterować."
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
		/obj/item/paicard = 1,
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_418_budowa
	name = "PR 418: MODsuit - budowa, SSU i skan RCD"
	pr = "aq33/AquilaStation#418"
	description = "Złóż MODsuit z części: na skorupę po kolei rdzeń, hełm, napierśnik, rękawice, buty i poszycie (kluczem i śrubokrętem między krokami). \
	Jednostka magazynowa (SSU) ma mieć w środku MODsuit inżynieryjny i go ładować. Fabrykator egzoszkieletów: kategorie „MOD Construction” i „MOD Modules”. \
	RCD: postaw ścianę, rozbierz ją, potem przycisk skanu RCD ma pokazać hologram zniszczonej ściany, a odbudowa ma być szybsza i tańsza."
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
