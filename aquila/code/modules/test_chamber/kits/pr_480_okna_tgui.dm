/datum/test_chamber_kit/pr_480
	name = "Okna TGUI z tg (tgui-core 6)"
	pr = "aq33/AquilaStation#480"
	description = "PR przenosi około 230 okien, więc zestaw obejmuje reprezentatywne; reszta jest poza komorą. Karta kapitana, PDA, holochip do automatu i drugi człowiek są w zestawie. \
		1) Otwórz kilka okien i przeklikaj przyciski, pola tekstowe (Enter i klik obok) oraz suwaki → oczekiwane: kontrolki reagują, tekst zatwierdza się Enterem i kliknięciem obok, suwaki zmieniają wartość, okno jest po polsku. \
		2) Boty: kliknij bota ręką, odblokuj kartą kapitana i zmień ustawienia → oczekiwane: jedno wspólne okno botów z ustawieniami tego bota. Negatyw: spróbuj zmienić ustawienia bez karty → oczekiwane: panel zablokowany. \
		3) Jednoręki bandyta: wrzuć holochip i pociągnij dźwignię → oczekiwane: okno pokazuje saldo i wynik losowania. Reflektor: kliknij i ustaw kąt → oczekiwane: obraca się. \
		4) RCD i RPLD: użyj w ręce, wybierz projekt i zbuduj → oczekiwane: okno wyboru projektu otwiera się i budowa działa. \
		5) Skrzynia: multitool na zamek, potem wpisz kod → oczekiwane: zły kod odrzucony, dobry otwiera. \
		6) Malarka PDA/ID: włóż PDA i kartę z ręki i pomaluj → oczekiwane: nowa ikona. Gablota: klucz kuratora, włóż przedmiot, edytuj opis → oczekiwane: opis się zapisuje. \
		7) Krzesło do implantów: wsadź człowieka i wszczep → oczekiwane: okno krzesła otwiera się (wcześniej DM otwierał nieistniejące okno), implant ląduje w człowieku. Konsola nakazów: karta ID w ręku → oczekiwane: okno pozwala wystawić nakaz. \
		8) Poza komorą: Esc (menu), preferencje, wybór profesji, panel gracza (także jako duch), Spawn → oczekiwane: okna otwierają się po polsku."
	items = list(
		/mob/living/carbon/human = 2,
		/mob/living/simple_animal/bot/cleanbot = 1,
		/mob/living/simple_animal/bot/medbot = 1,
		/mob/living/simple_animal/bot/floorbot = 1,
		/obj/machinery/computer/slot_machine = 1,
		/obj/structure/reflector/single = 1,
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/construction/plumbing = 1,
		/obj/structure/closet/crate/secure/loot = 1,
		/obj/item/multitool = 1,
		/obj/machinery/pdapainter = 1,
		/obj/structure/displaycase/trophy = 1,
		/obj/item/key/displaycase = 1,
		/obj/machinery/implantchair = 1,
		/obj/machinery/computer/warrant = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/modular_computer/tablet/pda = 1,
	)

/datum/test_chamber_kit/pr_480/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Automat przyjmuje holochipy (tryb płatności domyślny), a nie gotówkę
	var/turf/chip_turf = turfs[min(length(items) + 1, length(turfs))]
	new /obj/item/holochip(chip_turf, 500)
