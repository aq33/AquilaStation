/obj/structure/sign/solgov_seal //Credit to baystation for these sprites!
	name = "Pieczęć Rządu Słonecznego"
	desc = "Pieczęć ze złotym obramowaniem, przedstawiająca gwiazdę Sol."
	icon = 'nsv13/icons/obj/solgov_logos.dmi'
	icon_state = "solgovseal"

/obj/structure/sign/solgov_flag
	name = "sztandar SolGov"
	desc = "Duża flaga z logo SolGov, lokalnego rządu układu Sol."
	icon = 'nsv13/icons/obj/solgov_logos.dmi'
	icon_state = "solgovflag-left"

/obj/structure/sign/solgov_flag/right
	icon_state = "solgovflag-right"


//3/4 signs stolen from bay
/obj/structure/sign/ship
	icon = 'nsv13/icons/obj/decals.dmi'

/obj/structure/sign/ship/space
	name = "OSTRZEŻENIE: DALEJ PRÓŻNIA"
	icon_state = "space"

/obj/structure/sign/ship/fire
	name = "Zagrożenie pożarowe"
	icon_state = "fire"

/obj/structure/sign/ship/nosmoking
	name = "Zakaz palenia"
	icon_state = "nosmoking"

/obj/structure/sign/ship/smoking
	name = "Palarnia"
	icon_state = "smoking"

/obj/structure/sign/ship/securearea
	name = "UWAGA: STREFA CHRONIONA"
	icon_state = "securearea"

/obj/structure/sign/ship/securearea/alt
	name = "UWAGA: STREFA CHRONIONA"
	icon_state = "securearea2"

/obj/structure/sign/ship/armoury
	name = "Szafa z bronią"
	icon_state = "armory"

/obj/structure/sign/ship/server
	name = "Serwerownia"
	icon_state = "server"

/obj/structure/sign/ship/shock
	name = "UWAGA: WYSOKIE NAPIĘCIE"
	icon_state = "shock"

/obj/structure/sign/ship/hikpa
	name = "UWAGA: WYSOKIE CIŚNIENIE"
	icon_state = "hikpa"

/obj/structure/sign/ship/mail
	name = "Poczta"
	icon_state = "mail"

/obj/structure/sign/ship/radiation
	name = "UWAGA: PROMIENIOWANIE"
	icon_state = "radiation"

/obj/structure/sign/ship/examroom
	name = "Gabinet badań"
	icon_state = "examroom"

/obj/structure/sign/ship/science
	name = "Badania i rozwój"
	icon_state = "science"

/obj/structure/sign/ship/chemistry
	name = "Chemia"
	icon_state = "chemistry"

/obj/structure/sign/ship/medical
	name = "Ambulatorium"
	icon_state = "bluecross2"

/obj/structure/sign/ship/plaque
	name = "Tablica pamiątkowa"
	desc = "Tablica z kilkoma napisami."
	icon_state = "lightplaque"

/obj/structure/sign/ship/plaque/dark
	icon_state = "darkplaque"

/obj/structure/sign/ship/plaque/light
	icon_state = "lightplaquealt"

/obj/structure/sign/ship/plaque/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/scream = get_overmap()
	to_chat(user, "<span class='notice'>Ta tablica upamiętnia uczestników ceremonii wodowania okrętu, na którym jesteś. <br> Tablica podaje nazwę okrętu: <b>[scream?.name]</b> </span>")

/obj/structure/sign/ship/pods
	name = "Kapsuły ratunkowe"
	icon_state = "podsnorth"

/obj/structure/sign/ship/pods/north
	icon_state = "podssouth"

/obj/structure/sign/ship/pods/east
	icon_state = "podseast"

/obj/structure/sign/ship/pods/west
	icon_state = "podswest"

/obj/structure/sign/ship/deck
	name = "Pokład 1"
	icon_state = "deck-1"

/obj/structure/sign/ship/deck/two
	name = "Pokład 2"
	icon_state = "deck-2"

/obj/structure/sign/ship/deck/three
	name = "Pokład 3"
	icon_state = "deck-3"

/obj/structure/sign/ship/deck/four
	name = "Pokład 4"
	icon_state = "deck-4"

/obj/structure/sign/ship/deck/five
	name = "Pokład 5"
	icon_state = "deck-5"
