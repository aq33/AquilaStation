/datum/test_chamber_kit/pr_513
	name = "Koło emotek, zlecenia amunicji, rewolucja, wybór misji"
	pr = "aq33/AquilaStation#513"
	description = "Koło emotek: przycisk z uśmiechem w rzędzie akcji (lewy górny róg). Pusty otwiera Panel emotek: oznacz gwiazdką kilka emotek (13. ma się nie zmieścić), kliknij przycisk jeszcze raz i użyj emotki z koła. Po reconnecie wybór ma zostać. \
		Rewolucja: pierwszy człowiek to przywódca rewolucji, przejmij go. Przycisk z czerwonym R po lewej stronie ekranu otwiera panel: miejsca (ty z obwódką), znacznik limitu, zablokowane miejsca i liczniki. Najedź na miejsca, przesuń panel za strzałki. \
		Przemowa działa tylko na cel z klientem (drugi gracz albo admin w drugim człowieku); po zapełnieniu limitu (VV drużyny: rev_cap = 1) przemowa ma odmówić. \
		Zlecenia amunicji: w konsoli zleceń cargo i na karcie zleceń cywilnych technika amunicji mają się pojawiać nowe zlecenia (części z zestawu pasują do elektroniki spustowej i tac). \
		Wybór misji: tylko w pierwszych ~2,5 min rundy. Zaloguj się kartą kapitana w konsoli łączności, zakładka Status misji: trzy misje, wybór daje ogłoszenie i odprawę wybranej misji."
	items = list(
		/mob/living/carbon/human = 2,
		/obj/machinery/computer/communications = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 2,
		/obj/item/ship_weapon/parts/loading_tray = 2,
	)

/datum/test_chamber_kit/pr_513/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/leader = locate() in spawned
	if(!leader)
		return
	leader.mind_initialize()
	leader.mind.add_antag_datum(/datum/antagonist/rev/head)
	leader.name = "przywódca testowy"
	leader.real_name = leader.name
