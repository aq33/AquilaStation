/obj/item/ammo_box/a357
	name = "szybkoładowacz (.357)"
	desc = "Służy do szybkiego przeładowywania rewolwerów."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/a357/match
	name = "szybkoładowacz (.357 wyczynowe)"
	desc = "Służy do szybkiego przeładowywania rewolwerów. Te naboje wykonano z wyjątkowo małymi tolerancjami, więc łatwo się nimi popisywać trikowymi strzałami."
	ammo_type = /obj/item/ammo_casing/a357/match

/obj/item/ammo_box/c38
	name = "szybkoładowacz (.38)"
	desc = "Służy do szybkiego przeładowywania rewolwerów."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	multiple_sprites = 1
	materials = list(/datum/material/iron = 20000)

/obj/item/ammo_box/c38/trac
	name = "szybkoładowacz (.38 TRAC)"
	desc = "Służy do szybkiego przeładowywania rewolwerów. Pociski TRAC umieszczają w ciele celu implant namierzający."
	ammo_type = /obj/item/ammo_casing/c38/trac

/obj/item/ammo_box/c38/match
	name = "szybkoładowacz (.38 wyczynowe)"
	desc = "Służy do szybkiego przeładowywania rewolwerów. Te naboje wykonano z wyjątkowo małymi tolerancjami, więc łatwo się nimi popisywać trikowymi strzałami."
	ammo_type = /obj/item/ammo_casing/c38/match

/obj/item/ammo_box/c38/match/bouncy
	name = "szybkoładowacz (.38 gumowe odbijające)"
	desc = "Służy do szybkiego przeładowywania rewolwerów. Te naboje niesamowicie się odbijają i są W WIĘKSZOŚCI nieśmiercionośne, więc świetnie nadają się do popisów trikowymi strzałami."
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy

/obj/item/ammo_box/c38/dumdum
	name = "szybkoładowacz (.38 dum-dum)"
	desc = "Służy do szybkiego przeładowywania rewolwerów. Pociski dum-dum rozpadają się przy trafieniu i szarpią wnętrzności celu, zwykle w nich utykając."
	ammo_type = /obj/item/ammo_casing/c38/dumdum

/obj/item/ammo_box/c38/hotshot
	name = "szybkoładowacz (.38 Hot Shot)"
	desc = "Służy do szybkiego przeładowywania rewolwerów. Pociski Hot Shot mają ładunek zapalający."
	ammo_type = /obj/item/ammo_casing/c38/hotshot

/obj/item/ammo_box/c38/iceblox
	name = "szybkoładowacz (.38 Iceblox)"
	desc = "Służy do szybkiego przeładowywania rewolwerów. Pociski Iceblox mają ładunek kriogeniczny."
	ammo_type = /obj/item/ammo_casing/c38/iceblox

/obj/item/ammo_box/c38/mime
	name = "szybkoładowacz (.38 palcowe)"
	max_ammo = 6
	desc = "Służy do szybkiego ładowania twoich palców zabójczymi nabojami."
	item_flags = DROPDEL
	ammo_type = /obj/item/ammo_casing/caseless/mime/lethal

/obj/item/ammo_box/c9mm
	name = "pojemnik z amunicją (9mm)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/c10mm
	name = "pojemnik z amunicją (10mm)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 20

/obj/item/ammo_box/c45
	name = "pojemnik z amunicją (.45)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/a40mm
	name = "pojemnik z amunicją (granaty 40mm)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/a762
	name = "łódka nabojowa (7.62mm)"
	desc = "Łódka nabojowa."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_box/n762
	name = "pojemnik z amunicją (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

/obj/item/ammo_box/foambox
	name = "pojemnik z amunicją (strzałki piankowe)"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40
	materials = list(/datum/material/iron = 500)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	materials = list(/datum/material/iron = 50000)
