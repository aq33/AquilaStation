// aq33/AquilaStation#407 - skrzynka z narzędziami z radialem, SSU z radialem, przelewy budżetów, TAB po kanałach radia, ERT z Bee

/datum/test_chamber_kit/pr_407
	name = "PR 407: skrzynka z narzędziami i SSU"
	pr = "aq33/AquilaStation#407"
	description = "1) Kliknij skrzynką (bez trybu walki) płytkę podłogi albo drzwi → oczekiwane: radial z narzędziami; wybrane ląduje w drugiej ręce, zostaje użyte i wraca do skrzynki. Spawarka sama się włącza i wyłącza. \
	2) Kliknij skrzynką stół → oczekiwane: skrzynka zwyczajnie się odkłada, bez radiala. \
	3) Standardowe SSU (ma w środku skafander, hełm i maskę): kliknij zamkniętą → radial otwórz/dezynfekuj/zablokuj; po zablokowaniu → radial z samym odblokowaniem; otwartą → zamknij + sloty, z których wyjmiesz skafander/hełm do ręki. \
	4) Inżynieryjne SSU → w schowku ma buty magnetyczne. \
	5) TAB w oknie czatu: załóż słuchawki z zestawu (inżynierii i ochrony) i przełączaj Say → Radio → kanały z twoich słuchawek → Me → oczekiwane: kanały z założonych słuchawek, bez OOC/LOOC. Negatyw: zdejmij słuchawki → oczekiwane: na liście TAB znikają ich kanały (zostaje tylko ogólny). \
	6) ERT: Secrets → Make ERT → oczekiwane: nowe opcje (doświadczony lider, losowe imiona, oficer odprawy), łowcy nagród CentComu, stażyści, oficjel jako rola ERT; lider to gracz z największą liczbą godzin, każdy członek ma mindshield. Wymaga ducha: chętnych do ERT."
	items = list(
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/storage/toolbox/electrical = 1,
		/obj/machinery/door/airlock = 1,
		/obj/structure/table = 1,
		/obj/machinery/suit_storage_unit/engine = 1,
		/obj/machinery/suit_storage_unit/standard_unit = 1,
		/obj/item/radio/headset/headset_eng = 1,
		/obj/item/radio/headset/headset_sec = 1,
	)

/datum/test_chamber_kit/pr_407_budget
	name = "PR 407: przelewy z kart budżetowych"
	pr = "aq33/AquilaStation#407"
	description = "1) Alt-klik na karcie budżetowej, wybierz departament z listy z saldami i wpisz małą kwotę → oczekiwane: obie karty dostają komunikat o przelewie, wpis w log_game. \
	2) Negatyw: wpisz 0 albo anuluj okno → oczekiwane: brak przelewu, salda bez zmian. \
	3) Negatyw: alt-klik bez ALLOW_BUDGET_MONEY_WITHDRAWAL → oczekiwane: od razu lista departamentów, bez opcji wypłaty gotówki. \
	UWAGA: to prawdziwe budżety działów w rundzie - przelewaj małe kwoty i oddaj je."
	items = list(
		/obj/item/card/id/departmental_budget/eng = 1,
		/obj/item/card/id/departmental_budget/sci = 1,
		/obj/item/card/id/departmental_budget/car = 1,
	)
