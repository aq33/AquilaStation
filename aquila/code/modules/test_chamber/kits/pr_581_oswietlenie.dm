// aq33/AquilaStation#581 - miękkie światło, poświata, promienie i cienie latarek (aquila/code/modules/lighting/)

/datum/test_chamber_kit/pr_581
	name = "Oświetlenie (poświata, cienie latarek)"
	pr = "aq33/AquilaStation#581"
	description = "Zestaw stawia ścianę z drzwiami 3 kafle na wschód od środka areny. Zgaś światło (przełącznik albo wyłączenie zasilania). \
	1) Preferencje → Grafika → Jakość: Miękkie światło, Poświata (wył./słaba/średnia/mocna), Promienie świateł. Zmiana działa od razu. \
	2) W ciemności: lampy, ekrany, alarmy i lasery (strzel z pistoletu) mają kolorową poświatę; mob przed ekranem ją zasłania. \
	3) Latarka lub latarnia przy ścianie: za ścianą ciemno, przez otwarte drzwi wpada klin światła. Otwórz i zamknij drzwi, stojąc w miejscu: cień ma się od razu zmienić. \
	4) Druga latarka po drugiej stronie ściany: jej światło nie znika (cień kończy się na brzegu plamy pierwszej latarki). \
	5) Sprawdź też noktowizję lub mezony i okno konsoli kamer. \
	6) Admin: aq_set_light_shadows(FALSE) przez Advanced ProcCall wyłącza cienie od razu."
	items = list(
		/obj/item/flashlight = 2,
		/obj/item/flashlight/lantern = 1,
		/obj/item/gun/energy/laser = 1,
	)

/datum/test_chamber_kit/pr_581/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// fałszywe ściany są nieprzezroczystymi obiektami, więc nie trzeba zmieniać kafli areny
	for(var/dy in -1 to 1)
		var/turf/T = locate(center.x + 3, center.y + dy, center.z)
		if(!T || T.density)
			continue
		if(dy == 0)
			new /obj/machinery/door/airlock(T)
		else
			new /obj/structure/falsewall(T)
