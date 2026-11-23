// aq33/AquilaStation#677 - zgłoszenia z testu 20.11

/datum/test_chamber_kit/pr_677
	name = "Zgłoszenia 20.11: hardsuit, automat, autoklaw, mapa FTL"
	pr = "aq33/AquilaStation#677"
	description = "1) Załóż hardsuit inżynieryjny, rozłóż hełm, włącz wbudowaną butlę (przycisk akcji) i postój minutę: brak obrażeń od duszenia, ciśnienie butli (examine) powoli spada. \
	2) Automat z napojami: nad każdą półką skrócona nazwa na ciemnym pasku, butelki da się odróżnić. \
	3) Autoklaw: włóż skalpel, zamknij pustą ręką, Ctrl+klik: cykl kończy się po około 10 s. \
	4) Konsola nawigacji FTL: mapa przewija się suwakami, przycisk skoku w zakładce Kafel widać przy domyślnym oknie, floty to kwadraty (konwoje: romby) w kolorach frakcji z liczbą, zakładki Wojna i Legenda. \
	5) Poza komorą: usiądź za sterem okrętu (klasyczny panel i komunikat „Silniki: działa X z Y dysz, ciąg Z%”), potem w myśliwcu (kompaktowy radar i pasek). \
	6) Poza komorą: misja Opuszczona stacja, prom przy stacji - kamera z obrysem lądowania; VIP zabity i ożywiony dalej zalicza misję po dowiezieniu."
	items = list(
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/obj/machinery/vending/cola = 1,
		/obj/machinery/autoclave = 1,
		/obj/item/scalpel = 1,
		/obj/machinery/computer/ship/navigation = 1,
	)
