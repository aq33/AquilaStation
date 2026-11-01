// Billboardy z tg (code/game/objects/structures/billboard.dm), potrzebne w ruinach górniczych.
/obj/structure/billboard
	name = "pusty billboard"
	desc = "Pusty billboard z miejscem na wszelkie reklamy."
	icon = 'aquila/icons/obj/billboard.dmi'
	icon_state = "billboard_blank"
	layer = ABOVE_MOB_LAYER
	max_integrity = 1000
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE

/obj/structure/billboard/donk_n_go
	name = "\improper billboard Donk-n-Go"
	desc = "Billboard reklamujący Donk-n-Go, wszechobecny i zawsze niezdrowy fast food firmy Donk Co.: WEJDŹ, ZJEDZ, ZNIKAJ!"
	icon_state = "billboard_donk_n_go"

/obj/structure/billboard/space_cola
	name = "\improper billboard Kosmicznej Coli"
	desc = "Billboard reklamujący Kosmiczną Colę: Wyluzuj, napij się Spoke'a."
	icon_state = "billboard_space_cola"

/obj/structure/billboard/nanotrasen
	name = "\improper billboard Nanotrasen"
	desc = "Billboard reklamujący Nanotrasen: Lepsze jutro już dziś."
	icon_state = "billboard_nanotrasen"

/obj/structure/billboard/nanotrasen/defaced
	name = "zniszczony billboard Nanotrasen"
	desc = "Billboard reklamujący Nanotrasen. Ktoś wysprejował na nim napis: Jebać korposwinie."
	icon_state = "billboard_fuck_corps"

/obj/structure/billboard/azik
	name = "\improper billboard Azik Interstellar"
	desc = "Billboard reklamujący Azik Interstellar i ich najnowszy model: żaglowiec słoneczny Autocrat. Azik Interstellar: tizirańska elegancja na galaktyczne potrzeby."
	icon_state = "billboard_azik"

/obj/structure/billboard/twenty_four_seven
	name = "\improper billboard 24-Seven"
	desc = "Billboard reklamujący nową serię limitowanych smaków Slushee w 24-Seven. 24-Seven: cały dzień, każdego dnia."
	icon_state = "billboard_twenty_four_seven"

/obj/structure/billboard/starway
	name = "\improper billboard Starway Transit"
	desc = "Billboard reklamujący bezpośredni lot Starway Transit z Nowej Moskwy do Nowego Jorku: koja w klasie ekonomicznej tylko za 2000 kr. Starway: twój bilet do gwiazd."
	icon_state = "billboard_starway"

/obj/effect/spawner/lootdrop/billboard
	name = "spawner billboardu"
	icon = 'aquila/icons/obj/billboard.dmi'
	icon_state = "billboard_random"
	loot = list(
		/obj/structure/billboard/azik = 50,
		/obj/structure/billboard/donk_n_go = 50,
		/obj/structure/billboard/space_cola = 50,
		/obj/structure/billboard/twenty_four_seven = 30,
		/obj/structure/billboard/starway = 30,
		/obj/structure/billboard/nanotrasen = 35,
		/obj/structure/billboard/nanotrasen/defaced = 15,
	)
