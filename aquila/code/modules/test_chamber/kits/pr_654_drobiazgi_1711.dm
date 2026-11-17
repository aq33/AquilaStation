/datum/test_chamber_kit/pr_654
	name = "Szukanie po angielsku, rzut z ręki, horror xenobio, chętni na cel, czat głosowy EN"
	pr = "aq33/AquilaStation#654"
	description = "1) Autolathe ma prąd i materiały: wpisz w wyszukiwarkę „multitool”, „health analyzer”, „welding” – mają się znaleźć polskie projekty (w wersji PL i EN). \
	2) Rzucaj przedmiotami z ręki (kredka, nóż, butelka, mydło) na różne odległości, też w biegu i po skosie: przedmiot ma wylatywać od twojej postaci i lecieć płynnie, bez pojawiania się od razu kilka pól dalej; obrót w locie i rozrzut po lądowaniu bez zmian. Sprawdź w combat mode i w starym trybie intencji. \
	3) Uśpiony pradawny horror: jako duch kliknij go (albo menu Spawnery) – masz dostać horrora z opisem roli i antagiem; w panelu antagów jako pradawny horror. \
	4) Ustawienia gry → Rozgrywka → „Chcę być celem antagonistów”: zaznacz, połącz się ponownie i sprawdź, że opcja została. Z dwoma graczami: drugi dostaje traitora (panel antagów), cele z osobą mają wskazywać gracza z opcją. \
	5) Czat głosowy (serwis zrestartowany po aktualizacji): ustaw język gry na English i kliknij „Czat głosowy” – strona i zgoda po angielsku, a powiedziane po angielsku zdanie wraca do gry poprawnie. Wróć do polskiego i odśwież starą kartę: strona ma być po polsku, a mowa rozpoznawana po polsku."
	items = list(
		/obj/machinery/modular_fabricator/autolathe = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/toy/crayon/red = 3,
		/obj/item/kitchen/knife = 2,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = 2,
		/obj/item/soap = 2,
		/obj/effect/mob_spawn/horror_xenobio = 1,
	)
