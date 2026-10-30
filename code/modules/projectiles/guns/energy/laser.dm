/obj/item/gun/energy/laser
	name = "karabin laserowy"
	desc = "Podstawowa energetyczna broń laserowa, która strzela skupionymi wiązkami światła przenikającymi przez szkło i cienki metal."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/iron=2000)
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	ammo_x_offset = 1
	shaded_charge = 1

/obj/item/gun/energy/laser/practice
	name = "treningowy karabin laserowy"
	desc = "Zmodyfikowana wersja podstawowego karabinu laserowego. Strzela słabiej skupionymi pociskami energii, przeznaczonymi do ćwiczeń strzeleckich."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	item_flags = NONE

/obj/item/gun/energy/laser/retro
	name ="retro karabin laserowy"
	icon_state = "retro"
	desc = "Nowoczesna broń laserowa używana przez ochronę i siły zbrojne Solgovu. Jest dość zabójcza i łatwa w utrzymaniu, więc chętnie się po nią sięga." //NSV13 changed description
	ammo_x_offset = 3

/obj/item/gun/energy/laser/retro/old
	name ="karabin laserowy"
	icon_state = "retro"
	desc = "Broń laserowa pierwszej generacji, zaprojektowana przez Nanotrasen i produkowana przez Solgov. Ma kłopoty z amunicją, ale nadrabia je wyjątkową zdolnością ładowania się bez magazynka." //NSV13 changed description
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)
	ammo_x_offset = 3

/obj/item/gun/energy/laser/captain
	name = "zabytkowy karabin laserowy"
	icon_state = "caplaser"
	item_state = "caplaser"
	w_class = WEIGHT_CLASS_NORMAL
	desc = "To zabytkowa broń laserowa. Całe wykonanie jest najwyższej jakości. Zdobią ją skóra i chrom. Przedmiot grozi kolcami energii. Na przedmiocie widnieje wizerunek Stacji Kosmicznej 13 z wygrawerowanym napisem NTSSGolden. Stacja wybucha."
	force = 10
	ammo_x_offset = 3
	selfcharge = 1
	charge_delay = 8
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/captain)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	weapon_weight = WEAPON_LIGHT
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/gun/energy/laser/captain/scattershot
	name = "rozpraszający karabin laserowy"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "Przemysłowy, wytrzymały karabin laserowy ze zmodyfikowaną soczewką, która rozprasza strzał na wiele mniejszych laserów. Wewnętrzny rdzeń sam się ładuje, więc teoretycznie działa w nieskończoność."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/cyborg
	can_charge = FALSE
	desc = "Energetyczna broń laserowa, która pobiera energię wprost z wewnętrznego ogniwa cyborga. Więc tak wygląda wolność?"
	use_cyborg_cell = TRUE

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "laser rozpraszający"
	desc = "Broń laserowa z zestawem refrakcyjnym, który rozprasza pociski."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/scatter/shotty
	name = "strzelba energetyczna"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "cshotgun"
	item_state = "shotgun"
	desc = "Wybebeszona strzelba bojowa przerobiona na wewnętrzny system laserowy. Przełącza się między strzałami paralizatora a rozproszonymi strzałami disablera."
	shaded_charge = 0
	pin = /obj/item/firing_pin/implant/mindshield
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/disabler, /obj/item/ammo_casing/energy/electrode)

///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "przyspieszające działo laserowe"
	desc = "Zaawansowane działo laserowe, które zadaje tym większe obrażenia, im dalej jest cel."
	icon_state = "lasercannon"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	pin = null
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/item/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/projectile/beam/laser/accelerator
	name = "laser przyspieszający"
	icon_state = "scatterlaser"
	range = 255
	damage = 6

/obj/item/projectile/beam/laser/accelerator/Range()
	..()
	damage += 7
	transform *= 1 + ((damage/7) * 0.2)//20% larger per tile

/obj/item/gun/energy/xray
	name = "\improper rentgenowski karabin laserowy"
	desc = "Laser dużej mocy, który wystrzeliwuje skupione impulsy promieniowania rentgenowskiego, przenikające przez wiele miękkich celów i cięższe materiały."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/xray)
	pin = null
	ammo_x_offset = 3
	w_class = WEIGHT_CLASS_BULKY

////////Laser Tag////////////////////

/obj/item/gun/energy/laser/bluetag
	name = "pistolet do laser taga"
	icon_state = "bluetag"
	desc = "Retro broń laserowa przerobiona tak, by strzelała nieszkodliwymi niebieskimi wiązkami światła. Efekty dźwiękowe w zestawie!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/blue
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/bluetag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag/hitscan)

/obj/item/gun/energy/laser/redtag
	name = "pistolet do laser taga"
	icon_state = "redtag"
	desc = "Retro broń laserowa przerobiona tak, by strzelała nieszkodliwymi czerwonymi wiązkami światła. Efekty dźwiękowe w zestawie!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/red
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/redtag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag/hitscan)
