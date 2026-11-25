// aq33/AquilaStation#699 - zgłoszenia z 25.11

/datum/test_chamber_kit/pr_699
	name = "Zgłoszenia 25.11: medibot, rośliny, prawo, stos korowy, stopnie"
	pr = "aq33/AquilaStation#699"
	description = "1) Medibot przy rannym: „próbuje opatrzyć rany” raz na pacjenta, kwestie z dźwiękiem najwyżej co 20 s. \
	2) Posadź pomidora w tacy, łopatką przenieś roślinę i kliknij kosz: znika roślina, łopatka zostaje w ręce. Drugą roślinę wyrwij prawym przyciskiem (i na intencji rozbrajania), trzecią kultywatorem. \
	3) PDA ochrony, program „Prawo kosmiczne”: wykroczenie = mandat 150 kr, przestępstwo z występkiem = GenPop i gułag 500 pkt, zbrodnia = trzy opcje dożywocia. \
	4) Wyjmij komuś stos korowy operacją, kliknij nim konsolę klonowania (rekord z imieniem), potem pustym stosem (kopia rekordu). \
	5) Rozlej wodę na jedno pole: kształt kałuży z SS14. Powiedz coś: stopień marynarki przed imieniem (w wersji EN angielski skrót). \
	6) Poza komorą: prom w trybie dokowania nad nową planetą sam staje i ląduje za pierwszym razem, a lądowanie leci w Spess.tv na PDA. Nowa postać ma pager w kieszeni. \
	7) Poza komorą: horror w nosicielu, zaawansowany skaner podpowiada „wyciągnięcie pasożyta”, operacja na głowie uwalnia nosiciela."
	items = list(
		/mob/living/basic/bot/medbot = 1,
		/obj/item/plant_tray = 1,
		/obj/item/plant_seeds/preset/tomato = 3,
		/obj/item/shovel/spade = 1,
		/obj/item/cultivator = 1,
		/obj/machinery/disposal/bin = 1,
		/obj/item/modular_computer/tablet/pda/security = 1,
		/obj/item/organ/cortical_stack = 2,
		/obj/machinery/computer/cloning = 1,
		/obj/machinery/clonepod = 1,
		/obj/machinery/dna_scannernew = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/reagent_containers/glass/bucket = 1,
	)
