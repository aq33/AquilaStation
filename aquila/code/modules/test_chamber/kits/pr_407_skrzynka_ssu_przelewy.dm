// aq33/AquilaStation#407 - skrzynka z narzędziami z radialem, SSU z radialem, przelewy budżetów, TAB po kanałach radia, ERT z Bee

/datum/test_chamber_kit/pr_407
	name = "PR 407: skrzynka z narzędziami i SSU"
	pr = "aq33/AquilaStation#407"
	description = "Skrzynka: kliknij skrzynką płytkę podłogi albo drzwi (nie harm) - radial z narzędziami, wybrane ląduje w drugiej ręce, zostaje użyte i wraca do skrzynki. \
	Spawarka sama się włącza i wyłącza. Na stole skrzynka ma się zwyczajnie odkładać. \
	SSU: zamiast okna radial - zamknięta: otwórz/dezynfekuj/zablokuj, zablokowana: odblokuj, otwarta: zamknij + sloty (puste czerwone). Inżynieryjne SSU ma w schowku buty magnetyczne. \
	TAB w oknie czatu: Say -> Radio -> kanały z twoich słuchawek -> Me (bez OOC/LOOC). \
	ERT: Secrets -> Make ERT - nowe opcje (doświadczony lider, losowe imiona, oficer odprawy), łowcy nagród CentComu, stażyści, oficjel jako rola ERT, mindshield dla wszystkich."
	items = list(
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/storage/toolbox/electrical = 1,
		/obj/machinery/door/airlock = 1,
		/obj/structure/table = 1,
		/obj/machinery/suit_storage_unit/engine = 1,
		/obj/machinery/suit_storage_unit/standard_unit = 1,
	)

/datum/test_chamber_kit/pr_407_budget
	name = "PR 407: przelewy z kart budżetowych"
	pr = "aq33/AquilaStation#407"
	description = "Alt-klik na karcie budżetowej: wybierz departament z listy z saldami, wpisz kwotę - obie karty dostają komunikat, przelew w log_game. \
	UWAGA: to prawdziwe budżety działów w rundzie - przelewaj małe kwoty i oddaj je. Wypłata gotówki ma być wyłączona (chyba że ktoś włączył ALLOW_BUDGET_MONEY_WITHDRAWAL)."
	items = list(
		/obj/item/card/id/departmental_budget/eng = 1,
		/obj/item/card/id/departmental_budget/sci = 1,
		/obj/item/card/id/departmental_budget/car = 1,
	)
