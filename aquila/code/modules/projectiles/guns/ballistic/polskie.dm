// AQUILA - polska broń z Polonium Station (polonium14/polonium-station): pistolet VIS MPS zamiast Walthera P99
// i karabin Alexis-BOR zamiast karabinu snajperskiego z tg. Sprite'y: Tofi_Dev, CC-BY-SA-3.0.
// Statystyki zostają nasze, zmienia się wygląd i nazwa.

/obj/item/gun/ballistic/automatic/pistol/glock
	name = "pistolet VIS MPS (cywilny)"
	desc = "Polski pistolet samopowtarzalny kalibru 9 mm w wersji cywilnej, przeznaczonej do ochrony osobistej."
	icon = 'aquila/icons/obj/guns/polskie.dmi'
	icon_state = "vis"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/polskie_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/polskie_righthand.dmi'
	item_state = "vis"

/obj/item/gun/ballistic/automatic/pistol/glock/security
	name = "pistolet VIS MPS"
	desc = "Standardowy pistolet polskich służb mundurowych, kalibru 9 mm. Może strzelać serią trzech pocisków."
	icon = 'aquila/icons/obj/guns/polskie.dmi'
	icon_state = "vis"
	item_state = "vis"

// Makarow, pistolet kolekcjonerski i Winona zostają przy swoich sprite'ach.
/obj/item/gun/ballistic/automatic/pistol/glock/makarov
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "glock"

/obj/item/gun/ballistic/automatic/pistol/glock/command
	name = "kolekcjonerski pistolet VIS MPS"
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "glock"

/obj/item/gun/ballistic/automatic/pistol/glock/security/hos
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "glock"

/obj/item/ammo_box/magazine/glock/lethal
	name = "Magazynek VIS"

/obj/item/ammo_box/magazine/glock
	name = "Magazynek VIS na gumową amunicję"

/obj/item/ammo_box/magazine/glock/ap
	name = "Magazynek VIS na amunicję przeciwpancerną"

/obj/item/ammo_box/magazine/glock/inc
	name = "Magazynek VIS na amunicję zapalającą"

/datum/design/lethalglockmag
	name = "Magazynek VIS"

/datum/design/glockmag
	name = "Magazynek VIS na gumową amunicję"

/datum/design/apglockmag
	name = "Magazynek VIS na amunicję przeciwpancerną"

/datum/design/incglockmag
	name = "Magazynek VIS na amunicję zapalającą"

/obj/item/gun/ballistic/automatic/sniper_rifle
	name = "karabin wyborowy Alexis-BOR"
	desc = "Polski karabin wyborowy na bazie Bora 7,62, przerobiony na amunicję kalibru .50. Zadaje poważne obrażenia z dużej odległości. Nie, quickscope nie zadziała."
	icon = 'aquila/icons/obj/guns/polskie.dmi'
	icon_state = "bor"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/polskie_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/polskie_righthand.dmi'
	item_state = "bor"
	worn_icon = 'aquila/icons/mob/clothing/back_polskie.dmi'
